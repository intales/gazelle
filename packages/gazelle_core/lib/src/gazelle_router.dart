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

  /// The route associated with the search result.
  final GazelleRoute route;

  /// Constructs a GazelleRouterSearchResult instance.
  ///
  /// The [request] parameter represents the request associated with the search result.
  /// The [route] parameter represents the route associated with the search result.
  const GazelleRouterSearchResult({
    required this.request,
    required this.route,
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

  /// Registers a GET route with the specified [route], [handler], and optional hooks.
  void get(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postResponseHooks = const [],
  }) =>
      insert(
        GazelleHttpMethod.get,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postResponseHooks: postResponseHooks,
      );

  /// Registers a POST route with the specified [route], [handler], and optional hooks.
  void post(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postResponseHooks = const [],
  }) =>
      insert(
        GazelleHttpMethod.post,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postResponseHooks: postResponseHooks,
      );

  /// Registers a PUT route with the specified [route], [handler], and optional hooks.
  void put(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postResponseHooks = const [],
  }) =>
      insert(
        GazelleHttpMethod.put,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postResponseHooks: postResponseHooks,
      );

  /// Registers a PATCH route with the specified [route], [handler], and optional hooks.
  void patch(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postResponseHooks = const [],
  }) =>
      insert(
        GazelleHttpMethod.patch,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postResponseHooks: postResponseHooks,
      );

  /// Registers a DELETE route with the specified [route], [handler], and optional hooks.
  void delete(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postResponseHooks = const [],
  }) =>
      insert(
        GazelleHttpMethod.delete,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postResponseHooks: postResponseHooks,
      );

  /// Inserts a route with the specified [method], [route], [handler], and optional hooks.
  void insert(
    GazelleHttpMethod method,
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postResponseHooks = const [],
  }) =>
      _routes.insert(
        "${method.name}/$route".split(_routeSeparator),
        GazelleRoute(
          handler,
          preRequestHooks: preRequestHooks,
          postResponseHooks: postResponseHooks,
        ),
      );

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

    GazelleTrieNode<GazelleRoute>? currentNode = result.node;
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
