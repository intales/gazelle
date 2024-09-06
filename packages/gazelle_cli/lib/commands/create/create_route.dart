import 'dart:io';

import 'package:dart_style/dart_style.dart';

import '../../commons/entities/http_method.dart';
import '../../commons/entities/project_configuration.dart';
import '../../commons/entities/project_route.dart';
import '../../commons/functions/capitalize_string.dart';
import '../../commons/functions/snake_to_pascal_case.dart';
import '../../commons/functions/uncapitalize_string.dart';
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
  required final String routeName,
  required final ProjectConfiguration projectConfiguration,
}) async {
  final codeRouteName = uncapitalizeString(snakeToPascalCase(routeName));

  final routeDirectory =
      "${projectConfiguration.path}/server/lib/routes/$routeName";

  final projectRoute = ProjectRoute(
    path: routeDirectory,
    name: capitalizeString(codeRouteName),
    methods: [],
  );

  final handler = await createHandler(
    route: projectRoute,
    httpMethod: HttpMethod.get,
  );

  final handlerImportDirectivePath =
      handler.handlerFilePath.replaceAll(routeDirectory, "").substring(1);

  final route = """
import 'package:gazelle_core/gazelle_core.dart';
import '$handlerImportDirectivePath';

final $codeRouteName = GazelleRoute(
  name: "$routeName",
).get(${uncapitalizeString(handler.handlerName)});
  """
      .trim();

  final routeFileName = "$routeDirectory/$routeName.dart";
  final routeFile = await File(routeFileName)
      .create(recursive: true)
      .then((file) => file.writeAsString(DartFormatter().format(route)));

  return CreateRouteResult(
    routeFilePath: routeFile.path,
    routeName: codeRouteName,
  );
}
