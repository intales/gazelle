import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_spin/cli_spin.dart';
import 'package:path/path.dart';

import '../../commons/functions/get_input.dart';
import '../../commons/functions/get_input_selection.dart';
import '../../commons/functions/load_project_configuration.dart';
import '../../commons/functions/snake_to_pascal_case.dart';
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

      final directory = Directory.current;
      final path = "${directory.path}/server/lib";

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
      final configuration = await loadProjectConfiguration();
      Directory.current = configuration.path;

      final serverPath = join(Directory.current.path, "server");

      final routesPath = join(serverPath, "lib", "routes");
      final availableRoutes = await Directory(routesPath).list().toList().then(
          (routes) => routes.map((route) => route.absolute.path).toList());

      final path = getInputSelection(
        options: availableRoutes,
        getOptionText: (option) => snakeToPascalCase(option.split("/").last),
      );

      String handlerName = snakeToPascalCase(path.split("/").last);

      final httpMehtods = ["Get", "Post", "Put", "Patch", "Delete"];

      final httpMethod = getInputSelection(
        options: httpMehtods,
        getOptionText: (option) => option,
      );

      handlerName += httpMethod;

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
