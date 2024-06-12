import 'package:gazelle_core/gazelle_core.dart';

void main() async {
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "hello_gazelle",
        get: (context, request, response) => GazelleResponse(
          statusCode: GazelleHttpStatusCode.success.ok_200,
          body: "Hello, Gazelle!",
        ),
      ),
    ],
  );

  await app.start();
  print("Gazelle listening at ${app.serverAddress}");
}
