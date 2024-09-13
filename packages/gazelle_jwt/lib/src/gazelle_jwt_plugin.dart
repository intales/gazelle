import 'package:gazelle_core/gazelle_core.dart';
import '../gazelle_jwt.dart';
import 'gazelle_jwt_consts.dart';

/// A plugin for JSON Web Token (JWT) authentication in Gazelle.
/// Example Usage:
///
/// ```dart
/// final app = GazelleApp();
/// await app.registerPlugin(GazelleJwtPlugin("supersecret"));
///
/// app
///   ..post(
///     "/login",
///    (request) async {
///       return GazelleResponse(
///        statusCode: 200,
///         body: app.getPlugin<GazelleJwtPlugin>().sign({"test": "123"}),
///       );
///    },
///  )
///  ..get(
///  "/hello_world",
///  (request) async {
///  return GazelleResponse(
///     statusCode: 200,
///	body: "Hello, World!",
///  );
/// },
///   preRequestHooks: [app.getPlugin<GazelleJwtPlugin>().authenticationHook],
/// );
///
/// await app.start();
/// ```
class GazelleJwtPlugin implements GazellePlugin {
  /// The secret used for JWT signing and verification.
  final JWTKey _secret;

  /// Constructs a GazelleJwtPlugin instance with the provided [secret].
  GazelleJwtPlugin(this._secret);

  @override
  Future<void> initialize(GazelleContext context) async {}

  /// Signs a JWT with the provided [payload].
  String sign(Map<String, dynamic> payload) => JWT(payload).sign(_secret);

  /// Verifies and decodes a JWT token.
  JWT? verify(String token) => JWT.tryVerify(token, _secret);

  /// Returns a pre-request hook for JWT authentication.
  ///
  /// If [shareWithChildRoutes] is true, the hook will be shared with child routes.
  GazellePreRequestHook getAuthenticationHook({
    bool shareWithChildRoutes = true,
  }) =>
      GazellePreRequestHook(
        (context, request, response) async {
          final authHeader = request.headers
              .where((header) =>
                  header.header == GazelleHttpHeader.authorization.header)
              .firstOrNull
              ?.values
              .firstOrNull;
          if (authHeader == null) {
            return (
              request,
              GazelleResponse(
                statusCode: GazelleHttpStatusCode.error.unauthorized_401,
                body: kMissingAuthHeaderMessage,
              )
            );
          }

          if (!authHeader.startsWith(kBearerSchema)) {
            return (
              request,
              GazelleResponse(
                statusCode: GazelleHttpStatusCode.error.unauthorized_401,
                body: kBadBearerSchemaMessage,
              )
            );
          }

          final token = authHeader.replaceAll(kBearerSchema, "");
          final jwt = verify(token);
          if (jwt == null) {
            return (
              request,
              GazelleResponse(
                statusCode: GazelleHttpStatusCode.error.unauthorized_401,
                body: kInvalidTokenMessage,
              )
            );
          }

          return (
            request..setJwt(jwt),
            response,
          );
        },
        shareWithChildRoutes: shareWithChildRoutes,
      );

  /// Shortcut to get the authentication hook with default settings.
  GazellePreRequestHook get authenticationHook => getAuthenticationHook();
}
