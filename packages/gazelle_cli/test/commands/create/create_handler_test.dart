import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:gazelle_cli/commands/create/create_handler.dart';
import 'package:gazelle_cli/commons/entities/http_method.dart';
import 'package:gazelle_cli/commons/entities/project_route.dart';
import 'package:test/test.dart';

void main() {
  group('CreateHandler tests', () {
    test('Should create a handler files for every http method', () async {
      // Arrange
      final tmpDirPath = "tmp/create_handler_tests";

      Directory tmpDir = Directory(tmpDirPath);
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
      tmpDir = await Directory(tmpDirPath).create(recursive: true);

      final route = ProjectRoute(
        path: "$tmpDirPath/hello_world",
        name: "HelloWorld",
        methods: [],
      );

      String getHandlerContent(String handlerName) {
        return DartFormatter().format("""
import 'package:gazelle_core/gazelle_core.dart';

class $handlerName extends GazelleRouteHandler<String> {
  const $handlerName();

  @override
  Future<GazelleResponse<String>> call(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse response,
  ) async {
    return GazelleResponse(
      statusCode: GazelleHttpStatusCode.success.ok_200,
      body: "Hello, Gazelle!",
    );
  }
}
  """
            .trim());
      }

      for (final httpMethod in HttpMethod.values) {
        final expectedHandlerName = "HelloWorld${httpMethod.pascalCase}";

        final handlerContent = getHandlerContent(expectedHandlerName);

        // Act
        final result = await createHandler(
          route: route,
          httpMethod: httpMethod,
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
