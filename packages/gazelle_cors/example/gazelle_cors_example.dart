import 'dart:async';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_cors/gazelle_cors.dart';

class GazelleCorsExampleHandler extends GazelleGetHandler<String> {
  const GazelleCorsExampleHandler();

  @override
  FutureOr<String> call(
    GazelleContext context,
    Null body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  ) =>
      "Hello, Gazelle!";
}

void main() async {
  // Setup your server.
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "",
        get: const GazelleCorsExampleHandler(),
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
