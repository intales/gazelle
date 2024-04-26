import 'dart:io';

const _mainTemplate = """
import 'package:gazelle_core/gazelle_core.dart';

Future<void> runApp(List<String> args) async {
  final app = GazelleApp(port: 8080);

  app.get('/', (request, response) async => response.copyWith(
    statusCode: 200,
    body: 'Hello, Gazelle!',
  ));

  await app.start();
  print('Server is running at http://\${app.address}:\${app.port}');
}
""";

String _getPubspecTemplate(String projectName) => """
name: $projectName 
description: A new Gazelle project.
version: 0.1.0

environment:
  sdk: ^3.3.4

dependencies:
  gazelle_core: ^0.2.0

dev_dependencies:
  lints: ">=2.1.0 <4.0.0"
  test: ^1.24.0
""";

String _getEntryPoint(String projectName) => """
import "package:$projectName/$projectName.dart" as $projectName;

void main(List<String> args) => $projectName.runApp(args);
""";

/// Represents an error during the creation process of a new project.
class CreateProjectError {
  /// The error message.
  final String message;

  /// Creates a [CreateProjectError].
  const CreateProjectError() : message = "Project already exists!";
}

/// Creates a new Gazelle project.
///
/// Throws a [CreateProjectError] if project already exists.
Future<String> createProject(
  String projectName, {
  String? path,
}) async {
  final nameOption = projectName;
  final pathOption = path;

  final completePath =
      pathOption != null ? "$pathOption/$nameOption" : nameOption;
  if (await Directory(completePath).exists()) {
    throw CreateProjectError();
  }

  await Directory(completePath).create(recursive: true);

  await File("$completePath/pubspec.yaml")
      .create(recursive: true)
      .then((file) => file.writeAsString(_getPubspecTemplate(nameOption)));

  await File("$completePath/lib/$nameOption.dart")
      .create(recursive: true)
      .then((file) => file.writeAsString(_mainTemplate));

  await File("$completePath/bin/$nameOption.dart")
      .create(recursive: true)
      .then((file) => file.writeAsString(_getEntryPoint(nameOption)));

  await Process.run(
    "dart",
    ["pub", "get"],
    workingDirectory: "$completePath/",
  );

  return completePath;
}
