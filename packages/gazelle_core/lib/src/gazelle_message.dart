import 'dart:convert';
import 'dart:io';

import 'gazelle_http_header.dart';
import 'gazelle_http_method.dart';
import 'gazelle_http_status_code.dart';

/// Represents a message exchanged between the client and the server in Gazelle.
///
/// This class serves as the base class for both [GazelleRequest] and [GazelleResponse].
abstract class GazelleMessage {
  /// The headers of the message.
  final List<GazelleHttpHeader> headers;

  /// Request's metadata.
  final Map<String, dynamic> metadata;

  /// Constructs a GazelleMessage instance.
  ///
  /// The optional parameter [headers] represents the headers of the message,
  /// defaulting to an empty map if not provided.
  ///
  /// The optional parameter [metadata] represents additional metadata associated
  /// with the message, defaulting to an empty map if not provided.
  const GazelleMessage({
    this.headers = const [],
    this.metadata = const {},
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

  /// The body of the request.
  final Future<String>? body;

  /// Constructs a GazelleRequest instance.
  ///
  /// The [uri] parameter represents the URI of the request.
  /// The [method] parameter represents the HTTP method of the request.
  /// The [pathParameters] parameter represents the path parameters extracted
  /// from the request URI.
  /// The optional [body] parameter represents the body of the request, which
  /// is a future that completes with a string.
  /// The optional [headers] parameter represents the headers of the request,
  /// defaulting to an empty map if not provided.
  /// The optional [metadata] parameter represents additional metadata associated
  /// with the request, defaulting to an empty map if not provided.
  const GazelleRequest({
    required this.uri,
    required this.method,
    required this.pathParameters,
    this.body,
    super.headers = const [],
    super.metadata = const {},
  });

  /// Constructs a [GazelleRequest] instance from an [HttpRequest].
  ///
  /// Optionally accepts a map of path parameters.
  static GazelleRequest fromHttpRequest(
    HttpRequest request, {
    Map<String, String> pathParameters = const {},
  }) {
    final headers = <GazelleHttpHeader>[];
    request.headers.forEach((key, value) =>
        headers.add(GazelleHttpHeader.fromString(key, values: value)));
    final body = utf8.decodeStream(request);

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
    List<GazelleHttpHeader>? headers,
    Future<String>? body,
    Map<String, dynamic>? metadata,
  }) =>
      GazelleRequest(
        uri: uri ?? this.uri,
        method: method ?? this.method,
        pathParameters: pathParameters ?? this.pathParameters,
        headers: headers ?? this.headers,
        metadata: metadata ?? this.metadata,
        body: body ?? this.body,
      );
}

/// Represents an HTTP response in Gazelle.
///
/// Encapsulates information about the HTTP response including the status code,
/// headers, and body.
class GazelleResponse extends GazelleMessage {
  /// The HTTP status code of the response.
  final GazelleHttpStatusCode statusCode;

  /// The body of the response.
  final String? body;

  /// Constructs a GazelleResponse instance.
  ///
  /// The [statusCode] parameter represents the HTTP status code of the response.
  /// The optional [body] parameter represents the body of the response.
  /// The optional [headers] parameter represents the headers of the response,
  /// defaulting to an empty map if not provided.
  /// The optional [metadata] parameter represents additional metadata associated
  /// with the response, defaulting to an empty map if not provided.
  const GazelleResponse({
    this.statusCode = const GazelleHttpStatusCode.custom(200),
    this.body,
    super.headers = const [],
    super.metadata = const {},
  });

  /// Writes this [GazelleResponse] to an [HttpResponse].
  void toHttpResponse(HttpResponse response) {
    response.statusCode = statusCode.code;

    for (final header in headers.toSet()) {
      response.headers.add(header.header, header.values);
    }

    if (body != null) {
      response.write(body);
    }

    response.close();
  }

  /// Creates a copy of this [GazelleResponse] with the specified attributes overridden.
  GazelleResponse copyWith({
    GazelleHttpStatusCode? statusCode,
    List<GazelleHttpHeader>? headers,
    Map<String, dynamic>? metadata,
    String? body,
  }) =>
      GazelleResponse(
        statusCode: statusCode ?? this.statusCode,
        headers: headers ?? this.headers,
        metadata: metadata ?? this.metadata,
        body: body ?? this.body,
      );
}

/// Extension methods for easy access to headers inside a [GazelleMessage].
extension GazelleMessageHeaderExtension on GazelleMessage {
  /// Gets the 'Accept' header from the headers list.
  ///
  /// Returns the 'Accept' header if present, otherwise null.
  GazelleHttpHeader? get accept => headers
      .where((header) => header.header == GazelleHttpHeader.accept.header)
      .firstOrNull;

