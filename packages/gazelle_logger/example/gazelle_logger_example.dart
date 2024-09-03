import 'dart:async';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_logger/gazelle_logger.dart';

class GazelleLoggerExampleHandler extends GazelleGetHandler<String> {
  const GazelleLoggerExampleHandler();

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
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "hello_gazelle",
        get: const GazelleLoggerExampleHandler(),
        preRequestHooks: (context) => [
          context.getPlugin<GazelleLoggerPlugin>().logRequestHook,
        ],
        postResponseHooks: (context) => [
          context.getPlugin<GazelleLoggerPlugin>().logResponseHook,
        ],
      )
    ],
    plugins: [
      GazelleLoggerPlugin(),
    ],
  );

  await app.start();
  print("Gazelle listening at ${app.serverAddress}");
}
