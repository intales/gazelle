part of 'gazelle_context.dart';

abstract class GazellePlugin {
  const GazellePlugin();

  Future<void> initialize(GazelleContext context);
}
