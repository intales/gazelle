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

class _TestHandler extends GazelleRouteHandler<_Test> {
  const _TestHandler();

  @override
  FutureOr<GazelleResponse<_Test>> call(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse response,
  ) {
    return GazelleResponse(
      statusCode: GazelleHttpStatusCode.success.ok_200,
      body: _Test(test: "Hello, World!"),
    );
  }
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

      // Assert
      expect(result.test, "Hello, World!");

      // Tear down
      client.close();
      await server.stop(force: true);
    });
  });
}
