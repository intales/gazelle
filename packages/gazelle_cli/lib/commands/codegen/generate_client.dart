import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';

import '../../commons/consts.dart';
import '../../commons/functions/get_latest_package_version.dart';
import '../../commons/functions/snake_to_pascal_case.dart';
import '../../commons/functions/uncapitalize_string.dart';
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
  String? parentName,
}) {
  if (node['children'] == null) return;
  for (final entry in node['children'].entries) {
    final className = "${parentName ?? ""}${_snakeToPascalCase(entry.key)}";
    final propertyName = uncapitalizeString(_snakeToPascalCase(entry.key));

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
        String returnType =
            entry.value['methods']['get']['returnType'] ?? "dynamic";

        if (returnType.startsWith("List")) {
          returnType = _extractGenericType(returnType);
          code.writeln(
              "Future<List<$returnType>> get({Map<String, dynamic>? queryParams}) => _client.list<$returnType>(queryParams: queryParams);");
        } else {
          code.writeln(
              "Future<$returnType> get({Map<String, dynamic>? queryParams}) => _client.get<$returnType>(queryParams: queryParams);");
        }
      }
      if (entry.value['methods']['post'] != null) {
        final returnType =
            entry.value['methods']['post']['returnType'] ?? "dynamic";
        final requestType =
            entry.value['methods']['post']['requestType'] ?? "dynamic";
        code.writeln(
            "Future<$returnType> post($requestType body) => _client.post<$requestType, $returnType>(body: body);");
      }
      if (entry.value['methods']['put'] != null) {
        final returnType =
            entry.value['methods']['put']['returnType'] ?? "dynamic";
        final requestType =
            entry.value['methods']['put']['requestType'] ?? "dynamic";
        code.writeln(
            "Future<$returnType> put($requestType body) => _client.put<$requestType, $returnType>(body: body);");
      }
      if (entry.value['methods']['patch'] != null) {
        final returnType =
            entry.value['methods']['patch']['returnType'] ?? "dynamic";
        final requestType =
            entry.value['methods']['patch']['requestType'] ?? "dynamic";
        code.writeln(
            "Future<$returnType> patch($requestType body) => _client.patch<$requestType, $returnType>(body: body);");
      }
      if (entry.value['methods']['delete'] == true) {
        final returnType =
            entry.value['methods']['delete']['returnType'] ?? "dynamic";
        final requestType =
            entry.value['methods']['delete']['requestType'] ?? "dynamic";
        code.writeln(
            "Future<$returnType> delete($requestType body) => _client.delete<$requestType, $returnType>(body: body);");
      }
    }

    _generateRouteProperties(
      entry.value,
      code,
      parentName: className,
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

String _extractGenericType(String typeString) {
  final startIndex = typeString.indexOf('<');
  final endIndex = typeString.indexOf('>');

  if (startIndex == -1 || endIndex == -1 || startIndex > endIndex) {
    throw ArgumentError('Invalid generic type format.');
  }

  return typeString.substring(startIndex + 1, endIndex);
}
