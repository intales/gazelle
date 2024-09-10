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

  /// Sends a GET request for a single [ResponseType].
  Future<ResponseType> get<ResponseType>({
    Map<String, dynamic>? queryParams,
  }) async {
    Uri uri = Uri.parse(_path);

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringQueryParams = queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      uri = uri.replace(queryParameters: stringQueryParams);
    }

    final response = await _sendRequest(
      callback: () => _httpClient.get(uri),
      method: "GET",
    );

    return _deserialize<ResponseType>(response.body);
  }

  /// Sends a GET request for a list of [ResponseType]s.
  Future<List<ResponseType>> list<ResponseType>({
    Map<String, dynamic>? queryParams,
  }) async {
    Uri uri = Uri.parse(_path);

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringQueryParams = queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      uri = uri.replace(queryParameters: stringQueryParams);
    }

    final response = await _sendRequest(
      callback: () => _httpClient.get(uri),
      method: "GET",
    );

    return _deserializeList<ResponseType>(response.body);
  }

  /// Sends a POST request for [ResponseType].
  Future<ResponseType> post<RequestType, ResponseType>({
    required RequestType body,
  }) async {
    final response = await _sendRequest(
      callback: () => _httpClient.post(
        Uri.parse(_path),
        body: _serialize<RequestType>(body),
      ),
      method: "POST",
    );

    return _deserialize<ResponseType>(response.body);
  }

  /// Sends a PUT request for [ResponseType].
  Future<ResponseType> put<RequestType, ResponseType>({
    required RequestType body,
  }) async {
    final response = await _sendRequest(
      callback: () => _httpClient.put(
        Uri.parse(_path),
        body: _serialize<RequestType>(body),
      ),
      method: "PUT",
    );

    return _deserialize<ResponseType>(response.body);
  }

  /// Sends a PATCH request for [ResponseType].
  Future<ResponseType> patch<RequestType, ResponseType>({
    required RequestType body,
  }) async {
    final response = await _sendRequest(
      callback: () => _httpClient.patch(
        Uri.parse(_path),
        body: _serialize<RequestType>(body),
      ),
      method: "PATCH",
    );

    return _deserialize<ResponseType>(response.body);
  }

  /// Sends a DELETE request for [ResponseType].
  Future<ResponseType> delete<ResponseType>() async {
    final response = await _sendRequest(
      callback: () => _httpClient.delete(
        Uri.parse(_path),
      ),
      method: "DELETE",
    );

    return _deserialize<ResponseType>(response.body);
  }

  Future<http.Response> _sendRequest({
    required Future<http.Response> Function() callback,
    required String method,
  }) async {
    final response = await callback();

    if (response.statusCode > 299) {
      throw GazelleApiClientException(
        path: _path,
        httpMethod: method,
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

  T _deserialize<T>(String json) {
    late final dynamic jsonObject;
    try {
      jsonObject = jsonDecode(json);
    } on FormatException {
      jsonObject = json;
    }
    return deserialize<T>(
      jsonObject: jsonObject,
      modelProvider: _gazelleModelProvider,
    );
  }

  List<T> _deserializeList<T>(String json) => deserializeList<T>(
        list: jsonDecode(json),
        modelProvider: _gazelleModelProvider,
      );
}
