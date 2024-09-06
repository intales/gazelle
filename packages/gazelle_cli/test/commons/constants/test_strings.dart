

part of 'resources.dart';

abstract class TestStrings {
  static const String userClass = """
class User {
  final String id;
  final String username;

  const User({
    required this.id,
    required this.username,
  });
}
""";
}
