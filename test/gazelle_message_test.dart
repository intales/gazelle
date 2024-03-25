import 'package:gazelle/src/gazelle_http_method.dart';
import 'package:gazelle/src/gazelle_message.dart';
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
        expect(await request?.body, "test");
      });

      test('Should copy request with given params', () async {
        // Arrange
        final request = GazelleRequest(
          uri: Uri.parse("/test"),
          method: GazelleHttpMethod.get,
          pathParameters: {},
        );
        final uri = Uri.parse('/test/123');
        const method = GazelleHttpMethod.post;
        const headers = {
          'Content-Type': ['application/json'],
        };
        const pathParameters = {
          'testID': '123',
        };
        const body = 'test';

        // Arrange
        final result = request.copyWith(
          uri: uri,
          method: method,
          headers: headers,
          pathParameters: pathParameters,
          body: Future.value(body),
        );

        // Assert
        expect(result.uri, uri);
        expect(result.method, method);
        expect(result.headers, headers);
        expect(result.pathParameters, pathParameters);
        expect(await result.body, body);
      });
    });

    group('GazelleResponse tests', () {
      test('Should send response to client', () async {
        // Arrange
        final server = await createTestHttpServer();
        server.listen((httpRequest) => GazelleResponse(
              statusCode: 200,
              body: "OK",
            ).toHttpResponse(httpRequest.response));

        // Act
        final result = await http.get(
            Uri.parse('http://${server.address.address}:${server.port}/test'));

        // Assert
        await server.close(force: true);
        expect(result.statusCode, 200);
        expect(result.body, "OK");
      });

      test('Should copy response with given params', () {
        // Arrange
        final response = GazelleResponse(statusCode: 400);
        const statusCode = 200;
        const headers = {
          'Content-Type': ['application/json'],
        };
        const body = "OK";

        // Act
        final result = response.copyWith(
          statusCode: statusCode,
          headers: headers,
          body: body,
        );

        // Assert
        expect(result.statusCode, statusCode);
        expect(result.headers, headers);
        expect(result.body, body);
      });
    });
  });
}
