import 'dart:io';

import 'analyze_class.dart';
import 'file_class_definition.dart';

/// Analyzes a Dart file.
Future<List<FileClassDefinition>> analyzeFile(String path) async {
  final file = File(path);
  if (!file.existsSync()) return [];

  final content = await file.readAsString();
  final classDefinitions = analyzeClasses(content)
      .map((classDefinition) => FileClassDefinition(
            classDefinition: classDefinition,
            fileName: path.split("/").last,
          ))
      .toList();

  return classDefinitions;
}
