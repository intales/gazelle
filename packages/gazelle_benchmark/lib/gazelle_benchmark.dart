import 'dart:async';

import 'package:gazelle_core/gazelle_core.dart';

/// Gazelle benchmark handler.
GazelleResponse<String> handler(
  GazelleContext context,
  GazelleRequest request,
) =>
    GazelleResponse(
      statusCode: GazelleHttpStatusCode.success.ok_200,
      body: "Hello, World!",
    );

/// Gazelle benchmark sever.
final app = GazelleApp(address: "0.0.0.0", port: 3000, routes: [
  GazelleRoute(
    name: "",
  ).get(handler),
]);

/// Starts the Gazelle server for benchmark tests.
Future<void> startGazelleServer() async {
  await app.start();
  print("Gazelle server listening at ${app.address}:${app.port}");
}

/// Stops the Gazelle server for benchmark tests.
Future<void> stopGazelleServer() => app.stop();
