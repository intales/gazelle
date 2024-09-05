import 'dart:async';

import 'package:gazelle_client/src/api/gazelle_api_client.dart';
import 'package:gazelle_core/gazelle_core.dart';
import 'package:test/test.dart';

class _Test {
  final String test;

  const _Test({
    required this.test,
  });
}

class _TestModelType extends GazelleModelType<_Test> {
  @override
  _Test fromJson(Map<String, dynamic> json) {
    return _Test(
      test: json["test"] as String,
    );
  }

  @override
  Map<String, dynamic> toJson(_Test value) {
    return {
      "test": value.test,
    };
  }
}

class _TestModelProvider extends GazelleModelProvider {
  @override
  Map<Type, GazelleModelType> get modelTypes => {
        _Test: _TestModelType(),
      };
}

GazelleResponse<_Test> testHandler(
  GazelleContext context,
  GazelleRequest request,
) =>
    GazelleResponse(
      statusCode: GazelleHttpStatusCode.success.ok_200,
      body: _Test(test: "Hello, World!"),
    );

GazelleResponse<String> stringHandler(
  GazelleContext context,
  GazelleRequest request,
) =>
    GazelleResponse(
      statusCode: GazelleHttpStatusCode.success.ok_200,
      body: "Hello, World!",
    );

void main() {
  group('GazelleApiClient tests', () {
    test('Should send a get request for a single item', () async {
      // Arrange
      final modelProvider = _TestModelProvider();

      final server = GazelleApp(
        modelProvider: modelProvider,
        routes: [
          GazelleRoute(
            name: "test",
            children: [
              GazelleRoute(
                name: "test",
              ).get(testHandler),
              GazelleRoute(
                name: "test_string",
              ).get(stringHandler),
            ],
          ),
        ],
      );

      await server.start();

      final client = GazelleApiClient(
        baseUrl: server.serverAddress,
        modelProvider: modelProvider,
      );

      // Act
      final result = await client("test")("test").get<_Test>();
      final resultString = await client("test")("test_string").get<String>();

      // Assert
      expect(result.test, "Hello, World!");
      expect(resultString, "Hello, World!");

      // Tear down
      client.close();
      await server.stop(force: true);
    });
  });
}
