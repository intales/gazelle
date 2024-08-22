import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';
import 'package:path/path.dart';

import '../../commons/functions/load_project_configuration.dart';
import 'analyze_entities.dart';
import 'generate_client.dart';
import 'generate_model_provider.dart';
import 'generate_models_barrel_file.dart';

/// CLI command to generate code.
class CodegenCommand extends Command {
  @override
  String get name => "codegen";
  @override
  String get description => "Generate code for your Gazelle project.";

  /// Creates a [CodegenCommand].
  CodegenCommand() {
    addSubcommand(_CodegenModelsCommand());
    addSubcommand(_CodegenClientCommand());
  }
}

class _CodegenModelsCommand extends Command {
  static const _entitiesPath = "models/lib/entities";
  static const _entitiesBasePath = "../entities";
  static const _destinationPath = "models/lib/models";
  static const _barrelFilePath = "models/lib";

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
      await generateModelsBarrelFile(
        entitiesPath: sourceFiles.map((e) => e.fileName).toList(),
        modelsPath: models.modelTypes.map((e) => e.path).toList(),
        modelProviderPath: models.modelProvider.path,
        barrelFilePath: _barrelFilePath,
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

class _CodegenClientCommand extends Command {
  @override
  String get name => "client";

  @override
  String get description =>
      "Generates a client for your Dart frontend application.";

  @override
  void run() async {
    CliSpin spinner = CliSpin();
    try {
      final projectConfiguration = await loadProjectConfiguration();

      spinner = CliSpin(
        text: "Generating client...",
        spinner: CliSpinners.dots,
      ).start();

      final result = await Process.run(
        'dart',
        [
          'run',
          join(projectConfiguration.path, "server/bin/server.dart"),
          '--export-routes'
        ],
        runInShell: true,
      );

      final output = result.stdout as String;
      await generateClient(
        structure: output,
        path: join(projectConfiguration.path, "client"),
        projectName: projectConfiguration.name,
      );

      spinner.success(
          "Client generated 🚀\nImport the client in your Dart frontend application!");
    } on LoadProjectConfigurationGazelleNotFoundError catch (e) {
      spinner.fail(e.errorMessage);
      exit(e.errorCode);
    } on AnalyzeEntitiesException catch (e) {
      spinner.fail(e.message);
      exit(2);
    } on Exception catch (e, stack) {
      spinner.fail("$e\n${stack.toString()}");
      exit(2);
    }
  }
}
