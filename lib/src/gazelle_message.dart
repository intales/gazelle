import 'dart:convert';
import 'dart:io';

import 'gazelle_http_method.dart';

sealed class GazelleMessage {
  final Map<String, List<String>> headers;
  final String? body;

  const GazelleMessage({
    this.headers = const {},
    this.body,
  });
}

class GazelleRequest extends GazelleMessage {
  final Uri uri;
  final GazelleHttpMethod method;
  final Map<String, String> pathParameters;

  const GazelleRequest({
    required this.uri,
    required this.method,
    required this.pathParameters,
    super.headers = const {},
    super.body,
  });

  static Future<GazelleRequest> fromHttpRequest(
    HttpRequest request, {
    Map<String, String> pathParameters = const {},
  }) async {
    final headers = <String, List<String>>{};
    request.headers.forEach((key, value) => headers[key] = value);
    final body = await utf8.decodeStream(request);

    return GazelleRequest(
      uri: request.uri,
      method: GazelleHttpMethod.fromString(request.method),
      pathParameters: pathParameters,
      headers: headers,
      body: body,
    );
  }

  GazelleRequest copyWith({
    Uri? uri,
    GazelleHttpMethod? method,
    Map<String, String>? pathParameters,
    Map<String, List<String>>? headers,
    String? body,
  }) =>
      GazelleRequest(
        uri: uri ?? this.uri,
        method: method ?? this.method,
        pathParameters: pathParameters ?? this.pathParameters,
        headers: headers ?? this.headers,
        body: body ?? this.body,
      );
}

class GazelleResponse extends GazelleMessage {
  final int statusCode;

  const GazelleResponse({
    required this.statusCode,
    super.headers = const {},
    super.body,
  });

  void toHttpResponse(HttpResponse response) => response
    ..statusCode = statusCode
    ..write(body)
    ..close();

  GazelleResponse copyWith({
    int? statusCode,
    Map<String, List<String>>? headers,
    String? body,
  }) =>
      GazelleResponse(
        statusCode: statusCode ?? this.statusCode,
        headers: headers ?? this.headers,
        body: body ?? this.body,
      );
}
