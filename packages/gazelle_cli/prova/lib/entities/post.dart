import 'user.dart';

class Post {
  final String id;
  final String content;
  final User user;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.content,
    required this.user,
    required this.createdAt,
  });
}
