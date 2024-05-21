import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_cors/gazelle_cors.dart';

void main() async {
  // Setup your server.
  final corsPlugin = GazelleCorsPlugin(corsHeaders: {
    GazelleCorsHeaders.accessControlAllowOrigin.name: ["example.com"],
  });

  final routes = [
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
  ];
  final app = GazelleApp(port: 3000, routes: routes);

  // Register the CORS plugin.
  await app.registerPlugin(corsPlugin);

  // Start your server.
  await app.start();
}
