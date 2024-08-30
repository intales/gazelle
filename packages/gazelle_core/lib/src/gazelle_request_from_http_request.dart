import 'dart:convert';
import 'dart:io';

import 'package:gazelle_serialization/gazelle_serialization.dart';

import 'gazelle_http_header.dart';
import 'gazelle_http_method.dart';
import 'gazelle_message.dart';

/// Creates a [GazelleRequest] from the given [httpRequest].
GazelleRequest<T> gazelleRequestFromHttpRequest<T>({
  required final HttpRequest httpRequest,
  required final GazelleModelProvider? modelProvider,
  final Map<String, String> pathParameters = const {},
}) {
  final headers = <GazelleHttpHeader>[];
  httpRequest.headers.forEach((key, value) =>
      headers.add(GazelleHttpHeader.fromString(key, values: value)));

  final body = utf8.decodeStream(httpRequest).then((body) {
    late final dynamic jsonObject;
    try {
      jsonObject = jsonDecode(body);
    } on FormatException {
      // Request body is not a json.
      jsonObject = body;
    }

    return deserialize<T>(
      jsonObject: jsonObject,
      modelProvider: modelProvider,
    );
  });

  return GazelleRequest<T>(
    uri: httpRequest.uri,
    method: GazelleHttpMethod.fromString(httpRequest.method),
    pathParameters: pathParameters,
    headers: headers,
    body: body,
  );
}
