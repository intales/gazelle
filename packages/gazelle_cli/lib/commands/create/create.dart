import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';

import 'create_project.dart';

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

    final nameOption = argResults?.option("name") ??
        argResults?.rest.firstOrNull ??
        "gazelle_app";
    final pathOption = argResults?.option("path");

    try {
      final result = await createProject(nameOption, path: pathOption);
      spinner.success(
        "$result project created!\nRun `gazelle run $result` to test it.",
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
