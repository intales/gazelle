import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:gazelle_cli/commands/codegen/analyze_entities.dart';
import 'package:gazelle_cli/commands/codegen/generate_model_provider.dart';
import 'package:test/test.dart';
import '../../commons/constants/resources.dart';


void main() {
  group('GenerateModelProvider tests', () {
    test('Should generate a model provider', () async {
      // Arrange
      final entitiesDirectoryPath =
          "tmp/generate_model_provider_tests/entities";
      final modelTypesPath = "tmp/generate_model_provider_tests/models";
      final entitiesDirectory = Directory(entitiesDirectoryPath);
      final modelTypesDirectory = Directory(modelTypesPath);
      if (entitiesDirectory.existsSync()) {
        entitiesDirectory.deleteSync(recursive: true);
      }
      if (modelTypesDirectory.existsSync()) {
        modelTypesDirectory.deleteSync(recursive: true);
      }
      entitiesDirectory.createSync(recursive: true);
      File("$entitiesDirectoryPath/user/user.dart")
        ..createSync(recursive: true)
        ..writeAsStringSync(TestStrings.generateModelProviderUserClass);
      File("$entitiesDirectoryPath/post.dart")
        ..createSync(recursive: true)
        ..writeAsStringSync(TestStrings.generateModelProviderPostClass);

      // Act
      final classes = await analyzeEntities(entitiesDirectory);
      final result = await generateModelProvider(
        projectName: "Test",
        sourceFiles: classes,
        entitiesBasePath: entitiesDirectoryPath.split("/").last,
        destinationPath: modelTypesPath,
      );

      // Assert
      final modelProvider = await result.modelProvider.readAsString();
      expect(modelProvider,
          equals(DartFormatter().format(TestStrings.generateModelProviderExpectedModelProvider)));

      final modelTypes =
          await Future.wait(result.modelTypes.map((e) => e.readAsString()));
      for (final modelType in modelTypes) {
        if (modelType.contains("class PostModelType")) {
          expect(
            modelType,
            equals(DartFormatter().format(TestStrings.generateModelProviderExpectedPostModelType)),
          );
        }
        if (modelType.contains("class UserModelType")) {
          expect(
            modelType,
            equals(DartFormatter().format(
                TestStrings.generateModelProviderExpectedUserModelType)),
          );
        }
      }

      // Tear down
      entitiesDirectory.deleteSync(recursive: true);
      modelTypesDirectory.deleteSync(recursive: true);
    });
  });
}
