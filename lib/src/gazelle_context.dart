import 'gazelle_http_method.dart';
import 'gazelle_plugin.dart';
import 'gazelle_router.dart';

class GazelleContext {
  final GazelleRouter router;
  final Map<Type, GazellePlugin> _plugins;
  final GazelleContext? _context;

  const GazelleContext({
    required this.router,
    required Map<Type, GazellePlugin> plugins,
    GazelleContext? context,
  })  : _context = context,
        _plugins = plugins;

  static GazelleContext create() => GazelleContext(
        router: GazelleRouter(),
        plugins: {},
      );

  void insertRoute(
    GazelleHttpMethod method,
    String route,
    GazelleRouteHandler handler,
  ) =>
      router.insert(method, route, handler);

  void get(String route, GazelleRouteHandler handler) =>
      router.get(route, handler);

  void post(String route, GazelleRouteHandler handler) =>
      router.post(route, handler);

  void put(String route, GazelleRouteHandler handler) =>
      router.put(route, handler);

  void patch(String route, GazelleRouteHandler handler) =>
      router.patch(route, handler);

  void delete(String route, GazelleRouteHandler handler) =>
      router.delete(route, handler);

  T getPlugin<T extends GazellePlugin>() {
    final plugin = _plugins[T] as T?;
    if (plugin != null) return plugin;

    if (_context != null) return _context.getPlugin<T>();

    throw Exception('GazelleContext: Unable to find $T plugin!');
  }

  Future<void> register<T extends GazellePlugin>(T plugin) async {
    final newContext = GazelleContext(
      router: router,
      plugins: {T: plugin},
      context: this,
    );

    await newContext._plugins[T]!.initialize(newContext);
    _plugins[T] = plugin;
  }
}
