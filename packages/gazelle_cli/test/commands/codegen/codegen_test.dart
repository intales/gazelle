import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:gazelle_cli/commands/codegen/codegen.dart';
import 'package:test/test.dart';

const _user = """
class User {
  final String name;
  final int age;
  final Propic propic;

  const User({
    required this.name,
    required this.age,
    requried this.propic,
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
      const entitiesPath = "$basePath/entities";
      final userFile = await File("$entitiesPath/user.dart")
          .create(recursive: true)
          .then((file) => file.writeAsString(DartFormatter().format(_user)));
      final propicFile = await File("$entitiesPath/propic.dart")
          .create(recursive: true)
          .then((file) => file.writeAsString(DartFormatter().format(_propic)));
      // Act

      final result = await codegen(entitiesPath);

      // Assert

      // Tear down
    });
  });
}
