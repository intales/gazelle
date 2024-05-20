import 'package:gazelle_core/gazelle_core.dart';

void main() async {
  final app = GazelleApp(address: "localhost", port: 8080);

  final route = GazelleRoute(
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
  );

  app.addRoute(route);

  await app.start();
  print("Gazelle listening at ${app.address}:${app.port}");
}
