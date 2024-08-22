import 'dart:io';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import '../entities/project_configuration.dart';

/// Reporesents an error that is thrown when project configuration cannot be found.
class LoadProjectConfigurationPubspecNotFoundError {
  /// Error code.
  final int errorCode;

  /// Error message.
  final String errorMessage;

  /// Builds a [LoadProjectConfigurationPubspecNotFoundError] instance.
  const LoadProjectConfigurationPubspecNotFoundError({
    this.errorCode = 2,
    this.errorMessage =
        "Unable to find pubspec.yaml file in current directory.",
  });
}

/// Reporesents an error that is thrown when project configuration does not contain the gazelle prop.
class LoadProjectConfigurationGazelleNotFoundError {
  /// Error code.
  final int errorCode;

  /// Error message.
  final String errorMessage;

  /// Builds a [LoadProjectConfigurationGazelleNotFoundError] instance.
  const LoadProjectConfigurationGazelleNotFoundError({
    this.errorCode = 2,
    this.errorMessage =
        "Unable to find gazelle property inside the pubspec.yaml file.",
  });
}

/// Loads configuration file from project `pubspec.yaml` file.
///
/// Throws [LoadProjectConfigurationPubspecNotFoundError] if `pubspec.yaml` is not found.
Future<ProjectConfiguration> loadProjectConfiguration({String? path}) async {
  final startDirectory = Directory(path ?? Directory.current.path);
  Directory directory = startDirectory;
  final markerFile = "gazelle.yaml";

  late final String pubspecPath;
  while (true) {
    final markerFilePath = "${directory.path}/$markerFile";
    if (File(markerFilePath).existsSync()) {
      pubspecPath = markerFilePath;
      break;
    }

    final parent = directory.parent;
    if (parent.path == directory.path) {
      pubspecPath = join(startDirectory.path, "backend", markerFile);
      break;
    }

    directory = parent;
  }

  File pubspec = File(pubspecPath);

  if (!await pubspec.exists()) {
    throw const LoadProjectConfigurationPubspecNotFoundError();
  }

  final yaml = loadYaml(await pubspec.readAsString()) as YamlMap;

  return ProjectConfiguration.fromYaml(
    yaml: yaml,
    path: pubspec.parent.absolute.path,
  );
}
