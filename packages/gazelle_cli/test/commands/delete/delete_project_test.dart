import 'dart:io';
import 'package:gazelle_cli/commands/delete/delete_project.dart';
import 'package:test/test.dart';

void main() {
  group('DeleteCommand', () {
    test('Should delete a project', () async {
      // Arrange
      const path = "tmp/delete_project_tests";

      try {
        await Directory(path).delete(recursive: true);
      } catch (_) {
        print("$path does not exist, creating it now.");
      }

      await Directory(path).create(recursive: true);

      // Act
      await deleteProject(path: path);
      // Assert
      expect(Directory(path).existsSync(), isFalse);
    });
  });
}
