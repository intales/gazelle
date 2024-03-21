import 'gazelle_context.dart';

/// Represents a plugin in Gazelle.
///
/// Example usage:
///
/// class MyPlugin extends GazellePlugin {
///   @override
///   Future<void> initialize(GazelleContext context) async {
///     // Plugin initialization logic
///   }
/// }
///
/// final app = GazelleApp();
/// final myPlugin = MyPlugin();
/// await app.registerPlugin(myPlugin);// Plugins can be registered with a [GazelleApp] to extend its functionality.
abstract class GazellePlugin {
  const GazellePlugin();

  /// Initializes the plugin with the provided [context].
  Future<void> initialize(GazelleContext context);
}
