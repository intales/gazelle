/// A class representing HTTP headers.
class GazelleHttpHeader {
  /// The header name.
  final String header;

  /// The header values.
  final List<String> values;

  /// Private constructor to initialize the header with optional values.
  const GazelleHttpHeader._(
    this.header, {
    this.values = const [],
  });

  /// Public constructor for custom headers with optional values.
  const GazelleHttpHeader.custom(
    this.header, {
    this.values = const [],
  });

  /// The Accept request-header field can be used to specify certain media types which are acceptable for the response.
  static const GazelleHttpHeader accept = GazelleHttpHeader._('Accept');

  /// The Accept-Charset request-header field can be used to indicate what character sets are acceptable for the response.
  static const GazelleHttpHeader acceptCharset =
      GazelleHttpHeader._('Accept-Charset');

  /// The Accept-Encoding request-header field is similar to Accept, but restricts the content-codings that are acceptable in the response.
  static const GazelleHttpHeader acceptEncoding =
      GazelleHttpHeader._('Accept-Encoding');

  /// The Accept-Language request-header field is similar to Accept, but restricts the set of natural languages that are preferred as a response to the request.
  static const GazelleHttpHeader acceptLanguage =
      GazelleHttpHeader._('Accept-Language');

  /// The Accept-Ranges response-header field allows the server to indicate its acceptance of range requests for a resource.
  static const GazelleHttpHeader acceptRanges =
      GazelleHttpHeader._('Accept-Ranges');

  /// Indicates whether the response to the request can be exposed when the credentials flag is true.
  static const GazelleHttpHeader accessControlAllowCredentials =
      GazelleHttpHeader._('Access-Control-Allow-Credentials');

  /// Used in response to a preflight request to indicate which HTTP headers can be used when making the actual request.
  static const GazelleHttpHeader accessControlAllowHeaders =
      GazelleHttpHeader._('Access-Control-Allow-Headers');

  /// Specifies the method or methods allowed when accessing the resource in response to a preflight request.
  static const GazelleHttpHeader accessControlAllowMethods =
      GazelleHttpHeader._('Access-Control-Allow-Methods');

  /// Indicates whether the response can be shared with requesting code from the given origin.
  static const GazelleHttpHeader accessControlAllowOrigin =
      GazelleHttpHeader._('Access-Control-Allow-Origin');

  /// Used in response to a preflight request to indicate which HTTP headers can be exposed to the client.
  static const GazelleHttpHeader accessControlExposeHeaders =
      GazelleHttpHeader._('Access-Control-Expose-Headers');

  /// Indicates how long the results of a preflight request can be cached.
  static const GazelleHttpHeader accessControlMaxAge =
      GazelleHttpHeader._('Access-Control-Max-Age');

  /// Used when issuing a preflight request to let the server know which HTTP headers will be used when the actual request is made.
  static const GazelleHttpHeader accessControlRequestHeaders =
      GazelleHttpHeader._('Access-Control-Request-Headers');

  /// Used when issuing a preflight request to let the server know which HTTP method will be used when the actual request is made.
  static const GazelleHttpHeader accessControlRequestMethod =
      GazelleHttpHeader._('Access-Control-Request-Method');

  /// The Age response-header field conveys the sender's estimate of the amount of time since the response was generated.
  static const GazelleHttpHeader age = GazelleHttpHeader._('Age');

  /// The Allow entity-header field lists the set of methods supported by the resource identified by the Request-URI.
  static const GazelleHttpHeader allow = GazelleHttpHeader._('Allow');

  /// The Authorization request-header field allows a user agent to authenticate itself with a server, usually after receiving a 401 response.
  static const GazelleHttpHeader authorization =
      GazelleHttpHeader._('Authorization');

  /// The Cache-Control general-header field is used to specify directives for caching mechanisms in both requests and responses.
  static const GazelleHttpHeader cacheControl =
      GazelleHttpHeader._('Cache-Control');

  /// The Connection general-header field allows the sender to specify options that are desired for that particular connection and must not be communicated by proxies over further connections.
  static const GazelleHttpHeader connection = GazelleHttpHeader._('Connection');

