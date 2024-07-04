import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
//ignore: implementation_imports
import 'package:analyzer/src/dart/ast/ast.dart';

import 'source_file_definition.dart';

/// Represents an error for [analyzeEntities].
class AnalyzeEntitiesException implements Exception {
  /// The error message.
  final String message;

  /// Builds a [AnalyzeEntitiesException].
  const AnalyzeEntitiesException({
    required this.message,
  });

  /// Builds a [AnalyzeEntitiesException] with external type error.
  const AnalyzeEntitiesException.externalType({
    this.message = "Can't reference an external type.",
  });

  @override
  String toString() => "AnalyzeEntitiesException: $message";
}

/// Analyzes a list of Dart classes.
Future<List<SourceFileDefinition>> analyzeEntities(
  Directory entitiesDirectory,
) async {
  final collection = AnalysisContextCollection(
    includedPaths: [entitiesDirectory.absolute.path],
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  );

  final sourceFileDefinitions = <SourceFileDefinition>[];
  for (final context in collection.contexts) {
    for (final filePath in context.contextRoot.analyzedFiles()) {
      if (!filePath.endsWith(".dart")) {
        continue;
      }

      final unit = await context.currentSession
          .getResolvedUnit(filePath)
          .then((unit) => (unit as ResolvedUnitResult).unit);

      final imports = unit.directives.whereType<ImportDirective>().toSet();
      final parts = unit.directives.whereType<PartDirective>().toSet();
      final partOf = unit.directives.whereType<PartOfDirective>().firstOrNull;

      final visitor = _ClassVisitor();
      unit.visitChildren(visitor);

      final sourceFileDefinition = SourceFileDefinition(
        fileName: filePath,
        classes: visitor.classes,
        importsPaths: imports.map((e) => e.uri.stringValue ?? "").toSet(),
        partsPaths: parts.map((e) => e.uri.stringValue ?? "").toSet(),
        partOf: partOf?.uri?.stringValue,
      );

      sourceFileDefinitions.add(sourceFileDefinition);
    }
  }

  return sourceFileDefinitions;
}

class _ClassVisitor extends GeneralizingAstVisitor<void> {
  Set<ClassDefinition> classes = {};

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final className = node.name.value().toString();
    final classProperties = <ClassPropertyDefinition>{};
    final constructorParamters = <ClassConstructorParameter>{};
    ConstructorDeclaration? constructorDeclaration;

    for (final member in node.members) {
      if (member is ConstructorDeclaration) {
        constructorDeclaration = member;
      }

      if (member is! FieldDeclaration) continue;

      for (final variable in member.fields.variables) {
        final dartType = variable.declaredElement!.type as InterfaceType;
        if (_isExternalType(dartType)) {
          throw AnalyzeEntitiesException.externalType();
        }
        final type = _getTypeDefinition(dartType);
        final propertyName = variable.name.value().toString();
        classProperties.add(ClassPropertyDefinition(
          name: propertyName,
          type: type,
        ));
      }
    }

    if (constructorDeclaration != null) {
      for (var i = 0;
          i < constructorDeclaration.parameters.parameters.length;
          i++) {
        final parameter = constructorDeclaration.parameters.parameters[i];
        final element = parameter.declaredElement!;

        final name = parameter.name?.value().toString();
        final position = name == null ? i : null;
        final dartType = element.type as InterfaceType;
        if (_isExternalType(dartType)) {
          throw AnalyzeEntitiesException.externalType();
        }
        final type = _getTypeDefinition(dartType);
        constructorParamters.add(ClassConstructorParameter(
          name: name,
          position: position,
          type: type,
        ));
      }
    }

    classes.add(ClassDefinition(
      name: className,
      properties: classProperties,
      constructorParameters: constructorParamters,
    ));
  }
}

TypeDefinition _getTypeDefinition(InterfaceType dartType) {
  return TypeDefinition(
    name: dartType.getDisplayString().replaceAll("?", ""),
    isNullable: dartType.nullabilitySuffix == NullabilitySuffix.question,
    source: dartType.element.source.fullName,
    isInt: dartType.isDartCoreInt,
    isMap: dartType.isDartCoreMap,
    isNum: dartType.isDartCoreNum,
    isSet: dartType.isDartCoreSet,
    isBool: dartType.isDartCoreBool,
    isEnum: dartType.isDartCoreEnum,
    isList: dartType.isDartCoreList,
    isNull: dartType.isDartCoreNull,
    isDouble: dartType.isDartCoreDouble,
    isObject: dartType.isDartCoreObject,
    isRecord: dartType.isDartCoreRecord,
    isString: dartType.isDartCoreString,
    isSymbol: dartType.isDartCoreSymbol,
    isFuture: dartType.isDartAsyncFuture,
    isStream: dartType.isDartAsyncStream,
    isIterable: dartType.isDartCoreIterable,
    isFutureOr: dartType.isDartAsyncFutureOr,
    isDateTime: dartType.getDisplayString() == "DateTime",
    isDuration: dartType.getDisplayString() == "Duration",
    isBigInt: dartType.getDisplayString() == "BigInt",
    isUri: dartType.getDisplayString() == "Uri",
    valueType: dartType.isDartCoreList
        ? _getTypeDefinition(dartType.typeArguments[0] as InterfaceType)
        : dartType.isDartCoreMap
            ? _getTypeDefinition(dartType.typeArguments[1] as InterfaceType)
            : null,
    keyType: dartType.isDartCoreMap
        ? _getTypeDefinition(dartType.typeArguments[0] as InterfaceType)
        : null,
  );
}

bool _isExternalType(DartType type) =>
    type.element!.source?.uri.path.contains(".pub-cache") ?? false;
