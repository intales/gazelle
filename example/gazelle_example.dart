import 'package:gazelle/gazelle.dart';

class HelloNamePlugin implements GazellePlugin {
  final String name;

  HelloNamePlugin(this.name);

  @override
  Future<void> initialize(GazelleContext context) async {
    context.router.get("/hello_name_plugin", (context, request) async {
      return GazelleRouteHandlerResult(
        statusCode: 200,
        response: "Hello, $name! (plugin)",
      );
    });
  }
}

class HelloWorldPlugin implements GazellePlugin {
  @override
  Future<void> initialize(GazelleContext context) async {
    await context.register(HelloNamePlugin("Filippo"));
    context.router.get("/hello_world_plugin", (context, request) async {
      return GazelleRouteHandlerResult(
        statusCode: 200,
        response: "Hello, World! (plugin)",
      );
    });
  }
}

void main() async {
  final app = GazelleApp(address: "localhost", port: 8080);

  app.registerPlugin(HelloWorldPlugin());
  app.get("/hello_world", (context, request) async {
    return GazelleRouteHandlerResult(
      statusCode: 200,
      response: "Hello, World!",
    );
  });

  await app.start();
}