  /// The Content-Disposition header field is used to specify the presentation style of the content.
  static const GazelleHttpHeader contentDisposition =
      GazelleHttpHeader._('Content-Disposition');

  /// The Content-Encoding entity-header field is used as a modifier to the media-type. When present, its value indicates what additional content codings have been applied to the entity-body.
  static const GazelleHttpHeader contentEncoding =
      GazelleHttpHeader._('Content-Encoding');

  /// The Content-Language entity-header field describes the natural language(s) of the intended audience for the enclosed entity.
  static const GazelleHttpHeader contentLanguage =
      GazelleHttpHeader._('Content-Language');

  /// The Content-Length entity-header field indicates the size of the entity-body, in decimal number of octets, sent to the recipient.
  static const GazelleHttpHeader contentLength =
      GazelleHttpHeader._('Content-Length');

  /// The Content-Location entity-header field may be used to supply the resource location for the entity enclosed in the message.
  static const GazelleHttpHeader contentLocation =
      GazelleHttpHeader._('Content-Location');

  /// The Content-Range entity-header field is sent with a partial entity-body to specify where in the full entity-body the partial body should be applied.
  static const GazelleHttpHeader contentRange =
      GazelleHttpHeader._('Content-Range');

  /// The Content-Type entity-header field indicates the media type of the entity-body sent to the recipient.
  static const GazelleHttpHeader contentType =
      GazelleHttpHeader._('Content-Type');

  /// The Cookie request-header field contains stored HTTP cookies previously sent by the server with the Set-Cookie header.
  static const GazelleHttpHeader cookie = GazelleHttpHeader._('Cookie');

  /// The Date general-header field represents the date and time at which the message was originated.
  static const GazelleHttpHeader date = GazelleHttpHeader._('Date');

  /// The ETag response-header field provides the current value of the entity tag for the requested variant.
  static const GazelleHttpHeader etag = GazelleHttpHeader._('ETag');

  /// The Expect request-header field is used to indicate that particular server behaviors are required by the client.
  static const GazelleHttpHeader expect = GazelleHttpHeader._('Expect');

  /// The Expires entity-header field gives the date/time after which the response is considered stale.
  static const GazelleHttpHeader expires = GazelleHttpHeader._('Expires');

  /// The Forwarded header contains information from the reverse proxy servers that is altered or stripped by the proxies.
  static const GazelleHttpHeader forwarded = GazelleHttpHeader._('Forwarded');

  /// The From request-header field, if given, should contain an Internet e-mail address for the human user who controls the requesting user agent.
  static const GazelleHttpHeader from = GazelleHttpHeader._('From');

  /// The Host request-header field specifies the Internet host and port number of the resource being requested.
  static const GazelleHttpHeader host = GazelleHttpHeader._('Host');

  /// The If-Match request-header field is used with a method to make it conditional. A client that has one or more entity tags previously obtained from the resource can use this header to make a request method conditional on the current value of the entity tag for the requested resource.
  static const GazelleHttpHeader ifMatch = GazelleHttpHeader._('If-Match');

  /// The If-Modified-Since request-header field is used with a method to make it conditional. A conditional GET method requests that the entity be transferred only if it has been modified since the date given by the If-Modified-Since field.
  static const GazelleHttpHeader ifModifiedSince =
      GazelleHttpHeader._('If-Modified-Since');

  /// The If-None-Match request-header field is used with a method to make it conditional. A client that has one or more entity tags previously obtained from the resource can use this header to make a request method conditional on the absence of any current entity tags for the requested resource.
  static const GazelleHttpHeader ifNoneMatch =
      GazelleHttpHeader._('If-None-Match');

  /// The If-Range request-header field is used with a method to make it conditional. A client that has one or more entity tags previously obtained from the resource can use this header to make a request method conditional on the current value of the entity tag for the requested resource.
  static const GazelleHttpHeader ifRange = GazelleHttpHeader._('If-Range');

