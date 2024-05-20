import 'package:gazelle_core/gazelle_core.dart';

void main() async {
  final app = GazelleApp(
    address: "localhost",
    port: 8080,
    routes: [
      GazelleRoute(
        name: "hello",
        children: [
          GazelleRoute(
            name: ":name",
            getHandler: (request, response) async => response.copyWith(
              statusCode: 200,
              body: "Hello, ${request.pathParameters["name"]}!",
            ),
            putHandler: (request, response) async => response.copyWith(
              statusCode: 200,
              body: "Hello, ${request.pathParameters["name"]}",
            ),
          ),
        ],
      ),
    ],
  );

  await app.start();
  print("Gazelle listening at ${app.serverAddress}");
}
