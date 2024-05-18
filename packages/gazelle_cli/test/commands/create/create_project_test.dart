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
      final result = await createProject("test", path: path);

      // Assert
      expect(File("$result/pubspec.yaml").existsSync(), isTrue);
      expect(File("$result/bin/test.dart").existsSync(), isTrue);
      expect(File("$result/lib/test.dart").existsSync(), isTrue);

      await Directory(path).delete(recursive: true);
    });
  });
}
