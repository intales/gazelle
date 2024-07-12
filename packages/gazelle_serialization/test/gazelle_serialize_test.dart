import 'package:gazelle_serialization/src/gazelle_model_provider.dart';
import 'package:gazelle_serialization/src/gazelle_model_type.dart';
import 'package:gazelle_serialization/src/gazelle_serialize.dart';
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
  group('Gazelle serialize tests', () {
    test('Should serialize', () {
      // Arrange
      final modelProvider = _TestModelProvider();
      final test = _Test(
        name: "filippo",
        age: 25,
        balance: 14.77,
        dayOfBirth: DateTime(1999, 4, 2),
      );

      final expected = {
        'name': 'filippo',
        'age': 25,
        'balance': 14.77,
        'dayOfBirth': DateTime(1999, 4, 2).toIso8601String(),
      };

      // Act
      final result = serialize(
        object: test,
        modelProvider: modelProvider,
      );

      expect(result, expected);
    });
  });
}
