import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_jwt/gazelle_jwt.dart';
import 'package:gazelle_jwt/src/gazelle_jwt_consts.dart';
import 'package:test/test.dart';

void main() {
  group('GazelleJwtRequestExtension tests', () {
    test('Should return a jwt token', () {
      // Arrange
      final jwt = JWT({
        "id": "123",
      });
      final request = GazelleRequest(
        uri: Uri.parse("http://localhost/test"),
        method: GazelleHttpMethod.get,
        pathParameters: {},
        metadata: {
          jwtKeyword: jwt,
        },
      );

      // Act
      final result = request.jwt;

      // Assert
      expect(result, jwt);
    });
  });
}
