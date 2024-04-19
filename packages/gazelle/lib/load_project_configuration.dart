import 'dart:io';
import 'package:yaml/yaml.dart';

import 'project_configuration.dart';

/// Reporesents an error that is thrown when project configuration cannot be loaded.
class LoadProjectConfigurationError {
  /// Error code.
  final int errorCode;

  /// Error message.
  final String errorMessage;

  /// Builds a [LoadProjectConfigurationError] instance.
  const LoadProjectConfigurationError({
    this.errorCode = 1,
    this.errorMessage =
        "Unable to find pubspec.yaml file in current directory.",
  });
}

/// Loads configuration file from project `pubspec.yaml` file.
///
/// Throws [LoadProjectConfigurationError] if `pubspec.yaml` is not found.
Future<ProjectConfiguration> loadProjectConfiguration() async {
  final directory = Directory.current;
  final pubspecPath = "${directory.path}/pubspec.yaml";
  final pubspec = File(pubspecPath);

  if (!await pubspec.exists()) throw const LoadProjectConfigurationError();

  final yaml = loadYaml(await pubspec.readAsString());
  return ProjectConfiguration.fromYaml(yaml);
}
