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
import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_logger/gazelle_logger.dart';

void main() async {
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "hello_gazelle",
        get: (context, request, resonse) async => GazelleResponse(
          statusCode: GazelleHttpStatusCode.success.ok_200,
          body: "Hello, Gazelle!",
        ),
        preRequestHooks: (context) => [
          context.getPlugin<GazelleLoggerPlugin>().logRequestHook,
        ],
        postResponseHooks: (context) => [
          context.getPlugin<GazelleLoggerPlugin>().logResponseHook,
        ],
      )
    ],
    plugins: [
      GazelleLoggerPlugin(),
    ],
  );

  await app.start();
  print("Gazelle listening at ${app.serverAddress}");
}
```

The `logRequestHook` logs incoming requests, while the `logResponseHook` logs outgoing responses.
