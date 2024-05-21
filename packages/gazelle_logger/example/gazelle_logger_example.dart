import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_logger/gazelle_logger.dart';

void main() async {
  final loggerPlugin = GazelleLoggerPlugin();

  final route = GazelleRoute(
    name: "",
    getHandler: (context, request, resonse) async => resonse.copyWith(
      statusCode: 200,
      body: "Hello, Gazelle!",
    ),
    preRequestHooks: (context) => [loggerPlugin.logRequestHook],
    postResponseHooks: (context) => [loggerPlugin.logResponseHook],
  );

  final app = GazelleApp(port: 3000, routes: [route]);
  await app.registerPlugin(GazelleLoggerPlugin());

  await app.start();
}