  /// The If-Unmodified-Since request-header field is used with a method to make it conditional. A client that has one or more entity tags previously obtained from the resource can use this header to make a request method conditional on the absence of any current entity tags for the requested resource.
  static const GazelleHttpHeader ifUnmodifiedSince =
      GazelleHttpHeader._('If-Unmodified-Since');

  /// The Last-Modified entity-header field indicates the date and time at which the origin server believes the variant was last modified.
  static const GazelleHttpHeader lastModified =
      GazelleHttpHeader._('Last-Modified');

  /// The Link entity-header field provides a means for serialising one or more links in HTTP headers.
  static const GazelleHttpHeader link = GazelleHttpHeader._('Link');

  /// The Location response-header field is used to redirect the recipient to a location other than the Request-URI for completion of the request or identification of a new resource.
  static const GazelleHttpHeader location = GazelleHttpHeader._('Location');

  /// The Max-Forwards request-header field provides a mechanism with the TRACE and OPTIONS methods to limit the number of proxies or gateways that can forward the request to the next inbound server.
  static const GazelleHttpHeader maxForwards =
      GazelleHttpHeader._('Max-Forwards');

  /// The Origin request-header field indicates where the cross-origin request or preflight request originates from.
  static const GazelleHttpHeader origin = GazelleHttpHeader._('Origin');

  /// The Pragma general-header field is used to include implementation-specific directives that might apply to any recipient along the request/response chain.
  static const GazelleHttpHeader pragma = GazelleHttpHeader._('Pragma');

  /// The Proxy-Authenticate response-header field allows the proxy server to demand authentication credentials from the client.
  static const GazelleHttpHeader proxyAuthenticate =
      GazelleHttpHeader._('Proxy-Authenticate');

  /// The Proxy-Authorization request-header field allows the client to identify itself (or its user) to a proxy that requires authentication.
  static const GazelleHttpHeader proxyAuthorization =
      GazelleHttpHeader._('Proxy-Authorization');

  /// The Range request-header field specifies the part of a document that the server should return.
  static const GazelleHttpHeader range = GazelleHttpHeader._('Range');

  /// The Referer request-header field allows the client to specify the URI of the resource from which the request URI was obtained.
  static const GazelleHttpHeader referer = GazelleHttpHeader._('Referer');

  /// The Retry-After response-header field can be used with a 503 (Service Unavailable) or 3xx (Redirection) response to indicate how long the service is expected to be unavailable to the requesting client.
  static const GazelleHttpHeader retryAfter =
      GazelleHttpHeader._('Retry-After');

  /// The Sec-WebSocket-Accept header field is used in the WebSocket opening handshake response.
  static const GazelleHttpHeader secWebSocketAccept =
      GazelleHttpHeader._('Sec-WebSocket-Accept');

  /// The Sec-WebSocket-Extensions header field is used to negotiate extensions to the WebSocket Protocol during the handshake process.
  static const GazelleHttpHeader secWebSocketExtensions =
      GazelleHttpHeader._('Sec-WebSocket-Extensions');

  /// The Sec-WebSocket-Key header field is used in the WebSocket opening handshake request.
  static const GazelleHttpHeader secWebSocketKey =
      GazelleHttpHeader._('Sec-WebSocket-Key');

  /// The Sec-WebSocket-Protocol header field is used to negotiate subprotocols during the WebSocket handshake.
  static const GazelleHttpHeader secWebSocketProtocol =
      GazelleHttpHeader._('Sec-WebSocket-Protocol');

  /// The Sec-WebSocket-Version header field is used in the WebSocket opening handshake to indicate the WebSocket protocol version the client is using.
  static const GazelleHttpHeader secWebSocketVersion =
      GazelleHttpHeader._('Sec-WebSocket-Version');

  /// The Server response-header field contains information about the software used by the origin server to handle the request.
  static const GazelleHttpHeader server = GazelleHttpHeader._('Server');

  /// The Set-Cookie response-header field is used to send cookies from the server to the user agent.
  static const GazelleHttpHeader setCookie = GazelleHttpHeader._('Set-Cookie');

