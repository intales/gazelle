import 'package:gazelle/src/gazelle_http_method.dart';
import 'package:gazelle/src/gazelle_message.dart';
import 'package:gazelle/src/gazelle_router.dart';
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
      router.insert(
        GazelleHttpMethod.get,
        '/test',
        (request) async => GazelleResponse(statusCode: 200),
      );
      await http.get(
          Uri.parse('http://${server.address.address}:${server.port}/test'));

      // Assert
      expect(result, isNotNull);
      server.close(force: true);
    });
  });
}
