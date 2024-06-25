import 'dart:io';

import 'analyze.dart';
import 'generate_gazelle_model_provider_file.dart';
import 'generate_gazelle_model_type_file.dart';

/// Generates models for serialization.
Future<void> codegen(
  String entitiesDirectoryPath,
  String projectName,
) async {
  final modelsDirectoryPath =
      "${Directory(entitiesDirectoryPath).parent.path}/models";
  final classDefinitions = await analyze(entitiesDirectoryPath);

  // Group by filename to handle imports
  final groupedClassDefinitions =
      classDefinitions.groupBy((item) => item.fileName);

  final modelTypeFiles = <File>[];
  for (final entry in groupedClassDefinitions.entries) {
    final key = entry.key;
    final value = entry.value;

    // The entities to import (should be always 1)
    final entitiesImports =
        groupedClassDefinitions.keys.where((e) => e == key).toList();

    // The list of model types that may be imported excluding the
    // model type that's being generated
    final modelTypesImports = groupedClassDefinitions.keys
        .where((e) => e != key)
        .map((e) => e.replaceAll(".dart", "_model_type.dart"))
        .toList();

    // Generated model type file name
    String fileName = "$modelsDirectoryPath/";
    fileName += key.replaceAll(".dart", "_model_type.dart");

    final modelTypeFile = await generateModelTypeFile(
      value.map((e) => e.classDefinition).toList(),
      entitiesImports,
      modelTypesImports,
      fileName,
    );

    modelTypeFiles.add(modelTypeFile);
  }

  final modelTypeFileName =
      "$modelsDirectoryPath/${projectName}_model_provider.dart";

  await generateModelProviderFile(
    projectName,
    classDefinitions.map((e) => e.classDefinition).toList(),
    modelTypeFiles,
    classDefinitions.map((e) => File(e.fileName)).toList(),
    modelTypeFileName,
  );
}

extension _ListGroupByX<T> on List<T> {
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) =>
      _groupBy(this, keyFunction);
}

Map<K, List<T>> _groupBy<T, K>(List<T> items, K Function(T) keyFunction) {
  final groupedMap = <K, List<T>>{};

  for (final T item in items) {
    final K key = keyFunction(item);
    if (!groupedMap.containsKey(key)) {
      groupedMap[key] = [];
    }
    groupedMap[key]!.add(item);
  }

  return groupedMap;
}
