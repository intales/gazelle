import 'package:gazelle_core/gazelle_core.dart';

void main() async {
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "hello",
        children: [
          GazelleRoute.parameter(
            name: "name",
            get: (context, request, response) => GazelleResponse(
              statusCode: GazelleHttpStatusCode.success.ok_200,
              body: "Hello, ${request.pathParameters["name"]}!",
            ),
            put: (context, request, response) => GazelleResponse(
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
