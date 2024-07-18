import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:gazelle_cli/commands/codegen/analyze_entities.dart';
import 'package:gazelle_cli/commands/codegen/generate_model_provider.dart';
import 'package:test/test.dart';

const _userClass = """
import '../post.dart';

class User {
  final String id;
  final String username;
  final List<Post>? posts;
  final Map<String, String> metadata;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.username,
    required this.posts,
    required this.metadata,
    this.createdAt,
  });
}
""";

const _postClass = """
import 'user/user.dart';

class Post {
  final String id;
  final String content;
  final User? user;
  final List<String> tags;

  const Post({
    required this.id,
    required this.content,
    this.user,
    required this.tags,
  });
}
""";

const _expectedUserModelType = """
import 'package:gazelle_serialization/gazelle_serialization.dart';

import '../../entities/user/user.dart';
import '../post_model_type.dart';

class UserModelType extends GazelleModelType<User> {
  @override
  User fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] as String,
      username: json["username"] as String,
      posts: json["posts"] != null ? (json["posts"] as List)
          .map((item) => PostModelType().fromJson(item))
          .toList() : null,
      metadata: (json["metadata"] as Map).map((k, v) => MapEntry(k as String, v as String)),
      createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
    );
  }

  @override
  Map<String, dynamic> toJson(User value) {
    return {
      "id": value.id,
      "username": value.username,
      "posts": value.posts?.map((item) => PostModelType().toJson(item)).toList(),
      "metadata": value.metadata.map((k, v) => MapEntry(k, v)),
      "createdAt": value.createdAt?.toIso8601String(),
    };
  }
}
""";
const _expectedPostModelType = """
import 'package:gazelle_serialization/gazelle_serialization.dart';

import '../entities/post.dart';
import 'user/user_model_type.dart';

class PostModelType extends GazelleModelType<Post> {
  @override
  Post fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"] as String,
      content: json["content"] as String,
      user: json["user"] != null ? UserModelType().fromJson(json["user"]) : null,
      tags: (json["tags"] as List).map((item) => item as String).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson(Post value) {
    return {
      "id": value.id,
      "content": value.content,
      "user": value.user != null ? UserModelType().toJson(value.user!) : null,
      "tags": value.tags.map((item) => item).toList(),
    };
  }
}
""";

const _expectedModelProvider = """
import 'package:gazelle_serialization/gazelle_serialization.dart';

import '../entities/post.dart';
import '../entities/user/user.dart';
import 'post_model_type.dart';
import 'user/user_model_type.dart';

class TestModelProvider extends GazelleModelProvider {
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
      File("$entitiesDirectoryPath/user/user.dart")
        ..createSync(recursive: true)
        ..writeAsStringSync(_userClass);
      File("$entitiesDirectoryPath/post.dart")
        ..createSync(recursive: true)
        ..writeAsStringSync(_postClass);

      // Act
      final classes = await analyzeEntities(entitiesDirectory);
      final result = await generateModelProvider(
        projectName: "Test",
        sourceFiles: classes,
        entitiesBasePath: entitiesDirectoryPath.split("/").last,
        destinationPath: modelTypesPath,
      );

      // Assert
      final modelProvider = await result.modelProvider.readAsString();
      expect(modelProvider,
          equals(DartFormatter().format(_expectedModelProvider)));

      final modelTypes =
          await Future.wait(result.modelTypes.map((e) => e.readAsString()));
      for (final modelType in modelTypes) {
        if (modelType.contains("class PostModelType")) {
          expect(
            modelType,
            equals(DartFormatter().format(_expectedPostModelType)),
          );
        }
        if (modelType.contains("class UserModelType")) {
          expect(
            modelType,
            equals(DartFormatter().format(_expectedUserModelType)),
          );
        }
      }

      // Tear down
      entitiesDirectory.deleteSync(recursive: true);
      modelTypesDirectory.deleteSync(recursive: true);
    });
  });
}
