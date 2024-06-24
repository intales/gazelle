import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:gazelle_cli/commands/codegen/codegen.dart';
import 'package:test/test.dart';

const _user = """
import 'propic.dart';

class User {
  final String name;
  final int age;
  final Propic propic;

  const User({
    required this.name,
    required this.age,
    required this.propic,
  });
}
""";

const _propic = """
class Propic {
  final String url;
  final int size;

  const Propic({
    required this.url,
    required this.size,
  });
}
""";

void main() {
  group('Codegen tests', () {
    test('Should generate model types', () async {
      // Arrange
      const basePath = "tmp/codgen_tests";
      final baseDirectory = Directory(basePath);
      final modelsDirectory = Directory("$basePath/models");
      const entitiesPath = "$basePath/entities";
      await File("$entitiesPath/user.dart")
          .create(recursive: true)
          .then((file) => file.writeAsString(DartFormatter().format(_user)));
      await File("$entitiesPath/propic.dart")
          .create(recursive: true)
          .then((file) => file.writeAsString(DartFormatter().format(_propic)));

      // Act
      await codegen(entitiesPath);

      // Assert
      final fileNames = modelsDirectory
          .listSync()
          .map((e) => e.path.split("/").last)
          .toList();
      expect(fileNames.contains("user_model_type.dart"), true);
      expect(fileNames.contains("propic_model_type.dart"), true);

      // Tear down
      await baseDirectory.delete(recursive: true);
    });
  });
}
