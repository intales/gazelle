import 'dart:io';

/// Uninstalls a Gazelle project.
class DeletingProjectError {
  /// The error message.
  final String message;

  /// Creates a [DeletingProjectError].
  const DeletingProjectError() : message = "No Gazelle project found.";
}

/// Delete a Gazelle project.
///
/// Throws a [DeletingProjectError] if project does not exist.

Future<String> deleteProject({String? path}) async {
  final pathOption = path ?? Directory.current.path;
  if (!await Directory(pathOption).exists()) {
    throw DeletingProjectError();
  }
  await Directory(pathOption).delete(recursive: true);
  return pathOption;
}
