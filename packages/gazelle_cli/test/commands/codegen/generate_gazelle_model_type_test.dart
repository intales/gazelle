import 'package:dart_style/dart_style.dart';
import 'package:gazelle_cli/commands/codegen/class_definition.dart';
import 'package:gazelle_cli/commands/codegen/generate_gazelle_model_type.dart';
import 'package:test/test.dart';

void main() {
  group('GenerateModelType tests', () {
    test('Should generate a model type', () {
      // Arrange
      const classDefinition = ClassDefinition(
        name: "User",
        properties: {
          ClassPropertyDefinition(
            name: "name",
            type: "String",
          ),
          ClassPropertyDefinition(
            name: "age",
            type: "int",
          ),
          ClassPropertyDefinition(
            name: "propic",
            type: "Propic",
          ),
        },
        constructorParameters: {
          ClassConstructorParameter(
            position: 0,
            isNamed: false,
            name: "name",
          ),
          ClassConstructorParameter(
            name: "age",
            isNamed: true,
          ),
          ClassConstructorParameter(
            name: "propic",
            type: "Propic",
            isNamed: true,
          ),
        },
      );

      const expected = """
      class UserModelType extends GazelleModelType<User> {
        @override
        Map<String, dynamic> toJson(User value) {
	  return {
	    "name": value.name,
	    "age": value.age,
	    "propic": PropicModelType().toJson(value.propic),
	  };
	}

	@override
	User fromJson(Map<String, dynamic> json) {
	  return User(
	    json["name"],
	    age: json["age"],
	    propic: PropicModelType().fromJson(json["propic"]),
	  );
	}
      }
      """;

      // Act
      final result = generateModelType(classDefinition);

      // Assert
      expect(result, DartFormatter().format(expected));
    });
  });
}
