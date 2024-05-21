import 'package:gazelle_core/gazelle_core.dart';
import 'package:test/test.dart';

void main() {
  group('GazelleRoute tests', () {
    test('Should return a copy of GazelleRoute with given params', () {
      // Arrange
      final route = GazelleRoute(
        name: "test",
        getHandler: (context, request, response) async => response.copyWith(
          statusCode: 200,
        ),
      );

      // Act
      final result = route.copyWith(
        preRequestHooks: [
          GazellePreRequestHook(
            (context, request, response) async => (request, response),
          )
        ],
        postResponseHooks: [
          GazellePostResponseHook(
            (context, request, response) async => (request, response),
          )
        ],
      );

      // Assert
      expect(result.preRequestHooks.length, 1);
      expect(result.postResponseHooks.length, 1);
    });
  });
}
