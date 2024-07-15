import 'package:gazelle_serialization/gazelle_serialization.dart';
import 'package:http/http.dart' as http;

import 'gazelle_route_client.dart';

/// The API client for a Gazelle application.
class GazelleApiClient {
  final String _baseUrl;
  final GazelleModelProvider _gazelleModelProvider;
  late final http.Client _httpClient;

  /// Builds an API client.
  GazelleApiClient({
    required String baseUrl,
    required GazelleModelProvider modelProvider,
  })  : _gazelleModelProvider = modelProvider,
        _baseUrl = baseUrl {
    _httpClient = http.Client();
  }

  /// Gives access to HTTP methods.
  GazelleRouteClient call(String path) => GazelleRouteClient(
        gazelleModelProvider: _gazelleModelProvider,
        httpClient: _httpClient,
        path: "$_baseUrl/$path",
      );
}
