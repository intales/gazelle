import 'dart:io';

import 'gazelle_hooks.dart';
import 'gazelle_http_method.dart';
import 'gazelle_plugin.dart';
import 'gazelle_route.dart';
import 'gazelle_router.dart';

/// Manages the context for Gazelle applications, including routing and plugin management.
///
/// The [GazelleContext] class facilitates route registration and searching,
/// as well as plugin management and initialization.
class GazelleContext {
  /// The gazelle router.
  final GazelleRouter _router;

  /// Registered plugins for this context.
  final Map<Type, GazellePlugin> _plugins;

  /// Parent context.
  final GazelleContext? _context;

  /// Creates a new instance of [GazelleContext].
  ///
  /// The [router] parameter specifies the router to use for route registration and searching.
  /// The [plugins] parameter contains a map of registered plugins.
  /// The optional [context] parameter points to the parent context, if any.
  const GazelleContext({
    required GazelleRouter router,
    required Map<Type, GazellePlugin> plugins,
    GazelleContext? context,
  })  : _router = router,
        _context = context,
        _plugins = plugins;

  /// Creates a new instance of [GazelleContext] with an empty router and plugin map.
  ///
  /// This static method is a convenience constructor for creating a new [GazelleContext] instance.
  static GazelleContext create() => GazelleContext(
        router: GazelleRouter(),
        plugins: {},
      );

  /// Inserts a new route with the specified HTTP method, route path, and handler function.
  ///
  /// Additional pre-request and post-response hooks can be provided to customize request handling.
  ///
  /// Example:
  /// ```dart
  /// final context = GazelleContext.create();
  /// context.insertRoute(
  ///   GazelleHttpMethod.GET,
  ///   '/hello',
  ///   (request) async => GazelleResponse(
  ///     statusCode: 200,
  ///     body: 'Hello, world!',
  ///   ),
  ///   preRequestHooks: [myPreRequestHook],
  ///   postRequestHooks: [myPostRequestHook],
  /// );
  /// ```
  void insertRoute(
    GazelleHttpMethod method,
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      _router.insert(
        method,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Searches for a route that matches the provided HTTP request.
  ///
  /// Returns the search result if a matching route is found, or null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final context = GazelleContext.create();
  /// final result = await context.searchRoute(httpRequest);
  /// ```
  Future<GazelleRouterSearchResult?> searchRoute(HttpRequest request) =>
      _router.search(request);

  void get(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      _router.get(
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
      _router.post(
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
      _router.put(
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
      _router.patch(
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
      _router.delete(
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Retrieves a plugin of the specified type from the context.
  ///
  /// Throws an exception if the plugin is not found.
  ///
  /// Example:
  /// ```dart
  /// final context = GazelleContext.create();
  /// final authPlugin = context.getPlugin<AuthenticationPlugin>();
  /// ```
  T getPlugin<T extends GazellePlugin>() {
    final plugin = _plugins[T] as T?;
    if (plugin != null) return plugin;

    if (_context != null) return _context.getPlugin<T>();

    throw Exception('GazelleContext: Unable to find $T plugin!');
  }

  /// Registers a new plugin with the context.
  ///
  /// The plugin is initialized and added to the context's plugin map.
  ///
  /// Example:
  /// ```dart
  /// final context = GazelleContext.create();
  /// final authPlugin = AuthenticationPlugin();
  /// await context.register(authPlugin);
  /// ```
  Future<void> register<T extends GazellePlugin>(T plugin) async {
    final newContext = GazelleContext(
      router: _router,
      plugins: {T: plugin},
      context: this,
    );

    await newContext._plugins[T]!.initialize(newContext);
    _plugins[T] = plugin;
  }
}
