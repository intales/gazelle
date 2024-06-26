import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';

import '../../commons/functions/get_input.dart';
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
    addSubcommand(_CreatHandlerCommand());
  }
}

/// CLI command to create a new Gazelle project.
class _CreateProjectCommand extends Command {
  @override
  String get name => "project";

  @override
  String get description => "Creates a new Gazelle project.";

  /// Creates a [_CreateProjectCommand].
  _CreateProjectCommand();

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

    final spinner = CliSpin(
      text: "Creating $projectName project...",
      spinner: CliSpinners.dots,
    ).start();

    try {
      final result = await createProject(
        projectName: projectName,
        path: Directory.current.path,
      );

      spinner.success(
        "$projectName project created 🚀\n💡To navigate to your project run \"cd ${result.split("/").last}\"\n💡Then, use \"gazelle run\" to execute it!",
      );

      Directory.current = result;
    } on CreateProjectError catch (e) {
      spinner.fail(e.message);
      exit(2);
    } on Exception catch (e) {
      spinner.fail(e.toString());
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
      await loadProjectConfiguration();
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

      final directory = Directory.current;
      final path = "${directory.path}/lib";

      await createRoute(
        routeName: routeName,
        path: path,
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
class _CreatHandlerCommand extends Command {
  @override
  String get name => "handler";

  @override
  String get description => "Creates a new Gazelle handler.";

  /// Creates a [_CreatHandlerCommand].
  _CreatHandlerCommand();

  @override
  void run() async {
    CliSpin spinner = CliSpin();
    try {
      await loadProjectConfiguration();

      final handlerName = getInput(
        "What is the route for this handler?",
        onEmpty: "Please provide a name for your route to proceed!",
        onValidated: (input) =>
            input.replaceAll(RegExp(r'\s+'), "_").toLowerCase(),
      );

      const httpMethods = ["GET", "POST", "PUT", "PATCH", "DELETE"];

      final httpMethod = getInput(
        "What HTTP method does your handler respond to?",
        onEmpty: "Please provide an HTTP method to proceed!",
        validator: (input) => httpMethods
                .contains(input.replaceAll(RegExp(r'\s+'), "").toUpperCase())
            ? null
            : "Please provide a valid HTTP method from the following: $httpMethods",
        defaultValue: "GET",
        onValidated: (input) =>
            input.replaceAll(RegExp(r'\s+'), "").toUpperCase(),
      );

      final path = getInput(
        "Where would you like to create the handler?",
        defaultValue: "lib/routes/${handlerName}_route/handlers",
        onEmpty: "Please provide a valid path to proceed:",
        validator: (input) {
          final handlerFile = File(
              "$input/${handlerName.toLowerCase()}_${httpMethod.toLowerCase()}_handler.dart");
          return handlerFile.existsSync()
              ? "A handler with the same name already exists at the provided path."
              : null;
        },
        onValidated: (input) =>
            (Directory(input)..createSync(recursive: true)).path,
      );

      stdout.writeln();

      spinner = CliSpin(
        text: "Creating $handlerName handler...",
        spinner: CliSpinners.dots,
      ).start();

      await createHandler(
        routeName: handlerName,
        httpMethod: httpMethod,
        path: path,
      );

      spinner.success("$handlerName handler created 🚀");
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
