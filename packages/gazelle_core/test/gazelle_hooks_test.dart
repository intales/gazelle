import 'package:gazelle_core/gazelle_core.dart';
import 'package:test/test.dart';

void main() {
  group('Gazelle hooks tests', () {
    group('GazellePreRequestHook tests', () {
      test('Should return a GazelleResponse', () {
        // Arrange
        final request = GazelleRequest(
          uri: Uri.parse("http://localhost/test"),
          method: GazelleHttpMethod.get,
          pathParameters: {},
        );
        hook(request) => GazelleResponse(
              statusCode: GazelleHttpStatus.unauthorized,
              body: "Unauthorized",
            );

        // Act
        final result = hook(request);

        // Assert
        expect(result, isA<GazelleResponse>());
      });
      test('Should return a GazelleRequest', () {
        // Arrange
        final request = GazelleRequest(
          uri: Uri.parse("http://localhost/test"),
          method: GazelleHttpMethod.get,
          pathParameters: {},
        );
        hook(request) => request;

        // Act
        final result = hook(request);

        // Assert
        expect(result, isA<GazelleRequest>());
      });
    });
    group('GazellePostResponseHook tests', () {
      test('Should return a response', () {
        // Arrange
        final response = GazelleResponse(
          statusCode: GazelleHttpStatus.ok,
          body: "OK",
        );
        hook(response) => response;

        // Act
        final result = hook(response);

        // Assert
        expect(result, isA<GazelleResponse>());
      });
    });
  });
}
