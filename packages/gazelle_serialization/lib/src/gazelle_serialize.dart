import 'gazelle_is_primitive.dart';
import 'gazelle_model_provider.dart';

/// Convert [object] into a json serializable object.
dynamic serialize({
  required dynamic object,
  GazelleModelProvider? modelProvider,
}) {
  if (isPrimitive(object)) return _serializePrimitive(object);

  if (object is List) {
    return object.isNotEmpty
        ? object
            .map((e) => serialize(object: e, modelProvider: modelProvider))
            .toList()
        : [];
  }

  if (modelProvider == null) {
    return object.toString();
  }

  final modelType = modelProvider.getModelTypeFor(object.runtimeType);
  return modelType.toJson(object);
}

dynamic _serializePrimitive(dynamic primitive) {
  if (primitive is DateTime) {
    return primitive.toIso8601String();
  }

  return primitive;
}
