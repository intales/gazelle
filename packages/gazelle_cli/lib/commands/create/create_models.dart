import 'dart:io';

import '../../commons/consts.dart';
import '../../commons/functions/get_latest_package_version.dart';
import '../../commons/functions/snake_to_pascal_case.dart';
import '../../commons/functions/version.dart';

String _getPubspecTemplate(String gazelleSerializationVersion) => """
name: models 
description: Models for Gazelle project.
version: 0.1.0
publish_to: "none"

environment:
  sdk: ^$dartSdkVersion

dependencies:
  gazelle_serialization: ^$gazelleSerializationVersion

dev_dependencies:
  lints: ">=2.1.0 <4.0.0"
  test: ^1.24.0
""";

String _getEmptyModelProvider(String projectName) => """
import 'package:gazelle_serialization/gazelle_serialization.dart';

class ${projectName}ModelProvider extends GazelleModelProvider {
  @overrides
  Map<Type, ModelType> get modelTypes => {};
}
""";

/// Creates models folder for a Gazelle Project.
Future<String> createModels({
  required String path,
  required String projectName,
}) async {
  final gazelleSerializationVersion =
      await getLatestPackageVersion(gazelleSerializationPackageName);

  await File("$path/pubspec.yaml").create(recursive: true).then((file) =>
      file.writeAsString(_getPubspecTemplate(gazelleSerializationVersion)));

  await Directory("$path/lib/entities").create(recursive: true);
  await File("$path/lib/models/${projectName}_model_provider.dart")
      .create(recursive: true)
      .then((file) => file.writeAsString(
          _getEmptyModelProvider(snakeToPascalCase(projectName))));
  await File("$path/lib/models.dart").create(recursive: true).then((file) =>
      file.writeAsString(
          "export 'models/${projectName}_model_provider.dart';"));

  await Process.run(
    "dart",
    ["pub", "get"],
    workingDirectory: "$path/",
  );

  return path;
}
