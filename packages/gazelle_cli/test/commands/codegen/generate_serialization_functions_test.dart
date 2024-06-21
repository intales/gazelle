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
