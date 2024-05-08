import 'dart:convert';
import 'dart:io';

import '../../commons/entities/stdin_broadcast.dart';
import '../../commons/functions/version.dart';

String _getPubspecTemplate(String projectName) => """
name: temp_project
description: A temporary project for running a Gazelle project.
version: 1.0.0
publish_to: none

environment:
  sdk: ^$dartSdkVersion

dependencies:
  hotreloader: ^4.2.0
  $projectName:
    path: ../../$projectName

dev_dependencies:
""";

String _getMainTemplate(String projectName, int timeout, bool verbose) => """
import 'dart:convert';
import 'dart:io';

import 'package:hotreloader/hotreloader.dart';
import 'package:$projectName/$projectName.dart' as main_project;

void main(List<String> arguments) async {
  final reloader = await HotReloader.create(
    automaticReload: false,
    watchDependencies: false,
    onBeforeReload: (ctx) {
      if($verbose){
        print('Reloading...');
      }
      return true;
    },
    onAfterReload: (ctx) => print('Reloaded'),
  );

  final tmpDirList =
      Directory.current.absolute.path.split(Platform.pathSeparator);

  final projectDir =
      tmpDirList.sublist(0, tmpDirList.length - 1).join(Platform.pathSeparator);

  final lib = Directory("\$projectDir/lib");
  final pubspec = File("\$projectDir/pubspec.yaml");

  void onModify(FileSystemEvent event) {
    if (event.type == FileSystemEvent.delete) {
      if($verbose){
        print("Ignoring delete event on '\${event.path}'.");
      }
      return;
    }
    if (event.path.endsWith('.dart')) {
      if($verbose){
        print("File '\${event.path}' modified.");
      }
      reload(reloader);
    } else if(event.path.endsWith('pubspec.yaml')) {
      reload(reloader);
    } else {
      if($verbose){
        print("Ignoring '\${event.path}' as it is not a dart file.");
      }
    }
  }

  lib.watch(recursive: true).listen(onModify);
  pubspec.watch().listen(onModify);

  ProcessSignal.sigint.watch().listen((event) {
    reloader.stop();
    exit(0);
  });

  stdin.transform(utf8.decoder).listen((event) async {
    if (event.trim() == "r") {
      reload(reloader);
    }
  });

  await main_project.runApp(arguments);
}

/// This executionIndex is just to implement debouncing
int executionIndex = 0;

void reload(HotReloader reloader) async {
  int tmp = ++executionIndex;
  await Future.delayed(Duration(milliseconds: $timeout));

  /// If the executionIndex has changed, then another restart was requested
  /// within the timeout period, so we will let the other restart request
  /// handle the rest and return
  if (tmp != executionIndex) return;

  reloader.reloadCode();
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
Future<void> runProject(String path, int timeout, bool verbose) async {
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

  await File("$tmpDirPath/main_hot_reload.dart").create(recursive: true).then(
      (file) =>
          file.writeAsString(_getMainTemplate(projectName, timeout, verbose)));

  final result = await Process.run(
    "dart",
    ["pub", "get"],
    workingDirectory: tmpDirPath,
  );

  if (result.exitCode != 0) {
    throw RunProjectError(result.stderr.toString(), result.exitCode);
  }

  Process? process = await startProcess(tmpDirPath);

  stdinBroadcast.listen((event) async {
    if (event.trim() == 'R') {
      /// Hot Restart
      process?.kill();
      process = await startProcess(tmpDirPath);
    } else {
      /// Else send the input to the process, the process will be
      /// responsible for if the event is 'r' then reload the code
      process?.stdin.writeln(event);
    }
  });

  ProcessSignal.sigint.watch().listen((event) {
    process?.kill();
    exit(0);
  });
}

/// Starts the temporary project process.
///
/// It also assigns basic event listeners to the process.
Future<Process> startProcess(String tmpProjectDir) async {
  final process = await Process.start(
    "dart",
    ["run", "--enable-vm-service", "main_hot_reload.dart"],
    workingDirectory: tmpProjectDir,
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

  return process;
}
