import 'gazelle_is_primitive.dart';
import 'gazelle_model_provider.dart';

/// An exception for the [deserialize] function.
class DeserializationException implements Exception {
  /// The error message.
  final String message;

  /// ModelProvider not found error constructor.
  const DeserializationException.modelProviderNotProvided()
      : message = "ModelProvider not provided.";
}

/// De-serializes [jsonObject] into a [T] instance.
T deserialize<T>({
  required dynamic jsonObject,
  GazelleModelProvider? modelProvider,
}) {
  if (isPrimitive(jsonObject)) return _deserializePrimitive(jsonObject) as T;

  if (modelProvider == null) {
    throw const DeserializationException.modelProviderNotProvided();
  }

  final modelType = modelProvider.getModelTypeFor(T);
  return modelType.fromJson(jsonObject) as T;
}

/// De-serializes [list] into a `List` of [T]s.
List<T> deserializeList<T>({
  required List list,
  GazelleModelProvider? modelProvider,
}) {
  if (list.isEmpty) return <T>[];

  final result = list
      .map((e) => deserialize<T>(jsonObject: e, modelProvider: modelProvider))
      .whereType<T>()
      .toList();

  return result;
}

dynamic _deserializePrimitive(dynamic primitive) {
  if (primitive is String) return DateTime.tryParse(primitive) ?? primitive;
  return primitive;
}
