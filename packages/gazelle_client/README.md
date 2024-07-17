# Gazelle Client

A flexible and powerful Dart client for interacting with Gazelle backend APIs.

## Features

- Easy-to-use API client for Gazelle backend applications
- Support for all major HTTP methods (GET, POST, PUT, PATCH, DELETE)
- Built-in error handling with custom exceptions
- Flexible serialization and deserialization of API responses
- Query parameter support for GET requests
- Fluent interface for building API paths

## Getting started

Add `gazelle_client` to your `pubspec.yaml`:

```yaml
dependencies:
  gazelle_client: ^1.0.0
```

Then run `dart pub get` 

## Usage

Here's a simple example of how to use the Gazelle Client:

```dart
import 'package:gazelle_client/gazelle_client.dart';

void main() async {
  final client = GazelleClient.init(
    baseUrl: 'https://api.example.com',
    modelProvider: YourModelProvider(),
  );

  // GET request
  final user = await client.api('users').get<User>(queryParams: {'id': 1});

  // POST request
  final newUser = User(name: 'John Doe', email: 'john@example.com');
  final createdUser = await client.api('users').post<User>(body: newUser);

  // Don't forget to close the client when you're done
  client.api.close();
}
```

## Additional information

For more detailed information on using the Gazelle Client, please refer to our
documentation.

## Error Handling

The client includes built-in error handling. If a request fails, it will throw a
`GazelleApiClientException` with details about the error.

## Custom Model Providers

You need to implement your own `GazelleModelProvider` to handle serialization
and deserialization of your specific models or generate it with the Gazelle CLI.
