import 'dart:io';

import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart';

import 'class_definition.dart';

List<File> generateModelProvider({
  required List<SourceFileDefinition> sourceFiles,
  required String entitiesBasePath,
  required String destinationPath,
}) {
  final modelTypesFiles = <File>[];
  for (final sourceFile in sourceFiles) {
    final modelType = _generateModelType(
      sourceFile: sourceFile,
      entitiesBasePath: entitiesBasePath,
    );
    String modelTypeFileName = "$destinationPath/";
    modelTypeFileName += sourceFile.fileName
        .split("/")
        .last
        .replaceAll(".dart", "_model_type.dart");

    final modelTypeFile = File(modelTypeFileName)
      ..createSync(recursive: true)
      ..writeAsStringSync(modelType);
    modelTypesFiles.add(modelTypeFile);
  }

  return modelTypesFiles;
}

String _generateModelType({
  required SourceFileDefinition sourceFile,
  required String entitiesBasePath,
}) {
  final imports = sourceFile.importsPaths
      .map((e) => "$entitiesBasePath/$e")
      .map(cb.Directive.import)
      .toList()
    ..add(cb.Directive.import("package:gazelle_core/gazelle_core.dart"))
    ..addAll(sourceFile.importsPaths.map((e) =>
        cb.Directive.import("${e.replaceAll(".dart", "")}_model_type.dart")));

  final classes = sourceFile.classes
      .map((clazz) => _generateModelTypeClass(classDefinition: clazz))
      .toList();
  final library = cb.Library((lib) => lib
    ..directives.addAll(imports)
    ..body.addAll(classes));

  final emitter = cb.DartEmitter(
    allocator: cb.Allocator(),
    orderDirectives: true,
  );
  return DartFormatter().format("${library.accept(emitter)}");
}

cb.Class _generateModelTypeClass({
  required ClassDefinition classDefinition,
}) {
  final clazz = cb.Class(
    (clazz) => clazz
      ..name = "${classDefinition.name}ModelType"
      ..extend = cb.refer("GazelleModelType<${classDefinition.name}>")
      ..methods.add(cb.Method((method) {
        method.annotations.add(cb.refer("override"));
        method.returns = cb.refer(classDefinition.name);
        method.name = "fromJson";
        method.requiredParameters.add(
          cb.Parameter((param) => param
            ..name = "json"
            ..type = cb.refer("Map<String, dynamic>")),
        );
        method.body = cb.Block((block) {
          final positionalParameters = classDefinition.constructorParameters
              .where((param) => !param.isNamed)
              .toList()
            ..sort((a, b) => a.position!.compareTo(b.position!));

          final namedParameters = classDefinition.constructorParameters
              .where((e) => e.isNamed)
              .toList();

          final parameters = [
            ...positionalParameters
                .map((e) => "${_generateFromJsonParameter(e)},"),
            ...namedParameters.map((e) => "${_generateFromJsonParameter(e)},"),
          ].join("\n");

          block.statements.add(cb.Code("""
	  return ${classDefinition.name}(
	    $parameters
	  );
	  """));
        });
      }))
      ..methods.add(cb.Method((method) {
        method.annotations.add(cb.refer("override"));
        method.returns = cb.refer("Map<String, dynamic>");
        method.name = "toJson";
        method.requiredParameters.add(
          cb.Parameter((param) => param
            ..name = "value"
            ..type = cb.refer(classDefinition.name)),
        );
        method.body = cb.Block((block) {
          final parameters = classDefinition.properties
              .map((prop) => "${_generateToJsonParameter(prop)},")
              .join("\n");

          block.statements.add(cb.Code("""
	  return {
	    $parameters
	  };
	  """));
        });
      })),
  );

  return clazz;
}

String _generateFromJsonParameter(ClassConstructorParameter param) {
  String parameter = param.isNamed ? "${param.name}: " : "";
  if (param.type.isPrimitive) {
    parameter += "json[\"${param.name}\"]";
  } else if (param.type.isList || param.type.isSet) {
    if (param.type.valueType!.isPrimitive) {
      parameter += "json[\"${param.name}\"]";
    } else {
      final castType = param.type.isList ? "List" : "Set";
      parameter +=
          "(json[\"${param.name}\"] as $castType).map((item) => ${param.type.valueType!.name}ModelType().fromJson(item)).toList()";
    }
  } else if (param.type.isMap) {
    parameter += "(json['${param.name}'] as Map).map((k, v) => MapEntry(";
    if (param.type.keyType!.isPrimitive) {
      parameter += "k, ";
    } else {
      parameter += "${param.type.keyType!.name}ModelType().fromJson(k)";
    }
    if (param.type.valueType!.isPrimitive) {
      parameter += "v";
    } else {
      parameter += "${param.type.valueType!.name}ModelType().fromJson(v)";
    }
    parameter += "))";
  } else {
    parameter +=
        "${param.type.name}ModelType().fromJson(json[\"${param.name}\"])";
  }

  return parameter;
}

String _generateToJsonParameter(ClassPropertyDefinition prop) {
  String parameter = "\"${prop.name}\": ";
  if (prop.type.isPrimitive) {
    parameter += "value.${prop.name}";
  } else if (prop.type.isList || prop.type.isSet) {
    if (prop.type.valueType!.isPrimitive) {
      parameter += "value.${prop.name}";
    } else {
      final toIterable = prop.type.isList ? "toList()" : "toSet()";
      parameter +=
          "value.${prop.name}.map((item) => ${prop.type.valueType!.name}ModelType().toJson(item)).$toIterable";
    }
  } else if (prop.type.isMap) {
    parameter += "value.${prop.name}.map((k, v) => MapEntry(";
    if (prop.type.keyType!.isPrimitive) {
      parameter += "k, ";
    } else {
      parameter += "${prop.type.keyType!.name}ModelType().toJson(k)";
    }
    if (prop.type.valueType!.isPrimitive) {
      parameter += "v";
    } else {
      parameter += "${prop.type.valueType!.name}ModelType().toJson(v)";
    }
    parameter += "))";
  } else {
    parameter += "${prop.type.name}ModelType().toJson(value.${prop.name})";
  }

  return parameter;
}
