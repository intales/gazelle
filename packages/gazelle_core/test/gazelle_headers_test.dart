import 'package:gazelle_core/src/gazelle_headers.dart';
import 'package:test/test.dart';

void main() {
  group('GazelleHeaders tests', () {
    test('Should return a correct list of headers', () {
      // Arrange
      final headers = [
        'accept',
        'accept-encoding',
        'authorization',
        'content-type',
        'origin',
        'user-agent',
      ];

      // Act
      final result = headers.map(GazelleHeaders.fromString).toList();

      // Assert
      expect(result, GazelleHeaders.values);
    });

    test('Should throw exception when header is unexpected', () {
      // Arrange
      final header = "unexpected";

      try {
        // Act
        GazelleHeaders.fromString(header);
        fail("Should have thrown an exception.");
      } catch (e) {
        // Assert
        expect(e.toString(), "Unexpected header: $header");
      }
    });

    test('Should return a correct list of names', () {
      // Arrange
      final headers = [
        'accept',
        'accept-encoding',
        'authorization',
        'content-type',
        'origin',
        'user-agent',
      ];

      // Act
      final result = GazelleHeaders.values.map((e) => e.name).toList();

      // Assert
      expect(result, headers);
    });
  });
}
