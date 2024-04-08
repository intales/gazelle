/// An enumeration representing standard HTTP headers values.
enum GazelleHeaders {
  /// The Accept request HTTP header indicates which content types, expressed as MIME types, the client is able to understand.
  accept,

  /// The Accept-Encoding request HTTP header indicates the content encoding (usually a compression algorithm) that the client can understand.
  acceptEncoding,

  /// The HTTP Authorization request header can be used to provide credentials that authenticate a user agent with a server, allowing access to a protected resource.
  authroization,

  /// The Content-Type representation header is used to indicate the original media type of the resource (prior to any content encoding applied for sending).
  contentType,

  /// The Origin request header indicates the origin (scheme, hostname, and port) that caused the request.
  origin,

  /// The User-Agent request header is a characteristic string that lets servers and network peers identify the application,operating system, vendor, and/or version of the requesting user agent.
  userAgent;

  /// Creates a [GazelleHeaders] from a given header
  static GazelleHeaders fromString(String header) => switch (header) {
        "accept" => GazelleHeaders.accept,
        "accept-encoding" => GazelleHeaders.acceptEncoding,
        "authorization" => GazelleHeaders.authroization,
        "content-type" => GazelleHeaders.contentType,
        "origin" => GazelleHeaders.origin,
        "user-agent" => GazelleHeaders.userAgent,
        _ => throw "Unexpected header: $header",
      };

  /// Gets the actual name of given header for an HTTP message.
  String get name => switch (this) {
        GazelleHeaders.accept => "accept",
        GazelleHeaders.acceptEncoding => "accept-encoding",
        GazelleHeaders.authroization => "authorization",
        GazelleHeaders.contentType => "content-type",
        GazelleHeaders.origin => "origin",
        GazelleHeaders.userAgent => "user-agent",
      };
}
