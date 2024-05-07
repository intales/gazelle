import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';
import 'delete_project.dart';

/// CLI command to delete a Gazelle project.
class DeleteCommand extends Command {
  @override
  String get description => "Deleting a Gazelle project";

  @override
  String get name => "delete";

  /// Creates a [DeleteCommand].
  DeleteCommand() {
    argParser.addOption(
      "name",
      abbr: "n",
      help: "The name of the project you want to delete.",
    );
    argParser.addOption(
      "path",
      abbr: "p",
      help: "The path of the project which you want to delete.",
    );
  }

  @override
  void run() async {
    bool answer =
        await getConfirmation('\nAre you sure you want to delete the project?');

    final spinner = CliSpin(
      text: "Deleting Gazelle project...",
      spinner: CliSpinners.dots,
    ).start();
    final nameOption = argResults?.option("name") ?? "gazelle_app";
    final pathOption = argResults?.option("path");
    if (!answer) {
      spinner.fail("Project deletion aborted.");
      return;
    }
    try {
      final result = await deleteProject(nameOption, path: pathOption);
      if (result == "abort") {
        spinner.fail("Project deletion aborted.");
        exit(2);
      }
      spinner.success(
        "$result project is deleted\n",
      );
    } on DeletingProjectError catch (e) {
      spinner.fail(e.message);
      exit(2);
    } on Exception catch (e) {
      spinner.fail(e.toString());
      exit(2);
    }
  }
}
