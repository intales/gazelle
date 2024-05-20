import 'package:gazelle_core/gazelle_core.dart';

/// Gazelle benchmark sever.
final app = GazelleApp(address: "0.0.0.0", port: 3000);

/// Starts the Gazelle server for benchmark tests.
Future<void> startGazelleServer() async {
  final route = GazelleRoute(
    name: "",
    getHandler: (request, response) async => response.copyWith(
      statusCode: 200,
      body: "Hello, World!",
    ),
  );

  app.addRoute(route);
  await app.start();
  print("Gazelle server listening at ${app.address}:${app.port}");
}

/// Stops the Gazelle server for benchmark tests.
Future<void> stopGazelleServer() => app.stop();
