import 'dart:io';

import 'package:dart_style/dart_style.dart';

import 'class_definition.dart';
import 'generate_gazelle_model_type.dart';

/// Generates a [File] containing a GazelleModelType for the given [classDefinitions].
Future<File> generateModelTypeFile(
  List<ClassDefinition> classDefinitions,
  List<String> entitiesImports,
  List<String> modelTypesImports,
  String fileName,
) async {
  // Generate model types
  final modelTypes = classDefinitions.map(generateModelType).join("\n");
  final gazelleCoreImport = "import 'package:gazelle_core/gazelle_core.dart';";
  final entitiesToImport =
      entitiesImports.map((file) => "import '../entities/$file';").join("\n");

  // Deduct which model types this model type needs to import
  final modelTypesToImport = modelTypesImports
      .map((file) => _getModelTypeImport(file, modelTypes))
      .whereType<String>()
      .map((import) => "import '$import';")
      .join("\n");

  // Complete list of imports
  final imports =
      [gazelleCoreImport, entitiesToImport, modelTypesToImport].join("\n");

  final contents = """
  $imports

  $modelTypes
  """
      .trim();

  return File(fileName)
      .create(recursive: true)
      .then((file) => file.writeAsString(DartFormatter().format(contents)));
}

String? _getModelTypeImport(String import, String modelTypes) {
  final modelTypeName = import
      .replaceAll(".dart", "")
      .split("_")
      .map((e) => e.replaceFirst(e[0], e[0].toUpperCase()))
      .join();

  if (modelTypes.contains(modelTypeName)) return import;
  return null;
}
