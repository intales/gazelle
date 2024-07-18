import 'dart:io';

import 'create_models.dart';
import 'create_server.dart';

/// Represents an error during the creation process of a new project.
class CreateProjectError {
  /// The error message.
  final String message;

  /// Creates a [CreateProjectError].
  const CreateProjectError() : message = "Project already exists!";
}

String _getGazelleYaml(String projectName) => """
name: $projectName
version: 0.1.0
""";

/// Creates a new Gazelle project.
///
/// Throws a [CreateProjectError] if project already exists.
Future<String> createProject({
  required String projectName,
  required String path,
}) async {
  final basePath = "$path/$projectName";
  if (Directory(basePath).existsSync()) {
    throw CreateProjectError();
  }

  await File("$basePath/gazelle.yaml")
      .create(recursive: true)
      .then((file) => file.writeAsString(_getGazelleYaml(projectName)));

  await createModels(path: "$basePath/models");
  await createServer(path: "$basePath/server");

  return basePath;
}
