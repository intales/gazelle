import 'package:gazelle_core/gazelle_core.dart';
import '../entities/post.dart';
import 'user_model_type.dart';

class PostModelType extends GazelleModelType<Post> {
  @override
  Map<String, dynamic> toJson(Post value) {
    return {
      "id": value.id,
      "content": value.content,
      "user": UserModelType().toJson(value.user),
      "createdAt": value.createdAt.toIso8601String(),
    };
  }

  @override
  Post fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      content: json["content"],
      user: UserModelType().fromJson(json["user"]),
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
