import 'dart:io';

import 'analyze_file.dart';
import 'file_class_definition.dart';

/// Analyzes Dart files inside of [directoryPath] and returns a list of [ClassDefinition].
Future<List<FileClassDefinition>> analyze(String directoryPath) async {
  final directory = Directory(directoryPath);
  final files =
      await directory.list(recursive: true).map((e) => e.path).toList();

  final classDefinitions = <FileClassDefinition>[];
  for (final file in files) {
    final classDefinition = await analyzeFile(file);
    classDefinitions.addAll(classDefinition);
  }

  return classDefinitions;
}
