import 'package:gazelle_core/gazelle_core.dart';

void main() async {
  final app = GazelleApp(address: "localhost", port: 8080);

  app.get("/", (request, response) async {
    return response.copyWith(
      statusCode: 200,
      body: "Hello, Gazelle!",
    );
  });

  await app.start();
}
