import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_logger/gazelle_logger.dart';

void main() async {
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "hello_gazelle",
        preRequestHooks: (context) => [
          context.getPlugin<GazelleLoggerPlugin>().logRequestHook,
        ],
        postResponseHooks: (context) => [
          context.getPlugin<GazelleLoggerPlugin>().logResponseHook,
        ],
      ).get((context, request) => GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            body: "Hello, Gazelle!",
          ))
    ],
    plugins: [
      GazelleLoggerPlugin(),
    ],
  );

  await app.start();
  print("Gazelle listening at ${app.serverAddress}");
}
