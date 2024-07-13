import 'package:gazelle_serialization/gazelle_serialization.dart';

class User {
  final String id;
  final String name;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}

class UserModelType extends GazelleModelType<User> {
  @override
  User fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] as String,
      name: json["name"] as String,
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }

  @override
  Map<String, dynamic> toJson(User value) {
    return {
      "id": value.id,
      "name": value.name,
      "createdAt": value.createdAt.toIso8601String(),
    };
  }
}

class ExampleModelProvider extends GazelleModelProvider {
  @override
  Map<Type, GazelleModelType> get modelTypes => {
        User: UserModelType(),
      };
}

void main(List<String> args) {
  final modelProvider = ExampleModelProvider();
  final user = User(
    id: "id",
    name: "John Doe",
    createdAt: DateTime.now(),
  );

  final serializedUser = modelProvider.getModelTypeFor(User).toJson(user);

  print(serializedUser);
}
