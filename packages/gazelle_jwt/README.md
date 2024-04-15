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
  final app = GazelleApp();
  await app.registerPlugin(GazelleJwtPlugin(SecretKey("supersecret")));

  app
    ..post(
      "/login",
      (request, response) async {
        return response.copyWith(
          statusCode: 200,
          body: app.getPlugin<GazelleJwtPlugin>().sign({"test": "123"}),
        );
      },
    )
    ..get(
      "/hello_world",
      (request, response) async {
        return response.copyWith(
          statusCode: 200,
          body: "Hello, World!",
        );
      },
      preRequestHooks: [app.getPlugin<GazelleJwtPlugin>().authenticationHook],
    );

  await app.start();
}
```
