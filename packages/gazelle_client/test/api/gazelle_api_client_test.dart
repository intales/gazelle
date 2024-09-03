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

class _TestHandler extends GazelleGetHandler<_Test> {
  const _TestHandler();

  @override
  FutureOr<_Test> call(
    GazelleContext context,
    Null body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  ) =>
      _Test(test: "Hello, World!");
}

class _TestStringHandler extends GazelleGetHandler<String> {
  const _TestStringHandler();

  @override
  FutureOr<String> call(
    GazelleContext context,
    Null body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  ) =>
      "Hello, World!";
}

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
                get: const _TestHandler(),
              ),
              GazelleRoute(
                name: "test_string",
                get: const _TestStringHandler(),
              ),
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
