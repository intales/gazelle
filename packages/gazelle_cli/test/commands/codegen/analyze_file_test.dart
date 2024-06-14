import 'dart:io';

import 'package:gazelle_cli/commands/codegen/analyze_file.dart';
import 'package:test/test.dart';

void main() {
  group('AnalyzeFile tests', () {
    test('Should return a list of class definitions', () async {
      // Arrange
      final fileContent = """
      class User {
        final String name;
	final int age;

	const User({
	  required this.name,
	  required this.age,
	});
      }

      class Post {
        final String username;
	final int id;

	const Post({
	  required this.username,
	  required this.id,
	});
      }
      """;
      final file = await File("tmp/analyze_file_test/classes.dart")
          .create(recursive: true);
      await file.writeAsString(fileContent);

      // Act
      final result = await analyzeFile(file.path);

      // Assert
      expect(result.length, 2);

      await file.delete(recursive: true);
    });
  });
}
