import 'dart:io';

import 'package:gazelle/gazelle.dart';
import 'package:gazelle/src/gazelle_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class GazelleContextMock extends Mock implements GazelleContext {}

class HttpRequestMock extends Mock implements HttpRequest {}

void main() {
  group("GazelleRouter tests", () {
    test("Should insert and search a value inside the trie", () {
      // Arrange
      final trie = Trie<GazelleRouteHandler>();
      final strings = "/user/profile".split("/");
      const expected = "Hello, World!";
      String? result;

      // Act
      trie.insert(strings, (_, __) => result = "Hello, World!");

      final value = trie.search(strings);
      if (value == null) fail("Value should not be null");

      value(GazelleContextMock(), HttpRequestMock());

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
      router.insertHandler(route, (_, __) => result = "Hello, World!");
      router.insertHandler(secondRoute, (_, __) => result = "Goodbye, World!");

      final handler = router.searchHandler(route);
      if (handler == null) fail("Handler should not be null");

      handler(GazelleContextMock(), HttpRequestMock());

      // Assert
      expect(result, expected);
    });
  });
}
