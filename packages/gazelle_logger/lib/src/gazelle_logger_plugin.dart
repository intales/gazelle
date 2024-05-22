import 'package:gazelle_core/gazelle_core.dart';
import 'package:logger/logger.dart';

/// A plugin for easy logging in Gazelle applications.
///
/// The [GazelleLoggerPlugin] class provides functionality for logging inside handlers
/// and standard hooks for request and response logging.
class GazelleLoggerPlugin implements GazellePlugin {
  /// The internal logger instance used for logging messages.
  late final Logger _logger;

  /// The desired output for logs.
  ///
  /// When set to null, default output is [ConsoleOutput].
  final LogOutput? _logOutput;

  /// Creates a [GazelleLoggerPlugin] instance.
  GazelleLoggerPlugin({LogOutput? logOutput}) : _logOutput = logOutput;

  /// Initializes the plugin and creates a logger instance.
  @override
  Future<void> initialize(GazelleContext context) async {
    _logger = Logger(
      output: _logOutput,
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        lineLength: 80,
        printTime: true,
        noBoxingByDefault: true,
      ),
    );
  }

  /// Logs a message with the 'info' level.
  void info(String message) => _logger.i(message, time: DateTime.now());

  /// Logs a message with the 'debug' level.
  void debug(String message) => _logger.d(message, time: DateTime.now());

  /// Logs a message with the 'warning' level.
  void warning(String message) => _logger.w(message, time: DateTime.now());

  /// Logs a message with the 'fatal' level.
  void fatal(String message) => _logger.f(message, time: DateTime.now());

  /// Provides a GazellePreRequestHook that logs details of incoming requests.
  GazellePreRequestHook get logRequestHook => GazellePreRequestHook(
        (context, request, response) async {
          final method = request.method.name;
          final route = request.uri.path;
          final headers = request.headers.entries
              .map((e) => "\t${e.key}:${e.value}")
              .join("\n");
          final pathParameters = request.pathParameters.entries
              .map((e) => "\t${e.key}:${e.value}")
              .join("\n");
          final queryParameters = request.uri.queryParameters.entries
              .map((e) => "\t${e.key}:${e.value}")
              .join("\n");

          String message = "INCOMING REQUEST\n";
          message += "METHOD: $method\n";
          message += "ROUTE: $route\n";
          if (headers.isNotEmpty) message += "HEADERS:\n$headers";
          if (pathParameters.isNotEmpty) {
            message += "\nROUTE PARAMS:\n$pathParameters";
          }
          if (queryParameters.isNotEmpty) {
            message += "\nQUERY PARAMS:\n$queryParameters";
          }

          info(message);

          return (request, response);
        },
        shareWithChildRoutes: true,
      );

  /// Provides a GazellePostResponseHook that logs details of outgoing responses.
  GazellePostResponseHook get logResponseHook => GazellePostResponseHook(
        (context, request, response) async {
          final method = request.method.name;
          final route = request.uri.path;
          final headers = response.headers.entries
              .map((e) => "${e.key}:${e.value}")
              .join("\n");
          final statusCode = response.statusCode;
          final body = response.body;

          String message = "OUTGOING RESPONSE\n";
          message += "METHOD: $method\n";
          message += "ROUTE: $route\n";
          if (headers.isNotEmpty) message += "HEADERS:\n$headers\n";
          message += "STATUS CODE: $statusCode";
          if (body?.isNotEmpty == true) message += "\nBODY: $body";

          if (statusCode.code >= 200 && statusCode.code <= 299) {
            info(message);
          } else if (statusCode.code >= 300 && statusCode.code <= 399) {
            info(message);
          } else if (statusCode.code >= 400 && statusCode.code <= 499) {
            warning(message);
          } else if (statusCode.code <= 500 && statusCode.code <= 599) {
            fatal(message);
          }

          return (request, response);
        },
        shareWithChildRoutes: true,
      );
}