  /// Gets the 'Accept-Charset' header from the headers list.
  ///
  /// Returns the 'Accept-Charset' header if present, otherwise null.
  GazelleHttpHeader? get acceptCharset => headers
      .where(
          (header) => header.header == GazelleHttpHeader.acceptCharset.header)
      .firstOrNull;

  /// Gets the 'Accept-Encoding' header from the headers list.
  ///
  /// Returns the 'Accept-Encoding' header if present, otherwise null.
  GazelleHttpHeader? get acceptEncoding => headers
      .where(
          (header) => header.header == GazelleHttpHeader.acceptEncoding.header)
      .firstOrNull;

  /// Gets the 'Accept-Language' header from the headers list.
  ///
  /// Returns the 'Accept-Language' header if present, otherwise null.
  GazelleHttpHeader? get acceptLanguage => headers
      .where(
          (header) => header.header == GazelleHttpHeader.acceptLanguage.header)
      .firstOrNull;

  /// Gets the 'Accept-Ranges' header from the headers list.
  ///
  /// Returns the 'Accept-Ranges' header if present, otherwise null.
  GazelleHttpHeader? get acceptRanges => headers
      .where((header) => header.header == GazelleHttpHeader.acceptRanges.header)
      .firstOrNull;

  /// Gets the 'Access-Control-Allow-Credentials' header from the headers list.
  ///
  /// Returns the 'Access-Control-Allow-Credentials' header if present, otherwise null.
  GazelleHttpHeader? get accessControlAllowCredentials => headers
      .where((header) =>
          header.header ==
          GazelleHttpHeader.accessControlAllowCredentials.header)
      .firstOrNull;

  /// Gets the 'Access-Control-Allow-Headers' header from the headers list.
  ///
  /// Returns the 'Access-Control-Allow-Headers' header if present, otherwise null.
  GazelleHttpHeader? get accessControlAllowHeaders => headers
      .where((header) =>
          header.header == GazelleHttpHeader.accessControlAllowHeaders.header)
      .firstOrNull;

  /// Gets the 'Access-Control-Allow-Methods' header from the headers list.
  ///
  /// Returns the 'Access-Control-Allow-Methods' header if present, otherwise null.
  GazelleHttpHeader? get accessControlAllowMethods => headers
      .where((header) =>
          header.header == GazelleHttpHeader.accessControlAllowMethods.header)
      .firstOrNull;

  /// Gets the 'Access-Control-Allow-Origin' header from the headers list.
  ///
  /// Returns the 'Access-Control-Allow-Origin' header if present, otherwise null.
  GazelleHttpHeader? get accessControlAllowOrigin => headers
      .where((header) =>
          header.header == GazelleHttpHeader.accessControlAllowOrigin.header)
      .firstOrNull;

  /// Gets the 'Access-Control-Expose-Headers' header from the headers list.
  ///
  /// Returns the 'Access-Control-Expose-Headers' header if present, otherwise null.
  GazelleHttpHeader? get accessControlExposeHeaders => headers
      .where((header) =>
          header.header == GazelleHttpHeader.accessControlExposeHeaders.header)
      .firstOrNull;

  /// Gets the 'Access-Control-Max-Age' header from the headers list.
  ///
  /// Returns the 'Access-Control-Max-Age' header if present, otherwise null.
  GazelleHttpHeader? get accessControlMaxAge => headers
      .where((header) =>
          header.header == GazelleHttpHeader.accessControlMaxAge.header)
      .firstOrNull;

  /// Gets the 'Access-Control-Request-Headers' header from the headers list.
  ///
  /// Returns the 'Access-Control-Request-Headers' header if present, otherwise null.
  GazelleHttpHeader? get accessControlRequestHeaders => headers
      .where((header) =>
          header.header == GazelleHttpHeader.accessControlRequestHeaders.header)
      .firstOrNull;

  /// Gets the 'Access-Control-Request-Method' header from the headers list.
  ///
  /// Returns the 'Access-Control-Request-Method' header if present, otherwise null.
  GazelleHttpHeader? get accessControlRequestMethod => headers
      .where((header) =>
          header.header == GazelleHttpHeader.accessControlRequestMethod.header)
      .firstOrNull;

  /// Gets the 'Age' header from the headers list.
  ///
  /// Returns the 'Age' header if present, otherwise null.
  GazelleHttpHeader? get age => headers
      .where((header) => header.header == GazelleHttpHeader.age.header)
      .firstOrNull;

