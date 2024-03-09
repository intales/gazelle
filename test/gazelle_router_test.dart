import 'package:gazelle/src/gazelle_router.dart';
import 'package:test/test.dart';

void main() {
  group("GazelleRouter tests", () {
    test("Should insert and search a value inside the trie", () {
      // Arrange
      final trie = Trie<GazelleRouteHandler>();
      final strings = "/user/profile".split("/");
      const expected = "Hello, World!";
      String? result;

      // Act
      trie.insert(strings, () => result = "Hello, World!");

      final value = trie.search(strings);
      if (value == null) fail("Value should not be null");

      value();

      // Expect
      expect(result, expected);
    });

    test("Should insert and search a route handler inside the router", () {
      // Arrange
      final router = GazelleRouter();
      final route = "/user/profile";
      final secondRoute = "/user/profile/change_username";

      const expected = "Hello, World!";
      String? result;

      // Act
      router.insertHandler(route, () => result = "Hello, World!");
      router.insertHandler(secondRoute, () => result = "Goodbye, World!");

      final handler = router.searchHandler(route);
      if (handler == null) fail("Handler should not be null");

      handler();

      // Assert
      expect(result, expected);
    });
  });
}
