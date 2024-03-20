import 'package:gazelle/gazelle.dart';

class HelloNamePlugin implements GazellePlugin {
  HelloNamePlugin();

  @override
  Future<void> initialize(GazelleContext context) async {
    context.router.get("/hello_name_plugin/:name", (request) async {
      return GazelleResponse(
        statusCode: 200,
        body:
            "Hello, ${request.pathParameters["name"]} ${request.uri.queryParameters["surname"] ?? ""}! (plugin)",
      );
    });
  }
}

class HelloWorldPlugin implements GazellePlugin {
  @override
  Future<void> initialize(GazelleContext context) async {
    await context.register(HelloNamePlugin());
    context.router.get("/hello_world_plugin", (request) async {
      return GazelleResponse(
        statusCode: 200,
        body: "Hello, World! (plugin)",
      );
    });
  }
}

void main() async {
  final app = GazelleApp(address: "localhost", port: 8080);

  app.registerPlugin(HelloWorldPlugin());
  app.get("/hello_world", (request) async {
    return GazelleResponse(
      statusCode: 200,
      body: "Hello, World!",
    );
  });

  await app.start();
}
