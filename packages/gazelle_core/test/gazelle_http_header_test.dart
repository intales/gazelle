import 'package:gazelle_core/src/gazelle_http_header.dart';
import 'package:test/test.dart';

void main() {
  group('GazelleHttpHeader tests', () {
    test('Should return a header from a string', () {
      // Arrange
      const header = "Accept";

      // Act
      final result = GazelleHttpHeader.fromString(header);

      // Assert
      expect(result.header, GazelleHttpHeader.accept.header);
      expect(result.values, const <String>[]);
    });

    test('Should a new header from a string and values', () {
      // Arrange
      const header = "Accept";
      const values = ["a", "b", "c"];

      // Act
      final result = GazelleHttpHeader.fromString(header, values: values);

      // Assert
      expect(result.header, header);
      expect(result.values, values);
    });

    test('Should return a header with added values', () {
      // Arrange
      const header = GazelleHttpHeader.accept;
      const values = ["a", "b", "c"];
      const values_2 = ["d", "e", "f"];

      // Act
      final result = header.addValues(values).addValues(values_2);

      // Assert
      expect(result.values, [...values, ...values_2]);
    });

    test('Should return a header with added value', () {
      // Arrange
      const header = GazelleHttpHeader.accept;
      const value = "a";
      const value_2 = "d";

      // Act
      final result = header.addValue(value).addValue(value_2);

      // Assert
      expect(result.values, [value, value_2]);
    });
  });
}
