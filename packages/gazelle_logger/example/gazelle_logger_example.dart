import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_logger/gazelle_logger.dart';

void main() async {
  final app = GazelleApp(
    routes: [
      GazelleRoute(
        name: "hello_gazelle",
        getHandler: (context, request, resonse) async => resonse.copyWith(
          statusCode: 200,
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
    plugins: {
      GazelleLoggerPlugin(),
    },
  );

  await app.start();
  print(app.serverAddress);
}
