/// An enumeration representing HTTP methods supported by Gazelle.
///
/// Supported methods are: GET, POST, PUT, PATCH, and DELETE.
enum GazelleHttpMethod {
  /// HTTP GET method.
  get,

  /// HTTP POST method.
  post,

  /// HTTP PUT method.
  put,

  /// HTTP PATCH method.
  patch,

  /// HTTP OPTIONS method.
  options,

  /// HTTP DELETE method.
  delete;

  /// Converts a string representation of an HTTP method to a [GazelleHttpMethod] enum.
  ///
  /// Throws an error if the input string does not match any supported HTTP method.
  static GazelleHttpMethod fromString(String method) =>
      switch (method.toUpperCase()) {
        "GET" => GazelleHttpMethod.get,
        "POST" => GazelleHttpMethod.post,
        "PUT" => GazelleHttpMethod.put,
        "PATCH" => GazelleHttpMethod.patch,
        "OPTIONS" => GazelleHttpMethod.options,
        "DELETE" => GazelleHttpMethod.delete,
        _ => throw "Unexpected method: $method",
      };

  /// Returns the string representation of the HTTP method.
  String get name => switch (this) {
        GazelleHttpMethod.get => "GET",
        GazelleHttpMethod.post => "POST",
        GazelleHttpMethod.put => "PUT",
        GazelleHttpMethod.patch => "PATCH",
        GazelleHttpMethod.options => "OPTIONS",
        GazelleHttpMethod.delete => "DELETE",
      };
}
