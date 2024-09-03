import 'dart:async';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_jwt/gazelle_jwt.dart';
import 'package:http/http.dart' as http;

class GazelleLoginJwtExampleHandler extends GazellePostHandler<String, String> {
  const GazelleLoginJwtExampleHandler();

  @override
  FutureOr<GazelleResponse<String>> call(
    GazelleContext context,
    GazelleRequest<String> request,
  ) =>
      GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: context.getPlugin<GazelleJwtPlugin>().sign({"test": "123"}),
      );
}

class GazelleHelloWorldJwtExampleHandler extends GazelleGetHandler<String> {
  const GazelleHelloWorldJwtExampleHandler();

  @override
  FutureOr<GazelleResponse<String>> call(
    GazelleContext context,
    GazelleRequest<Null> request,
  ) =>
      GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: "Hello, World!",
      );
}

void main() async {
  // Initialize your Gazelle app.
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "login",
        post: const GazelleLoginJwtExampleHandler(),
      ),
      GazelleRoute(
        name: "hello_world",
        get: const GazelleHelloWorldJwtExampleHandler(),
        // Add the authentication hook provided by the plugin to guard your routes.
        preRequestHooks: (context) => [
          context.getPlugin<GazelleJwtPlugin>().authenticationHook,
        ],
      ),
    ],
    plugins: [GazelleJwtPlugin(SecretKey("supersecret"))],
  );

  // Start your server.
  await app.start();

  // CLIENT SIDE
  final baseUrl = app.serverAddress;

  // Ask for a token.
  final token =
      await http.post(Uri.parse("$baseUrl/login")).then((e) => e.body);

  // Authenticate your requests.
  final result = await http.get(Uri.parse("$baseUrl/hello_world"), headers: {
    "Authorization": "Bearer $token",
  });

  print(result.body); // Prints "Hello, World!"

  await app.stop(force: true);
}
