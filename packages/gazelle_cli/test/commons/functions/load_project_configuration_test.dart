import 'dart:io';

import 'package:gazelle_cli/commands/create/create_project.dart';
import 'package:gazelle_cli/commons/functions/load_project_configuration.dart';
import 'package:test/test.dart';

void main() {
  group("LoadProjectConfiguration tests", () {
    test("Should throw error when pubspec doesn't exist", () async {
      // Arrange
      const path = "tmp/load_project_configuration_tests";

      try {
        await Directory(path).delete(recursive: true);
      } catch (_) {
        print("$path does not exist, creating it now.");
      }

      await Directory(path).create(recursive: true);

      final projectPath = await createProject(
        projectName: "test_project",
        path: path,
      );

      // Act
      final result = await loadProjectConfiguration(path: projectPath);

      // Assert
      expect(result.name, "test_project");

      // Tear down
      await Directory(path).delete(recursive: true);
    });
  });
}