  /// The Strict-Transport-Security response-header field lets a web site tell browsers that it should only be accessed using HTTPS.
  static const GazelleHttpHeader strictTransportSecurity =
      GazelleHttpHeader._('Strict-Transport-Security');

  /// The TE request-header field indicates what extension transfer-codings the client is willing to accept in the response.
  static const GazelleHttpHeader te = GazelleHttpHeader._('TE');

  /// The Trailer general-header field allows the sender to include additional fields at the end of chunked transfers.
  static const GazelleHttpHeader trailer = GazelleHttpHeader._('Trailer');

  /// The Transfer-Encoding general-header field indicates what type of transformation has been applied to the message body to safely transfer it between the sender and the recipient.
  static const GazelleHttpHeader transferEncoding =
      GazelleHttpHeader._('Transfer-Encoding');

  /// The Upgrade general-header field allows the client to specify which additional protocols it supports and would like to use if the server finds it appropriate to switch protocols.
  static const GazelleHttpHeader upgrade = GazelleHttpHeader._('Upgrade');

  /// The User-Agent request-header field contains information about the user agent originating the request.
  static const GazelleHttpHeader userAgent = GazelleHttpHeader._('User-Agent');

  /// The Vary response-header field is used by servers to indicate that the response content varies depending on the value of the specified request headers.
  static const GazelleHttpHeader vary = GazelleHttpHeader._('Vary');

  /// The Via general-header field is used to track message forwards, avoid request loops, and identify the protocol capabilities of senders along the request/response chain.
  static const GazelleHttpHeader via = GazelleHttpHeader._('Via');

  /// The WWW-Authenticate response-header field indicates the authentication scheme that should be used to access the requested entity.
  static const GazelleHttpHeader wwwAuthenticate =
      GazelleHttpHeader._('WWW-Authenticate');

  /// A list of all predefined headers.
  static const List<GazelleHttpHeader> predefinedValues = [
    accept,
    acceptCharset,
    acceptEncoding,
    acceptLanguage,
    acceptRanges,
    accessControlAllowCredentials,
    accessControlAllowHeaders,
    accessControlAllowMethods,
    accessControlAllowOrigin,
    accessControlExposeHeaders,
    accessControlMaxAge,
    accessControlRequestHeaders,
    accessControlRequestMethod,
    age,
    allow,
    authorization,
    cacheControl,
    connection,
    contentDisposition,
    contentEncoding,
    contentLanguage,
    contentLength,
    contentLocation,
    contentRange,
    contentType,
    cookie,
    date,
    etag,
    expect,
    expires,
    forwarded,
    from,
    host,
    ifMatch,
    ifModifiedSince,
    ifNoneMatch,
    ifRange,
    ifUnmodifiedSince,
    lastModified,
    link,
    location,
    maxForwards,
    origin,
    pragma,
    proxyAuthenticate,
    proxyAuthorization,
    range,
    referer,
    retryAfter,
    secWebSocketAccept,
    secWebSocketExtensions,
    secWebSocketKey,
    secWebSocketProtocol,
    secWebSocketVersion,
    server,
    setCookie,
    strictTransportSecurity,
    te,
    trailer,
    transferEncoding,
    upgrade,
    userAgent,
    vary,
    via,
    wwwAuthenticate,
  ];

  /// Creates a [GazelleHttpHeader] instance from a string.
  /// If the header string matches a predefined header, returns that.
  /// Otherwise, creates a custom header.
  factory GazelleHttpHeader.fromString(
    String headerString, {
    List<String> values = const [],
  }) {
    return predefinedValues
        .firstWhere(
          (header) => header.header.toLowerCase() == headerString.toLowerCase(),
          orElse: () => GazelleHttpHeader.custom(headerString, values: values),
        )
        .addValues(values);
  }

  /// Returns a header with given [values], after current [values].
  GazelleHttpHeader addValues(List<String> values) =>
      GazelleHttpHeader._(header, values: [...this.values, ...values]);

  /// Returns a header with given [value] after current [values].
  GazelleHttpHeader addValue(String value) =>
      GazelleHttpHeader._(header, values: [...values, value]);

  @override
  String toString() => '$header: ${values.join(', ')}';
}
