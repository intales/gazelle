import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_jwt/gazelle_jwt.dart';
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
            "Authorization": ["Bearer $token"],
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
      expect(result.body, "Unauthorized");
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
            "Authorization": [" $token"],
          });

      // Act
      final result = await hook(request);

      // Assert
      expect(result.runtimeType, GazelleResponse);
      expect((result as GazelleResponse).statusCode, 401);
      expect(result.body, "Unauthorized");
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
            "Authorization": [" $token aaaa"],
          });

      // Act
      final result = await hook(request);

      // Assert
      expect(result.runtimeType, GazelleResponse);
      expect((result as GazelleResponse).statusCode, 401);
      expect(result.body, "Unauthorized");
    });
  });
}
