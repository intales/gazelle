import 'dart:io';

import 'class_definition.dart';
import 'generate_gazelle_model_provider.dart';

/// Generates the model provider file for the current project.
Future<File> generateModelProviderFile(
  String projectName,
  List<ClassDefinition> classDefinitions,
  List<File> modelTypesFiles,
  List<File> entitiesFiles,
  String fileName,
) async {
  final modelProvider = generateModelProvider(
    projectName,
    classDefinitions,
    modelTypesFiles,
    entitiesFiles,
  );

  return File(fileName)
      .create(recursive: true)
      .then((file) => file.writeAsString(modelProvider));
}
