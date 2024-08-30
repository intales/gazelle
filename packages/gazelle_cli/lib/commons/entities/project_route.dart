import 'http_method.dart';

/// Defines a route inside a Gazelle project.
class ProjectRoute {
  /// The path of the route.
  final String path;

  /// The name of the route.
  final String name;

  /// Methods for this route.
  final List<HttpMethod> methods;

  /// Builds a [ProjectRoute].
  const ProjectRoute({
    required this.path,
    required this.name,
    required this.methods,
  });
}
