import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';

import 'create_project.dart';

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

/// CLI command to create a new Gazelle project.
class CreateCommand extends Command {
  @override
  String get name => "create";

  @override
  String get description => "Creates a Gazelle project.";

  /// Createsa [CreateCommand].
  CreateCommand() {
    argParser.addOption(
      "name",
      abbr: "n",
      help: "The name of the project you want to build.",
    );
    argParser.addOption(
      "path",
      abbr: "p",
      help: "The path where you want to build the project.",
    );
  }

  @override
  void run() async {
    final spinner = CliSpin(
      text: "Creating Gazelle project...",
      spinner: CliSpinners.dots,
    ).start();

    final nameOption = argResults?.option("name") ?? "gazelle_app";
    final pathOption = argResults?.option("path");

    try {
      final result = await createProject(nameOption, path: pathOption);
      spinner.success(
        "$result project created!\nRun `dart run $result/bin/$nameOption.dart` to test it.",
      );
    } on CreateProjectError catch (e) {
      spinner.fail(e.message);
      exit(2);
    } on Exception catch (e) {
      spinner.fail(e.toString());
      exit(2);
    }
  }
}
