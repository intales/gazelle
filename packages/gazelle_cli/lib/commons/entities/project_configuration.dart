import 'package:yaml/yaml.dart';

/// Represents the current package configuration.
///
/// Information is fetched from project `pubspec.yaml` file.
class ProjectConfiguration {
  /// Name of the package.
  final String name;

  /// Version of the package.
  final String version;

  /// Creates a [ProjectConfiguration] instance.
  const ProjectConfiguration({
    required this.name,
    required this.version,
  });

  /// Creates a [ProjectConfiguration] instance from given [yaml].
  factory ProjectConfiguration.fromYaml(YamlMap yaml) => ProjectConfiguration(
        name: yaml["name"],
        version: yaml["version"],
      );
}
