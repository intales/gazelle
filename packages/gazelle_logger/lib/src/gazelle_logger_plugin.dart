import 'package:gazelle_core/gazelle_core.dart';
import 'package:logger/logger.dart';

class GazelleLoggerPlugin implements GazellePlugin {
  late final Logger _logger;

  @override
  Future<void> initialize(GazelleContext context) async {
    _logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        lineLength: 80,
        printTime: true,
        noBoxingByDefault: true,
      ),
    );
  }

  GazellePreRequestHook get logRequestHook => GazellePreRequestHook(
        (request, response) async {
          final route = request.uri.path;
          final headers = request.headers.entries
              .map((e) => "${e.key}:${e.value}")
              .join("\n");
          final pathParameters = request.pathParameters.entries
              .map((e) => "${e.key}:${e.value}")
              .join("\n");
          final queryParameters = request.uri.queryParameters.entries
              .map((e) => "${e.key}:${e.value}")
              .join("\n");

          String message = "INCOMING REQUEST\n";
          message += "ROUTE: $route\n";
          message += "HEADERS: $headers\n";
          message += "ROUTE PARAMS: $pathParameters\n";
          message += "QUERY PARAMS: $queryParameters";

          _logger.i(message, time: DateTime.now());

          return (request, response);
        },
        shareWithChildRoutes: true,
      );

  GazellePostResponseHook get logResponseHook => GazellePostResponseHook(
        (request, response) async {
          final route = request.uri.path;
          final headers = request.headers.entries
              .map((e) => "${e.key}:${e.value}")
              .join("\n");
          final pathParameters = request.pathParameters.entries
              .map((e) => "${e.key}:${e.value}")
              .join("\n");
          final queryParameters = request.uri.queryParameters.entries
              .map((e) => "${e.key}:${e.value}")
              .join("\n");

          String message = "OUTGOING REQUEST\n";
          message += "ROUTE: $route\n";
          message += "HEADERS: $headers\n";
          message += "ROUTE PARAMS: $pathParameters\n";
          message += "QUERY PARAMS: $queryParameters";

          _logger.i(message, time: DateTime.now());

          return (request, response);
        },
        shareWithChildRoutes: true,
      );
}
