import 'package:dart_style/dart_style.dart';

import 'class_definition.dart';
import 'generate_serialization_functions.dart';

/// Generates a `GazelleModelType` given a [classDefinition].
String generateModelType(ClassDefinition classDefinition) {
  final fromJson = generateFromJson(classDefinition);
  final toJson = generateToJson(classDefinition);

  final modelType = """
class ${classDefinition.name}ModelType extends GazelleModelType<${classDefinition.name}> {
  @override
  $toJson

  @override
  $fromJson
}
  """
      .trim();

  return DartFormatter().format(modelType);
}
