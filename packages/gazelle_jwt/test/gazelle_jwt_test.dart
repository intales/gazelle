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
      final plugin = GazelleJwtPlugin("supersecret");
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
      final plugin = GazelleJwtPlugin("supersecret");
      await plugin.initialize(context);
      final token = plugin.sign({"test": "123"});

      final hook = plugin.authenticationHook;
      final request = GazelleRequest(
          uri: Uri.parse("http://localhost/test"),
          method: GazelleHttpMethod.get,
          pathParameters: {},
          headers: {
            "authorization": ["Bearer $token"],
          });

      // Act
      final result = await hook(request);

      // Assert
      expect(result.runtimeType, GazelleRequest);
      expect((result as GazelleRequest).jwt.payload["test"], "123");
    });

    test('Should return a response when auth header is not set', () async {
      // Arrange
      final context = GazelleContext.create();
      final plugin = GazelleJwtPlugin("supersecret");
      await plugin.initialize(context);

      final hook = plugin.authenticationHook;
      final request = GazelleRequest(
        uri: Uri.parse("http://localhost/test"),
        method: GazelleHttpMethod.get,
        pathParameters: {},
      );
      // Act
      final result = await hook(request);

      // Assert
      expect(result.runtimeType, GazelleResponse);
      expect((result as GazelleResponse).statusCode, 401);
      expect(result.body, missingAuthHeaderMessage);
    });

    test('Should return a response when header schema is invalid', () async {
      // Arrange
      final context = GazelleContext.create();
      final plugin = GazelleJwtPlugin("supersecret");
      await plugin.initialize(context);
      final token = plugin.sign({"test": "123"});

      final hook = plugin.authenticationHook;
      final request = GazelleRequest(
          uri: Uri.parse("http://localhost/test"),
          method: GazelleHttpMethod.get,
          pathParameters: {},
          headers: {
            "authorization": [" $token"],
          });

      // Act
      final result = await hook(request);

      // Assert
      expect(result.runtimeType, GazelleResponse);
      expect((result as GazelleResponse).statusCode, 401);
      expect(result.body, badBearerSchemaMessage);
    });

    test('Should return a response when token is invalid', () async {
      // Arrange
      final context = GazelleContext.create();
      final plugin = GazelleJwtPlugin("supersecret");
      await plugin.initialize(context);
      final token = plugin.sign({"test": "123"});

      final hook = plugin.authenticationHook;
      final request = GazelleRequest(
          uri: Uri.parse("http://localhost/test"),
          method: GazelleHttpMethod.get,
          pathParameters: {},
          headers: {
            "authorization": ["Bearer $token aaaa"],
          });

      // Act
      final result = await hook(request);

      // Assert
      expect(result.runtimeType, GazelleResponse);
      expect((result as GazelleResponse).statusCode, 401);
      expect(result.body, invalidTokenMessage);
    });

    test('Should integrate with gazelle core', () async {
      // Arrange
      final app = GazelleApp();
      await app.registerPlugin(GazelleJwtPlugin("supersecret"));

      app
        ..post(
          "/login",
          (request) async {
            return GazelleResponse(
              statusCode: 200,
              body: app.getPlugin<GazelleJwtPlugin>().sign({"test": "123"}),
            );
          },
        )
        ..get(
          "/test",
          (request) async {
            return GazelleResponse(
              statusCode: 200,
              body: "Hello, World!",
            );
          },
          preRequestHooks: [
            app.getPlugin<GazelleJwtPlugin>().authenticationHook,
          ],
        );

      await app.start();

      // Act
      final baseUrl = "http://${app.address}:${app.port}";
      final token =
          await http.post(Uri.parse("$baseUrl/login")).then((e) => e.body);

      final result = await http.get(Uri.parse("$baseUrl/test"), headers: {
        "authorization": "Bearer $token",
      });

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, "Hello, World!");
    });
  });
}
