import 'dart:io';

import 'package:gazelle_cli/commands/create/create_handler.dart';
import 'package:test/test.dart';

void main() {
  group('CreateHandler tests', () {
    test('Should create a handler file', () async {
      // Arrange
      final tmpDirPath = "tmp/create_handler_test";
      Directory tmpDir = Directory(tmpDirPath);
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
      tmpDir = await Directory(tmpDirPath).create(recursive: true);

      // Act
      final result = await createHandler(
        routeName: "hello_world",
        httpMethod: "GET",
        path: tmpDirPath,
      );

      // Assert
      expect(File(result).existsSync(), isTrue);
    });
  });
}
