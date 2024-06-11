import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_cors/gazelle_cors.dart';

void main() async {
  // Setup your server.
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "",
        get: (context, request, response) async {
          return GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            body: "Hello, Gazelle!",
          );
        },
        // Add CORS hook from the regsitered plugin.
        preRequestHooks: (context) => [
          context.getPlugin<GazelleCorsPlugin>().corsHook,
        ],
      ),
    ],
    plugins: [
      GazelleCorsPlugin(corsHeaders: [
        GazelleHttpHeader.accessControlAllowOrigin.addValue("example.com"),
      ])
    ],
  );

  // Start your server.
  await app.start();
  print("Gazelle listening at ${app.serverAddress}");
}
