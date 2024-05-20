import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_logger/gazelle_logger.dart';

void main() async {
  final app = GazelleApp(port: 3000);
  await app.registerPlugin(GazelleLoggerPlugin());

  final route = GazelleRoute(
    name: "",
    getHandler: (request, resonse) async => resonse.copyWith(
      statusCode: 200,
      body: "Hello, Gazelle!",
    ),
    preRequestHooks: [app.getPlugin<GazelleLoggerPlugin>().logRequestHook],
    postResponseHooks: [app.getPlugin<GazelleLoggerPlugin>().logResponseHook],
  );

  app.addRoute(route);
  await app.start();
}
