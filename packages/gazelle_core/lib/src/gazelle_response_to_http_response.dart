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

  String body = "";

  // When GazelleResponse.body is a Dart primitive type
  if (_isPrimitive(gazelleResponse.body)) {
    // Simply transform it to a string
    body = gazelleResponse.body.toString();
  }

  // When GazelleResponse.body is a List
  else if (gazelleResponse.body is List) {
    final list = gazelleResponse.body as List;

    // When the list is empty, return an empty json list
    if (list.isEmpty) {
      body = jsonEncode([]);
    } else {
      // Get the type of the items inside the list
      final listItemType = _getTypeOfItemsInList(list);

      // Get the correct model type and serialize every item inside the list
      final modelType = modelProvider.getModelTypeFor(listItemType);
      final items = list.map(modelType.toJson).toList();

      // Encode into a json string
      body = jsonEncode(items);
    }
  }

  // When the body is not a primitive nor a List nor a Map
  else {
    // Get the correct model type
    final modelType =
        modelProvider.getModelTypeFor(gazelleResponse.body.runtimeType);

    // Encode into a json string
    body = jsonEncode(modelType.toJson(gazelleResponse.body));
  }

  httpResponse.write(body);
  httpResponse.close();
}

Type _getTypeOfItemsInList(List list) => list.first.runtimeType;

bool _isPrimitive(dynamic body) =>
    body is String ||
    body is num ||
    body is bool ||
    body is List<String> ||
    body is List<num> ||
    body is List<bool>;
