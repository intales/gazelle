import 'gazelle_is_primitive.dart';
import 'gazelle_model_provider.dart';

/// De-serializes [jsonObject] into a [T] instance.
T deserialize<T>({
  required dynamic jsonObject,
  GazelleModelProvider? modelProvider,
}) {
  if (isPrimitive(jsonObject)) return _deserializePrimitive(jsonObject) as T;

  if (modelProvider == null) {
    return jsonObject as T;
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
      .map((e) => e is List
          ? deserializeList<T>(
              list: list,
              modelProvider: modelProvider,
            )
          : deserialize<T>(
              jsonObject: e,
              modelProvider: modelProvider,
            ))
      .whereType<T>()
      .toList();

  return result;
}

dynamic _deserializePrimitive(dynamic primitive) {
  if (primitive is String) return DateTime.tryParse(primitive) ?? primitive;
  return primitive;
}