  /// Gets the 'Allow' header from the headers list.
  ///
  /// Returns the 'Allow' header if present, otherwise null.
  GazelleHttpHeader? get allow => headers
      .where((header) => header.header == GazelleHttpHeader.allow.header)
      .firstOrNull;

  /// Gets the 'Authorization' header from the headers list.
  ///
  /// Returns the 'Authorization' header if present, otherwise null.
  GazelleHttpHeader? get authorization => headers
      .where(
          (header) => header.header == GazelleHttpHeader.authorization.header)
      .firstOrNull;

  /// Gets the 'Cache-Control' header from the headers list.
  ///
  /// Returns the 'Cache-Control' header if present, otherwise null.
  GazelleHttpHeader? get cacheControl => headers
      .where((header) => header.header == GazelleHttpHeader.cacheControl.header)
      .firstOrNull;

  /// Gets the 'Connection' header from the headers list.
  ///
  /// Returns the 'Connection' header if present, otherwise null.
  GazelleHttpHeader? get connection => headers
      .where((header) => header.header == GazelleHttpHeader.connection.header)
      .firstOrNull;

  /// Gets the 'Content-Disposition' header from the headers list.
  ///
  /// Returns the 'Content-Disposition' header if present, otherwise null.
  GazelleHttpHeader? get contentDisposition => headers
      .where((header) =>
          header.header == GazelleHttpHeader.contentDisposition.header)
      .firstOrNull;

  /// Gets the 'Content-Encoding' header from the headers list.
  ///
  /// Returns the 'Content-Encoding' header if present, otherwise null.
  GazelleHttpHeader? get contentEncoding => headers
      .where(
          (header) => header.header == GazelleHttpHeader.contentEncoding.header)
      .firstOrNull;

  /// Gets the 'Content-Language' header from the headers list.
  ///
  /// Returns the 'Content-Language' header if present, otherwise null.
  GazelleHttpHeader? get contentLanguage => headers
      .where(
          (header) => header.header == GazelleHttpHeader.contentLanguage.header)
      .firstOrNull;

  /// Gets the 'Content-Length' header from the headers list.
  ///
  /// Returns the 'Content-Length' header if present, otherwise null.
  GazelleHttpHeader? get contentLength => headers
      .where(
          (header) => header.header == GazelleHttpHeader.contentLength.header)
      .firstOrNull;

  /// Gets the 'Content-Location' header from the headers list.
  ///
  /// Returns the 'Content-Location' header if present, otherwise null.
  GazelleHttpHeader? get contentLocation => headers
      .where(
          (header) => header.header == GazelleHttpHeader.contentLocation.header)
      .firstOrNull;

  /// Gets the 'Content-Range' header from the headers list.
  ///
  /// Returns the 'Content-Range' header if present, otherwise null.
  GazelleHttpHeader? get contentRange => headers
      .where((header) => header.header == GazelleHttpHeader.contentRange.header)
      .firstOrNull;

  /// Gets the 'Content-Type' header from the headers list.
  ///
  /// Returns the 'Content-Type' header if present, otherwise null.
  GazelleHttpHeader? get contentType => headers
      .where((header) => header.header == GazelleHttpHeader.contentType.header)
      .firstOrNull;

  /// Gets the 'Cookie' header from the headers list.
  ///
  /// Returns the 'Cookie' header if present, otherwise null.
  GazelleHttpHeader? get cookie => headers
      .where((header) => header.header == GazelleHttpHeader.cookie.header)
      .firstOrNull;

  /// Gets the 'Date' header from the headers list.
  ///
  /// Returns the 'Date' header if present, otherwise null.
  GazelleHttpHeader? get date => headers
      .where((header) => header.header == GazelleHttpHeader.date.header)
      .firstOrNull;

  /// Gets the 'ETag' header from the headers list.
  ///
  /// Returns the 'ETag' header if present, otherwise null.
  GazelleHttpHeader? get etag => headers
      .where((header) => header.header == GazelleHttpHeader.etag.header)
      .firstOrNull;

  /// Gets the 'Expect' header from the headers list.
  ///
  /// Returns the 'Expect' header if present, otherwise null.
  GazelleHttpHeader? get expect => headers
      .where((header) => header.header == GazelleHttpHeader.expect.header)
      .firstOrNull;

