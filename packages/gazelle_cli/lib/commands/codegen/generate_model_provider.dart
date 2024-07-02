import 'dart:io';

import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart';

import 'class_definition.dart';

/// Represents the result of `GenerateModelProvider`.
class GenerateModelProviderResult {
  /// The model provider.
  final File modelProvider;

  /// The model types.
  final List<File> modelTypes;

  /// Builds a [GenerateModelProviderResult].
  const GenerateModelProviderResult({
    required this.modelProvider,
    required this.modelTypes,
  });
}

/// Generates a `GazelleModelProvider` for the current project.
GenerateModelProviderResult generateModelProvider({
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

    final modelTypeFileName =
        "$destinationPath/${sourceFile.fileName.split("/").last.replaceAll(".dart", "_model_type.dart")}";
    final modelTypeFile = File(modelTypeFileName)
      ..createSync(recursive: true)
      ..writeAsStringSync(modelType);
    modelTypesFiles.add(modelTypeFile);
  }

  final modelProvider = _generateModelProvider(
    sourceFiles: sourceFiles,
    entitiesBasePath: entitiesBasePath,
    modelTypesFiles: modelTypesFiles,
  );

  final modelProviderFile = File("$destinationPath/model_provider.dart")
    ..createSync(recursive: true)
    ..writeAsStringSync(modelProvider);

  return GenerateModelProviderResult(
    modelProvider: modelProviderFile,
    modelTypes: modelTypesFiles,
  );
}

String _generateModelProvider({
  required List<SourceFileDefinition> sourceFiles,
  required String entitiesBasePath,
  required List<File> modelTypesFiles,
}) {
  final entitiesImports = sourceFiles
      .map((e) => "$entitiesBasePath/${e.fileName.split("/").last}")
      .map(cb.Directive.import)
      .toList();

  final modelTypesImports = modelTypesFiles
      .map((e) => e.path.split("/").last)
      .map(cb.Directive.import)
      .toList();

  final gazelleImport =
      cb.Directive.import("package:gazelle_core/gazelle_core.dart");

  final modelTypesCode = StringBuffer('return {');
  for (final entity in sourceFiles.expand((e) => e.classes)) {
    modelTypesCode.writeln('${entity.name}: ${entity.name}ModelType(),');
  }
  modelTypesCode.writeln('};');

  final clazz = cb.Class((clazz) {
    clazz
      ..name = "ModelProvider"
      ..extend = cb.refer("GazelleModelProvider")
      ..methods.addAll([
        cb.Method((method) {
          method
            ..annotations.add(cb.refer("override"))
            ..returns = cb.refer("Map<Type, GazelleModelType>")
            ..name = "modelTypes"
            ..type = cb.MethodType.getter
            ..body = cb.Code(modelTypesCode.toString());
        }),
      ]);
  });

  final library = cb.Library((lib) => lib
    ..directives.addAll([
      ...entitiesImports,
      ...modelTypesImports,
      gazelleImport,
    ])
    ..body.add(clazz));

  final emitter = cb.DartEmitter(
    allocator: cb.Allocator(),
    orderDirectives: true,
  );

  return DartFormatter().format('${library.accept(emitter)}');
}

String _generateModelType({
  required SourceFileDefinition sourceFile,
  required String entitiesBasePath,
}) {
  final imports = sourceFile.importsPaths
      .map((e) => "${e.replaceAll(".dart", "")}_model_type.dart")
      .map(cb.Directive.import)
      .toList()
    ..add(cb.Directive.import("package:gazelle_core/gazelle_core.dart"))
    ..add(cb.Directive.import(
        "$entitiesBasePath/${sourceFile.fileName.split("/").last}"));

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

  return DartFormatter().format('${library.accept(emitter)}');
}

cb.Class _generateModelTypeClass({
  required ClassDefinition classDefinition,
}) {
  final clazz = cb.Class(
    (clazz) => clazz
      ..name = "${classDefinition.name}ModelType"
      ..extend = cb.refer("GazelleModelType<${classDefinition.name}>")
      ..methods.addAll([
        _generateFromJsonMethod(classDefinition),
        _generateToJsonMethod(classDefinition),
      ]),
  );

  return clazz;
}

