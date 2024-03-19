import 'package:gazelle/src/gazelle_message.dart';
import 'package:gazelle/src/gazelle_router.dart';
import 'package:test/test.dart';

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
        (_) async => GazelleResponse(
          statusCode: 200,
          body: "Hello, World!",
        ),
      );

      final value = trie.search("/user/profile/123".split("/"));
      if (value.value == null) fail("Value should not be null");

      final result = await value.value!(
        GazelleRequest(
          headers: {},
          pathParameters: {'id': '123'},
          method: GazelleHttpMethod.get,
          uri: Uri.parse('http://localhost/user/profile/123'),
        ),
      );

      // Expect
      expect(result.body, expected);
    });
  });
}
