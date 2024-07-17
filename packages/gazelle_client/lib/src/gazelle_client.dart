import 'package:gazelle_serialization/gazelle_serialization.dart';

import 'api/gazelle_api_client.dart';

/// The client for a Gazelle application.
class GazelleClient {
  final GazelleApiClient _apiClient;

  const GazelleClient._({
    required GazelleApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Api client.
  GazelleApiClient get api => _apiClient;

  /// Builds a [GazelleClient].
  static GazelleClient init({
    required String baseUrl,
    required GazelleModelProvider modelProvider,
  }) {
    final apiClient = GazelleApiClient(
      baseUrl: baseUrl,
      modelProvider: modelProvider,
    );

    return GazelleClient._(apiClient: apiClient);
  }
}
