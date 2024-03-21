import 'dart:io';

import 'gazelle_hooks.dart';
import 'gazelle_http_method.dart';
import 'gazelle_message.dart';
import 'gazelle_trie.dart';

/// Represents a handler for a Gazelle route.
///
/// It is a function that takes a [GazelleRequest] as input and returns a [Future] of [GazelleResponse].
typedef GazelleRouteHandler = Future<GazelleResponse> Function(
  GazelleRequest request,
);

/// Represents a route in the Gazelle router.
///
/// Contains a [handler] for processing requests, along with optional pre-request and post-response hooks.
class GazelleRoute {
  final GazelleRouteHandler handler;
  final List<GazellePreRequestHook> preRequestHooks;
  final List<GazellePostResponseHook> postRequestHooks;

  const GazelleRoute(
    this.handler, {
    this.preRequestHooks = const [],
    this.postRequestHooks = const [],
  });
}

/// Represents the result of a search in the Gazelle router.
///
/// Contains the original request and the matched route.
class GazelleRouterSearchResult {
  final GazelleRequest request;
  final GazelleRoute route;

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

  GazelleRouter() : _routes = GazelleTrie<GazelleRoute>(wildcard: _wildcard);

  /// Registers a GET route with the specified [route], [handler], and optional hooks.
  void get(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      insert(
        GazelleHttpMethod.get,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Registers a POST route with the specified [route], [handler], and optional hooks.
  void post(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      insert(
        GazelleHttpMethod.post,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Registers a PUT route with the specified [route], [handler], and optional hooks.
  void put(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      insert(
        GazelleHttpMethod.put,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Registers a PATCH route with the specified [route], [handler], and optional hooks.
  void patch(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      insert(
        GazelleHttpMethod.patch,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Registers a DELETE route with the specified [route], [handler], and optional hooks.
  void delete(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      insert(
        GazelleHttpMethod.delete,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Inserts a route with the specified [method], [route], [handler], and optional hooks.
  void insert(
    GazelleHttpMethod method,
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      _routes.insert(
        "${method.name}/$route".split(_routeSeparator),
        GazelleRoute(
          handler,
          preRequestHooks: preRequestHooks,
          postRequestHooks: postRequestHooks,
        ),
      );

  /// Searches for a route that matches the specified [request].
  ///
  /// Returns a [GazelleRouterSearchResult] if a match is found, otherwise returns `null`.
  Future<GazelleRouterSearchResult?> search(HttpRequest request) async {
    final route = _routeFromRequest(request);
    final result = _routes.search(route.split(_routeSeparator));

    if (result.value == null) return null;

    return GazelleRouterSearchResult(
      request: await GazelleRequest.fromHttpRequest(
        request,
        pathParameters: result.wildcardValues,
      ),
      route: result.value!,
    );
  }

  /// Extracts the route from the specified [request].
  String _routeFromRequest(HttpRequest request) {
    final method = GazelleHttpMethod.fromString(request.method).name;
    final path = request.uri.path;

    return "$method/$path";
  }
}
