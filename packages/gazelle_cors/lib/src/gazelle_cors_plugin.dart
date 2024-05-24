import 'package:gazelle_core/gazelle_core.dart';

/// A plugin for managing CORS (Cross-Origin Resource Sharing) headers in Gazelle applications.
///
/// The [GazelleCorsPlugin] class provides functionality for adding CORS headers to HTTP responses,
/// allowing cross-origin requests to access server resources securely.
class GazelleCorsPlugin implements GazellePlugin {
  /// Default CORS headers to be included in responses.
  static final _defaultCorsHeaders = <GazelleHttpHeader>[
    GazelleHttpHeader.accessControlExposeHeaders.addValue(""),
    GazelleHttpHeader.accessControlAllowCredentials.addValue(""),
    GazelleHttpHeader.accessControlAllowHeaders.addValues([
      GazelleHttpHeader.accept.header,
      GazelleHttpHeader.acceptEncoding.header,
      GazelleHttpHeader.authorization.header,
      GazelleHttpHeader.contentType.header,
      GazelleHttpHeader.origin.header,
      GazelleHttpHeader.userAgent.header,
    ]),
    GazelleHttpHeader.accessControlAllowMethods.addValues(
      GazelleHttpMethod.values.map((method) => method.name).toList(),
    ),
    GazelleHttpHeader.accessControlMaxAge.addValue('86400'),
  ];

  /// Custom CORS headers provided by the user.
  final List<GazelleHttpHeader>? _corsHeaders;

  /// Constructs a [GazelleCorsPlugin] instance.
  ///
  /// The optional [corsHeaders] parameter allows customization of CORS headers.
  const GazelleCorsPlugin({
    List<GazelleHttpHeader>? corsHeaders,
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
          final origin = request.headers
              .where(
                  (header) => header.header == GazelleHttpHeader.origin.header)
              .firstOrNull
              ?.values;
          if (origin == null) return (request, response);

          // Combine default and custom CORS headers
          final headers = <GazelleHttpHeader>{
            ..._defaultCorsHeaders,
            ...?_corsHeaders,
          };

          // Set Access-Control-Allow-Origin header
          final accessControlAllowOrigin = _corsHeaders
              ?.where((header) =>
                  header.header ==
                  GazelleHttpHeader.accessControlAllowOrigin.header)
              .firstOrNull
              ?.values;
          if (accessControlAllowOrigin != null) {
            headers.add(GazelleHttpHeader.accessControlAllowOrigin
                .addValues(accessControlAllowOrigin));
            headers.add(GazelleHttpHeader.vary
                .addValue(GazelleHttpHeader.origin.header));
          } else {
            headers.add(
                GazelleHttpHeader.accessControlAllowOrigin.addValues(origin));
          }

          final newHeaders = {
            ...request.headers,
            ...headers,
          }.toList();

          // Handle preflight OPTIONS requests
          if (request.method == GazelleHttpMethod.options) {
            return (
              request,
              response.copyWith(
                statusCode: GazelleHttpStatusCode.success.ok_200,
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
