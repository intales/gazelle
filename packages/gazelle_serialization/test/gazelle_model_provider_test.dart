import 'package:gazelle_serialization/src/gazelle_model_provider.dart';
import 'package:gazelle_serialization/src/gazelle_model_type.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _TestEntity {
  final String test;

  const _TestEntity({
    required this.test,
  });
}

class _TestModelType extends GazelleModelType<_TestEntity> {
  @override
  _TestEntity fromJson(Map<String, dynamic> json) {
    return _TestEntity(test: json["test"] as String);
  }

  @override
  Map<String, dynamic> toJson(_TestEntity value) {
    return {
      "test": value.test,
    };
  }
}

class _TestModelProvider extends GazelleModelProvider {
  @override
  Map<Type, GazelleModelType> get modelTypes => {
        _TestEntity: _TestModelType(),
      };
}

void main() {
  group('GazelleModelProvider tests', () {
    test('Should return the correct model type', () {
      // Arrange
      final modelProvider = _TestModelProvider();

      // Act
      final result = modelProvider.getModelTypeFor(_TestEntity);

      // Assert
      expect(result, isA<_TestModelType>());
    });
  });
}
