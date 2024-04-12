import 'package:gazelle_cors/gazelle_cors.dart';
import 'package:test/test.dart';

void main() {
  group("GazelleCorsHeaders tests", () {
    test('Should return header name for every header', () {
      // Arrange
      final headers = [
        "access-control-allow-origin",
        "access-control-expose-headers",
        "access-control-allow-credentials",
        "access-control-allow-headers",
        "access-control-allow-methods",
        "access-control-max-age",
        "vary",
      ];

      // Act
      final results = GazelleCorsHeaders.values.map((e) => e.name);

      // Assert
      expect(results, headers);
    });

    test('Should return header for every header name', () {
      // Arrange
      final headers = [
        "access-control-allow-origin",
        "access-control-expose-headers",
        "access-control-allow-credentials",
        "access-control-allow-headers",
        "access-control-allow-methods",
        "access-control-max-age",
        "vary",
      ];

      // Act
      final results = headers.map(GazelleCorsHeaders.fromString);

      // Assert
      expect(results, GazelleCorsHeaders.values);
    });
  });
}
