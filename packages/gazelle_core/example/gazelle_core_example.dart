import 'dart:async';

import 'package:gazelle_core/gazelle_core.dart';

class HelloGazelleGetHandler extends GazelleGetHandler<String> {
  HelloGazelleGetHandler();

  @override
  FutureOr<String> call(
    GazelleContext context,
    Null body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  ) =>
      "Hello, Gazelle!";
}

Future<void> main() async {
  try {
    final app = GazelleApp(
      routes: [
        GazelleRoute(
          name: "hello_gazelle",
          get: HelloGazelleGetHandler(),
        ),
      ],
    );

    await app.start();
    print("Gazelle listening at ${app.serverAddress}");
  } catch (e) {
    print("Failed to start the server: $e");
  }
}
