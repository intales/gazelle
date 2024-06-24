import 'dart:io';

import 'package:dart_style/dart_style.dart';

import 'class_definition.dart';
import 'generate_gazelle_model_type.dart';

/// Generates a [File] containing a GazelleModelType for the given [classDefinitions].
Future<File> generateModelTypeFile(
  List<ClassDefinition> classDefinitions,
  List<String> filesToImport,
  String fileName,
) async {
  final gazelleCoreImport = "import 'package:gazelle_core/gazelle_core.dart';";
  final imports =
      filesToImport.map((file) => "import '../entities/$file';").join("\n");

  final modelTypes = classDefinitions.map(generateModelType).join("\n");

  final contents = """
  $gazelleCoreImport
  $imports

  $modelTypes
  """
      .trim();

  return File(fileName)
      .create(recursive: true)
      .then((file) => file.writeAsString(DartFormatter().format(contents)));
}
