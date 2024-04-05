import 'package:gazelle_core/gazelle_core.dart';

/// Gazelle benchmark sever.
final app = GazelleApp(address: "0.0.0.0", port: 3000);

/// Starts the Gazelle server for benchmark tests.
Future<void> startGazelleServer() async {
  app.get("/", (request) async {
    return GazelleResponse(
      statusCode: 200,
      body: "{ hello: 'world' }",
    );
  });

  await app.start();
  print("Gazelle server listening at ${app.address}:${app.port}");
}

/// Stops the Gazelle server for benchmark tests.
Future<void> stopGazelleServer() => app.stop();
