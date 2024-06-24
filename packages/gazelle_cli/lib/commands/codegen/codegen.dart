import 'dart:io';

import 'analyze.dart';
import 'generate_gazelle_model_type_file.dart';

/// Generates models for serialization.
Future<void> codegen(String entitiesDirectoryPath) async {
  final modelsDirectoryPath =
      "${Directory(entitiesDirectoryPath).parent.path}/models";
  final classDefinitions = await analyze(entitiesDirectoryPath);
  final groupedClassDefinitions =
      classDefinitions.groupBy((item) => item.fileName);

  final modelTypeFiles = <File>[];
  for (final entry in groupedClassDefinitions.entries) {
    final key = entry.key;
    final value = entry.value;

    final filesToImport =
        groupedClassDefinitions.keys.where((item) => item != key).toList();

    String fileName = "$modelsDirectoryPath/";
    fileName += key.replaceAll(".dart", "");
    fileName += "_model_type.dart";

    final modelTypeFile = await generateModelTypeFile(
      value.map((e) => e.classDefinition).toList(),
      filesToImport,
      fileName,
    );

    modelTypeFiles.add(modelTypeFile);
  }
}

extension _ListGroupByX<T> on List<T> {
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) =>
      _groupBy(this, keyFunction);
}

Map<K, List<T>> _groupBy<T, K>(List<T> items, K Function(T) keyFunction) {
  Map<K, List<T>> groupedMap = {};

  for (final T item in items) {
    final K key = keyFunction(item);
    if (!groupedMap.containsKey(key)) {
      groupedMap[key] = [];
    }
    groupedMap[key]!.add(item);
  }

  return groupedMap;
}
