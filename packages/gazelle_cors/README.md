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
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "",
        get: (context, request, response) async {
          return GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            body: "Hello, Gazelle!",
          );
        },
        // Add CORS hook from the regsitered plugin.
        preRequestHooks: (context) => [
          context.getPlugin<GazelleCorsPlugin>().corsHook,
        ],
      ),
    ],
    plugins: [
      GazelleCorsPlugin(corsHeaders: [
        GazelleHttpHeader.accessControlAllowOrigin.addValue("example.com"),
      ])
    ],
  );

  // Start your server.
  await app.start();
  print("Gazelle listening at ${app.serverAddress}");
}
```
