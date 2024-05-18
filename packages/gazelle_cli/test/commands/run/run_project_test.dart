import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gazelle_cli/commands/create/create_project.dart';
import 'package:gazelle_cli/commands/run/run_project.dart';
import 'package:gazelle_cli/commons/entities/stdin_broadcast.dart';
import 'package:test/test.dart';

void main() {
  group("Run Command Tests", () {
    test('Should create a tmp project', () async {
      /// Arrange (Creating a new gazelle project)
      String path = "tmp${Platform.pathSeparator}test_project";
      final dir = Directory(path);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      path = "tmp";
      await createProject("test_project", path: path);

      /// Act (Running the gazelle project)
      path = "tmp${Platform.pathSeparator}test_project";
      final process = await runProject(path, 1000, true);
      expect(process != null, true,
          reason: "Process should have started by now.");
      process!.kill();

      /// Assert (The tmp project must have been created)
      final tmpDir = Directory("${path + Platform.pathSeparator}.tmp");
      expect(tmpDir.existsSync(), true);

      final pubspec = File("${tmpDir.path}/pubspec.yaml");
      expect(pubspec.existsSync(), true);

      final mainHotReload = File("${tmpDir.path}/main_hot_reload.dart");
      expect(mainHotReload.existsSync(), true);
      stdinCleanUp(ProcessSignal.sigint);
    });
  });

  test('Should run for 10 seconds', () async {
    final testTimeout = 10;

    /// Arrange (Creating a new gazelle project and then
    /// immediately killing it,
    /// so as to create a tmp project)
    String path = "tmp${Platform.pathSeparator}test_project";
    final dir = Directory(path);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    path = "tmp";
    await createProject("test_project", path: path);
    path = "tmp${Platform.pathSeparator}test_project";
    final runProcess = await runProject(path, 1000, true);
    expect(runProcess != null, true,
        reason: "Process should have started by now.");
    runProcess!.kill();

    /// Act (Running the tmp project)
    final tmpDir =
        Directory("${path + Platform.pathSeparator}.tmp").absolute.path;
    final process = await Process.start(
      "dart",
      ["run", "--enable-vm-service", "main_hot_reload.dart"],
      workingDirectory: tmpDir,
    );

    /// Assert (The process should run for [testTimeout] seconds without any errors)
    bool isRunning = true;
    process.stderr.transform(utf8.decoder).listen((event) {
      /// on any kind of error, fail the test
      fail(event);
    });
    process.exitCode.then((exitCode) {
      if (!isRunning) return;

      /// If the process exits before we kill it, fail the test
      fail(
          "Process should not have exited yet, but has exited with code $exitCode.");
    });

    /// Waiting for [testTimeout] seconds
    final timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (stdin.hasTerminal) {
        stdout.write("\rTime Left: ${testTimeout - timer.tick} seconds");
      }
    });
    await Future.delayed(Duration(seconds: testTimeout));

    /// Cleanup (Kill the process)
    stdinCleanUp(ProcessSignal.sigint);
    timer.cancel();
    isRunning = false;
    process.kill();
  });
}
