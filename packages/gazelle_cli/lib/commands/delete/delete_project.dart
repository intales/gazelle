import 'dart:io';

/// Uninstalls a Gazelle project.
class DeleteProjectError {
  /// The error message.
  final String message;

  /// Creates a [DeleteProjectError].
  const DeleteProjectError() : message = "No Gazelle project found.";
}

/// Delete a Gazelle project.
///
/// Throws a [DeleteProjectError] if project does not exist.

Future<String> deleteProject({String? path}) async {
  final pathOption = path ?? Directory.current.path;
  if (!await Directory(pathOption).exists()) {
    throw DeleteProjectError();
  }
  await Directory(pathOption).delete(recursive: true);
  return pathOption;
}
