import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';
import 'package:path/path.dart';

import '../../commons/entities/project_configuration.dart';
import '../../commons/functions/load_project_configuration.dart';
import 'run_project.dart';

/// CLI command to run a Gazelle project.
class RunCommand extends Command {
  @override
  String get name => "run";

  @override
  String get description => "Runs a Gazelle project with hot reload.";

  /// The default timeout in milliseconds.
  int defaultTimeout = 1000;

  /// Creates a [RunCommand].
  RunCommand() {
    argParser.addFlag(
      "verbose",
      abbr: 'v',
      negatable: true,
      defaultsTo: false,
      help: "Prints all logs.",
    );
  }

  @override
  void run() async {
    final verbose = argResults?.flag("verbose") ?? false;

    late final ProjectConfiguration config;
    try {
      config = await loadProjectConfiguration();
    } on LoadProjectConfigurationPubspecNotFoundError catch (e) {
      print(e.errorMessage);
      exit(e.errorCode);
    } catch (e) {
      print(e);
      exit(2);
    }

    final projectName = config.name;
    final spinner = CliSpin(
      text: "Running Project '$projectName'...",
      spinner: CliSpinners.dots,
    ).start();

    try {
      await runProject(join(config.path, "server"), defaultTimeout, verbose);
      spinner.success();
      print(
          "Press 'r' to hot-reload the project.\nPress 'R' to hot-restart.\nCtrl+c to exit.\n");
    } on RunProjectError catch (e) {
      spinner.fail(e.message);
      exit(e.errCode);
    } on Exception catch (e) {
      spinner.fail(e.toString());
      exit(2);
    }
  }
}
