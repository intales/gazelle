import 'dart:io';

/// Asks for confirmation before deleting a project.
///
/// Returns `true` if user confirms, `false` otherwise.
bool getConfirmation(String message) {
  print('$message (y/N)');
  String? answer = stdin.readLineSync();
  if (answer?.toLowerCase() == 'y' || answer?.toLowerCase() == 'yes') {
    return true;
  }
  return false;
}
