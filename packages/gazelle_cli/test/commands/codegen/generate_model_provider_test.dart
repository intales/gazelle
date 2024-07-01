import 'dart:io';

import 'package:gazelle_cli/commands/codegen/analyze_entities.dart';
import 'package:gazelle_cli/commands/codegen/generate_model_provider.dart';
import 'package:test/test.dart';

const _userClass = """
import 'post.dart';

class User {
  final String id;
  final String username;
  final List<Post> posts;
  final Map<String, String> metadata;

  const User({
    required this.id,
    required this.username,
    required this.posts,
    required this.metadata,
  });
}
""";

const _postClass = """
import 'user.dart';

class Post {
  final String id;
  final String content;
  final User user;
  final List<String> tags;

  const Post({
    required this.id,
    required this.content,
    required this.user,
    required this.tags,
  });
}
""";

void main() {
  group('GenerateModelProvider tests', () {
    test('Should generate a model provider', () async {
      // Arrange
      final entitiesDirectoryPath =
          "tmp/generate_model_provider_tests/entities";
      final modelTypesPath = "tmp/generate_model_provider_tests/models";
      final entitiesDirectory = Directory(entitiesDirectoryPath);
      final modelTypesDirectory = Directory(modelTypesPath);
      if (entitiesDirectory.existsSync()) {
        entitiesDirectory.deleteSync(recursive: true);
      }
      if (modelTypesDirectory.existsSync()) {
        modelTypesDirectory.deleteSync(recursive: true);
      }
      entitiesDirectory.createSync(recursive: true);
      File("$entitiesDirectoryPath/user.dart")
        ..createSync(recursive: true)
        ..writeAsStringSync(_userClass);
      File("$entitiesDirectoryPath/post.dart")
        ..createSync(recursive: true)
        ..writeAsStringSync(_postClass);

      // Act
      final classes = await analyzeEntities(entitiesDirectory);
      final generated = generateModelProvider(
        sourceFiles: classes,
        entitiesBasePath: entitiesDirectoryPath,
        destinationPath: modelTypesPath,
      );

      for (final modelType in generated) {
        print(modelType.readAsStringSync());
      }

      // Tear down
      entitiesDirectory.deleteSync(recursive: true);
      modelTypesDirectory.deleteSync(recursive: true);
    });
  });
}
