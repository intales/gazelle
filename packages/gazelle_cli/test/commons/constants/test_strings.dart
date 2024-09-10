part of 'resources.dart';

abstract class TestStrings {

  // FileName: analyze_entities_test.dart
  static const String analyzeEntitiesUserClass = """
class User {
  final String id;
  final String username;

  const User({
    required this.id,
    required this.username,
  });
}
""";

  static const String analyzeEntitiesPostClass = """
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

  // FileName: generate_model_provider_test.dart
  static const String generateModelProviderUserClass = """
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

  static const String generateModelProviderPostClass = """
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

  static const String generateModelProviderExpectedUserModelType = """
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

  static const String generateModelProviderExpectedPostModelType = """
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

  static const String generateModelProviderExpectedModelProvider = """
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
}
