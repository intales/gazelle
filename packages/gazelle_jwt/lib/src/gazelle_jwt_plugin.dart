import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:gazelle_core/gazelle_core.dart';
import 'gazelle_jwt_consts.dart';

class GazelleJwtPlugin implements GazellePlugin {
  static const _authHeaderName = "Authorization";
  static const _bearerSchema = "Bearer ";
  static const _unauthorized = "Unauthorized";

  final String _secret;
  late final SecretKey _secretKey;

  GazelleJwtPlugin(this._secret);

  @override
  Future<void> initialize(GazelleContext context) async {
    _secretKey = SecretKey(_secret);
  }

  String sign(Map<String, dynamic> payload) => JWT(payload).sign(_secretKey);

  JWT? verify(String token) => JWT.tryVerify(token, _secretKey);

  GazellePreRequestHook get authenticationHook => (request) async {
        final authHeader = request.headers[_authHeaderName]?.first;
        if (authHeader == null) {
          return GazelleResponse(
            statusCode: 401,
            body: _unauthorized,
          );
        }

        if (!authHeader.startsWith(_bearerSchema)) {
          return GazelleResponse(
            statusCode: 401,
            body: _unauthorized,
          );
        }

        final token = authHeader.replaceAll(_bearerSchema, "");
        final jwt = verify(token);
        if (jwt == null) {
          return GazelleResponse(
            statusCode: 401,
            body: _unauthorized,
          );
        }

        return request.copyWith(metadata: {
          ...request.metadata,
          jwtKeyword: jwt,
        });
      };
}
