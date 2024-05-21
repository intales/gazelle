import 'package:gazelle_core/gazelle_core.dart';

import 'gazelle_cors_headers.dart';

/// A plugin for managing CORS (Cross-Origin Resource Sharing) headers in Gazelle applications.
///
/// The [GazelleCorsPlugin] class provides functionality for adding CORS headers to HTTP responses,
/// allowing cross-origin requests to access server resources securely.
class GazelleCorsPlugin implements GazellePlugin {
  /// Default CORS headers to be included in responses.
  static final _defaultCorsHeaders = <String, List<String>>{
    GazelleCorsHeaders.accessControlExposeHeaders.name: [''],
    GazelleCorsHeaders.accessControlAllowCredentials.name: [''],
    GazelleCorsHeaders.accessControlAllowHeaders.name:
        GazelleHeaders.values.map((header) => header.name).toList(),
    GazelleCorsHeaders.accessControlAllowMethods.name:
        GazelleHttpMethod.values.map((method) => method.name).toList(),
    GazelleCorsHeaders.accessControlMaxAge.name: ['86400'],
  };

  /// Custom CORS headers provided by the user.
  final Map<String, List<String>>? _corsHeaders;

  /// Constructs a [GazelleCorsPlugin] instance.
  ///
  /// The optional [corsHeaders] parameter allows customization of CORS headers.
  const GazelleCorsPlugin({
    Map<String, List<String>>? corsHeaders,
  }) : _corsHeaders = corsHeaders;

  @override
  Future<void> initialize(GazelleContext context) async {}

  /// Returns a pre-request hook for handling CORS requests.
  ///
  /// The [corsHook] intercepts incoming requests, adds appropriate CORS headers,
  /// and handles preflight OPTIONS requests.
  GazellePreRequestHook get corsHook => GazellePreRequestHook(
        (context, request, response) async {
          // Check if the request includes an Origin header
          final origin = request.headers[GazelleHeaders.origin.name];
          if (origin == null) return (request, response);

          // Combine default and custom CORS headers
          final headers = <String, List<String>>{
            ..._defaultCorsHeaders,
            ...?_corsHeaders,
          };

          // Set Access-Control-Allow-Origin header
          final accessControlAllowOrigin =
              _corsHeaders?[GazelleCorsHeaders.accessControlAllowOrigin.name];
          if (accessControlAllowOrigin != null) {
            headers[GazelleCorsHeaders.accessControlAllowOrigin.name] =
                accessControlAllowOrigin;
            headers[GazelleCorsHeaders.vary.name] = [
              GazelleHeaders.origin.name,
            ];
          } else {
            headers[GazelleCorsHeaders.accessControlAllowOrigin.name] = origin;
          }

          final newHeaders = {
            ...request.headers,
            ...headers,
          };

          // Handle preflight OPTIONS requests
          if (request.method == GazelleHttpMethod.options) {
            return (
              request,
              response.copyWith(
                statusCode: 200,
                headers: newHeaders,
              )
            );
          }

          // Add CORS headers to the request
          return (
            request,
            response.copyWith(
              headers: newHeaders,
            )
          );
        },
        shareWithChildRoutes: true,
      );
}
