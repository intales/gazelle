import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/visitor.dart';
//ignore: implementation_imports
import 'package:analyzer/src/dart/ast/ast.dart';

import 'class_definition.dart';

/// Defines an error while analyzing Dart classes.
class AnalyzeClassesException implements Exception {
  /// The error message.
  final String message;

  /// Builds a [AnalyzeClassesException].
  const AnalyzeClassesException({
    this.message = "Class content is empty!",
  });
}

/// Analyzes a list of Dart classes.
List<ClassDefinition> analyzeClasses(String classContent) {
  if (classContent.isEmpty) const AnalyzeClassesException();

  final parsingResult = parseString(content: classContent);
  final compilationUnit = parsingResult.unit;

  final visitor = _ClassVisitor();
  compilationUnit.visitChildren(visitor);

  return visitor.classes.toList();
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
        final type = member.fields.type.toString();
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
        final name = parameter.name?.value().toString();
        final isNamed = name != null;
        final position = isNamed ? null : i;
        final type = classProperties
            .where((prop) => prop.name == parameter.name.toString())
            .firstOrNull
            ?.type;

        constructorParamters.add(ClassConstructorParameter(
          name: name,
          isNamed: isNamed,
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
