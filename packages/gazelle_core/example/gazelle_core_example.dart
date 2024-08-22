import 'dart:async';

import 'package:gazelle_core/gazelle_core.dart';

class HelloGazelleGetHandler extends GazelleRouteHandler<String> {
  const HelloGazelleGetHandler();

  @override
  FutureOr<GazelleResponse<String>> call(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse response,
  ) {
    return GazelleResponse(
      statusCode: GazelleHttpStatusCode.success.ok_200,
      body: "Hello, Gazelle!",
    );
  }
}

Future<void> main() async {
  try {
    final app = GazelleApp(
      routes: [
        GazelleRoute(
          name: "hello_gazelle",
          get: const HelloGazelleGetHandler(),
        ),
      ],
    );

    await app.start();
    print("Gazelle listening at ${app.serverAddress}");
  } catch (e) {
    print("Failed to start the server: $e");
  }
}
