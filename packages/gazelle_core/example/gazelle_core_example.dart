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
            getHandler: (context, request, response) => response.copyWith(
              statusCode: GazelleHttpStatusCode.success.ok_200,
              body: "Hello, ${request.pathParameters["name"]}!",
            ),
            putHandler: (context, request, response) => response.copyWith(
              statusCode: GazelleHttpStatusCode.success.ok_200,
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
