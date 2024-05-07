import 'package:args/command_runner.dart';

import 'commands/create/create.dart';
import 'commands/delete/delete.dart';
import 'commands/dockerize/dockerize.dart';
import 'commands/run/run.dart';

/// Runs Gazelle CLI with given arguments.
void run(List<String> arguments) =>
    CommandRunner("gazelle", "Gazelle CLI for Gazelle framework.")
      ..addCommand(CreateCommand())
      ..addCommand(DockerizeCommand())
      ..addCommand(RunCommand())
      ..addCommand(DeleteCommand())
      ..run(arguments);
