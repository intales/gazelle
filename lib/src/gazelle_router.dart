import 'dart:io';

import 'package:gazelle/src/gazelle_context.dart';

typedef GazelleRouteHandler = void Function(
  GazelleContext context,
  HttpRequest request,
);

class GazelleRouter {
  static const _routeSeparator = "/";

  Trie<GazelleRouteHandler> routes = Trie<GazelleRouteHandler>();

  void insertHandler(String route, GazelleRouteHandler handler) =>
      routes.insert(route.split(_routeSeparator), handler);

  GazelleRouteHandler? searchHandler(String route) =>
      routes.search(route.split(_routeSeparator));
}

class TrieNode<T> {
  Map<String, TrieNode<T>> children = {};
  T? value;
}

class Trie<T> {
  TrieNode<T> root = TrieNode<T>();

  void insert(List<String> strings, T value) {
    TrieNode<T> current = root;

    for (final string in strings) {
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
      if (!current.children.containsKey(string)) {
        return null;
      }
      current = current.children[string]!;
    }

    return current.value;
  }
}
