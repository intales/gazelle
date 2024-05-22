import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_jwt/gazelle_jwt.dart';
import 'package:http/http.dart' as http;

void main() async {
  // Initialize your Gazelle app.
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "login",
        postHandler: (context, request, response) async {
          // Use the request to get data sent from the client.
          return response.copyWith(
            statusCode: 200,
            // Sign a token and send it back to the client.
            body: context.getPlugin<GazelleJwtPlugin>().sign({"test": "123"}),
          );
        },
      ),
      GazelleRoute(
        name: "hello_world",
        getHandler: (context, request, response) async {
          return response.copyWith(
            statusCode: 200,
            body: "Hello, World!",
          );
        },
        // Add the authentication hook provided by the plugin to guard your routes.
        preRequestHooks: (context) => [
          context.getPlugin<GazelleJwtPlugin>().authenticationHook,
        ],
      ),
    ],
    plugins: {GazelleJwtPlugin(SecretKey("supersecret"))},
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
