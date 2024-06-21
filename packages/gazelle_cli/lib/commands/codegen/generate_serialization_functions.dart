import 'package:dart_style/dart_style.dart';

import 'class_definition.dart';

/// Returns a `fromJson` function from a [classDefinition].
String generateFromJson(ClassDefinition classDefinition) {
  final constructorParameters =
      _generateFromJsonConstructorProps(classDefinition.constructorParameters);

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
  Set<ClassConstructorParameter> constructorParameters,
) {
  final parameters = <String>[];
  final positionalParameters = constructorParameters
      .where((parameter) => parameter.position != null)
      .toList()
    ..sort((a, b) => a.position!.compareTo(b.position!));
  for (final positionalParameter in positionalParameters) {
    final parameter = "json[\"${positionalParameter.name}\"],";
    parameters.add(parameter);
  }

  final namedParameters =
      constructorParameters.where((parameter) => parameter.isNamed);
  for (final namedParameter in namedParameters) {
    final parameter =
        "${namedParameter.name}: json[\"${namedParameter.name}\"],";
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
