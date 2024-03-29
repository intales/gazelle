# Gazelle

Gazelle is a lightweight and flexible HTTP server framework for Dart,
designed to streamline the development of web applications with ease.
With Gazelle, you can quickly set up powerful APIs, web servers, and
microservices, all with minimal configuration and maximum efficiency.

## Features

 - **Easy-to-Use**: Gazelle is built with simplicity in mind.
 Whether you're a seasoned developer or just starting out, Gazelle's intuitive
 API and clear documentation make it easy to get up and running in no time.

 - **Plugin System**: Extend Gazelle's functionality with custom plugins.
 Seamlessly integrate authentication, logging, and other common features into
 your application with Gazelle's plugin architecture.

 - **Middleware Support**: Gazelle supports middleware functions, allowing you to
 customize request handling with ease.
 Add authentication, rate limiting, and more to your routes with just a
 few lines of code.

 - **HTTP/HTTPS Support**: Gazelle fully supports both HTTP and HTTPS protocols,
 ensuring secure communication for your applications.
 Easily configure SSL certificates for added security.

## Getting started

### Installation

To start using Gazelle in your Dart project, simply add it to your `pubspec.yaml` file:
```yaml
dependencies:
  gazelle: <latest-version> 
```
Then, run `dart pub get` or `flutter pub get` to install the package.

### Example usage

Here's a quick example of how to create a simple Gazelle server:
```dart
import 'package:gazelle_core/gazelle_core.dart';

void main() async {
  final app = GazelleApp();

  app.get('/', (request) async => GazelleResponse(
    statusCode: 200,
    body: 'Hello, Gazelle!',
  ));

  await app.start();
  print('Server is running at http://${app.address}:${app.port}');
}
```
That's it! You've just created a basic Gazelle server that responds with "Hello, Gazelle!"
to any incoming requests to the root route.

For more advanced usage and detailed documentation, check out the Gazelle documentation.

## Contributing 

At Gazelle, we believe in the power of community collaboration.
Our plugin system not only helps scale your codebase but also empowers developers to
contribute to the community without relying solely on the core maintainers.
Whether you're interested in fixing bugs, adding new features, improving documentation, or leaving a feedback,
your contributions are welcome and valued.

We encourage you to get involved by opening issues, submitting pull requests,
or joining discussions on our GitHub repository.
Together, we can make Gazelle even better for everyone.
