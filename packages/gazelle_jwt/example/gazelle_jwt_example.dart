import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_jwt/gazelle_jwt.dart';
import 'package:http/http.dart' as http;

void main() async {
  // Initialize your Gazelle app.
  final app = GazelleApp(port: 3000);
  // Register GazelleJwtPlugin.
  await app.registerPlugin(GazelleJwtPlugin("supersecret"));

  // Setup your routes.
  app
    ..post(
      "/login",
      (request) async {
        // Use the request to get data sent from the client.
        return GazelleResponse(
          statusCode: 200,
          // Sign a token and send it back to the client.
          body: app.getPlugin<GazelleJwtPlugin>().sign({"test": "123"}),
        );
      },
    )
    ..get(
      "/hello_world",
      (request) async {
        return GazelleResponse(
          statusCode: 200,
          body: "Hello, World!",
        );
      },
      // Add the authentication hook provided by the plugin to guard your routes.
      preRequestHooks: [app.getPlugin<GazelleJwtPlugin>().authenticationHook],
    );

  // Start your server.
  await app.start();

  // CLIENT SIDE
  final baseUrl = "http://${app.address}:${app.port}";

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
