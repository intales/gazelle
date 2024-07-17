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
