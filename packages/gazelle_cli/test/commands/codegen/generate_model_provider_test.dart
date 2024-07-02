import 'dart:io';

import 'package:dart_style/dart_style.dart';
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

const _expectedUserModelType = """
import 'package:gazelle_core/gazelle_core.dart';

import 'entities/user.dart';
import 'post_model_type.dart';

class UserModelType extends GazelleModelType<User> {
  @override
  User fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      username: json["username"],
      posts: (json["posts"] as List)
          .map((item) => PostModelType().fromJson(item))
          .toList(),
      metadata: (json["metadata"] as Map).map((k, v) => MapEntry(k, v)),
    );
  }

  @override
  Map<String, dynamic> toJson(User value) {
    return {
      "id": value.id,
      "username": value.username,
      "posts": value.posts.map((item) => PostModelType().toJson(item)).toList(),
      "metadata": value.metadata.map((k, v) => MapEntry(k, v)),
    };
  }
}
""";
const _expectedPostModelType = """
import 'package:gazelle_core/gazelle_core.dart';

import 'entities/post.dart';
import 'user_model_type.dart';

class PostModelType extends GazelleModelType<Post> {
  @override
  Post fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      content: json["content"],
      user: UserModelType().fromJson(json["user"]),
      tags: json["tags"],
    );
  }

  @override
  Map<String, dynamic> toJson(Post value) {
    return {
      "id": value.id,
      "content": value.content,
      "user": UserModelType().toJson(value.user),
      "tags": value.tags,
    };
  }
}
""";

const _expectedModelProvider = """
import 'package:gazelle_core/gazelle_core.dart';

import 'entities/post.dart';
import 'entities/user.dart';
import 'post_model_type.dart';
import 'user_model_type.dart';

class ModelProvider extends GazelleModelProvider {
  @override
  Map<Type, GazelleModelType> get modelTypes {
    return {
      Post: PostModelType(),
      User: UserModelType(),
    };
  }
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
      final result = generateModelProvider(
        sourceFiles: classes,
        entitiesBasePath: entitiesDirectoryPath.split("/").last,
        destinationPath: modelTypesPath,
      );

      // Assert
      for (final modelType in result.modelTypes) {
        if (modelType.path.contains("post")) {
          expect(
            modelType
                .readAsStringSync()
                .contains(DartFormatter().format(_expectedPostModelType)),
            isTrue,
          );
        }
        if (modelType.path.contains("user")) {
          expect(
            modelType
                .readAsStringSync()
                .contains(DartFormatter().format(_expectedUserModelType)),
            isTrue,
          );
        }
      }

      expect(
        result.modelProvider
            .readAsStringSync()
            .contains(DartFormatter().format(_expectedModelProvider)),
        isTrue,
      );

      // Tear down
      entitiesDirectory.deleteSync(recursive: true);
      modelTypesDirectory.deleteSync(recursive: true);
    });
  });
}
