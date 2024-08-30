import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';

import '../../commons/functions/get_available_methods.dart';
import '../../commons/functions/get_input_selection.dart';
import '../../commons/functions/get_project_routes.dart';
import '../../commons/functions/load_project_configuration.dart';
import 'create_handler.dart';
import 'create_project.dart';
import 'create_route.dart';

/// CLI command to create a new Gazelle project.
class CreateCommand extends Command {
  @override
  String get name => "create";

  @override
  String get description => "Creates a new Gazelle project.";

  /// Creates a [CreateCommand].
  CreateCommand() {
    addSubcommand(_CreateProjectCommand());
    addSubcommand(_CreateRouteCommand());
    addSubcommand(_CreateHandlerCommand());
  }
}

/// CLI command to create a new Gazelle project.
class _CreateProjectCommand extends Command {
  @override
  String get name => "project";

  @override
  String get description => "Creates a new Gazelle project.";

  /// Creates a [_CreateProjectCommand].
  _CreateProjectCommand() {
    argParser.addFlag(
      "flutter",
      abbr: "f",
      help: "Create a full-stack project with Gazelle and Flutter.",
    );
  }

  @override
  void run() async {
    stdout.writeln("✨ What would you like to name your new project? 🚀");
    String? projectName = stdin.readLineSync();
    while (projectName == null || projectName == "") {
      stdout.writeln("⚠ Please provide a name for your project to proceed:");
      projectName = stdin.readLineSync();
    }
    stdout.writeln();

    projectName = projectName.replaceAll(RegExp(r'\s+'), "_").toLowerCase();
    final fullstack = argResults?.flag("flutter") != null ? true : false;

    final spinner = CliSpin(
      text: "Creating $projectName project...",
      spinner: CliSpinners.dots,
    ).start();

    try {
      await createProject(
        projectName: projectName,
        path: Directory.current.path,
        fullstack: fullstack,
      );

      spinner.success(
        "$projectName project created 🚀\n💡To navigate to your project run \"cd $projectName\"\n💡Then, use \"gazelle run\" to execute it!",
      );
    } on CreateProjectError catch (e) {
      spinner.fail(e.message);
      exit(2);
    } on Exception catch (e, stack) {
      spinner.fail(stack.toString());
      exit(2);
    }
  }
}

/// CLI command to create a new Gazelle project.
class _CreateRouteCommand extends Command {
  @override
  String get name => "route";

  @override
  String get description =>
      "Creates a new route inside the current Gazelle project.";

  _CreateRouteCommand();

  @override
  void run() async {
    CliSpin spinner = CliSpin();
    try {
      final configuration = await loadProjectConfiguration();
      Directory.current = configuration.path;

      stdout.writeln("✨ What would you like to name your new route? 🚀");
      String? routeName = stdin.readLineSync();
      while (routeName == null || routeName == "") {
        stdout.writeln("⚠ Please provide a name for your route to proceed:");
        routeName = stdin.readLineSync();
      }
      stdout.writeln();

      routeName = routeName.replaceAll(RegExp(r'\s+'), "_").toLowerCase();

      spinner = CliSpin(
        text: "Creating $routeName route...",
        spinner: CliSpinners.dots,
      ).start();

      await createRoute(
        routeName: routeName,
        projectConfiguration: configuration,
      );

      spinner.success(
        "$routeName route created 🚀",
      );
    } on LoadProjectConfigurationGazelleNotFoundError catch (e) {
      spinner.fail(e.errorMessage);
      exit(e.errorCode);
    } on Exception catch (e) {
      spinner.fail(e.toString());
      exit(2);
    }
  }
}

/// CLI command to create a new Gazelle handler.
class _CreateHandlerCommand extends Command {
  @override
  String get name => "handler";

  @override
  String get description => "Creates a new Gazelle handler.";

  /// Creates a [_CreateHandlerCommand].
  _CreateHandlerCommand();

  @override
  void run() async {
    CliSpin spinner = CliSpin();
    try {
      final configuration = await loadProjectConfiguration();
      Directory.current = configuration.path;

      final availableRoutes = await getProjectRoutes(configuration);

      final route = getInputSelection(
        options: availableRoutes,
        getOptionText: (option) => option.name,
        prompt: "Pick a route:",
      );

      final availableMethods = getAvailableMethods(route);

      final httpMethod = getInputSelection(
        options: availableMethods,
        getOptionText: (option) => option.name,
        prompt: "Pick a method:",
      );

      spinner = CliSpin(
        text: "Creating ${route.name}_${httpMethod}_handler...",
        spinner: CliSpinners.dots,
      ).start();

      final result = await createHandler(
        route: route,
        httpMethod: httpMethod,
      );

      spinner.success("${result.handlerName} created 🚀");
    } on LoadProjectConfigurationGazelleNotFoundError catch (e) {
      spinner.fail(e.errorMessage);
      exit(e.errorCode);
    } on LoadProjectConfigurationPubspecNotFoundError catch (e) {
      spinner.fail(e.errorMessage);
      exit(e.errorCode);
    } on Exception catch (e) {
      spinner.fail(e.toString());
      exit(2);
    }
  }
}
