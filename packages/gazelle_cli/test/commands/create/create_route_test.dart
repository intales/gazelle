import 'dart:io';

import 'package:gazelle_cli/commands/create/create_route.dart';
import 'package:gazelle_cli/commons/entities/project_configuration.dart';
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

      final projectConfiguration = ProjectConfiguration(
        name: "test",
        version: "0.1.0",
        path: tmpDirPath,
      );

      // Act
      final result = await createRoute(
        routeName: "hello_world",
        projectConfiguration: projectConfiguration,
      );

      // Assert
      expect(File(result.routeFilePath).existsSync(), isTrue);

      // Clean up
      await tmpDir.delete(recursive: true);
    });
  });
}