cb.Method _generateFromJsonMethod(ClassDefinition classDefinition) {
  return cb.Method((method) {
    method
      ..annotations.add(cb.refer("override"))
      ..returns = cb.refer(classDefinition.name)
      ..name = "fromJson"
      ..requiredParameters.add(
        cb.Parameter((param) => param
          ..name = "json"
          ..type = cb.refer("Map<String, dynamic>")),
      )
      ..body = cb.Block((block) {
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
  });
}

cb.Method _generateToJsonMethod(ClassDefinition classDefinition) {
  return cb.Method((method) {
    method
      ..annotations.add(cb.refer("override"))
      ..returns = cb.refer("Map<String, dynamic>")
      ..name = "toJson"
      ..requiredParameters.add(
        cb.Parameter((param) => param
          ..name = "value"
          ..type = cb.refer(classDefinition.name)),
      )
      ..body = cb.Block((block) {
        final parameters = classDefinition.properties
            .map((prop) => "${_generateToJsonParameter(prop)},")
            .join("\n");

        block.statements.add(cb.Code("""
          return {
            $parameters
          };
        """));
      });
  });
}

String _generateFromJsonParameter(ClassConstructorParameter param) {
  final parameter = StringBuffer();
  if (param.isNamed) {
    parameter.write("${param.name}: ");
  }
  if (param.type.isPrimitive) {
    parameter.write('json["${param.name}"]');
  } else if (param.type.isList || param.type.isSet) {
    if (param.type.valueType!.isPrimitive) {
      parameter.write('json["${param.name}"]');
    } else {
      final castType = param.type.isList ? "List" : "Set";
      parameter.write(
          '(json["${param.name}"] as $castType).map((item) => ${param.type.valueType!.name}ModelType().fromJson(item)).toList()');
    }
  } else if (param.type.isMap) {
    parameter.write('(json["${param.name}"] as Map).map((k, v) => MapEntry(');
    if (param.type.keyType!.isPrimitive) {
      parameter.write('k, ');
    } else {
      parameter.write('${param.type.keyType!.name}ModelType().fromJson(k)');
    }
    if (param.type.valueType!.isPrimitive) {
      parameter.write('v');
    } else {
      parameter.write('${param.type.valueType!.name}ModelType().fromJson(v)');
    }
    parameter.write('))');
  } else if (param.type.isDateTime) {
    parameter.write("DateTime.parse(json[\"${param.name}\"])");
  } else if (param.type.isDuration) {
    parameter.write("Duration(microseconds: json[\"${param.name}\"])");
  } else if (param.type.isBigInt) {
    parameter.write("BigInt.from(json[\"${param.name}\"])");
  } else if (param.type.isUri) {
    parameter.write("Uri.parse(json[\"${param.name}\"])");
  } else {
    parameter
        .write('${param.type.name}ModelType().fromJson(json["${param.name}"])');
  }
  return parameter.toString();
}

String _generateToJsonParameter(ClassPropertyDefinition prop) {
  final parameter = StringBuffer('''"${prop.name}": ''');
  if (prop.type.isPrimitive) {
    parameter.write('value.${prop.name}');
  } else if (prop.type.isList || prop.type.isSet) {
    if (prop.type.valueType!.isPrimitive) {
      parameter.write('value.${prop.name}');
    } else {
      final toIterable = prop.type.isList ? "toList()" : "toSet()";
      parameter.write(
          'value.${prop.name}.map((item) => ${prop.type.valueType!.name}ModelType().toJson(item)).$toIterable');
    }
  } else if (prop.type.isMap) {
    parameter.write('value.${prop.name}.map((k, v) => MapEntry(');
    if (prop.type.keyType!.isPrimitive) {
      parameter.write('k, ');
    } else {
      parameter.write('${prop.type.keyType!.name}ModelType().toJson(k)');
    }
    if (prop.type.valueType!.isPrimitive) {
      parameter.write('v');
    } else {
      parameter.write('${prop.type.valueType!.name}ModelType().toJson(v)');
    }
    parameter.write('))');
  } else if (prop.type.isDateTime) {
    parameter.write("value.${prop.name}.toIso8601String()");
  } else if (prop.type.isDuration) {
    parameter.write("value.${prop.name}.inMicroseconds");
  } else if (prop.type.isBigInt) {
    parameter.write("value.${prop.name}.toString()");
  } else if (prop.type.isUri) {
    parameter.write("value.${prop.name}.toString()");
  } else {
    parameter.write('${prop.type.name}ModelType().toJson(value.${prop.name})');
  }
  return parameter.toString();
}
