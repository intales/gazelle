import 'dart:io';

import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart';

import 'source_file_definition.dart';

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

        print(parameters);

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
  parameter.write(_parseJsonValue(param.name!, param.type));
  return parameter.toString();
}

String _generateToJsonParameter(ClassPropertyDefinition prop) {
  final parameter = StringBuffer('''"${prop.name}": ''');
  parameter.write(_serializeJsonValue(prop.name, prop.type));
  return parameter.toString();
}

String _parseJsonValue(
  String name,
  TypeDefinition type, {
  bool insideCollection = false,
}) {
  final buffer = StringBuffer();
  final objectReference = insideCollection ? name : 'json["$name"]';
  if (type.isNullable) {
    buffer.write('$objectReference != null ? ');
  }
  if (type.isPrimitive) {
    buffer.write(objectReference);
  } else if (type.isDateTime) {
    buffer.write('DateTime.parse($objectReference)');
  } else if (type.isDuration) {
    buffer.write('Duration(microseconds: $objectReference)');
  } else if (type.isUri) {
    buffer.write('Uri.parse($objectReference)');
  } else if (type.isBigInt) {
    buffer.write('BigInt.from($objectReference)');
  } else if (type.isList || type.isSet) {
    final valueType = type.valueType!;
    final castType = type.isList ? "List" : "Set";
    buffer.write(
        '($objectReference as $castType).map((item) => ${_parseJsonValue("item", valueType, insideCollection: true)}).to$castType()');
  } else if (type.isMap) {
    final keyType = type.keyType!;
    final valueType = type.valueType!;
    buffer.write(
        '($objectReference as Map).map((k, v) => MapEntry(${_parseJsonValue("k", keyType, insideCollection: true)}, ${_parseJsonValue("v", valueType, insideCollection: true)}))');
  } else {
    buffer.write('${type.name}ModelType().fromJson($objectReference)');
  }
  if (type.isNullable) {
    buffer.write(' : null');
  }
  return buffer.toString();
}

String _serializeJsonValue(
  String name,
  TypeDefinition type, {
  bool valuePrefix = true,
}) {
  final buffer = StringBuffer(valuePrefix ? "value." : "");
  if (type.isPrimitive) {
    buffer.write(name);
  } else if (type.isDateTime) {
    buffer.write("$name${type.isNullable ? "?" : ""}.toIso8601String()");
  } else if (type.isDuration) {
    buffer.write("$name${type.isNullable ? "?" : ""}.inMicroseconds");
  } else if (type.isUri) {
    buffer.write("$name${type.isNullable ? "?" : ""}.toString()");
  } else if (type.isBigInt) {
    buffer.write("$name${type.isNullable ? "?" : ""}.toString()");
  } else if (type.isList || type.isSet) {
    final valueType = type.valueType!;
    final toStatement = type.isList ? "toList()" : "toSet()";
    buffer.write(
        '$name${type.isNullable ? "?" : ""}.map((item) => ${_serializeJsonValue("item", valueType, valuePrefix: false)}).$toStatement');
  } else if (type.isMap) {
    final keyType = type.keyType!;
    final valueType = type.valueType!;
    buffer.write(
        '$name${type.isNullable ? "?" : ""}.map((k, v) => MapEntry(${_serializeJsonValue("k", keyType, valuePrefix: false)}, ${_serializeJsonValue("v", valueType, valuePrefix: false)}))');
  } else {
    buffer.clear();
    buffer.write(
        "${type.isNullable ? "${valuePrefix ? "value." : ""}$name != null ?" : ""}${type.name}ModelType().toJson(${valuePrefix ? "value." : ""}$name)${type.isNullable ? " : null" : ""}");
  }
  return buffer.toString();
}
