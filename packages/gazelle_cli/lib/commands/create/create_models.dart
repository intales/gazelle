import 'dart:io';

import '../../commons/functions/version.dart';

String get _pubspecTemplate => """
name: models 
description: Models for Gazelle project.
version: 0.1.0
publish_to: "none"

environment:
  sdk: ^$dartSdkVersion

dependencies:
  gazelle_serialization: ^0.1.1

dev_dependencies:
  lints: ">=2.1.0 <4.0.0"
  test: ^1.24.0
""";

/// Creates models folder for a Gazelle Project.
Future<String> createModels({
  required String path,
}) async {
  await File("$path/pubspec.yaml")
      .create(recursive: true)
      .then((file) => file.writeAsString(_pubspecTemplate));

  await Directory("$path/lib/entities").create(recursive: true);
  await File("$path/lib/models.dart").create(recursive: true);

  await Process.run(
    "dart",
    ["pub", "get"],
    workingDirectory: "$path/",
  );

  return path;
}
