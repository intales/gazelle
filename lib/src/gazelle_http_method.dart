enum GazelleHttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  static GazelleHttpMethod fromString(String method) => switch (method) {
        "GET" => GazelleHttpMethod.get,
        "POST" => GazelleHttpMethod.post,
        "PUT" => GazelleHttpMethod.put,
        "PATCH" => GazelleHttpMethod.patch,
        "DELETE" => GazelleHttpMethod.delete,
        _ => throw "Unexpected method: $method",
      };

  String get name => switch (this) {
        GazelleHttpMethod.get => "GET",
        GazelleHttpMethod.post => "POST",
        GazelleHttpMethod.put => "PUT",
        GazelleHttpMethod.patch => "PATCH",
        GazelleHttpMethod.delete => "DELETE",
      };
}
