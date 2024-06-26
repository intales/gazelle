import 'package:gazelle_cli/commands/codegen/analyze_class.dart';
import 'package:test/test.dart';

void main() {
  group('AnalyzeClass tests', () {
    test('Should analyze a list of classes', () async {
      // Arrange
      const classContent = """
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

      // Act
      final result = await analyzeClasses(classContent);
      final userDefinition = result.first;
      final postDefinition = result.last;

      // Assert
      expect(result.length, 2);
      expect(userDefinition.name, "User");
      expect(postDefinition.name, "Post");
      expect(userDefinition.properties.first.name, "name");
      expect(userDefinition.properties.first.type, "String");
      expect(userDefinition.properties.last.name, "age");
      expect(userDefinition.properties.last.type, "int");
      expect(postDefinition.properties.first.name, "username");
      expect(postDefinition.properties.first.type, "String");
      expect(postDefinition.properties.last.name, "id");
      expect(postDefinition.properties.last.type, "int");
    });
  });
}
