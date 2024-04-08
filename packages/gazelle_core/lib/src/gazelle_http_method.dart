/// An enumeration representing HTTP methods supported by Gazelle.
///
/// Supported methods are: GET, POST, PUT, PATCH, and DELETE.
enum GazelleHttpMethod {
  /// HTTP GET method.
  get,

  /// HTTP HEAD method.
  head,

  /// HTTP POST method.
  post,

  /// HTTP PUT method.
  put,

  /// HTTP PATCH method.
  patch,

  /// HTTP DELETE method.
  delete,

  /// HTTP OPTIONS method.
  options;

  /// Converts a string representation of an HTTP method to a [GazelleHttpMethod] enum.
  ///
  /// Throws an error if the input string does not match any supported HTTP method.
  static GazelleHttpMethod fromString(String method) =>
      switch (method.toUpperCase()) {
        "GET" => GazelleHttpMethod.get,
        "HEAD" => GazelleHttpMethod.head,
        "POST" => GazelleHttpMethod.post,
        "PUT" => GazelleHttpMethod.put,
        "PATCH" => GazelleHttpMethod.patch,
        "DELETE" => GazelleHttpMethod.delete,
        "OPTIONS" => GazelleHttpMethod.options,
        _ => throw "Unexpected method: $method",
      };

  /// Returns the string representation of the HTTP method.
  String get name => switch (this) {
        GazelleHttpMethod.get => "GET",
        GazelleHttpMethod.head => "HEAD",
        GazelleHttpMethod.post => "POST",
        GazelleHttpMethod.put => "PUT",
        GazelleHttpMethod.patch => "PATCH",
        GazelleHttpMethod.delete => "DELETE",
        GazelleHttpMethod.options => "OPTIONS",
      };
}
