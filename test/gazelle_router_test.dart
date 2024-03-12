import 'dart:io';

import 'package:gazelle/gazelle.dart';
import 'package:gazelle/src/gazelle_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class GazelleContextMock extends Mock implements GazelleContext {}

class HttpRequestMock extends Mock implements HttpRequest {}

void main() {
  group("GazelleRouter tests", () {
    test("Should insert and search a value inside the trie", () async {
      // Arrange
      final trie = Trie<GazelleRouteHandler>();
      final strings = "/user/profile/:id".split("/");
      const expected = "Hello, World!";

      // Act
      trie.insert(
        strings,
        (_, __) async => GazelleRouteHandlerResult(
          statusCode: 200,
          response: "Hello, World!",
        ),
      );

      final value = trie.search("/user/profile/123".split("/"));
      if (value == null) fail("Value should not be null");

      final result = await value(GazelleContextMock(), HttpRequestMock());

      // Expect
      expect(result.response, expected);
    });

    test("Should insert and search a route handler inside the router",
        () async {
      // Arrange
      final router = GazelleRouter();
      final route = "/user/profile";
      final secondRoute = "/user/profile/change_username";

      const expected = "Hello, World!";

      // Act
      router.insertHandler(
        GazelleHttpMethod.get,
        route,
        (_, __) async => GazelleRouteHandlerResult(
          statusCode: 200,
          response: "Hello, World!",
        ),
      );
      router.insertHandler(
        GazelleHttpMethod.get,
        secondRoute,
        (_, __) async => GazelleRouteHandlerResult(
          statusCode: 200,
          response: "Goodbye, World!",
        ),
      );

      final handler =
          router.searchHandler("${GazelleHttpMethod.get.name}/$route");
      if (handler == null) fail("Handler should not be null");

      final result = await handler(GazelleContextMock(), HttpRequestMock());

      // Assert
      expect(result.response, expected);
    });
  });
}
