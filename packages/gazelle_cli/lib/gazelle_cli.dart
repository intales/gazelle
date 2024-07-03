import 'package:args/command_runner.dart';

import 'commands/codegen/codegen.dart';
import 'commands/create/create.dart';
import 'commands/delete/delete.dart';
import 'commands/dockerize/dockerize.dart';
import 'commands/run/run.dart';

/// Runs Gazelle CLI with given arguments.
void run(List<String> arguments) async {
  final runner = CommandRunner("gazelle", "Gazelle CLI for Gazelle framework.")
    ..addCommand(CreateCommand())
    ..addCommand(CodegenCommand())
    ..addCommand(DockerizeCommand())
    ..addCommand(RunCommand())
    ..addCommand(DeleteCommand());
  try {
    await runner.run(arguments);
  } catch (e) {
    print(e);
  }
}
