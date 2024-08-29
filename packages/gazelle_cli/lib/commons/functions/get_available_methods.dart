import '../entities/http_method.dart';
import '../entities/project_route.dart';

/// Returns the available methods for the given [route].
List<HttpMethod> getAvailableMethods(final ProjectRoute route) =>
    HttpMethod.values.toSet().difference(route.methods.toSet()).toList();
