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

    for (final member in node.members) {
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

    classes.add(ClassDefinition(
      name: className,
      properties: classProperties,
    ));
  }
}
