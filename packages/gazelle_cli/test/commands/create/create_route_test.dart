import 'dart:io';

import 'package:gazelle_cli/commands/create/create_route.dart';
import 'package:test/test.dart';

void main() {
  group('CreateRoute tests', () {
    test('Should create a route', () async {
      // Arrange
      final tmpDirPath = "tmp/create_route_test";
      Directory tmpDir = Directory(tmpDirPath);
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
      tmpDir = await Directory(tmpDirPath).create(recursive: true);

      // Act
      final result = await createRoute(
        routeName: "hello_world",
        path: tmpDirPath,
      );

      // Assert
      expect(File(result.routeFilePath).existsSync(), isTrue);

      // Clean up
      await tmpDir.delete(recursive: true);
    });
  });
}
