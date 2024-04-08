import 'package:gazelle_core/gazelle_core.dart';
import 'package:test/test.dart';

void main() {
  group('GazelleHttpMethod tests', () {
    test('Should return GazelleHttpMethod from string', () {
      // Arrange
      final methods = [
        "GET",
        "HEAD",
        "POST",
        "PUT",
        "PATCH",
        "DELETE",
        "OPTIONS",
      ];

      // Act
      final results = methods.map(GazelleHttpMethod.fromString).toList();

      // Assert
      expect(results, GazelleHttpMethod.values);
    });

    test('Should throw exception when method is not expected', () {
      // Arrange
      final method = "UNEXPECTED";

      try {
        // Act
        GazelleHttpMethod.fromString(method);
        fail("Should have thrown an exception.");
      } catch (e) {
        // Assert
        expect(e.toString(), "Unexpected method: $method");
      }
    });

    test('Should return name of GazelleHttpMethod', () {
      // Arrange
      final methods = [
        "GET",
        "HEAD",
        "POST",
        "PUT",
        "PATCH",
        "DELETE",
        "OPTIONS",
      ];

      // Act
      final results = GazelleHttpMethod.values.map((e) => e.name).toList();

      // Assert
      expect(results, methods);
    });
  });
}
