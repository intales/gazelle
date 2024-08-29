import 'dart:io';

import 'package:path/path.dart' as path;
import '../entities/http_method.dart';
import '../entities/project_configuration.dart';
import '../entities/project_route.dart';
import 'get_server_path.dart';
import 'snake_to_pascal_case.dart';

/// Return the routes for the given [projectConfiguration].
Future<List<ProjectRoute>> getProjectRoutes(
  final ProjectConfiguration projectConfiguration,
) async {
  final serverPath = getServerPath(projectConfiguration);
  final routesPath = path.join(serverPath, "lib", "routes");
  final routePaths = await Directory(routesPath)
      .list()
      .toList()
      .then((routes) => routes.map((route) => route.absolute.path).toList());

  final routes = <ProjectRoute>[];
  for (final routePath in routePaths) {
    final route = ProjectRoute(
      path: routePath,
      name: snakeToPascalCase(routePath.split("/").last),
      methods: await _getMethodsForRoute(routePath),
    );

    routes.add(route);
  }

  return routes;
}

Future<List<HttpMethod>> _getMethodsForRoute(final String routePath) async {
  return Directory(routePath).list().toList().then((handlers) => handlers
      .map((handler) => handler.absolute.path)
      .map(_extractHttpMethod)
      .nonNulls
      .toList());
}

HttpMethod? _extractHttpMethod(final String handlerPath) {
  final regex = RegExp(
    r'_(get|post|put|delete|patch)',
    caseSensitive: false,
  );

  final match = regex.firstMatch(handlerPath)?.group(1)?.toUpperCase();

  return switch (match) {
    "GET" => HttpMethod.get,
    "POST" => HttpMethod.post,
    "PUT" => HttpMethod.put,
    "PATCH" => HttpMethod.patch,
    "DELETE" => HttpMethod.delete,
    _ => null,
  };
}
