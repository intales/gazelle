import 'package:gazelle_cli/commands/codegen/class_definition.dart';
import 'package:gazelle_cli/commands/codegen/generate_serialization_functions.dart';
import 'package:test/test.dart';

void main() {
  group('GenerateSerializationFunctions tests', () {
    test('Should generate a fromJson function', () {
      // Arrange
      final expected = """
	User fromJson(Map<String, dynamic> json) {
	  return User(
	    json["name"],
	    age: json["age"],
	    propic: PropicModelType().fromJson(json["propic"]),
	  );
	}
      """
          .trim()
          .replaceAll("\t", "");
      final classDefinition = ClassDefinition(
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

      // Act
      final result = generateFromJson(classDefinition);

      // Assert
      expect(result, expected);
    });

    test('Should generate a toJson function', () {
      // Arrange
      final expected = """
	Map<String, dynamic> toJson(User value) {
	  return {
	    "name": value.name,
	    "age": value.age,
	    "propic": PropicModelType().toJson(value.propic),
	  };
	}
      """
          .trim()
          .replaceAll("\t", "");
      final classDefinition = ClassDefinition(
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
        constructorParameters: {},
      );

      // Act
      final result = generateToJson(classDefinition);

      // Assert
      expect(result, expected);
    });
  });
}
