import 'package:dart_style/dart_style.dart';

import 'class_definition.dart';

const _types = {
  "num",
  "int",
  "double",
  "bool",
  "String",
  "DateTime",
  "Duration",
  "BigInt",
  "Uri",
};

bool _isPrimitive(String typeName) => _types.contains(typeName);

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
    String parameter = "json[\"${positionalParameter.name}\"]";
    if (positionalParameter.type != null &&
        !_isPrimitive(positionalParameter.type!)) {
      parameter =
          "${positionalParameter.type!}ModelType().fromJson($parameter)";
    }
    parameter += ",";
    parameters.add(parameter);
  }

  final namedParameters =
      constructorParameters.where((parameter) => parameter.isNamed);
  for (final namedParameter in namedParameters) {
    String parameter =
        "${namedParameter.name}: json[\"${namedParameter.name}\"],";
    if (namedParameter.type != null && !_isPrimitive(namedParameter.type!)) {
      parameter =
          "${namedParameter.name}: ${namedParameter.type!}ModelType().fromJson(json[\"${namedParameter.name}\"]),";
    }
    parameters.add(parameter);
  }

  return parameters.join("\n");
}

/// Returns a `toJson` function from a [classDefinition].
String generateToJson(ClassDefinition classDefinition) {
  final toJsonProps = _generateToJsonProperties(classDefinition.properties);

  final classOutput = """
  Map<String, dynamic> toJson(${classDefinition.name} value) {
    return {
      $toJsonProps
    };
  }
  """;

  final result = DartFormatter().format(classOutput).trim();
  return result;
}

String _generateToJsonProperties(
  Set<ClassPropertyDefinition> classPropertyDefinitions,
) {
  final parameters = <String>[];
  for (final propDefinition in classPropertyDefinitions) {
    String parameter = "\"${propDefinition.name}\": ";
    if (_isPrimitive(propDefinition.type.toString())) {
      parameter += "value.${propDefinition.name}";
    } else {
      parameter +=
          "${propDefinition.type}ModelType().toJson(value.${propDefinition.name})";
    }
    parameter += ",";

    parameters.add(parameter);
  }

  return parameters.join("\n");
}
