import 'package:dart_style/dart_style.dart';

import 'class_definition.dart';

/// Returns a `fromJson` function from a [classDefinition].
String generateFromJson(ClassDefinition classDefinition) {
  final constructorParameters =
      _generateFromJsonConstructorProps(classDefinition.properties);

  final classOutput = """
  ${classDefinition.name} fromJson(Map<String, dynamic> json) {
    return ${classDefinition.name}(
      $constructorParameters
    );
  }
  """;

  final result = DartFormatter().format(classOutput).trim();
  return result;
}

String _generateFromJsonConstructorProps(
  Set<ClassPropertyDefinition> classPropertyDefinitions,
) {
  final parameters = <String>[];
  for (final propDefinition in classPropertyDefinitions) {
    final parameter =
        "${propDefinition.name}: json[\"${propDefinition.name}\"] as ${propDefinition.type},";
    parameters.add(parameter);
  }

  return parameters.join("\n");
}

/// Returns a `toJson` function from a [classDefinition].
String generateToJson(ClassDefinition classDefinition) {
  final constructorParameters =
      _generateToJsonConstructorProps(classDefinition.properties);

  final classOutput = """
  Map<String, dynamic> toJson(${classDefinition.name} value) {
    return {
      $constructorParameters
    };
  }
  """;

  final result = DartFormatter().format(classOutput).trim();
  return result;
}

String _generateToJsonConstructorProps(
  Set<ClassPropertyDefinition> classPropertyDefinitions,
) {
  final parameters = <String>[];
  for (final propDefinition in classPropertyDefinitions) {
    final parameter =
        "\"${propDefinition.name}\": value.${propDefinition.name},";
    parameters.add(parameter);
  }

  return parameters.join("\n");
}
