import 'dart:io';

/// Uninstalls a Gazelle project.
class UninstallProjectError {
  /// The error message.
  final String message;

  /// Creates a [UninstallProjectError].
  const UninstallProjectError() : message = "Failed to uninstall project!";
}

/// Uninstalls a Gazelle project.
///
/// Throws a [UninstallProjectError] if project does not exist.

Future<String> uninstallProject(
  String projectName, {
  String? path,
}) async {
  final nameOption = projectName;
  final pathOption = path;

  final completePath =
      pathOption != null ? "$pathOption/$nameOption" : nameOption;
  if (!await Directory(completePath).exists()) {
    throw UninstallProjectError();
  }

  await Directory(completePath).delete(recursive: true);

  return completePath;
}
