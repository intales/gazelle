import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_cors/gazelle_cors.dart';

void main() async {
  // Setup your server.
  final app = GazelleApp(port: 3000);

  // Register the CORS plugin.
  await app.registerPlugin(GazelleCorsPlugin(corsHeaders: {
    GazelleCorsHeaders.accessControlAllowOrigin.name: ["example.com"],
  }));

  // Setup your routes.
  app.get(
    "/",
    (request, response) async {
      return response.copyWith(
        statusCode: 200,
        body: "Hello, Gazelle!",
      );
    },
    // Add CORS hook from the regsitered plugin.
    preRequestHooks: [app.getPlugin<GazelleCorsPlugin>().corsHook],
  );

  // Start your server.
  await app.start();
}
