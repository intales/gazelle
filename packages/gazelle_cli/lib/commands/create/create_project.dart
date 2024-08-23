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

String _getFlutterMain(String projectName) => """
import 'package:flutter/material.dart';
import 'package:client/client.dart';

void main() {
  gazelle.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('$projectName'),
        ),
        body: Center(
          child: FutureBuilder(
            future: gazelle.client.api.helloGazelle.get(),
            builder: (_, snapshot) => switch (snapshot) {
              AsyncSnapshot(:final data?) => Text(data),
              AsyncSnapshot(:final error?) =>
                Text('\${error.runtimeType}: \$error'),
              _ => const CircularProgressIndicator(),
            },
          ),
        ),
      ),
    );
  }
}
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
    final serverPath = "$projectName/backend/server/bin/server.dart";

    final result = await Process.run(
      'dart',
      ['run', serverPath, '--export-routes'],
      runInShell: true,
    );

    final output = result.stdout as String;

    await generateClient(
      structure: output,
      path: "$projectName/backend/client",
      projectName: "backend",
    );

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

    await File("$projectName/lib/main.dart")
        .writeAsString(_getFlutterMain(projectName));

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
