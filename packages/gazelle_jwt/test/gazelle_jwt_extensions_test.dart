import 'dart:typed_data';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_jwt/gazelle_jwt.dart';
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
        bodyStream: Stream.value(Uint8List(0)),
      )..setJwt(jwt);

      // Act
      final result = request.jwt;

      // Assert
      expect(result, jwt);
    });
  });
}
