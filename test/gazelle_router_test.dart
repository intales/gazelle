import 'dart:io';

import 'package:gazelle/src/gazelle_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class HttpRequestMock extends Mock implements HttpRequest {
  final String path;

  @override
  final String method;

  HttpRequestMock({
    required this.path,
    required this.method,
  });

  @override
  Uri get uri => Uri.parse("http://localhost$path");
}

void main() {
  group("GazelleRouter tests", () {
    test("Should insert and search a value inside the trie", () async {
      // Arrange
      final trie = Trie<GazelleRouteHandler>(wildcard: ":");
      final strings = "/user/profile/:id".split("/");
      const expected = "Hello, World!";

      // Act
      trie.insert(
        strings,
        (_) async => GazelleRouteHandlerResult(
          statusCode: 200,
          response: "Hello, World!",
        ),
      );

      final value = trie.search("/user/profile/123".split("/"));
      if (value.value == null) fail("Value should not be null");

      final result = await value.value!(
        GazelleHttpRequest(
          httpRequest: HttpRequestMock(
            method: "GET",
            path: "/user/profile/123",
          ),
        ),
      );

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
      router.insert(
        GazelleHttpMethod.get,
        route,
        (_) async => GazelleRouteHandlerResult(
          statusCode: 200,
          response: "Hello, World!",
        ),
      );
      router.insert(
        GazelleHttpMethod.get,
        secondRoute,
        (_) async => GazelleRouteHandlerResult(
          statusCode: 200,
          response: "Goodbye, World!",
        ),
      );

      final handler = router
          .search(HttpRequestMock(
            method: "GET",
            path: "/user/profile",
          ))
          .handler;
      if (handler == null) fail("Handler should not be null");

      final result = await handler(
        GazelleHttpRequest(
          httpRequest: HttpRequestMock(
            method: "GET",
            path: "/user/profile",
          ),
        ),
      );

      // Assert
      expect(result.response, expected);
    });
  });
}
