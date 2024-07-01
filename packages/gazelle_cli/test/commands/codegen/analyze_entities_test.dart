import 'dart:io';

import 'package:gazelle_cli/commands/codegen/analyze_entities.dart';
import 'package:test/test.dart';

const _userClass = """
class User {
  final String id;
  final String username;

  const User({
    required this.id,
    required this.username,
  });
}
""";

const _postClass = """
import 'user.dart';

class Post {
  final String id;
  final String content;
  final User user;

  const Post({
    required this.id,
    required this.content,
    required this.user,
  });
}
""";

void main() {
  group('Analyze tests', () {
    test('Should analyze some dart classes', () async {
      // Arrange
      final entitiesDirectoryPath = "tmp/analyze_tests/entities";
      final entitiesDirectory = Directory(entitiesDirectoryPath);
      if (entitiesDirectory.existsSync()) {
        entitiesDirectory.deleteSync(recursive: true);
      }
      entitiesDirectory.createSync(recursive: true);
      final userFile = File("$entitiesDirectoryPath/user.dart")
        ..createSync(recursive: true)
        ..writeAsStringSync(_userClass);
      final postFile = File("$entitiesDirectoryPath/post.dart")
        ..createSync(recursive: true)
        ..writeAsStringSync(_postClass);

      // Act
      final result = await analyzeEntities(entitiesDirectory);

      // Assert
      final userDefinition = result
          .where((e) => e.fileName == userFile.absolute.path)
          .singleOrNull;
      final postDefinition = result
          .where((e) => e.fileName == postFile.absolute.path)
          .singleOrNull;

      expect(userDefinition, isNotNull);
      expect(postDefinition, isNotNull);

      final userClasses = userDefinition!.classes;
      final postClasses = postDefinition!.classes;

      expect(userClasses.length, 1);
      expect(postClasses.length, 1);

      final postImports = postDefinition.importsPaths;

      expect(postImports.length, 1);
      expect(postImports.first, "user.dart");

      // Tear down
      entitiesDirectory.deleteSync(recursive: true);
    });
  });
}
