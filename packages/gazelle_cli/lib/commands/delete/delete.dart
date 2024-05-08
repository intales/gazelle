import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';
import '../../commons/functions/confirmation.dart';
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
      "path",
      abbr: "p",
      help: "The path of the project which you want to delete.",
    );
  }

  @override
  void run() async {
    Confirmation confirmation = Confirmation();
    bool answer = confirmation
        .getConfirmation('\nAre you sure you want to delete the project?');

    final spinner = CliSpin(
      text: "Deleting Gazelle project...",
      spinner: CliSpinners.dots,
    ).start();
    final pathOption = argResults?.option("path");
    if (!answer) {
      spinner.fail("Project deletion aborted.");
      return;
    }
    try {
      final result = await deleteProject(path: pathOption);
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
