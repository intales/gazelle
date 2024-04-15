# Gazelle Logger Plugin

The Gazelle Logger Plugin provides logging functionality for Gazelle applications.
It allows developers to log incoming requests and outgoing responses, making it easier to debug and monitor application behavior.

Based on [logger](https://pub.dev/packages/logger).

## Installation
To use the Gazelle Logger Plugin, add `gazelle_logger` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  gazelle_core: <latest-version>
  gazelle_logger: <latest-version>
```

Then, run `dart pub get` to install the package.

## Usage
Import the package in your Dart file:

```dart
import 'package:gazelle_logger/gazelle_logger.dart';
```

Initialize the plugin and register it with your Gazelle application:

```dart
void main() async {
  final app = GazelleApp();
  await app.registerPlugin(GazelleLoggerPlugin());

  // Define your routes here

  await app.start();
}
```

Now, you can use the provided hooks to log requests and responses:

```dart
app.get(
  "/",
  (request, response) async => response.copyWith(
    statusCode: 200,
    body: "Hello, Gazelle!",
  ),
  preRequestHooks: [app.getPlugin<GazelleLoggerPlugin>().logRequestHook],
  postRequestHooks: [app.getPlugin<GazelleLoggerPlugin>().logResponseHook],
);
```

The `logRequestHook` logs incoming requests, while the `logResponseHook` logs outgoing responses.
