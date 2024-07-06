import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';

import '../../commons/functions/load_project_configuration.dart';
import 'analyze_entities.dart';
import 'generate_model_provider.dart';

/// CLI command to generate code.
class CodegenCommand extends Command {
  @override
  String get name => "codegen";
  @override
  String get description => "Generate code for your Gazelle project.";

  /// Creates a [CodegenCommand].
  CodegenCommand() {
    addSubcommand(_CodegenModelsCommand());
  }
}

class _CodegenModelsCommand extends Command {
  static const _entitiesPath = "lib/entities";
  static const _entitiesBasePath = "../entities";
  static const _destinationPath = "lib/models";

  @override
  String get name => "models";

  @override
  String get description => "Generate models based on your entities.";

  @override
  void run() async {
    CliSpin spinner = CliSpin();
    try {
      final projectConfiguration = await loadProjectConfiguration();

      spinner = CliSpin(
        text: "Generating models...",
        spinner: CliSpinners.dots,
      ).start();

      final sourceFiles = await analyzeEntities(Directory(_entitiesPath));
      final models = await generateModelProvider(
        projectName: projectConfiguration.name,
        sourceFiles: sourceFiles,
        entitiesBasePath: _entitiesBasePath,
        destinationPath: _destinationPath,
      );

      spinner.success(
        "Models generated 🚀\nAdd ${models.modelProvider.path.split("/").last} to your GazelleApp!",
      );
    } on LoadProjectConfigurationGazelleNotFoundError catch (e) {
      spinner.fail(e.errorMessage);
      exit(e.errorCode);
    } on AnalyzeEntitiesException catch (e) {
      spinner.fail(e.message);
      exit(2);
    } on Exception catch (e) {
      spinner.fail(e.toString());
      exit(2);
    }
  }
}
