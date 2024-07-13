/// Represents a model class to be serialzed by Gazelle.
abstract class GazelleModelType<T> {
  /// Base constructor of a [GazelleModelType].
  const GazelleModelType();

  /// Transforms [value] into a json map.
  Map<String, dynamic> toJson(T value);

  /// Transforms [json] into a [T] model instance.
  T fromJson(Map<String, dynamic> json);
}
