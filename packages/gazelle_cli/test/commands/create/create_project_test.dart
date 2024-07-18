import 'dart:io';

import 'package:gazelle_cli/commands/create/create_project.dart';
import 'package:test/test.dart';

void main() {
  group('CreateProject tests', () {
    test('Should create a new project', () async {
      // Arrange
      const path = "tmp/create_project_tests";

      try {
        await Directory(path).delete(recursive: true);
      } catch (_) {
        print("$path does not exist, creating it now.");
      }

      await Directory(path).create(recursive: true);

      // Act
      final result = await createProject(projectName: "test", path: path);

      // Assert
      expect(File("$result/gazelle.yaml").existsSync(), isTrue);

      expect(File("$result/server/pubspec.yaml").existsSync(), isTrue);
      expect(File("$result/server/bin/server.dart").existsSync(), isTrue);
      expect(File("$result/server/lib/server.dart").existsSync(), isTrue);

      expect(File("$result/models/pubspec.yaml").existsSync(), isTrue);
      expect(File("$result/models/lib/models.dart").existsSync(), isTrue);
      expect(Directory("$result/models/lib/entities").existsSync(), isTrue);

      await Directory(path).delete(recursive: true);
    });
  });
}
