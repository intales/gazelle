import 'dart:io';

import 'analyze_class.dart';
import 'class_definition.dart';

/// Analyzes a Dart file.
Future<List<ClassDefinition>> analyzeFile(String path) async {
  final file = File(path);
  if (!file.existsSync()) return [];

  final content = await file.readAsString();
  final classDefinitions = analyzeClasses(content);

  return classDefinitions;
}
