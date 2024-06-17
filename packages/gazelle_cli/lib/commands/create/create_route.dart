import 'dart:io';

import 'package:dart_style/dart_style.dart';

import 'create_handler.dart';

/// Represents the result of [createRoute] function.
class CreateRouteResult {
  /// The path of the created route file.
  final String routeFilePath;

  /// The name of the created route.
  final String routeName;

  /// Creates a [CreateRouteResult].
  const CreateRouteResult({
    required this.routeFilePath,
    required this.routeName,
  });
}

/// Creates a route for a Gazelle project.
Future<CreateRouteResult> createRoute({
  required String routeName,
  required String path,
}) async {
  final routeNameParts = routeName.split("_");

  String codeRouteName = "";
  for (var i = 0; i < routeNameParts.length; i++) {
    final part = routeNameParts[i];
    if (i == 0) {
      codeRouteName += part.toLowerCase();
      continue;
    }
    codeRouteName += "${part[0].toUpperCase()}${part.substring(1)}";
  }

  final handlerPath = "$path/handlers";
  final handler = await createHandler(
    routeName: routeName,
    httpMethod: "GET",
    path: handlerPath,
  );

  final handlerImportDirectivePath =
      handler.handlerFilePath.replaceAll(path, "").substring(1);

  final route = """
import 'package:gazelle_core/gazelle_core.dart';
import '$handlerImportDirectivePath';

final ${codeRouteName}Route = GazelleRoute(
  name: $routeName,
  get: ${handler.handlerName},
);
  """
      .trim();

  final routeFileName = "$path/$routeName.dart";
  final routeFile = await File(routeFileName)
      .create(recursive: true)
      .then((file) => file.writeAsString(DartFormatter().format(route)));

  return CreateRouteResult(
    routeFilePath: routeFile.path,
    routeName: routeName,
  );
}
