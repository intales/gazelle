import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';

import '../../commons/functions/load_project_configuration.dart';
import 'codegen.dart';

/// CLI command to delete a Gazelle project.
class CodegenCommand extends Command {
  @override
  String get description => "Generates models for the current project";

  @override
  String get name => "codegen";

  /// Creates a [CodegenCommand].
  CodegenCommand();

  @override
  void run() async {
    final projectConfiguration =
        await loadProjectConfiguration(path: Directory.current.path);

    final spinner = CliSpin(
      text: "Generating Gazelle models...",
      spinner: CliSpinners.dots,
    ).start();
    try {
      final entitiesDirectoryPath = "${Directory.current.path}/lib/entities";
      await codegen(entitiesDirectoryPath, projectConfiguration.name);
      spinner.success(
        "Models generated!",
      );
    } on Exception catch (e) {
      spinner.fail(e.toString());
      exit(2);
    }
  }
}
