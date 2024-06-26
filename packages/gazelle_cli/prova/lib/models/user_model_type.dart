import 'package:gazelle_core/gazelle_core.dart';
import '../entities/user.dart';

class UserModelType extends GazelleModelType<User> {
  @override
  Map<String, dynamic> toJson(User value) {
    return {
      "id": value.id,
      "name": value.name,
      "surname": value.surname,
      "username": value.username,
      "createdAt": value.createdAt.toIso8601String(),
    };
  }

  @override
  User fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      surname: json["surname"],
      username: json["username"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
