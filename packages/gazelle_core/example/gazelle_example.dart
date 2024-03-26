import 'package:gazelle_core/gazelle_core.dart';

class HelloNamePlugin implements GazellePlugin {
  HelloNamePlugin();

  @override
  Future<void> initialize(GazelleContext context) async {
    context.get("/hello_name_plugin/:name", (request) async {
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
    context.get("/hello_world_plugin", (request) async {
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
  app.get("/", (request) async {
    return GazelleResponse(
      statusCode: 200,
      body: "Hello, Gazelle!",
    );
  });

  await app.start();
}
