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

typedef GazelleRouteHandler = Future<GazelleRouteHandlerResult> Function(
  GazelleContext context,
  HttpRequest request,
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

class GazelleRouter {
  static const _routeSeparator = "/";

  Trie<GazelleRouteHandler> routes = Trie<GazelleRouteHandler>();

  void get(String route, GazelleRouteHandler handler) =>
      insertHandler(GazelleHttpMethod.get, route, handler);

  void post(String route, GazelleRouteHandler handler) =>
      insertHandler(GazelleHttpMethod.post, route, handler);

  void put(String route, GazelleRouteHandler handler) =>
      insertHandler(GazelleHttpMethod.put, route, handler);

  void patch(String route, GazelleRouteHandler handler) =>
      insertHandler(GazelleHttpMethod.patch, route, handler);

  void delete(String route, GazelleRouteHandler handler) =>
      insertHandler(GazelleHttpMethod.delete, route, handler);

  void insertHandler(
    GazelleHttpMethod method,
    String route,
    GazelleRouteHandler handler,
  ) =>
      routes.insert("${method.name}/$route".split(_routeSeparator), handler);

  GazelleRouteHandler? searchHandler(String route) =>
      routes.search(route.split(_routeSeparator));
}

class TrieNode<T> {
  Map<String, TrieNode<T>> children = {};
  T? value;
}

class Trie<T> {
  static const wildcard = ":";

  TrieNode<T> root = TrieNode<T>();

  void insert(List<String> strings, T value) {
    TrieNode<T> current = root;

    for (final string in strings) {
      if (string.startsWith(wildcard)) {
        if (!current.children.containsKey(wildcard)) {
          current.children[wildcard] = TrieNode<T>();
        }
        current = current.children[wildcard]!;
        continue;
      }

      if (!current.children.containsKey(string)) {
        current.children[string] = TrieNode<T>();
      }
      current = current.children[string]!;
    }

    current.value = value;
  }

  T? search(List<String> strings) {
    TrieNode<T> current = root;
    for (final string in strings) {
      if (current.children.containsKey(string)) {
        current = current.children[string]!;
      } else if (current.children.containsKey(wildcard)) {
        current = current.children[wildcard]!;
      } else {
        return null;
      }
    }

    return current.value;
  }
}
