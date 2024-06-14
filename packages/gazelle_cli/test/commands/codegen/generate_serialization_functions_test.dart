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
	    name: json["name"] as String,
	    age: json["age"] as int,
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
      );

      // Act
      final result = generateToJson(classDefinition);

      // Assert
      expect(result, expected);
    });
  });
}
