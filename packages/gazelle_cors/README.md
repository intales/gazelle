# Gazelle CORS Plugin

Gazelle CORS Plugin is a Dart package that provides Cross-Origin Resource Sharing (CORS) support for Gazelle applications.

## Installation
Add `gazelle_cors` as a dependency in your `pubspec.yaml` file:
```yaml
dependencies:
  gazelle_core: <latest-version>
  gazelle_cors: <latest-version>
```

Then, run `dart pub get`.

## Usage
```dart
import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_cors/gazelle_cors.dart';

void main() async {
  // Setup your server.
  final app = GazelleApp(port: 3000);

  // Register the CORS plugin.
  await app.registerPlugin(GazelleCorsPlugin(corsHeaders: {
    GazelleCorsHeaders.accessControlAllowOrigin.name: ["example.com"],
  }));

  // Setup your routes.
  app.get(
    "/",
    (request, response) async {
      return response.copyWith(
        statusCode: 200,
        body: "Hello, Gazelle!",
      );
    },
    // Add CORS hook from the registered plugin.
    preRequestHooks: [app.getPlugin<GazelleCorsPlugin>().corsHook],
  );

  // Start your server.
  await app.start();
}
```
