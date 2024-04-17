import 'dart:io';

import 'package:gazelle/create_docker_files.dart';
import 'package:test/test.dart';

void main() {
  group("CreateDockerFiles tests", () {
    test("Should return Dockerfile contents", () {
      // Arrange
      const mainFilePath = "bin/main.dart";
      const exposedPort = 8080;

      // Act
      final result = generateDockerFileContent(
        mainFilePath: mainFilePath,
        exposedPort: exposedPort,
      );

      // Assert
      expect(result.contains(mainFilePath), isTrue);
      expect(result.contains("$exposedPort"), isTrue);
    });

    test("Should create docker files", () async {
      // Arrange
      const path = "tmp/docker_files_tests";

      try {
        await Directory(path).delete(recursive: true);
      } catch (_) {
        print("$path does not exist, creating it now.");
      }

      await Directory(path).create(recursive: true);

      const mainFilePath = "bin/main.dart";
      const exposedPort = 8080;

      // Act
      await createDockerFiles(
        path: path,
        mainFilePath: mainFilePath,
        exposedPort: exposedPort,
      );

      // Assert
      expect(await File("$path/.dockerignore").exists(), isTrue);
      expect(await File("$path/Dockerfile").exists(), isTrue);
    });
  });
}
