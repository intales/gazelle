import 'package:gazelle_core/gazelle_core.dart';
import 'package:http/http.dart' as http;

class GazelleRouteClient<T> {
  final GazelleModelProvider gazelleModelProvider;
  final http.Client httpClient;
  final String path;

  const GazelleRouteClient({
    required this.gazelleModelProvider,
    required this.httpClient,
    required this.path,
  });

  GazelleRouteClient<R> call<R>(String path) => GazelleRouteClient<R>(
        gazelleModelProvider: gazelleModelProvider,
        httpClient: httpClient,
        path: "${this.path}/$path",
      );

  Future<String> get({Map<String, dynamic>? queryParams}) async {
    Uri uri = Uri.parse(path);

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringQueryParams = queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      uri = uri.replace(queryParameters: stringQueryParams);
    }

    final response = await httpClient.get(uri);

    return response.body;
  }

  Future<String> post({Map<String, dynamic>? body}) async {
    final response = await httpClient.post(
      Uri.parse(path),
      body: body,
    );

    return response.body;
  }

  Future<String> put({Map<String, dynamic>? body}) async {
    final response = await httpClient.put(
      Uri.parse(path),
      body: body,
    );

    return response.body;
  }

  Future<String> patch({Map<String, dynamic>? body}) async {
    final response = await httpClient.patch(
      Uri.parse(path),
      body: body,
    );

    return response.body;
  }

  Future<String> delete({Map<String, dynamic>? body}) async {
    final response = await httpClient.delete(
      Uri.parse(path),
      body: body,
    );

    return response.body;
  }
}
