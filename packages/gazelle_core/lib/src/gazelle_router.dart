import 'dart:io';

import 'gazelle_context.dart';
import 'gazelle_hooks.dart';
import 'gazelle_message.dart';
import 'gazelle_route.dart';
import 'gazelle_router_item.dart';
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
  final GazelleRouterItem route;

  /// Constructs a GazelleRouterSearchResult instance.
  ///
  /// The [request] parameter represents the request associated with the search result.
  /// The [route] parameter represents the route associated with the search result.
  const GazelleRouterSearchResult({
    required this.request,
    required this.route,
    this.response = const GazelleResponse(),
  });
}

/// A router for managing Gazelle routes.
///
/// Handles registration and searching of routes based on HTTP methods and paths.
class GazelleRouter {
  static const _routeSeparator = "/";
  static const _whitespace = " ";

  /// The wildcard character used to identify param-routes.
  static const wildcard = ":";

  final GazelleTrie<GazelleRouterItem> _routes;

  /// Constructs a GazelleRouter instance.
  GazelleRouter()
      : _routes = GazelleTrie<GazelleRouterItem>(wildcard: wildcard);

  /// Adds routes to this router.
  void addRoutes(
    List<GazelleRoute> routes,
    GazelleContext context,
  ) {
    final route = GazelleRoute(
      name: "",
      children: routes,
    );

    _addRoute(route, [], context);
  }

  void _addRoute(
    GazelleRoute route,
    List<String> parentPath,
    GazelleContext context,
  ) {
    if (route.name.contains(_whitespace)) {
      throw RouterWhitespaceExcpetion(route.name);
    }

    List<String> path = [...parentPath, route.name];
    final routerItem = GazelleRouterItem(
      context: context,
      name: route.name,
      get: route.get,
      post: route.post,
      put: route.put,
      patch: route.patch,
      delete: route.delete,
      preRequestHooks: route.preRequestHooks != null
          ? route.preRequestHooks!(context)
          : const [],
      postResponseHooks: route.postResponseHooks != null
          ? route.postResponseHooks!(context)
          : const [],
    );

    _routes.insert(path, routerItem);

    for (final route in route.children) {
      _addRoute(route, path, context);
    }
  }

  /// Searches for a route that matches the specified [request].
  ///
  /// Returns a [GazelleRouterSearchResult] if a match is found, otherwise returns `null`.
  GazelleRouterSearchResult? search(HttpRequest request) {
    final route = request.uri.path;
    final result = _routes.search(route.split(_routeSeparator));

    if (result.value == null) return null;

    List<GazellePreRequestHook> preRequestsHooks = [
      ...result.value!.preRequestHooks
    ];
    List<GazellePostResponseHook> postResponseHooks = [
      ...result.value!.postResponseHooks
    ];

    GazelleTrieNode<GazelleRouterItem>? currentNode = result.node?.parent;
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
}

/// Router exception thrown when a route contains whitespaces.
class RouterWhitespaceExcpetion implements Exception {
  /// Exception message.
  final String message;

  /// Builds a [RouterWhitespaceExcpetion].
  const RouterWhitespaceExcpetion(String route)
      : message = "$route contains whitespaces.";

  @override
  String toString() => message;
}
