import 'dart:io';

import 'package:gazelle_cli/commands/create/create_project.dart';
import 'package:gazelle_cli/commons/functions/load_project_configuration.dart';
import 'package:test/test.dart';

void main() {
  group('LoadProjectConfiguration tests', () {
    test('Should find a gazelle configuration', () async {
      // Arrange
      final path = "tmp/load_project_configuration_tests";
      final directory = Directory(path);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
      directory.createSync(recursive: true);

      // Act
      final project = await createProject(
        projectName: "test_project",
        path: path,
      );
      final result =
          await loadProjectConfiguration(path: "$project/server/lib");

      // Assert
      expect(result.name, "test_project");

      // Tear down
      directory.deleteSync(recursive: true);
    });
  });
}
