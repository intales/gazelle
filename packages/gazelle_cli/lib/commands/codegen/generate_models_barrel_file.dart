import 'dart:io';

import 'calculate_relative_path.dart';

/// Creates a barrel file that exports entities and models.
Future<String> generateModelsBarrelFile({
  required List<String> entitiesPath,
  required List<String> modelsPath,
  required String modelProviderPath,
  required String barrelFilePath,
}) async {
  final barrelFileName = "$barrelFilePath/models.dart";
  final exports = <String>[];

  for (final path in entitiesPath) {
    final exportPath = calculateRelativePath(barrelFileName, path);
    exports.add("export '$exportPath';");
  }

  for (final path in modelsPath) {
    final exportPath = calculateRelativePath(barrelFileName, path);
    exports.add("export '$exportPath';");
  }

  final modelProviderExportPath =
      calculateRelativePath(barrelFileName, modelProviderPath);
  exports.add("export '$modelProviderExportPath';");

  exports.sort((a, b) => a.compareTo(b));

  return File(barrelFileName).create(recursive: true).then((file) =>
      file.writeAsString(exports.join("\n")).then((file) => file.path));
}
