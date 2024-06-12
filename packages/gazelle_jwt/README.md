# Gazelle JWT Plugin

The Gazelle JWT Plugin provides JSON Web Token (JWT) authentication capabilities
for the Gazelle framework. This plugin allows you to easily secure your routes
by integrating JWT-based authentication into your Gazelle application.

This plugin is based on [dart_jsonwebtoken](https://pub.dev/packages/dart_jsonwebtoken).

## Getting started

### Installation

To install the Gazelle JWT Plugin, add it to your pubspec.yaml file:
```yaml
dependencies:
  gazelle_core: <latest-version>
  gazelle_jwt: <latest-version> 
```
Then, run `dart pub get` or ` flutter pub get`  to install  the package.

### Example usage

Here's a quick example on how to use the GazelleJwtPlugin:
```dart
import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_jwt/gazelle_jwt.dart';

void main() async {
  // Initialize your Gazelle app.
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "login",
        post: (context, request, response) async {
          // Use the request to get data sent from the client.
          return GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            // Sign a token and send it back to the client.
            body: context.getPlugin<GazelleJwtPlugin>().sign({"test": "123"}),
          );
        },
      ),
      GazelleRoute(
        name: "hello_world",
        get: (context, request, response) async {
          return GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            body: "Hello, World!",
          );
        },
        // Add the authentication hook provided by the plugin to guard your routes.
        preRequestHooks: (context) => [
          context.getPlugin<GazelleJwtPlugin>().authenticationHook,
        ],
      ),
    ],
    plugins: [GazelleJwtPlugin(SecretKey("supersecret"))],
  );

  // Start your server.
  await app.start();
}
```
