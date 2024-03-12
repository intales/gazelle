import 'dart:io';

import 'package:gazelle/src/gazelle_context.dart';

class GazelleRouteHandlerResult {
  final int statusCode;
  final String response;

  GazelleRouteHandlerResult({
    required this.statusCode,
    required this.response,
  });
}

class GazelleHttpRequest {
  final HttpRequest httpRequest;
  final Map<String, String> pathParams;

  GazelleHttpRequest({
    required this.httpRequest,
    this.pathParams = const {},
  });
}

typedef GazelleRouteHandler = Future<GazelleRouteHandlerResult> Function(
  GazelleContext context,
  GazelleHttpRequest request,
);

enum GazelleHttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  static GazelleHttpMethod fromString(String method) => switch (method) {
        "GET" => GazelleHttpMethod.get,
        "POST" => GazelleHttpMethod.post,
        "PUT" => GazelleHttpMethod.put,
        "PATCH" => GazelleHttpMethod.patch,
        "DELETE" => GazelleHttpMethod.delete,
        _ => throw "Unexpected method: $method",
      };

  String get name => switch (this) {
        GazelleHttpMethod.get => "GET",
        GazelleHttpMethod.post => "POST",
        GazelleHttpMethod.put => "PUT",
        GazelleHttpMethod.patch => "PATCH",
        GazelleHttpMethod.delete => "DELETE",
      };
}

class GazelleRouterSearchResult {
  final GazelleHttpRequest request;
  final GazelleRouteHandler? handler;

  GazelleRouterSearchResult({
    required this.request,
    this.handler,
  });
}

class GazelleRouter {
  static const _routeSeparator = "/";
  static const _wildcard = ":";

  Trie<GazelleRouteHandler> routes = Trie<GazelleRouteHandler>(
    wildcard: _wildcard,
  );

  void get(String route, GazelleRouteHandler handler) =>
      insert(GazelleHttpMethod.get, route, handler);

  void post(String route, GazelleRouteHandler handler) =>
      insert(GazelleHttpMethod.post, route, handler);

  void put(String route, GazelleRouteHandler handler) =>
      insert(GazelleHttpMethod.put, route, handler);

  void patch(String route, GazelleRouteHandler handler) =>
      insert(GazelleHttpMethod.patch, route, handler);

  void delete(String route, GazelleRouteHandler handler) =>
      insert(GazelleHttpMethod.delete, route, handler);

  void insert(
    GazelleHttpMethod method,
    String route,
    GazelleRouteHandler handler,
  ) =>
      routes.insert("${method.name}/$route".split(_routeSeparator), handler);

  GazelleRouterSearchResult search(HttpRequest request) {
    final route = _routeFromRequest(request);
    final result = routes.search(route.split(_routeSeparator));

    return GazelleRouterSearchResult(
      request: GazelleHttpRequest(
        httpRequest: request,
        pathParams: result.wildcardValues,
      ),
      handler: result.value,
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
