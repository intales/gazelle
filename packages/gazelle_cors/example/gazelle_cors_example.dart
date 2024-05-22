import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_cors/gazelle_cors.dart';

void main() async {
  // Setup your server.
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "",
        getHandler: (context, request, response) async {
          return response.copyWith(
            statusCode: 200,
            body: "Hello, Gazelle!",
          );
        },
        // Add CORS hook from the regsitered plugin.
        preRequestHooks: (context) => [
          context.getPlugin<GazelleCorsPlugin>().corsHook,
        ],
      ),
    ],
    plugins: {
      GazelleCorsPlugin(corsHeaders: {
        GazelleCorsHeaders.accessControlAllowOrigin.name: ["example.com"],
      })
    },
  );

  // Start your server.
  await app.start();
  print("Gazelle listening at ${app.serverAddress}");
}
