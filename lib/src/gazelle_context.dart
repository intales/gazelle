import 'gazelle_plugin.dart';
import 'gazelle_router.dart';

class GazelleContext {
  final GazelleRouter router;
  final Map<Type, GazellePlugin> _plugins;
  final GazelleContext? _context;

  GazelleContext({
    required this.router,
    required Map<Type, GazellePlugin> plugins,
    GazelleContext? context,
  })  : _context = context,
        _plugins = plugins;

  static GazelleContext create() => GazelleContext(
        router: GazelleRouter(),
        plugins: {},
      );

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
