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
      final route = GazelleRoute(
        name: "test",
        getHandler: (request, response) async =>
            response.copyWith(statusCode: 200),
      );
      router.addRoute(route);

      await http.get(
          Uri.parse('http://${server.address.address}:${server.port}/test'));

      // Assert
      expect(result, isNotNull);
      server.close(force: true);
    });
  });
}
