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

  /// Exports the router structure.
  ///
  /// This method is used primarily by the CLI to generate
  /// a client class that can be used by other Dart applications
  /// like Flutter apps.
  Map<String, dynamic> get routesStructure => _exportNode(_routes.root);

  Map<String, dynamic> _exportNode(GazelleTrieNode<GazelleRouterItem> node) {
    if (node.name.isEmpty && node.children.length == 1 && node.value == null) {
      return _exportNode(node.children.values.first);
    }

    final Map<String, dynamic> result = {
      'name': "${node.isWildcard ? ":" : ""}${node.name}",
      'methods': {},
      'children': {},
    };

    final Map<String, dynamic> methods = {};
    if (node.value != null) {
      if (node.value!.get != null) {
        methods['get'] = {
          'returnType': node.value!.get!.responseType.toString(),
        };
      }
      if (node.value!.post != null) {
        methods['post'] = {
          'requestType': node.value!.post!.requestType.toString(),
          'returnType': node.value!.post!.responseType.toString(),
        };
      }
      if (node.value!.put != null) {
        methods['put'] = {
          'requestType': node.value!.put!.requestType.toString(),
          'returnType': node.value!.put!.responseType.toString(),
        };
      }
      if (node.value!.patch != null) {
        methods['patch'] = {
          'requestType': node.value!.patch!.requestType.toString(),
          'returnType': node.value!.patch!.responseType.toString(),
        };
      }
      if (node.value!.delete != null) {
        methods['delete'] = {
          'requestType': node.value!.delete!.requestType.toString(),
          'returnType': node.value!.delete!.responseType.toString(),
        };
      }
    }

    result['methods'] = methods;

    for (var child in node.children.values) {
      result['children'][child.name] = _exportNode(child);
    }

    return result;
  }

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

    final path = [...parentPath, route.name];
    final routerItem = route.toRouterItem(context);

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
