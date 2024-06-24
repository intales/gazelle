import 'class_definition.dart';

/// Represents a class definition read from a file.
class FileClassDefinition {
  /// The class definition.
  final ClassDefinition classDefinition;

  /// The name of the file.
  final String fileName;

  /// Builds a [FileClassDefinition].
  const FileClassDefinition({
    required this.classDefinition,
    required this.fileName,
  });
}
