import 'dart:io';

import 'package:gazelle_serialization/gazelle_serialization.dart';

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

  /// The model provider.
  final GazelleModelProvider? modelProvider;

  /// Creates a new instance of [GazelleContext].
  ///
  /// The [router] parameter specifies the router to use for route registration and searching.
  /// The [plugins] parameter contains a map of registered plugins.
  /// The optional [context] parameter points to the parent context, if any.
  // coverage-ignore: end
  const GazelleContext({
    required GazelleRouter router,
    required Map<Type, GazellePlugin> plugins,
    this.modelProvider,
    GazelleContext? context,
  })  : _router = router,
        _context = context,
        _plugins = plugins;

  /// Creates a new instance of [GazelleContext] with an empty router and plugin map.
  ///
  /// This static method is a convenience constructor for creating a new [GazelleContext] instance.
  static GazelleContext create({
    GazelleModelProvider? modelProvider,
  }) =>
      GazelleContext(
        router: GazelleRouter(),
        modelProvider: modelProvider,
        plugins: {},
      );

  /// Adds routes to the router.
  void addRoutes(List<GazelleRoute> routes) => _router.addRoutes(routes, this);

  /// Exports the routes structure.
  Map<String, dynamic> get routesStructure => _router.routesStructure;

  /// Searches for a route that matches the provided HTTP request.
  ///
  /// Returns the search result if a matching route is found, or null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final context = GazelleContext.create();
  /// final result = context.searchRoute(httpRequest);
  /// ```
  GazelleRouterSearchResult? searchRoute(HttpRequest request) =>
      _router.search(request);

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

  /// Registers a set of plugins.
  Future<void> registerPlugins(Set<GazellePlugin> plugins) async {
    for (final plugin in plugins) {
      await register(plugin);
    }
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
  Future<void> register(GazellePlugin plugin) async {
    final newContext = GazelleContext(
      router: _router,
      plugins: {plugin.runtimeType: plugin},
      context: this,
    );

    await newContext._plugins[plugin.runtimeType]!.initialize(newContext);
    _plugins[plugin.runtimeType] = plugin;
  }
}
