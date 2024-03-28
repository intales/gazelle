import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:gazelle_core/gazelle_core.dart';
import 'gazelle_jwt_consts.dart';

class GazelleJwtPlugin implements GazellePlugin {
  final String _secret;
  late final SecretKey _secretKey;

  GazelleJwtPlugin(this._secret);

  @override
  Future<void> initialize(GazelleContext context) async {
    _secretKey = SecretKey(_secret);
  }

  String sign(Map<String, dynamic> payload) => JWT(payload).sign(_secretKey);

  JWT? verify(String token) => JWT.tryVerify(token, _secretKey);

  GazellePreRequestHook getAuthenticationHook({
    bool shareWithChildRoutes = true,
  }) =>
      GazellePreRequestHook(
        (request) async {
          final authHeader = request.headers[authHeaderName]?.first;
          if (authHeader == null) {
            return GazelleResponse(
              statusCode: 401,
              body: missingAuthHeaderMessage,
            );
          }

          if (!authHeader.startsWith(bearerSchema)) {
            return GazelleResponse(
              statusCode: 401,
              body: badBearerSchemaMessage,
            );
          }

          final token = authHeader.replaceAll(bearerSchema, "");
          final jwt = verify(token);
          if (jwt == null) {
            return GazelleResponse(
              statusCode: 401,
              body: invalidTokenMessage,
            );
          }

          return request.copyWith(metadata: {
            ...request.metadata,
            jwtKeyword: jwt,
          });
        },
        shareWithChildRoutes: shareWithChildRoutes,
      );

  GazellePreRequestHook get authenticationHook => getAuthenticationHook();
}
