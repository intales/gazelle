import 'dart:convert';
import 'dart:io';

import 'gazelle_http_method.dart';

/// Represents a message exchanged between the client and the server in Gazelle.
///
/// This class serves as the base class for both [GazelleRequest] and [GazelleResponse].
abstract class GazelleMessage {
  /// The headers of the message.
  final Map<String, List<String>> headers;

  /// The body of the message.
  final String? body;

  const GazelleMessage({
    this.headers = const {},
    this.body,
  });
}

/// Represents an HTTP request in Gazelle.
///
/// Encapsulates information about the HTTP request including the URI, method,
/// path parameters, headers, and body.
class GazelleRequest extends GazelleMessage {
  /// The URI of the request.
  final Uri uri;

  /// The HTTP method of the request.
  final GazelleHttpMethod method;

  /// The path parameters extracted from the request URI.
  final Map<String, String> pathParameters;

  const GazelleRequest({
    required this.uri,
    required this.method,
    required this.pathParameters,
    Map<String, List<String>> headers = const {},
    String? body,
  }) : super(headers: headers, body: body);

  /// Constructs a [GazelleRequest] instance from an [HttpRequest].
  ///
  /// Optionally accepts a map of path parameters.
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

  /// Creates a copy of this [GazelleRequest] with the specified attributes overridden.
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

/// Represents an HTTP response in Gazelle.
///
/// Encapsulates information about the HTTP response including the status code,
/// headers, and body.
class GazelleResponse extends GazelleMessage {
  /// The HTTP status code of the response.
  final int statusCode;

  const GazelleResponse({
    required this.statusCode,
    Map<String, List<String>> headers = const {},
    String? body,
  }) : super(headers: headers, body: body);

  /// Writes this [GazelleResponse] to an [HttpResponse].
  void toHttpResponse(HttpResponse response) => response
    ..statusCode = statusCode
    ..write(body)
    ..close();

  /// Creates a copy of this [GazelleResponse] with the specified attributes overridden.
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
