import 'dart:convert';
import 'dart:io';

String _getPubspecTemplate(String projectName) => """
name: temp_project
description: A temporary project for running a Gazelle project.
version: 1.0.0
publish_to: none

environment:
  sdk: ^3.0.0

dependencies:
  hotreloader: ^4.2.0
  $projectName:
    path: ../../$projectName

dev_dependencies:
""";

String _getMainTemplate(String projectName) => """
import 'dart:io';

import 'package:hotreloader/hotreloader.dart';
import 'package:$projectName/$projectName.dart' as main_project;

void main(List<String> arguments) async {
  final reloader = await HotReloader.create(
    debounceInterval: Duration(milliseconds: 500),
    onBeforeReload: (ctx) {
      print('Reloading...');
      return true;
    },
    onAfterReload: (ctx) => print('Reloaded'),
  );

  main_project.runApp(arguments);

  final tmpDirList =
      Directory.current.absolute.path.split(Platform.pathSeparator);

  final projectDir =
      tmpDirList.sublist(0, tmpDirList.length - 1).join(Platform.pathSeparator);

  final lib = Directory("\$projectDir/lib");

  lib.watch(recursive: true).listen((event) {
    reloader.reloadCode();
  });

  ProcessSignal.sigint.watch().listen((event) {
    reloader.stop();
    exit(0);
  });
}
""";

/// Represents an error during the running process of a project.
class RunProjectError {
  /// The error message.
  final String message;

  /// The error code.
  final int errCode;

  /// Creates a [RunProjectError].
  RunProjectError(this.message, this.errCode);
}

/// Runs a Gazelle project.
Future<void> runProject(String path) async {
  final projectDir = Directory(path);
  if (!await projectDir.exists()) {
    throw RunProjectError("Project not found!", 1);
  }

  final tmpDir =
      Directory("${projectDir.absolute.path + Platform.pathSeparator}.tmp");
  if (await tmpDir.exists()) {
    await tmpDir.delete(recursive: true);
  }
  await tmpDir.create();

  final tmpDirPath = tmpDir.absolute.path;

  final projectName = path.split(Platform.pathSeparator).last;
  await File("$tmpDirPath/pubspec.yaml")
      .create(recursive: true)
      .then((file) => file.writeAsString(_getPubspecTemplate(projectName)));

  await File("$tmpDirPath/main_hot_reload.dart")
      .create(recursive: true)
      .then((file) => file.writeAsString(_getMainTemplate(projectName)));

  final result = await Process.run(
    "dart",
    ["pub", "get"],
    workingDirectory: tmpDirPath,
  );

  if (result.exitCode != 0) {
    throw RunProjectError(result.stderr.toString(), result.exitCode);
  }

  final process = await Process.start(
    "dart",
    ["run", "--enable-vm-service", "main_hot_reload.dart"],
    workingDirectory: tmpDirPath,
  );

  process.stdout.transform(utf8.decoder).listen((event) {
    stdout.write(event);
  });

  process.stderr.transform(utf8.decoder).listen((event) {
    stdout.write(event);
  });

  process.exitCode.then((exitCode) {
    print("Process exited with code $exitCode");
  });

  ProcessSignal.sigint.watch().listen((event) {
    process.kill();
    // tmpDir.deleteSync(recursive: true);
    exit(0);
  });
}
