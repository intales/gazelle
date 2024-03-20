import 'dart:io';

import 'gazelle_hooks.dart';
import 'gazelle_http_method.dart';
import 'gazelle_message.dart';
import 'gazelle_trie.dart';

typedef GazelleRouteHandler = Future<GazelleResponse> Function(
  GazelleRequest request,
);

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

class GazelleRouterSearchResult {
  final GazelleRequest request;
  final GazelleRoute route;

  const GazelleRouterSearchResult({
    required this.request,
    required this.route,
  });
}

class GazelleRouter {
  static const _routeSeparator = "/";
  static const _wildcard = ":";

  final GazelleTrie<GazelleRoute> _routes;

  GazelleRouter() : _routes = GazelleTrie<GazelleRoute>(wildcard: _wildcard);

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

  String _routeFromRequest(HttpRequest request) {
    final method = GazelleHttpMethod.fromString(request.method).name;
    final path = request.uri.path;

    return "$method/$path";
  }
}
