import 'dart:io';

import 'package:args/command_runner.dart';

import 'analyze_entities.dart';
import 'generate_model_provider.dart';

class CodegenCommand extends Command {
  @override
  String get name => "codegen";
  @override
  String get description =>
      "Generates a model provder for the current project.";

  @override
  void run() async {
    final sourceFiles = await analyzeEntities(Directory("lib/entities"));
    generateModelProvider(
      sourceFiles: sourceFiles,
      entitiesBasePath: "../entities",
      destinationPath: "lib/models",
    );
  }
}
