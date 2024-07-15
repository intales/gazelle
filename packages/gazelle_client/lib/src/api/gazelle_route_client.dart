import 'dart:convert';

import 'package:gazelle_serialization/gazelle_serialization.dart';
import 'package:http/http.dart' as http;

/// Defines an error in the API client.
///
/// This exception is thrown whenever a request
/// contains an error.
class GazelleApiClientException implements Exception {
  /// The path where the error occurred.
  final String path;

  /// The http method.
  final String httpMethod;

  /// The status code of the error.
  final int statusCode;

  /// The body of the error.
  final String body;

  /// Builds a [GazelleApiClientException].
  const GazelleApiClientException({
    required this.path,
    required this.httpMethod,
    required this.statusCode,
    required this.body,
  });

  @override
  String toString() {
    final buffer = StringBuffer("GazelleApiClientException:")
      ..writeln("PATH: $path")
      ..writeln("METHOD: $httpMethod")
      ..writeln("STATUS CODE: $statusCode")
      ..writeln("BODY: $body");
    return buffer.toString();
  }
}

/// Represents a route for the API client.
class GazelleRouteClient {
  final GazelleModelProvider _gazelleModelProvider;
  final http.Client _httpClient;
  final String _path;

  /// Builds a [GazelleRouteClient].
  const GazelleRouteClient({
    required GazelleModelProvider gazelleModelProvider,
    required http.Client httpClient,
    required String path,
  })  : _path = path,
        _httpClient = httpClient,
        _gazelleModelProvider = gazelleModelProvider;

  /// Adds a new route segment.
  GazelleRouteClient call(String path) => GazelleRouteClient(
        gazelleModelProvider: _gazelleModelProvider,
        httpClient: _httpClient,
        path: "$_path/$path",
      );

  /// Sends a GET request for a single [T].
  Future<T> get<T>({Map<String, dynamic>? queryParams}) async {
    Uri uri = Uri.parse(_path);

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringQueryParams = queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      uri = uri.replace(queryParameters: stringQueryParams);
    }

    final response = await _sendRequest(() => _httpClient.get(uri));

    return _deserialize<T>(response.body);
  }

  /// Sends a GET request for a list of [T]s.
  Future<List<T>> list<T>({Map<String, dynamic>? queryParams}) async {
    Uri uri = Uri.parse(_path);

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringQueryParams = queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      uri = uri.replace(queryParameters: stringQueryParams);
    }

    final response = await _sendRequest(() => _httpClient.get(uri));

    return _deserializeList<T>(response.body);
  }

  /// Sends a POST request for [T].
  Future<T> post<T>({required T body}) async {
    final response = await _sendRequest(() => _httpClient.post(
          Uri.parse(_path),
          body: _serialize<T>(body),
        ));

    return _deserialize<T>(response.body);
  }

  /// Sends a PUT request for [T].
  Future<T> put<T>({required T body}) async {
    final response = await _sendRequest(() => _httpClient.put(
          Uri.parse(_path),
          body: _serialize<T>(body),
        ));

    return _deserialize<T>(response.body);
  }

  /// Sends a PATCH request for [T].
  Future<T> patch<T>({required T body}) async {
    final response = await _sendRequest(() => _httpClient.patch(
          Uri.parse(_path),
          body: _serialize<T>(body),
        ));

    return _deserialize<T>(response.body);
  }

  /// Sends a DELETE request for [T].
  Future<T> delete<T>({required T body}) async {
    final response = await _sendRequest(() => _httpClient.delete(
          Uri.parse(_path),
          body: _serialize<T>(body),
        ));

    return _deserialize<T>(response.body);
  }

  Future<http.Response> _sendRequest(
    Future<http.Response> Function() callback,
  ) async {
    final response = await callback();

    if (response.statusCode >= 299) {
      throw GazelleApiClientException(
        path: response.request!.url.path,
        httpMethod: response.request!.method,
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    return response;
  }

  String _serialize<T>(T object) => jsonEncode(serialize(
        object: object,
        modelProvider: _gazelleModelProvider,
      ));

  T _deserialize<T>(String json) => deserialize<T>(
        jsonObject: jsonDecode(json),
        modelProvider: _gazelleModelProvider,
      );

  List<T> _deserializeList<T>(String json) => deserializeList<T>(
        list: jsonDecode(json),
        modelProvider: _gazelleModelProvider,
      );
}
