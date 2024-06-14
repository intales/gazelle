import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_jwt/gazelle_jwt.dart';
import 'package:gazelle_jwt/src/gazelle_jwt_consts.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('GazelleJwtPlugin tests', () {
    test('Should sign and verify a JWT', () async {
      // Arrange
      const payload = {"test": "123"};
      final context = GazelleContext.create();
      final plugin = GazelleJwtPlugin(SecretKey("supersecret"));
      await plugin.initialize(context);

      // Act
      final token = plugin.sign(payload);
      final jwt = plugin.verify(token);

      // Assert
      expect(jwt?.payload["test"], payload["test"]);
    });

    test('Should return a request with a JWT', () async {
      // Arrange
      final context = GazelleContext.create();
      final plugin = GazelleJwtPlugin(SecretKey("supersecret"));
      await plugin.initialize(context);
      final token = plugin.sign({"test": "123"});

      final hook = plugin.authenticationHook;
      GazelleRequest request = GazelleRequest(
          uri: Uri.parse("http://localhost/test"),
          method: GazelleHttpMethod.get,
          pathParameters: {},
          headers: [
            GazelleHttpHeader.authorization.addValue("Bearer $token"),
          ]);
      GazelleResponse response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.noContent_204,
      );

      // Act
      (request, response) = await hook(context, request, response);

      // Assert
      expect(request.jwt.payload["test"], "123");
    });

    test('Should return a response when auth header is not set', () async {
      // Arrange
      final context = GazelleContext.create();
      final plugin = GazelleJwtPlugin(SecretKey("supersecret"));
      await plugin.initialize(context);

      final hook = plugin.authenticationHook;
      GazelleRequest request = GazelleRequest(
        uri: Uri.parse("http://localhost/test"),
        method: GazelleHttpMethod.get,
        pathParameters: {},
      );
      GazelleResponse response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.noContent_204,
      );

      // Act
      (request, response) = await hook(context, request, response);

      // Assert
      expect(response.statusCode, GazelleHttpStatusCode.error.unauthorized_401);
      expect(response.body, missingAuthHeaderMessage);
    });

    test('Should return a response when header schema is invalid', () async {
      // Arrange
      final context = GazelleContext.create();
      final plugin = GazelleJwtPlugin(SecretKey("supersecret"));
      await plugin.initialize(context);
      final token = plugin.sign({"test": "123"});

      final hook = plugin.authenticationHook;
      GazelleRequest request = GazelleRequest(
          uri: Uri.parse("http://localhost/test"),
          method: GazelleHttpMethod.get,
          pathParameters: {},
          headers: [
            GazelleHttpHeader.authorization.addValue(" $token"),
          ]);
      GazelleResponse response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.noContent_204,
      );

      // Act
      (request, response) = await hook(context, request, response);

      // Assert
      expect(response.statusCode, GazelleHttpStatusCode.error.unauthorized_401);
      expect(response.body, badBearerSchemaMessage);
    });

    test('Should return a response when token is invalid', () async {
      // Arrange
      final context = GazelleContext.create();
      final plugin = GazelleJwtPlugin(SecretKey("supersecret"));
      await plugin.initialize(context);
      final token = plugin.sign({"test": "123"});

      final hook = plugin.authenticationHook;
      GazelleRequest request = GazelleRequest(
          uri: Uri.parse("http://localhost/test"),
          method: GazelleHttpMethod.get,
          pathParameters: {},
          headers: [
            GazelleHttpHeader.authorization.addValue("Bearer $token aaaa"),
          ]);
      GazelleResponse response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.noContent_204,
      );

      // Act
      (request, response) = await hook(context, request, response);

      // Assert
      expect(response.statusCode, GazelleHttpStatusCode.error.unauthorized_401);
      expect(response.body, invalidTokenMessage);
    });

    test('Should integrate with gazelle core', () async {
      // Arrange
      final app = GazelleApp(
        routes: [
          GazelleRoute(
            name: "login",
            post: (context, request, response) async {
              return GazelleResponse(
                statusCode: GazelleHttpStatusCode.success.ok_200,
                body:
                    context.getPlugin<GazelleJwtPlugin>().sign({"test": "123"}),
              );
            },
          ),
          GazelleRoute(
            name: "test",
            get: (context, request, response) async {
              return GazelleResponse(
                statusCode: GazelleHttpStatusCode.success.ok_200,
                body: "Hello, World!",
              );
            },
            preRequestHooks: (context) => [
              context.getPlugin<GazelleJwtPlugin>().authenticationHook,
            ],
            children: [
              GazelleRoute(
                name: "test_2",
                get: (context, request, response) async {
                  return GazelleResponse(
                    statusCode: GazelleHttpStatusCode.success.ok_200,
                    body: "Hello, World!",
                  );
                },
              ),
            ],
          ),
        ],
        plugins: [
          GazelleJwtPlugin(SecretKey("supersecret")),
        ],
      );
      await app.start();

      // Act
      final baseUrl = app.serverAddress;
      final token =
          await http.post(Uri.parse("$baseUrl/login")).then((e) => e.body);

      final test = await http.get(Uri.parse("$baseUrl/test"), headers: {
        "authorization": "Bearer $token",
      });

      final test2 = await http.get(Uri.parse("$baseUrl/test/test_2"), headers: {
        "authorization": "Bearer $token",
      });

      // Assert
      expect(test.statusCode, 200);
      expect(test.body, "Hello, World!");
      expect(test2.statusCode, 200);
      expect(test2.body, "Hello, World!");
    });
  });
}
