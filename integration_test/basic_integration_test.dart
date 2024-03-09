import 'package:gazelle/gazelle.dart';

class HelloNamePlugin implements GazellePlugin {
  final String name;

  HelloNamePlugin(this.name);

  @override
  Future<void> initialize(GazelleContext context) async {
    context.router.insertHandler("/hello_name_plugin", (context, request) {
      request.response.statusCode = 200;
      request.response.write("Hello, $name! (plugin)");
      request.response.close();
    });
  }
}

class HelloWorldPlugin implements GazellePlugin {
  @override
  Future<void> initialize(GazelleContext context) async {
    await context.register(HelloNamePlugin("Filippo"));
    context.router.insertHandler("/hello_world_plugin", (context, request) {
      request.response.statusCode = 200;
      request.response.write("Hello, World! (plugin)");
      request.response.close();
    });
  }
}

void main() async {
  final app = GazelleApp(address: "localhost", port: 8080);

  app.registerPlugin(HelloWorldPlugin());
  app.insertRoute("/hello_world", (context, request) {
    request.response.statusCode = 200;
    request.response.write("Hello, World!");
    request.response.close();
  });

  await app.start();
  print("Server started!");
}