  /// Gets the 'Expires' header from the headers list.
  ///
  /// Returns the 'Expires' header if present, otherwise null.
  GazelleHttpHeader? get expires => headers
      .where((header) => header.header == GazelleHttpHeader.expires.header)
      .firstOrNull;

  /// Gets the 'From' header from the headers list.
  ///
  /// Returns the 'From' header if present, otherwise null.
  GazelleHttpHeader? get from => headers
      .where((header) => header.header == GazelleHttpHeader.from.header)
      .firstOrNull;

  /// Gets the 'Host' header from the headers list.
  ///
  /// Returns the 'Host' header if present, otherwise null.
  GazelleHttpHeader? get host => headers
      .where((header) => header.header == GazelleHttpHeader.host.header)
      .firstOrNull;

  /// Gets the 'If-Match' header from the headers list.
  ///
  /// Returns the 'If-Match' header if present, otherwise null.
  GazelleHttpHeader? get ifMatch => headers
      .where((header) => header.header == GazelleHttpHeader.ifMatch.header)
      .firstOrNull;

  /// Gets the 'If-Modified-Since' header from the headers list.
  ///
  /// Returns the 'If-Modified-Since' header if present, otherwise null.
  GazelleHttpHeader? get ifModifiedSince => headers
      .where(
          (header) => header.header == GazelleHttpHeader.ifModifiedSince.header)
      .firstOrNull;

  /// Gets the 'If-None-Match' header from the headers list.
  ///
  /// Returns the 'If-None-Match' header if present, otherwise null.
  GazelleHttpHeader? get ifNoneMatch => headers
      .where((header) => header.header == GazelleHttpHeader.ifNoneMatch.header)
      .firstOrNull;

  /// Gets the 'If-Range' header from the headers list.
  ///
  /// Returns the 'If-Range' header if present, otherwise null.
  GazelleHttpHeader? get ifRange => headers
      .where((header) => header.header == GazelleHttpHeader.ifRange.header)
      .firstOrNull;

  /// Gets the 'If-Unmodified-Since' header from the headers list.
  ///
  /// Returns the 'If-Unmodified-Since' header if present, otherwise null.
  GazelleHttpHeader? get ifUnmodifiedSince => headers
      .where((header) =>
          header.header == GazelleHttpHeader.ifUnmodifiedSince.header)
      .firstOrNull;

  /// Gets the 'Last-Modified' header from the headers list.
  ///
  /// Returns the 'Last-Modified' header if present, otherwise null.
  GazelleHttpHeader? get lastModified => headers
      .where((header) => header.header == GazelleHttpHeader.lastModified.header)
      .firstOrNull;

  /// Gets the 'Location' header from the headers list.
  ///
  /// Returns the 'Location' header if present, otherwise null.
  GazelleHttpHeader? get location => headers
      .where((header) => header.header == GazelleHttpHeader.location.header)
      .firstOrNull;

  /// Gets the 'Max-Forwards' header from the headers list.
  ///
  /// Returns the 'Max-Forwards' header if present, otherwise null.
  GazelleHttpHeader? get maxForwards => headers
      .where((header) => header.header == GazelleHttpHeader.maxForwards.header)
      .firstOrNull;

  /// Gets the 'Origin' header from the headers list.
  ///
  /// Returns the 'Origin' header if present, otherwise null.
  GazelleHttpHeader? get origin => headers
      .where((header) => header.header == GazelleHttpHeader.origin.header)
      .firstOrNull;

  /// Gets the 'Pragma' header from the headers list.
  ///
  /// Returns the 'Pragma' header if present, otherwise null.
  GazelleHttpHeader? get pragma => headers
      .where((header) => header.header == GazelleHttpHeader.pragma.header)
      .firstOrNull;

  /// Gets the 'Proxy-Authenticate' header from the headers list.
  ///
  /// Returns the 'Proxy-Authenticate' header if present, otherwise null.
  GazelleHttpHeader? get proxyAuthenticate => headers
      .where((header) =>
          header.header == GazelleHttpHeader.proxyAuthenticate.header)
      .firstOrNull;

  /// Gets the 'Proxy-Authorization' header from the headers list.
  ///
  /// Returns the 'Proxy-Authorization' header if present, otherwise null.
  GazelleHttpHeader? get proxyAuthorization => headers
      .where((header) =>
          header.header == GazelleHttpHeader.proxyAuthorization.header)
      .firstOrNull;

  /// Gets the 'Range' header from the headers list.
  ///
  /// Returns the 'Range' header if present, otherwise null.
  GazelleHttpHeader? get range => headers
      .where((header) => header.header == GazelleHttpHeader.range.header)
      .firstOrNull;

