import 'dart:io';

import 'package:dart_style/dart_style.dart';

import 'class_definition.dart';

/// Generates the model provider for the current project.
String generateModelProvider(
  String projectName,
  List<ClassDefinition> classDefinitions,
  List<File> modelTypesFiles,
  List<File> entitiesFiles,
) {
  final entitiesImports = <String>[];
  for (final entityFile in entitiesFiles) {
    final importPath = entityFile.path.split("/").last;
    final import = "import '../entities/$importPath';";

    entitiesImports.add(import);
  }

  final modelTypeImports = <String>[];
  for (final modelTypeFile in modelTypesFiles) {
    final importPath = modelTypeFile.path.split("/").last;
    final import = "import '$importPath';";

    modelTypeImports.add(import);
  }

  final modelProviderClassName = projectName
      .split("_")
      .map((e) => e.replaceFirst(e[0], e[0].toUpperCase()))
      .join();

  final modelTypes = <String, String>{};
  for (final classDefinition in classDefinitions) {
    final type = classDefinition.name;
    final modelType = "${classDefinition.name}ModelType()";

    modelTypes[type] = modelType;
  }

  String modelTypesOverride =
      "Map<Type, GazelleModelType> get modelTypes => {\n";
  for (final keyValue in modelTypes.entries) {
    final key = keyValue.key;
    final value = keyValue.value;

    modelTypesOverride += "$key: $value,\n";
  }
  modelTypesOverride += "};";

  final result = """
  import 'package:gazelle_core/gazelle_core.dart';
  ${entitiesImports.join("\n")}
  ${modelTypeImports.join("\n")}

  class ${modelProviderClassName}ModelProvider extends GazelleModelProvider {
    @override
    $modelTypesOverride
  }
  """
      .trim();

  return DartFormatter().format(result);
}
