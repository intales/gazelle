import 'dart:convert';
import 'dart:io';

import 'package:gazelle_serialization/gazelle_serialization.dart';

import 'gazelle_message.dart';

/// Transforms a [GazelleResponse] to a [HttpResponse].
void gazelleResponseToHttpResponse({
  required GazelleResponse gazelleResponse,
  required HttpResponse httpResponse,
  GazelleModelProvider? modelProvider,
}) {
  httpResponse.statusCode = gazelleResponse.statusCode.code;

  for (final header in gazelleResponse.headers.toSet()) {
    httpResponse.headers.add(header.header, header.values);
  }

  if (gazelleResponse.body == null) {
    httpResponse.close();
    return;
  }

  final body = serialize(
    object: gazelleResponse.body,
    modelProvider: modelProvider,
  );
  dynamic httpBody;

  if (body is Map || body is List) {
    httpResponse.headers.add(HttpHeaders.contentTypeHeader.toString(),
        [ContentType.json.toString()]);
    httpBody = jsonEncode(body);
  } else {
    httpResponse.headers.add(HttpHeaders.contentTypeHeader.toString(),
        [ContentType.text.toString()]);
    httpBody = body;
  }

  httpResponse.write(httpBody);
  httpResponse.close();
}
