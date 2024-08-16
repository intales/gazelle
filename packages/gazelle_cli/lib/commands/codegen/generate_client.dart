import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';

import '../../commons/functions/version.dart';

String get _pubspecTemplate => """
name: client 
description: Client for Gazelle project.
version: 0.1.0
publish_to: "none"

environment:
  sdk: ^$dartSdkVersion

dependencies:
  gazelle_serialization: ^0.1.1
  gazelle_client: ^0.1.1

dev_dependencies:
  lints: ">=2.1.0 <4.0.0"
  test: ^1.24.0
""";

/// Generates a Dart client for the current Gazelle project.
Future<void> generateClient({
  required String structure,
  required String path,
}) async {
  final routeStructure = jsonDecode(structure);
  final code = StringBuffer();

  code.writeln("import 'package:gazelle_client/gazelle_client.dart';");
  code.writeln(
      "export 'package:gazelle_client/gazelle_client.dart' hide GazelleRouteClient, GazelleApiClient;");
  code.writeln();

  code.writeln("extension GazelleApiClientExtension on GazelleApiClient {");
  _generateRouteProperties(routeStructure, code);
  code.writeln("}");
  code.writeln();

  _generateRouteClasses(routeStructure, code);

  final clientExtensions = DartFormatter().format(code.toString());
  await _createClientPackage(path: path, clientExtensions: clientExtensions);
}

Future<String> _createClientPackage({
  required String path,
  required String clientExtensions,
}) async {
  await File("$path/pubspec.yaml")
      .create(recursive: true)
      .then((file) => file.writeAsString(_pubspecTemplate));

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
  StringBuffer code,
) {
  if (node['children'] != null) {
    for (var entry in node['children'].entries) {
      final className = _snakeToPascalCase(entry.key);
      final propertyName =
          className.replaceRange(0, 1, className[0].toLowerCase());

      if (entry.value['name'].startsWith(':')) {
        code.writeln(
            "$className $propertyName(String value) => $className(this(value));");
      } else {
        code.writeln(
            "$className get $propertyName => $className(this('$propertyName'));");
      }
    }
  }
}

void _generateRouteClasses(
  Map<String, dynamic> node,
  StringBuffer code,
) {
  if (node['children'] == null) return;
  for (var entry in node['children'].entries) {
    final className = _snakeToPascalCase(entry.key);

    code.writeln("class $className {");
    code.writeln("final GazelleRouteClient _client;");
    code.writeln("$className(this._client);");
    code.writeln("GazelleRouteClient call(String path) => _client(path);");

    if (entry.value['methods'] != null) {
      if (entry.value['methods']['get'] == true) {
        code.writeln(
            "Future<dynamic> get({Map<String, dynamic>? queryParams}) => _client.get(queryParams: queryParams);");
      }
      if (entry.value['methods']['post'] == true) {
        code.writeln(
            "Future<dynamic> post(dynamic body) => _client.post(body: body);");
      }
      if (entry.value['methods']['put'] == true) {
        code.writeln(
            "Future<dynamic> put(dynamic body) => _client.put(body: body);");
      }
      if (entry.value['methods']['patch'] == true) {
        code.writeln(
            "Future<dynamic> patch(dynamic body) => _client.patch(body: body);");
      }
      if (entry.value['methods']['delete'] == true) {
        code.writeln(
            "Future<dynamic> delete(dynamic body) => _client.delete(body: body);");
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
    );
  }
}

String _snakeToPascalCase(String input) {
  return input.split('_').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join('');
}
