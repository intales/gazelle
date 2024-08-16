import 'package:gazelle_core/gazelle_core.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../test_resources/create_test_http_server.dart';

void main() {
  group('GazelleRouter tests', () {
    test('Should insert and find a route', () async {
      // Arrange
      final server = await createTestHttpServer();
      final router = GazelleRouter();

      GazelleRouterSearchResult? result;
      server.listen((httpRequest) async {
        result = router.search(httpRequest);
        httpRequest.response.statusCode = 200;
        httpRequest.response.write('OK');
        httpRequest.response.close();
      });

      // Act
      router.addRoutes([
        GazelleRoute(
            name: "test",
            get: (context, request, response) async => GazelleResponse(
                  statusCode: GazelleHttpStatusCode.success.ok_200,
                )),
      ], GazelleContext.create());

      await http.get(
          Uri.parse('http://${server.address.address}:${server.port}/test'));

      // Assert
      expect(result, isNotNull);
      server.close(force: true);
    });

    test(
        'Should throw a RouterWhitespaceExcpetion when a route contains whitespace',
        () {
      // Arrange
      final context = GazelleContext.create();
      final router = GazelleRouter();
      final route = GazelleRoute(name: "test test");

      try {
        // Act
        router.addRoutes([route], context);
        fail("Should have thrown a RouterWhitespaceExcpetion.");
      } catch (e) {
        expect(e, isA<RouterWhitespaceExcpetion>());
      }
    });

    test('Should export the router structure to a map', () {
      // Arrange
      final context = GazelleContext.create();
      final router = GazelleRouter();
      const expected = {
        "name": "",
        "methods": {},
        "children": {
          "users": {
            "name": "users",
            "methods": {},
            "children": {
              "userId": {
                "name": "userId",
                "methods": {},
                "children": {
                  "posts": {
                    "name": "posts",
                    "methods": {},
                    "children": {},
                  },
                }
              }
            }
          },
          "posts": {
            "name": "posts",
            "methods": {},
            "children": {},
          },
        }
      };
      final routes = [
        GazelleRoute(
          name: "users",
          children: [
            GazelleRoute.parameter(
              name: "userId",
              children: [
                GazelleRoute(
                  name: "posts",
                ),
              ],
            ),
          ],
        ),
        GazelleRoute(
          name: "posts",
        ),
      ];
      router.addRoutes(routes, context);

      // Act
      final result = router.routesStructure;

      // Assert
      expect(result, expected);
    });
  });
}
