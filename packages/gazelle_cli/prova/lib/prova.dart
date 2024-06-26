import 'package:gazelle_core/gazelle_core.dart';
import 'routes/hello_gazelle_route/hello_gazelle_route.dart';

Future<void> runApp(List<String> args) async {
  final app = GazelleApp(
    routes: [
      helloGazelleRoute,
    ],
  );

  await app.start();
  print("Gazelle listening at ${app.serverAddress}");
}
