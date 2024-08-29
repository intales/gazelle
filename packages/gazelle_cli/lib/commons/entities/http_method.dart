/// Represents an HTTP method.
enum HttpMethod {
  /// GET
  get("GET"),

  /// POST
  post("POST"),

  /// PUT
  put("PUT"),

  /// PATCH
  patch("PATCH"),

  /// DELETE
  delete("DELETE");

  /// The name of the method.
  final String name;

  const HttpMethod(this.name);

  /// Returns the method name in PascalCase format.
  String get pascalCase => "${name[0]}${name.substring(1).toLowerCase()}";
}
