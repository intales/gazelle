import 'dart:async';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_logger/gazelle_logger.dart';

class GazelleLoggerExampleHandler extends GazelleGetHandler<String> {
  const GazelleLoggerExampleHandler();

  @override
  FutureOr<GazelleResponse<String>> call(
    GazelleContext context,
    GazelleRequest<Null> request,
  ) =>
      GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: "Hello, Gazelle!",
      );
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
