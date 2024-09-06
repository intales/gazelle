import 'dart:io';

import 'package:dart_style/dart_style.dart';

import '../../commons/entities/http_method.dart';
import '../../commons/entities/project_route.dart';
import '../../commons/functions/uncapitalize_string.dart';

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
  required final ProjectRoute route,
  required final HttpMethod httpMethod,
}) async {
  final handlerName = "${route.name}${httpMethod.pascalCase}";
  final handler = """
import 'package:gazelle_core/gazelle_core.dart';

Future<GazelleResponse<String>> ${uncapitalizeString(handlerName)}(
  GazelleContext context,
  GazelleRequest request,
) async {
  return GazelleResponse(
    statusCode: GazelleHttpStatusCode.success.ok_200,
    body: "Hello, Gazelle!",
  );
}
  """
      .trim();

  final handlerFileName =
      "${route.path}/${route.path.split("/").last}_${httpMethod.name.toLowerCase()}.dart";
  final handlerFilePath = await File(handlerFileName)
      .create(recursive: true)
      .then((file) => file.writeAsString(DartFormatter().format(handler)))
      .then((file) => file.path);

  return CreateHandlerResult(
    handlerFilePath: handlerFilePath,
    handlerName: handlerName,
  );
}
