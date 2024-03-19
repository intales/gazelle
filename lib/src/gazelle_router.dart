import 'dart:io';

import 'package:gazelle/src/gazelle_message.dart';

typedef GazelleRouteHandler = Future<GazelleResponse> Function(
  GazelleRequest request,
);

typedef GazellePreRequestHook = Future<GazelleMessage> Function(
  GazelleRequest request,
);

typedef GazellePostRequestHook = Future<GazelleResponse> Function(
  GazelleResponse response,
);

class GazelleRoute {
  final GazelleRouteHandler handler;
  final List<GazellePreRequestHook> preRequestHooks;
  final List<GazellePostRequestHook> postRequestHooks;

  GazelleRoute(
    this.handler, {
    this.preRequestHooks = const [],
    this.postRequestHooks = const [],
  });
}

class GazelleRouterSearchResult {
  final GazelleRequest request;
  final GazelleRoute route;

  GazelleRouterSearchResult({
    required this.request,
    required this.route,
  });
}

class GazelleRouter {
  static const _routeSeparator = "/";
  static const _wildcard = ":";

  Trie<GazelleRoute> routes = Trie<GazelleRoute>(
    wildcard: _wildcard,
  );

  void get(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostRequestHook> postRequestHooks = const [],
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
    List<GazellePostRequestHook> postRequestHooks = const [],
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
    List<GazellePostRequestHook> postRequestHooks = const [],
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
    List<GazellePostRequestHook> postRequestHooks = const [],
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
    List<GazellePostRequestHook> postRequestHooks = const [],
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
    List<GazellePostRequestHook> postRequestHooks = const [],
  }) =>
      routes.insert(
        "${method.name}/$route".split(_routeSeparator),
        GazelleRoute(
          handler,
          preRequestHooks: preRequestHooks,
          postRequestHooks: postRequestHooks,
        ),
      );

  Future<GazelleRouterSearchResult?> search(HttpRequest request) async {
    final route = _routeFromRequest(request);
    final result = routes.search(route.split(_routeSeparator));

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

class TrieSearchResult<T> {
  final T? value;
  final Map<String, String> wildcardValues;

  TrieSearchResult({
    required this.value,
    this.wildcardValues = const {},
  });
}

class TrieNode<T> {
  Map<String, TrieNode<T>> children = {};
  T? value;

  String? _wildcardName;
  set wildcardName(String name) => _wildcardName = name;
  String get wildcardName =>
      _wildcardName == null ? throw "Wildcard name is null" : _wildcardName!;

  bool get isWildcard => _wildcardName != null;
  bool get hasWildcardChild => children.values.any((e) => e.isWildcard);

  TrieNode<T> get wildcardChild =>
      children.values.singleWhere((e) => e.isWildcard);
}

class Trie<T> {
  final String wildcard;

  TrieNode<T> root = TrieNode<T>();

  Trie({
    required this.wildcard,
  });

  void insert(List<String> strings, T value) {
    TrieNode<T> current = root;

    for (final string in strings) {
      if (string.startsWith(wildcard)) {
        final wildcardName = string.replaceAll(wildcard, "");
        if (!current.children.containsKey(wildcardName)) {
          current.children[wildcardName] = TrieNode<T>();
        }
        current = current.children[wildcardName]!;

        current.wildcardName = wildcardName;
        continue;
      }

      if (!current.children.containsKey(string)) {
        current.children[string] = TrieNode<T>();
      }
      current = current.children[string]!;
    }

    current.value = value;
  }

  TrieSearchResult<T> search(List<String> strings) {
    TrieNode<T> current = root;
    Map<String, String> wildcards = {};

    for (final string in strings) {
      if (current.children.containsKey(string)) {
        current = current.children[string]!;
      } else if (current.hasWildcardChild) {
        current = current.wildcardChild;
        wildcards[current.wildcardName] = string;
      } else {
        return TrieSearchResult(
          value: null,
          wildcardValues: wildcards,
        );
      }
    }

    return TrieSearchResult(
      value: current.value,
      wildcardValues: wildcards,
    );
  }
}
