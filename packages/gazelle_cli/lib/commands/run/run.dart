import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';

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
    argParser.addOption(
      "path",
      abbr: "p",
      help: "The path where the project is located.",
    );
    argParser.addOption(
      "timeout",
      abbr: "t",
      help: "The time in milliseconds to wait for a restart request.",
      defaultsTo: "$defaultTimeout",
    );
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
    final pathOption = argResults?.option("path") ??
        argResults?.rest.firstOrNull ??
        Directory.current.path;
    final timeoutOption =
        int.tryParse((argResults?.option("timeout")).toString()) ??
            defaultTimeout;
    final bool verbose = argResults?.flag("verbose") ?? false;
    final projectName = pathOption.split(Platform.pathSeparator).last;

    final spinner = CliSpin(
      text: "Running '$projectName'...",
      spinner: CliSpinners.dots,
    ).start();

    try {
      await runProject(pathOption, timeoutOption, verbose);
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
