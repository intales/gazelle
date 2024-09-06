import 'package:gazelle_core/gazelle_core.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../test_resources/create_test_http_server.dart';

void main() {
  group('GazelleMessage tests', () {
    group('GazelleRequest tests', () {
      test('Should return a GazelleRequest from an HttpRequest', () async {
        // Arrange
        final server = await createTestHttpServer();
        final uri =
            Uri.parse('http://${server.address.address}:${server.port}/test');

        GazelleRequest? request;
        server.listen(
          (httpRequest) async {
            request = GazelleRequest.fromHttpRequest(httpRequest);
            httpRequest.response.statusCode = 200;
            httpRequest.response.write("OK");
            httpRequest.response.close();
          },
        );

        // Act
        await http.post(uri, body: "test");

        // Assert
        await server.close(force: true);
        expect(request?.uri.path, uri.path);
        expect(request?.headers.isNotEmpty, isTrue);
        expect(request?.method, GazelleHttpMethod.post);
        //       expect(await request?.body, "test");
      });
    });
  });
}
