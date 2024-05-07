import 'dart:io';

/// Uninstalls a Gazelle project.
class DeletingProjectError {
  /// The error message.
  final String message;

  /// Creates a [DeletingProjectError].
  const DeletingProjectError() : message = "Failed to delete project!";
}

/// Asks for confirmation before deleting a project.
///
/// Returns `true` if user confirms, `false` otherwise.
Future<bool> getConfirmation(String message) async {
  print('$message (y/N)');
  String? answer = stdin.readLineSync();
  if (answer?.toLowerCase() == 'y' || answer?.toLowerCase() == 'yes') {
    return true;
  }
  return false;
}

/// Delete a Gazelle project.
///
/// Throws a [DeletingProjectError] if project does not exist.

Future<String> deleteProject(
  String projectName, {
  String? path,
}) async {
  final nameOption = projectName;
  final pathOption = path;
  final completePath =
      pathOption != null ? "$pathOption/$nameOption" : nameOption;
  if (!await Directory(completePath).exists()) {
    throw DeletingProjectError();
  }
  await Directory(completePath).delete(recursive: true);
  return completePath;
}
