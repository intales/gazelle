import 'package:gazelle_core/src/gazelle_trie.dart';
import 'package:test/test.dart';

void main() {
  group("GazelleTrie tests", () {
    test("Should insert and search a value inside the trie", () async {
      // Arrange
      final trie = GazelleTrie<int>(wildcard: ":");
      final strings = "/user/profile/:id".split("/");

      // Act
      trie.insert(
        strings,
        1,
      );

      final value = trie.search("/user/profile/123".split("/"));
      if (value.value == null) fail("Value should not be null");

      final result = value.value!;

      // Expect
      expect(result, 1);
      expect(value.node?.parent?.name, "profile");
      expect(value.node?.parent?.parent?.name, "user");
      expect(value.node?.parent?.parent?.parent?.name, "");
    });
  });
}
