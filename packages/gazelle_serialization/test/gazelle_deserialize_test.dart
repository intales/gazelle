import 'package:gazelle_serialization/src/gazelle_deserialize.dart';
import 'package:gazelle_serialization/src/gazelle_model_provider.dart';
import 'package:gazelle_serialization/src/gazelle_model_type.dart';
import 'package:test/test.dart';

class _Test {
  final String name;
  final int age;
  final double balance;
  final DateTime dayOfBirth;

  const _Test({
    required this.name,
    required this.age,
    required this.balance,
    required this.dayOfBirth,
  });
}

class _TestModelType extends GazelleModelType<_Test> {
  @override
  _Test fromJson(Map<String, dynamic> json) {
    return _Test(
      name: json["name"] as String,
      age: json["age"] as int,
      balance: json["balance"] as double,
      dayOfBirth: DateTime.parse(json["dayOfBirth"]),
    );
  }

  @override
  Map<String, dynamic> toJson(_Test value) {
    return {
      'name': value.name,
      'age': value.age,
      'balance': value.balance,
      'dayOfBirth': value.dayOfBirth.toIso8601String(),
    };
  }
}

class _TestModelProvider extends GazelleModelProvider {
  @override
  Map<Type, GazelleModelType> get modelTypes => {_Test: _TestModelType()};
}

void main() {
  group('Gazelle deserialize tests', () {
    test('Should de-serialize', () {
      // Arrange
      final modelProvider = _TestModelProvider();
      final jsonObject = {
        'name': 'filippo',
        'age': 25,
        'balance': 14.77,
        'dayOfBirth': DateTime(1999, 4, 2).toIso8601String(),
      };

      final expected = _Test(
        name: "filippo",
        age: 25,
        balance: 14.77,
        dayOfBirth: DateTime(1999, 4, 2),
      );

      // Act
      final result = deserialize<_Test>(
        jsonObject: jsonObject,
        modelProvider: modelProvider,
      );

      // Assert
      expect(result.name, expected.name);
      expect(result.age, expected.age);
      expect(result.balance, expected.balance);
      expect(result.dayOfBirth, expected.dayOfBirth);
    });

    test('Should de-serialize a List', () {
      // Arrange
      final modelProvider = _TestModelProvider();

      final list = [
        {
          'name': 'filippo',
          'age': 25,
          'balance': 14.77,
          'dayOfBirth': DateTime(1999, 4, 2).toIso8601String(),
        },
        {
          'name': 'elia',
          'age': 26,
          'balance': 18.77,
          'dayOfBirth': DateTime(1997, 12, 13).toIso8601String(),
        },
      ];

      final expected = [
        _Test(
          name: "filippo",
          age: 25,
          balance: 14.77,
          dayOfBirth: DateTime(1999, 4, 2),
        ),
        _Test(
          name: "elia",
          age: 26,
          balance: 18.77,
          dayOfBirth: DateTime(1997, 12, 13),
        ),
      ];

      // Act
      final result = deserializeList<_Test>(
        list: list,
        modelProvider: modelProvider,
      );

      // Assert
      expect(result.length, 2);
      expect(result, isA<List<_Test>>());

      expect(result.first.name, expected.first.name);
      expect(result.first.age, expected.first.age);
      expect(result.first.balance, expected.first.balance);
      expect(result.first.dayOfBirth, expected.first.dayOfBirth);

      expect(result.last.name, expected.last.name);
      expect(result.last.age, expected.last.age);
      expect(result.last.balance, expected.last.balance);
      expect(result.last.dayOfBirth, expected.last.dayOfBirth);
    });
  });
}
