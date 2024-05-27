import 'dart:io';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class _TestPlugin implements GazellePlugin {
  bool isInitialized = false;

  @override
  Future<void> initialize(GazelleContext context) async => isInitialized = true;
}

class SSLTestOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  group('GazelleApp tests', () {
    test('Should start and stop a GazelleApp', () async {
      // Arrange
      final app = GazelleApp(routes: []);

      // Act
      await app.start();
      // Assert
      expect(app.isListening, isTrue);

      // Act
      await app.stop(force: true);
      // Assert
      expect(app.isListening, isFalse);
    });

    test('Should start and stop a GazelleApp with ssl configured', () async {
      // Arrange
      final sslCertificate = GazelleSSLCertificate(
        certificatePath: 'test_resources/ssl_cert/cert.crt',
        privateKeyPath: 'test_resources/ssl_cert/cert.key',
      );
      final app = GazelleApp(sslCertificate: sslCertificate, routes: []);

      // Act
      await app.start();
      // Assert
      expect(app.isListening, isTrue);

      // Act
      await app.stop(force: true);
      // Assert
      expect(app.isListening, isFalse);
    });

    test('Should register a plugin', () async {
      // Arrange
      final plugin = _TestPlugin();
      final app = GazelleApp(
        routes: [],
        plugins: [plugin],
      );

      // Act
      await app.start();

      // Assert
      expect(plugin.isInitialized, isTrue);
      app.stop(force: true);
    });

    test('Should return error 404', () async {
      // Arrange
      final app = GazelleApp(routes: []);

      // Act
      await app.start();
      final result = await http.get(Uri.parse("${app.serverAddress}/test"));

      // Assert
      expect(result.statusCode, 404);
      await app.stop(force: true);
    });

    test('Should return error 500', () async {
      // Arrange
      final app = GazelleApp(routes: [
        GazelleRoute(
          name: "test",
          getHandler: (context, request, response) async =>
              throw Exception("error"),
        ),
      ]);

      // Act
      await app.start();

      final result = await http.get(Uri.parse("${app.serverAddress}/test"));

      // Assert
      expect(result.statusCode, 500);
      await app.stop(force: true);
    });

    test('Should handle HTTPS requests', () async {
      // Arrange
      HttpOverrides.global = SSLTestOverrides();
      final sslCertificate = GazelleSSLCertificate(
        certificatePath: 'test_resources/ssl_cert/cert.crt',
        privateKeyPath: 'test_resources/ssl_cert/cert.key',
      );
      final app = GazelleApp(
        sslCertificate: sslCertificate,
        routes: [
          GazelleRoute(
            name: "test",
            getHandler: (context, request, response) async => GazelleResponse(
              statusCode: GazelleHttpStatusCode.success.ok_200,
              body: "OK",
            ),
          )
        ],
      );

      await app.start();

      // Act
      final result =
          await http.Client().get(Uri.parse("${app.serverAddress}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, "OK");
      await app.stop(force: true);
      HttpOverrides.global = null;
    });

    test('Should share hooks with child routes', () async {
      // Arrange
      int preRequestHooksCount = 0;
      int postResponseHooksCount = 0;

      final app = GazelleApp(
        routes: [
          GazelleRoute(
            name: "test",
            getHandler: (context, request, response) async => GazelleResponse(
              statusCode: GazelleHttpStatusCode.success.ok_200,
              body: "OK",
            ),
            preRequestHooks: (context) => [
              GazellePreRequestHook(
                (context, request, response) async {
                  preRequestHooksCount += 1;
                  return (request, response);
                },
                shareWithChildRoutes: true,
              ),
            ],
            postResponseHooks: (context) => [
              GazellePostResponseHook(
                (context, request, response) async {
                  postResponseHooksCount += 1;
                  return (request, response);
                },
              ),
            ],
            children: [
              GazelleRoute(
                name: "test_2",
                getHandler: (context, request, response) async =>
                    GazelleResponse(
                  statusCode: GazelleHttpStatusCode.success.ok_200,
                  body: "OK",
                ),
                postResponseHooks: (context) => [
                  GazellePostResponseHook(
                    (context, request, response) async {
                      postResponseHooksCount += 1;
                      return (request, response);
                    },
                  ),
                ],
              ),
            ],
          )
        ],
      );

      // Act
      await app.start();
      final test = await http.get(Uri.parse("${app.serverAddress}/test"));
      final test2 =
          await http.get(Uri.parse("${app.serverAddress}/test/test_2"));

      // Assert
      expect(test.statusCode, 200);
      expect(test.body, "OK");
      expect(test2.statusCode, 200);
      expect(test2.body, "OK");
      expect(preRequestHooksCount, 2);
      expect(postResponseHooksCount, 2);
      await app.stop(force: true);
    });

    test('Should insert a route and get a response for each method', () async {
      // Arrange
      final routes = [
        GazelleRoute(
          name: "test",
          getHandler: (context, request, response) async => GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            body: "OK",
          ),
          postHandler: (context, request, response) async => GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            body: "OK",
          ),
          putHandler: (context, request, response) async => GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            body: "OK",
          ),
          patchHandler: (context, request, response) async => GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            body: "OK",
          ),
          deleteHandler: (context, request, response) async => GazelleResponse(
            statusCode: GazelleHttpStatusCode.success.ok_200,
            body: "OK",
          ),
        ),
      ];
      final app = GazelleApp(routes: routes);
      await app.start();
      final uri = Uri.parse("${app.serverAddress}/test");

      for (final method in GazelleHttpMethod.values) {
        Future<http.Response> Function()? sendRequest;
        switch (method) {
          case GazelleHttpMethod.get:
            sendRequest = () => http.get(uri);
            break;
          case GazelleHttpMethod.head:
            sendRequest = () => http.head(uri);
            break;
          case GazelleHttpMethod.put:
            sendRequest = () => http.put(uri);
            break;
          case GazelleHttpMethod.post:
            sendRequest = () => http.post(uri);
            break;
          case GazelleHttpMethod.patch:
            sendRequest = () => http.patch(uri);
            break;
          case GazelleHttpMethod.delete:
            sendRequest = () => http.delete(uri);
            break;
          case GazelleHttpMethod.options:
            sendRequest = () => http.Client()
                .send(http.Request("OPTIONS", uri))
                .then(http.Response.fromStream);
            break;
          default:
            fail("Unexpected method.");
        }

        final result = await sendRequest();

        // Assert
        if (method == GazelleHttpMethod.head) {
          expect(result.statusCode, 200);
          expect(result.body, "");
        } else if (method == GazelleHttpMethod.options) {
          expect(result.statusCode, 204);
          expect(result.body, "");
        } else {
          expect(result.statusCode, 200);
          expect(result.body, "OK");
        }
      }

      await app.stop(force: true);
    });

    test('Should send a response without a body when sending a HEAD request',
        () async {
      // Arrange
      final app = GazelleApp(
        routes: [
          GazelleRoute(
            name: "test",
            getHandler: (context, request, response) async {
              return GazelleResponse(
                statusCode: GazelleHttpStatusCode.success.ok_200,
                body: "Hello, World!",
              );
            },
          )
        ],
      );
      await app.start();

      // Act
      final uri = Uri.parse("${app.serverAddress}/test");
      final getResponse = await http.get(uri);
      final headResponse = await http.head(uri);

      // Assert
      expect(getResponse.statusCode, 200);
      expect(getResponse.body, "Hello, World!");

      expect(headResponse.statusCode, 200);
      expect(headResponse.body.length, 0);

      await app.stop(force: true);
    });

    test(
        'Should send a response with allow header when sending an OPTIONS request',
        () async {
      // Arrange
      final app = GazelleApp(
        routes: [
          GazelleRoute(
            name: "test",
            getHandler: (context, request, response) async {
              return GazelleResponse(
                statusCode: GazelleHttpStatusCode.success.ok_200,
                body: "Hello, World!",
              );
            },
          )
        ],
      );
      await app.start();

      // Act
      final uri = Uri.parse("${app.serverAddress}/test");
      final response = await http.Client()
          .send(http.Request("OPTIONS", uri))
          .then(http.Response.fromStream);

      // Assert
      expect(response.statusCode, 204);
      expect(response.headers["allow"]!.contains("GET"), true);
      expect(response.headers["allow"]!.contains("HEAD"), true);
      expect(response.headers["allow"]!.contains("OPTIONS"), true);

      await app.stop(force: true);
    });
  });
}
