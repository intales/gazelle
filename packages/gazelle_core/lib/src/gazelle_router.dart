import 'dart:io';

import 'gazelle_hooks.dart';
import 'gazelle_http_method.dart';
import 'gazelle_message.dart';
import 'gazelle_route.dart';
import 'gazelle_trie.dart';

/// Represents the result of a search in the Gazelle router.
///
/// Contains the original request and the matched route.
class GazelleRouterSearchResult {
  /// The request associated with the search result.
  final GazelleRequest request;

  /// The response associated with the search result.
  ///
  /// This response is empty by default, it will be compiled by the user
  /// in a handler function.
  final GazelleResponse response;

  /// The route associated with the search result.
  final GazelleRoute route;

  /// Constructs a GazelleRouterSearchResult instance.
  ///
  /// The [request] parameter represents the request associated with the search result.
  /// The [route] parameter represents the route associated with the search result.
  const GazelleRouterSearchResult({
    required this.request,
    required this.route,
    this.response = const GazelleResponse(statusCode: 204),
  });
}

/// A router for managing Gazelle routes.
///
/// Handles registration and searching of routes based on HTTP methods and paths.
class GazelleRouter {
  static const _routeSeparator = "/";
  static const _wildcard = ":";

  final GazelleTrie<GazelleRoute> _routes;

  /// Constructs a GazelleRouter instance.
  GazelleRouter() : _routes = GazelleTrie<GazelleRoute>(wildcard: _wildcard);

  /// Adds routes to this router.
  void addRoutes(List<GazelleRoute> routes) {
    final route = GazelleRoute(
      name: "",
      children: routes,
    );

    _addRoute(route, []);
  }

  void _addRoute(GazelleRoute route, List<String> parentPath) {
    final currentPath = [...parentPath, route.name];

    void addHandler(GazelleHttpMethod method, GazelleRouteHandler? handler) {
      if (handler == null) return;
      final path = [method.name, ...currentPath];
      _routes.insert(path, route);
    }

    addHandler(GazelleHttpMethod.get, route.getHandler);
    addHandler(GazelleHttpMethod.head, route.headHandler);
    addHandler(GazelleHttpMethod.post, route.postHandler);
    addHandler(GazelleHttpMethod.put, route.putHandler);
    addHandler(GazelleHttpMethod.patch, route.patchHandler);
    addHandler(GazelleHttpMethod.delete, route.deleteHandler);
    addHandler(GazelleHttpMethod.options, route.optionsHandler);

    for (final route in route.children) {
      _addRoute(route, currentPath);
    }
  }

  /// Searches for a route that matches the specified [request].
  ///
  /// Returns a [GazelleRouterSearchResult] if a match is found, otherwise returns `null`.
  GazelleRouterSearchResult? search(HttpRequest request) {
    final route = _routeFromRequest(request);
    final result = _routes.search(route.split(_routeSeparator));

    if (result.value == null) return null;

    List<GazellePreRequestHook> preRequestsHooks = [
      ...result.value!.preRequestHooks
    ];
    List<GazellePostResponseHook> postResponseHooks = [
      ...result.value!.postResponseHooks
    ];

    GazelleTrieNode<GazelleRoute>? currentNode = result.node?.parent;
    while (currentNode != null) {
      preRequestsHooks.addAll(currentNode.value?.preRequestHooks
              .where((hook) => hook.shareWithChildRoutes) ??
          []);
      postResponseHooks.addAll(currentNode.value?.postResponseHooks
              .where((hook) => hook.shareWithChildRoutes) ??
          []);

      currentNode = currentNode.parent;
    }

    return GazelleRouterSearchResult(
      request: GazelleRequest.fromHttpRequest(
        request,
        pathParameters: result.wildcardValues,
      ),
      route: result.value!.copyWith(
        preRequestHooks: preRequestsHooks.reversed.toList(),
        postResponseHooks: postResponseHooks.reversed.toList(),
      ),
    );
  }

  /// Extracts the route from the specified [request].
  String _routeFromRequest(HttpRequest request) {
    final method = GazelleHttpMethod.fromString(request.method).name;
    final path = request.uri.path;

    return "$method/$path";
  }
}
