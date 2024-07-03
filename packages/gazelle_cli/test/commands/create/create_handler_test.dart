import 'dart:io';

import 'package:dart_style/dart_style.dart';
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
      expect(result.handlerName, "helloWorldGet");
      expect(File(result.handlerFilePath).existsSync(), isTrue);

      // Clean up
      await tmpDir.delete(recursive: true);
    });
    test('Should create handler files with the correct content', () async {
      // Arrange
      final tmpDirPath = "tmp/create_handler_exhaustive_tests";
      final routeName = "hello_world";

      Directory tmpDir = Directory(tmpDirPath);
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
      tmpDir = await Directory(tmpDirPath).create(recursive: true);

      String getHandlerContent(String handlerName) {
        return DartFormatter().format("""
import 'package:gazelle_core/gazelle_core.dart';

GazelleResponse $handlerName(
  GazelleContext context,
  GazelleRequest request,
  GazelleResponse response,
) {
  return GazelleResponse(
    statusCode: GazelleHttpStatusCode.success.ok_200,
    body: "Hello, World!",
  );
}
  """
            .trim());
      }

      for (final httpMethod in ["GET", "POST", "PUT", "PATCH", "DELETE"]) {
        String handlerName = switch (httpMethod) {
          "GET" => "Get",
          "POST" => "Post",
          "PUT" => "Put",
          "PATCH" => "Patch",
          "DELETE" => "Delete",
          _ => throw "Unexpected error",
        };
        final expectedHandlerName = "helloWorld$handlerName";

        final handlerContent = getHandlerContent(expectedHandlerName);

        // Act
        final result = await createHandler(
          routeName: routeName,
          httpMethod: httpMethod,
          path: tmpDirPath,
        );

        // Assert
        expect(result.handlerName, expectedHandlerName);
        expect(File(result.handlerFilePath).existsSync(), isTrue);
        expect(File(result.handlerFilePath).readAsStringSync(), handlerContent);
      }
      // Clean up
      await tmpDir.delete(recursive: true);
    });
  });
}
