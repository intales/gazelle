import 'dart:convert';
import 'dart:io';

import 'gazelle_message.dart';
import 'gazelle_model_provider.dart';

/// Transforms a [GazelleResponse] to a [HttpResponse].
void gazelleResponseToHttpResponse({
  required GazelleResponse gazelleResponse,
  required HttpResponse httpResponse,
  required GazelleModelProvider modelProvider,
}) {
  httpResponse.statusCode = gazelleResponse.statusCode.code;

  for (final header in gazelleResponse.headers.toSet()) {
    httpResponse.headers.add(header.header, header.values);
  }

  if (gazelleResponse.body == null) {
    httpResponse.close();
    return;
  }

  final body = _serialize(gazelleResponse.body, modelProvider);
  final json = jsonEncode(body);

  httpResponse.write(json);
  httpResponse.close();
}

dynamic _serialize(
  dynamic object,
  GazelleModelProvider modelProvider,
) {
  // When GazelleResponse.body is a Dart primitive type
  if (_isPrimitive(object)) {
    // Simply transform it to a string
    return object;
  }

  // When GazelleResponse.body is a List
  else if (object is List) {
    final list = object;

    // When the list is empty, return an empty json list
    if (list.isEmpty) {
      return [];
    } else {
      // Get the correct model type and serialize every item inside the list
      final items =
          list.map((item) => _serialize(item, modelProvider)).toList();

      return items;
    }
  }

  // Whene the body is a Map
  else if (object is Map) {
    final map = object;
    final jsonMap = {};

    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      final jsonKey = _serialize(key, modelProvider);
      final jsonValue = _serialize(value, modelProvider);
      jsonMap[jsonKey.toString()] = jsonValue;
    }

    return jsonMap;
  }

  // When the body is not a primitive nor a List nor a Map
  else {
    // Get the correct model type
    final modelType = modelProvider.getModelTypeFor(object.runtimeType);

    // Encode into a json string
    return modelType.toJson(object);
  }
}

bool _isPrimitive(dynamic body) =>
    body is String ||
    body is num ||
    body is bool ||
    body is List<String> ||
    body is List<num> ||
    body is List<bool>;
