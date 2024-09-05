import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_cors/gazelle_cors.dart';

void main() async {
  // Setup your server.
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "",
        // Add CORS hook from the regsitered plugin.
        preRequestHooks: (context) => [
          context.getPlugin<GazelleCorsPlugin>().corsHook,
        ],
      ).get((context, request) => GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            body: "Hello, Gazelle!",
          )),
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
