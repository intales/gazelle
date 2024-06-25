import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:gazelle_cli/commands/codegen/class_definition.dart';
import 'package:gazelle_cli/commands/codegen/generate_gazelle_model_provider.dart';
import 'package:test/test.dart';

void main() {
  group('GenerateModelProvider tests', () {
    test('Should generate a map of model types', () {
      // Arrange
      const expected = """
      import 'package:gazelle_core/gazelle_core.dart';
      import '../entities/user.dart';
      import '../entities/propic.dart';
      import 'user_model_type.dart';
      import 'propic_model_type.dart';

      class ProjectNameModelProvider extends GazelleModelProvider {
        @override
        Map<Type, GazelleModelType> get modelTypes => {
          User: UserModelType(),
          Propic: PropicModelType(),
        };
      }""";
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
      final result = generateModelProvider(
        "project_name",
        classDefinitions,
        [
          File("user_model_type.dart"),
          File("propic_model_type.dart"),
        ],
        [
          File("user.dart"),
          File("propic.dart"),
        ],
      );

      // Assert
      expect(result, DartFormatter().format(expected));
    });
  });
}
