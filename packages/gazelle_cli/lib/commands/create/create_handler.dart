import 'dart:io';

import 'package:dart_style/dart_style.dart';

/// Represents the result of [createHandler] function.
class CreateHandlerResult {
  /// Where the handler has been created.
  final String handlerFilePath;

  /// The name of the handler.
  final String handlerName;

  /// Creates a [CreateHandlerResult].
  const CreateHandlerResult({
    required this.handlerFilePath,
    required this.handlerName,
  });
}

/// Creates an handler for a Gazelle project.
Future<CreateHandlerResult> createHandler({
  required String routeName,
  required String httpMethod,
  required String path,
}) async {
  final routeNameParts = routeName.split("_");

  String handlerName = "";
  for (var i = 0; i < routeNameParts.length; i++) {
    final part = routeNameParts[i];
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

  handlerName += "Handler";

  final handler = """
import 'package:gazelle_core/gazelle_core.dart';

class $handlerName extends GazelleRouteHandler {
  const $handlerName();

  @override
  Future<GazelleResponse> call(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse response,
  ) async {
    return GazelleResponse(
      statusCode: GazelleHttpStatusCode.success.ok_200,
      body: "Hello, World!",
    );
  }
}
  """
      .trim();

  final handlerFileName =
      "$path/${routeName.toLowerCase()}_${httpMethod.toLowerCase()}_handler.dart";
  final handlerFilePath = await File(handlerFileName)
      .create(recursive: true)
      .then((file) => file.writeAsString(DartFormatter().format(handler)))
      .then((file) => file.path);

  return CreateHandlerResult(
    handlerFilePath: handlerFilePath,
    handlerName: handlerName,
  );
}
