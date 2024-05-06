import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';
import 'uninstall_project.dart';

/// CLI command to uninstall a Gazelle project.
class UninstallCommand extends Command {
  @override
  String get description => "Uninstalling a Gazelle project";

  @override
  String get name => "uninstall";

  /// Creates a [UninstallCommand].
  UninstallCommand() {
    argParser.addOption(
      "name",
      abbr: "n",
      help: "The name of the project you want to uninstall.",
    );
    argParser.addOption(
      "path",
      abbr: "p",
      help: "The path where you want to uninstall the project.",
    );
  }

  @override
  void run() async {
    final spinner = CliSpin(
      text: "Uninstalling Gazelle project...",
      spinner: CliSpinners.dots,
    ).start();
    final nameOption = argResults?.option("name") ?? "gazelle_app";
    final pathOption = argResults?.option("path");
    try {
      final result = await uninstallProject(nameOption, path: pathOption);
      spinner.success(
        "$result project uninstalled!\n",
      );
    } on UninstallProjectError catch (e) {
      spinner.fail(e.message);
      exit(2);
    } on Exception catch (e) {
      spinner.fail(e.toString());
      exit(2);
    }
  }
}
