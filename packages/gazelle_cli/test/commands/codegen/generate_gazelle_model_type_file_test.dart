import 'package:dart_style/dart_style.dart';
import 'package:gazelle_cli/commands/codegen/class_definition.dart';
import 'package:gazelle_cli/commands/codegen/generate_gazelle_model_type_file.dart';
import 'package:test/test.dart';

void main() {
  group('GenerateModelTypeFile tests', () {
    test('Should generate a model type file', () async {
      // Arrange
      const expected = """
      import 'package:gazelle_core/gazelle_core.dart';
      import '../entities/metadata.dart';

      class UserModelType extends GazelleModelType<User> {
        @override
        Map<String, dynamic> toJson(User value) {
	  return {
	    "name": value.name,
	    "age": value.age,
	    "propic": PropicModelType().toJson(value.propic),
	    "metadata": MetadataModelType().toJson(value.metadata),
	  };
	}

	@override
	User fromJson(Map<String, dynamic> json) {
	  return User(
	    json["name"],
	    age: json["age"],
	    propic: PropicModelType().fromJson(json["propic"]),
	    metadata: MetadataModelType().fromJson(json["metadata"]),
	  );
	}
      }

      class PropicModelType extends GazelleModelType<Propic> {
        @override
	Map<String, dynamic> toJson(Propic value) {
	  return {
	    "url": value.url,
	    "size": value.size,
	  };
	}

	@override
	Propic fromJson(Map<String, dynamic> json) {
	  return Propic(
	    url: json["url"],
	    size: json["size"],
	  );
	}
      }
      """;
      const fileName = "tmp/generate_mode_type_file_tests/user_model_type.dart";
      const classDefinitions = [
        ClassDefinition(
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
            ClassPropertyDefinition(
              name: "metadata",
              type: "Metadata",
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
            ClassConstructorParameter(
              name: "metadata",
              type: "Metadata",
              isNamed: true,
            ),
          },
        ),
        ClassDefinition(
          name: "Propic",
          properties: {
            ClassPropertyDefinition(
              name: "url",
              type: "String",
            ),
            ClassPropertyDefinition(
              name: "size",
              type: "int",
            ),
          },
          constructorParameters: {
            ClassConstructorParameter(
              name: "url",
              isNamed: true,
            ),
            ClassConstructorParameter(
              name: "size",
              isNamed: true,
            ),
          },
        ),
      ];

      // Act
      final result = await generateModelTypeFile(
        classDefinitions,
        ["metadata.dart"],
        fileName,
      );

      // Assert
      expect(
          result.readAsStringSync(), DartFormatter().format(expected.trim()));

      // Tear down
      await result.delete(recursive: true);
    });
  });
}
