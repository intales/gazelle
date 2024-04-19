import 'package:gazelle/load_project_configuration.dart';
import 'package:test/test.dart';

void main() {
  group("LoadProjectConfiguration tests", () {
    test("Should throw error when pubspec doesn't exist", () async {
      // Act
      final result = await loadProjectConfiguration();

      // Assert
      expect(result.name, "gazelle");
    });
  });
}
