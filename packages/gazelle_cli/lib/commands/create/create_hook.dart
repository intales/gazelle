import 'dart:io';

import 'package:dart_style/dart_style.dart';

/// The result of [createHook] function.
class CreateHookResult {
  /// The path of the create hook file.
  final String hookFilePath;

  /// The name of the created hook.
  final String hookName;

  /// Creates a [CreateHookResult].
  const CreateHookResult({
    required this.hookFilePath,
    required this.hookName,
  });
}

/// Enumerates available hook types.
enum CreateHookType {
  /// Pre request hook.
  preRequest,

  /// Post request hook.
  postResponse;

  @override
  String toString() => switch (this) {
        CreateHookType.preRequest => "pre_request",
        CreateHookType.postResponse => "post_response",
      };
}

/// Creates a new hook.
Future<CreateHookResult> createHook({
  required String hookName,
  required CreateHookType hookType,
  required String path,
}) async {
  final routeNameParts = hookName.split("_");

  String codeHookName = "";
  for (var i = 0; i < routeNameParts.length; i++) {
    final part = routeNameParts[i];
    if (i == 0) {
      codeHookName += part.toLowerCase();
      continue;
    }
    codeHookName += "${part[0].toUpperCase()}${part.substring(1)}";
  }
  codeHookName += switch (hookType) {
    CreateHookType.preRequest => "PreRequest",
    CreateHookType.postResponse => "PostResponse",
  };
  codeHookName += "Hook";

  final hook = switch (hookType) {
    CreateHookType.preRequest => _createPreRequestHook(
        hookName: codeHookName,
      ),
    CreateHookType.postResponse => _createPostResponseHook(
        hookName: codeHookName,
      ),
  };

  final hookFileName = "$path/${hookName}_$hookType.dart";

  final hookFile = await File(hookFileName)
      .create(recursive: true)
      .then((file) => file.writeAsString(DartFormatter().format(hook)));

  return CreateHookResult(
    hookFilePath: hookFile.path,
    hookName: codeHookName,
  );
}

String _createPreRequestHook({
  required String hookName,
}) {
  final hook = """
import 'package:gazelle_core/gazelle_core.dart';

final $hookName = GazellePreReqestHook(
  (context, request, response) async {
    // TODO: Write an awesome hook!

    return (request, response);
  },
);
  """
      .trim();

  return hook;
}

String _createPostResponseHook({
  required String hookName,
}) {
  final hook = """
import 'package:gazelle_core/gazelle_core.dart';

final $hookName = GazellePostResponseHook(
  (context, request, response) async {
    // TODO: Write an awesome hook!

    return (request, response);
  },
);
  """
      .trim();

  return hook;
}
