import 'dart:convert';

import 'package:gazelle_serialization/gazelle_serialization.dart';
import 'package:http/http.dart' as http;

class GazelleRouteClient {
  final GazelleModelProvider gazelleModelProvider;
  final http.Client httpClient;
  final String path;

  const GazelleRouteClient({
    required this.gazelleModelProvider,
    required this.httpClient,
    required this.path,
  });

  GazelleRouteClient call(String path) => GazelleRouteClient(
        gazelleModelProvider: gazelleModelProvider,
        httpClient: httpClient,
        path: "${this.path}/$path",
      );

  Future<T> get<T>({Map<String, dynamic>? queryParams}) async {
    Uri uri = Uri.parse(path);

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringQueryParams = queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      uri = uri.replace(queryParameters: stringQueryParams);
    }

    final response = await httpClient.get(uri);

    return _deserialize<T>(response.body);
  }

  Future<List<T>> list<T>({Map<String, dynamic>? queryParams}) async {
    Uri uri = Uri.parse(path);

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringQueryParams = queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      uri = uri.replace(queryParameters: stringQueryParams);
    }

    final response = await httpClient.get(uri);

    return _deserializeList<T>(response.body);
  }

  Future<T> post<T>({required T body}) async {
    final response = await httpClient.post(
      Uri.parse(path),
      body: _serialize<T>(body),
    );

    return _deserialize<T>(response.body);
  }

  Future<T> put<T>({required T body}) async {
    final response = await httpClient.put(
      Uri.parse(path),
      body: _serialize<T>(body),
    );

    return _deserialize<T>(response.body);
  }

  Future<T> patch<T>({required T body}) async {
    final response = await httpClient.patch(
      Uri.parse(path),
      body: _serialize<T>(body),
    );

    return _deserialize<T>(response.body);
  }

  Future<T> delete<T>({required T body}) async {
    final response = await httpClient.delete(
      Uri.parse(path),
      body: _serialize<T>(body),
    );

    return _deserialize<T>(response.body);
  }

  String _serialize<T>(T object) => jsonEncode(serialize(
        object: object,
        modelProvider: gazelleModelProvider,
      ));

  T _deserialize<T>(String json) => deserialize<T>(
        jsonObject: jsonDecode(json),
        modelProvider: gazelleModelProvider,
      );

  List<T> _deserializeList<T>(String json) => deserializeList<T>(
        list: jsonDecode(json),
        modelProvider: gazelleModelProvider,
      );
}
