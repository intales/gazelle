/// An enumeration representing CORS headers.
enum GazelleCorsHeaders {
  /// The Access-Control-Allow-Origin response header indicates whether the response can be shared with requesting code from the given origin.
  accessControlAllowOrigin,

  /// The Access-Control-Expose-Headers response header allows a server to indicate which response headers should be made available to scripts running in the browser, in response to a cross-origin request.
  accessControlExposeHeaders,

  /// The Access-Control-Allow-Credentials response header tells browsers whether the server allows cross-origin HTTP requests to include credentials.
  accessControlAllowCredentials,

  /// The Access-Control-Allow-Headers response header is used in response to a preflight request which includes the Access-Control-Request-Headers to indicate which HTTP headers can be used during the actual request.
  accessControlAllowHeaders,

  /// The Access-Control-Allow-Methods response header specifies one or more methods allowed when accessing a resource in response to a preflight request.
  accessControlAllowMethods,

  /// The Access-Control-Max-Age response header indicates how long the results of a preflight request (that is the information contained in the Access-Control-Allow-Methods and Access-Control-Allow-Headers headers) can be cached.
  accessControlMaxAge,

  /// The Vary HTTP response header describes the parts of the request message aside from the method and URL that influenced the content of the response it occurs in.
  vary;

  /// Returns the HTTP header name of given [GazelleCorsHeaders].
  String get name => switch (this) {
        GazelleCorsHeaders.accessControlAllowOrigin =>
          "Access-Control-Allow-Origin",
        GazelleCorsHeaders.accessControlExposeHeaders =>
          "Access-Control-Expose-Headers",
        GazelleCorsHeaders.accessControlAllowCredentials =>
          "Access-Control-Allow-Credentials",
        GazelleCorsHeaders.accessControlAllowHeaders =>
          "Access-Control-Allow-Headers",
        GazelleCorsHeaders.accessControlAllowMethods =>
          "Access-Control-Allow-Methods",
        GazelleCorsHeaders.accessControlMaxAge => "Access-Control-Max-Age",
        GazelleCorsHeaders.vary => "Vary",
      };

  /// Returns a [GazelleCorsHeaders] from a given header.
  static GazelleCorsHeaders fromString(String header) => switch (header) {
        "Access-Control-Allow-Origin" =>
          GazelleCorsHeaders.accessControlAllowOrigin,
        "Access-Control-Expose-Headers" =>
          GazelleCorsHeaders.accessControlExposeHeaders,
        "Access-Control-Allow-Credentials" =>
          GazelleCorsHeaders.accessControlAllowCredentials,
        "Access-Control-Allow-Headers" =>
          GazelleCorsHeaders.accessControlAllowHeaders,
        "Access-Control-Allow-Methods" =>
          GazelleCorsHeaders.accessControlAllowMethods,
        "Access-Control-Max-Age" => GazelleCorsHeaders.accessControlMaxAge,
        "Vary" => GazelleCorsHeaders.vary,
        _ => throw "Unexpected header: $header",
      };
}