  /// Gets the 'Referer' header from the headers list.
  ///
  /// Returns the 'Referer' header if present, otherwise null.
  GazelleHttpHeader? get referer => headers
      .where((header) => header.header == GazelleHttpHeader.referer.header)
      .firstOrNull;

  /// Gets the 'Retry-After' header from the headers list.
  ///
  /// Returns the 'Retry-After' header if present, otherwise null.
  GazelleHttpHeader? get retryAfter => headers
      .where((header) => header.header == GazelleHttpHeader.retryAfter.header)
      .firstOrNull;

  /// Gets the 'Sec-WebSocket-Key' header from the headers list.
  ///
  /// Returns the 'Sec-WebSocket-Key' header if present, otherwise null.
  GazelleHttpHeader? get secWebSocketKey => headers
      .where(
          (header) => header.header == GazelleHttpHeader.secWebSocketKey.header)
      .firstOrNull;

  /// Gets the 'Sec-WebSocket-Protocol' header from the headers list.
  ///
  /// Returns the 'Sec-WebSocket-Protocol' header if present, otherwise null.
  GazelleHttpHeader? get secWebSocketProtocol => headers
      .where((header) =>
          header.header == GazelleHttpHeader.secWebSocketProtocol.header)
      .firstOrNull;

  /// Gets the 'Sec-WebSocket-Version' header from the headers list.
  ///
  /// Returns the 'Sec-WebSocket-Version' header if present, otherwise null.
  GazelleHttpHeader? get secWebSocketVersion => headers
      .where((header) =>
          header.header == GazelleHttpHeader.secWebSocketVersion.header)
      .firstOrNull;

  /// Gets the 'Server' header from the headers list.
  ///
  /// Returns the 'Server' header if present, otherwise null.
  GazelleHttpHeader? get server => headers
      .where((header) => header.header == GazelleHttpHeader.server.header)
      .firstOrNull;

  /// Gets the 'Set-Cookie' header from the headers list.
  ///
  /// Returns the 'Set-Cookie' header if present, otherwise null.
  GazelleHttpHeader? get setCookie => headers
      .where((header) => header.header == GazelleHttpHeader.setCookie.header)
      .firstOrNull;

  /// Gets the 'TE' header from the headers list.
  ///
  /// Returns the 'TE' header if present, otherwise null.
  GazelleHttpHeader? get te => headers
      .where((header) => header.header == GazelleHttpHeader.te.header)
      .firstOrNull;

  /// Gets the 'Trailer' header from the headers list.
  ///
  /// Returns the 'Trailer' header if present, otherwise null.
  GazelleHttpHeader? get trailer => headers
      .where((header) => header.header == GazelleHttpHeader.trailer.header)
      .firstOrNull;

  /// Gets the 'Transfer-Encoding' header from the headers list.
  ///
  /// Returns the 'Transfer-Encoding' header if present, otherwise null.
  GazelleHttpHeader? get transferEncoding => headers
      .where((header) =>
          header.header == GazelleHttpHeader.transferEncoding.header)
      .firstOrNull;

  /// Gets the 'Upgrade' header from the headers list.
  ///
  /// Returns the 'Upgrade' header if present, otherwise null.
  GazelleHttpHeader? get upgrade => headers
      .where((header) => header.header == GazelleHttpHeader.upgrade.header)
      .firstOrNull;

  /// Gets the 'User-Agent' header from the headers list.
  ///
  /// Returns the 'User-Agent' header if present, otherwise null.
  GazelleHttpHeader? get userAgent => headers
      .where((header) => header.header == GazelleHttpHeader.userAgent.header)
      .firstOrNull;

  /// Gets the 'Vary' header from the headers list.
  ///
  /// Returns the 'Vary' header if present, otherwise null.
  GazelleHttpHeader? get vary => headers
      .where((header) => header.header == GazelleHttpHeader.vary.header)
      .firstOrNull;

  /// Gets the 'Via' header from the headers list.
  ///
  /// Returns the 'Via' header if present, otherwise null.
  GazelleHttpHeader? get via => headers
      .where((header) => header.header == GazelleHttpHeader.via.header)
      .firstOrNull;

  /// Gets the 'WWW-Authenticate' header from the headers list.
  ///
  /// Returns the 'WWW-Authenticate' header if present, otherwise null.
  GazelleHttpHeader? get wwwAuthenticate => headers
      .where(
          (header) => header.header == GazelleHttpHeader.wwwAuthenticate.header)
      .firstOrNull;
}
