import 'dart:io';

import 'package:dart_style/dart_style.dart';

/// Creates an handler for a Gazelle project.
Future<String> createHandler({
  required String routeName,
  required String httpMethod,
  required String path,
}) async {
  final routeNameParts = routeName.split("_");

  String handlerName = "";
  for (var i = 0; i < routeNameParts.length; i++) {
    final part = routeNameParts[i];
    if (i == 0) {
      handlerName += part.toLowerCase();
      continue;
    }
    handlerName += "${part[0].toUpperCase()}${part.substring(1)}";
  }

  handlerName += switch (httpMethod) {
    "GET" => "Get",
    "POST" => "Post",
    "PUT" => "Put",
    "PATCH" => "Patch",
    "DELETE" => "Delete",
    _ => throw "Unexpected error",
  };

  final handler = """
import 'package:gazelle_core/gazelle_core.dart';

GazelleResponse $handlerName(
  GazelleContext context,
  GazelleRequest request,
  GazelleResponse response,
) {
  return GazelleResponse(
    statusCode: GazelleHttpStatusCode.success.ok_200,
    body: "Hello, World!",
  );
}
  """
      .trim();

  final handlerFileName =
      "$path/${routeName.toLowerCase()}_${httpMethod.toLowerCase()}.dart";
  return File(handlerFileName)
      .create(recursive: true)
      .then((file) => file.writeAsString(DartFormatter().format(handler)))
      .then((file) => file.path);
}
