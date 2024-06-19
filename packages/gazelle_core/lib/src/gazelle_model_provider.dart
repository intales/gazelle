import 'gazelle_model_type.dart';

/// Represents a provder of [GazelleModelType]s.
abstract class GazelleModelProvider {
  /// Base constructor of a [GazelleModelProvider].
  const GazelleModelProvider();

  /// [GazelleModelType]s registered in the current [GazelleModelProvider].
  Map<Type, GazelleModelType> get modelTypes;

  /// Returns the [GazelleModelType] associated with [T].
  ///
  /// Throws an [Exception] if no [GazelleModelType] is found.
  GazelleModelType<T> get<T>() {
    final modelType = modelTypes[T];
    if (modelType == null) {
      throw Exception("Unable to find $T model type.");
    }

    return modelType as GazelleModelType<T>;
  }

  /// Returns the [GazelleModelType] associated with [type].
  ///
  /// Throws an [Exception] if no [GazelleModelType] is found.
  GazelleModelType getModelTypeFor(Type type) {
    final modelType = modelTypes[type];
    if (modelType == null) {
      throw Exception("Unable to find $type model type.");
    }

    return modelType;
  }
}
