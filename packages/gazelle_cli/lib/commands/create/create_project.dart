import 'dart:io';

import 'package:path/path.dart';

import '../codegen/generate_client.dart';
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
  bool fullstack = false,
}) async {
  String backendProjectName = projectName;
  String basePath = "$path/$projectName";

  if (fullstack) {
    await Process.run(
      "flutter",
      ["create", projectName],
      workingDirectory: "$path/",
    );
    basePath = "$path/$projectName/backend";
    backendProjectName = "backend";
  }

  if (Directory(basePath).existsSync()) {
    throw CreateProjectError();
  }

  await File("$basePath/gazelle.yaml")
      .create(recursive: true)
      .then((file) => file.writeAsString(_getGazelleYaml(backendProjectName)));

  await createModels(path: "$basePath/models", projectName: backendProjectName);
  await createServer(path: "$basePath/server", projectName: backendProjectName);

  if (fullstack) {
    await _replaceStringInFile(
      filePath: join(projectName, "pubspec.yaml"),
      oldString: """dependencies:
  flutter:
    sdk: flutter"""
          .trim(),
      newString: """dependencies:
  flutter:
    sdk: flutter

  client:
    path: backend/client""",
    );

    await Process.run(
      "flutter",
      ["pub", "get"],
      workingDirectory: "$projectName/",
    );
  }

  return basePath;
}

Future<void> _replaceStringInFile({
  required String filePath,
  required String oldString,
  required String newString,
}) async {
  final fileContent = await File(filePath).readAsString();
  final updatedContent = fileContent.replaceAll(oldString, newString);

  await File(filePath).writeAsString(updatedContent);
}
