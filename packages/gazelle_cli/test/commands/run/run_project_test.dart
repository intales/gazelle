import 'dart:io';

import 'package:gazelle_cli/commands/create/create_project.dart';
import 'package:gazelle_cli/commands/run/run_project.dart';
import 'package:test/test.dart';

void main() {
  group("Run Command Tests:", () {
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

      /// Waiting for the process to start properly and then killing it
      await Future.delayed(Duration(seconds: 5));
      process!.kill();

      /// Assert (The tmp project must have been created)
      final tmpDir = Directory("${path + Platform.pathSeparator}.tmp");
      expect(tmpDir.existsSync(), true);

      final pubspec = File("${tmpDir.path}/pubspec.yaml");
      expect(pubspec.existsSync(), true);

      final mainHotReload = File("${tmpDir.path}/main_hot_reload.dart");
      expect(mainHotReload.existsSync(), true);
    });
  });
}
