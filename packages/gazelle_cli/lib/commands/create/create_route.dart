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
  codeRouteName += "Route";

  final routeDirectory = "$path/routes/${routeName}_route";
  final handlerPath = "$routeDirectory/handlers";
  final handler = await createHandler(
    routeName: routeName,
    httpMethod: "GET",
    path: handlerPath,
  );

  final handlerImportDirectivePath =
      handler.handlerFilePath.replaceAll(routeDirectory, "").substring(1);

  final route = """
import 'package:gazelle_core/gazelle_core.dart';
import '$handlerImportDirectivePath';

const $codeRouteName = GazelleRoute(
  name: "$routeName",
  get: GazelleRouteHandler(${handler.handlerName}),
);
  """
      .trim();

  final routeFileName = "$routeDirectory/${routeName}_route.dart";
  final routeFile = await File(routeFileName)
      .create(recursive: true)
      .then((file) => file.writeAsString(DartFormatter().format(route)));

  return CreateRouteResult(
    routeFilePath: routeFile.path,
    routeName: codeRouteName,
  );
}
