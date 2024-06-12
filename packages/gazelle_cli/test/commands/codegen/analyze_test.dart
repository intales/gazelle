import 'dart:io';

import 'package:gazelle_cli/commands/codegen/analyze.dart';
import 'package:test/test.dart';

void main() {
  group('Analyze tests', () {
    test('Should return a list of class definitions', () async {
      // Arrange
      const directoryPath = "tmp/analyze_test";
      const userDefinition = """
      class User {
        final String name;
	final int age;

	const User({
	  required this.name,
	  required this.age,
	});
      }
      """;
      const userDefinitionPath = "$directoryPath/user.dart";
      const postDefinition = """
      class Post {
        final String username;
	final int id;

	const Post({
	  required this.username,
	  required this.id,
	});
      }
      """;
      const postDefinitionPath = "$directoryPath/post.dart";
      final directory = await Directory(directoryPath).create(recursive: true);
      final userDefinitionFile =
          await File(userDefinitionPath).create(recursive: true);
      final postDefinitionFile =
          await File(postDefinitionPath).create(recursive: true);
      await userDefinitionFile.writeAsString(userDefinition);
      await postDefinitionFile.writeAsString(postDefinition);

      // Act
      final result = await analyze(directoryPath);

      // Assert
      expect(result.length, 2);

      await directory.delete(recursive: true);
    });
  });
}
