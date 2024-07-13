import 'package:gazelle_client/src/api/gazelle_route_client.dart';
import 'package:gazelle_serialization/gazelle_serialization.dart';
import 'package:http/http.dart' as http;

class GazelleApiClient {
  final String _baseUrl;
  final GazelleModelProvider _gazelleModelProvider;
  late final http.Client _httpClient;

  GazelleApiClient({
    required String baseUrl,
    required GazelleModelProvider modelProvider,
  })  : _gazelleModelProvider = modelProvider,
        _baseUrl = baseUrl {
    _httpClient = http.Client();
  }

  GazelleRouteClient<T> call<T>(String path) => GazelleRouteClient<T>(
        gazelleModelProvider: _gazelleModelProvider,
        httpClient: _httpClient,
        path: "$_baseUrl/$path",
      );
}
