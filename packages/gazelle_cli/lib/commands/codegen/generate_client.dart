import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';

import '../../commons/consts.dart';
import '../../commons/functions/get_latest_package_version.dart';
import '../../commons/functions/snake_to_pascal_case.dart';
import '../../commons/functions/version.dart';

String _getPubspecTemplate({
  required String gazelleClientVersion,
  required String gazelleSerializationVersion,
}) =>
    """
name: client 
description: Client for Gazelle project.
version: 0.1.0
publish_to: "none"

environment:
  sdk: ^$dartSdkVersion

dependencies:
  gazelle_serialization: ^$gazelleSerializationVersion
  gazelle_client: ^$gazelleClientVersion
  models:
    path: ../models

dev_dependencies:
  lints: ">=2.1.0 <4.0.0"
  test: ^1.24.0
""";

/// Generates a Dart client for the current Gazelle project.
Future<void> generateClient({
  required String structure,
  required String path,
  required String projectName,
}) async {
  final routeStructure = jsonDecode(structure);
  final code = StringBuffer();

  code.writeln("import 'package:models/models.dart';");
  code.writeln("import 'package:gazelle_client/gazelle_client.dart';");
  code.writeln("export 'package:models/models.dart';");
  code.writeln(
      "export 'package:gazelle_client/gazelle_client.dart' hide GazelleRouteClient, GazelleApiClient;");
  code.writeln();

  code.writeln("extension GazelleApiClientExtension on GazelleApiClient {");
  _generateRouteProperties(routeStructure, code, extension: true);
  code.writeln("}");
  code.writeln();

  _generateRouteClasses(routeStructure, code);
  code.writeln();

  code.writeln("class Gazelle {");
  code.writeln("static GazelleClient? _client;");
  code.writeln("""void init({String? baseUrl}) => _client = GazelleClient.init(
        baseUrl: baseUrl ?? "http://localhost:3000",
        modelProvider: ${_snakeToPascalCase(projectName)}ModelProvider(),
      );""");
  code.writeln("""GazelleClient get client =>
      _client == null ? throw "Gazelle not configured!" : _client!;""");
  code.writeln("}");
  code.writeln();

  code.writeln("final gazelle = Gazelle();");

  final clientExtensions = DartFormatter().format(code.toString());
  await _createClientPackage(path: path, clientExtensions: clientExtensions);
}

Future<String> _createClientPackage({
  required String path,
  required String clientExtensions,
}) async {
  final latestVersions = await Future.wait([
    getLatestPackageVersion(gazelleSerializationPackageName),
    getLatestPackageVersion(gazelleClientPackageName),
  ]);

  await File("$path/pubspec.yaml")
      .create(recursive: true)
      .then((file) => file.writeAsString(_getPubspecTemplate(
            gazelleClientVersion: latestVersions[1],
            gazelleSerializationVersion: latestVersions[0],
          )));

  await File("$path/lib/client.dart")
      .create(recursive: true)
      .then((file) => file.writeAsString(clientExtensions));

  await Process.run(
    "dart",
    ["pub", "get"],
    workingDirectory: "$path/",
  );

  return path;
}

void _generateRouteProperties(
  Map<String, dynamic> node,
  StringBuffer code, {
  bool extension = false,
}) {
  if (node['children'] == null) return;
  for (final entry in node['children'].entries) {
    final className = _snakeToPascalCase(entry.key);
    final propertyName =
        className.replaceRange(0, 1, className[0].toLowerCase());

    if (entry.value['name'].startsWith(':')) {
      code.writeln(
          "${className}Route $propertyName(String value) => ${className}Route(${extension ? "this" : "_client"}(value));");
    } else {
      code.writeln(
          "${className}Route get $propertyName => ${className}Route(${extension ? "this" : "_client"}('${entry.key}'));");
    }
  }
}

void _generateRouteClasses(
  Map<String, dynamic> node,
  StringBuffer code, {
  String? parentName,
}) {
  if (node['children'] == null) return;
  for (final entry in node['children'].entries) {
    final className =
        "${parentName ?? ""}${_snakeToPascalCase(entry.key)}Route";

    code.writeln("class $className {");
    code.writeln("final GazelleRouteClient _client;");
    code.writeln("$className(this._client);");

    if (entry.value['methods'] != null) {
      if (entry.value['methods']['get'] != null) {
        final returnType =
            entry.value['methods']['get']['returnType'] ?? "dynamic";
        code.writeln(
            "Future<$returnType> get({Map<String, dynamic>? queryParams}) => _client.get<$returnType>(queryParams: queryParams);");
      }
      if (entry.value['methods']['post'] != null) {
        final returnType =
            entry.value['methods']['post']['returnType'] ?? "dynamic";
        code.writeln(
            "Future<$returnType> post($returnType body) => _client.post<$returnType>(body: body);");
      }
      if (entry.value['methods']['put'] != null) {
        final returnType =
            entry.value['methods']['put']['returnType'] ?? "dynamic";
        code.writeln(
            "Future<$returnType> put($returnType body) => _client.put<$returnType>(body: body);");
      }
      if (entry.value['methods']['patch'] != null) {
        final returnType =
            entry.value['methods']['patch']['returnType'] ?? "dynamic";
        code.writeln(
            "Future<$returnType> patch($returnType body) => _client.patch<$returnType>(body: body);");
      }
      if (entry.value['methods']['delete'] == true) {
        final returnType =
            entry.value['methods']['delete']['returnType'] ?? "dynamic";
        code.writeln(
            "Future<$returnType> delete($returnType body) => _client.delete<$returnType>(body: body);");
      }
    }

    _generateRouteProperties(
      entry.value,
      code,
    );

    code.writeln("}");

    _generateRouteClasses(
      entry.value,
      code,
      parentName: className,
    );
  }
}

String _snakeToPascalCase(String input) => snakeToPascalCase(input);
