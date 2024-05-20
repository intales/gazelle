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
      final app = GazelleApp();

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
      final app = GazelleApp(sslCertificate: sslCertificate);

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
      final app = GazelleApp();
      final plugin = _TestPlugin();

      // Act
      await app.registerPlugin(plugin);

      // Assert
      expect(plugin.isInitialized, isTrue);
    });

    test('Should return error 404', () async {
      // Arrange
      final app = GazelleApp();

      // Act
      await app.start();
      final result =
          await http.get(Uri.parse("http://${app.address}:${app.port}/test"));

      // Assert
      expect(result.statusCode, 404);
      await app.stop(force: true);
    });

    test('Should return error 500', () async {
      // Arrange
      final app = GazelleApp();

      // Act
      final route = GazelleRoute(
        name: "test",
        getHandler: (request, response) async => throw Exception("error"),
      );

      app.addRoute(route);
      await app.start();

      final result =
          await http.get(Uri.parse("http://${app.address}:${app.port}/test"));

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
      final app = GazelleApp(sslCertificate: sslCertificate);

      final route = GazelleRoute(
        name: "test",
        getHandler: (request, response) async => GazelleResponse(
          statusCode: 200,
          body: "OK",
        ),
      );

      app.addRoute(route);
      await app.start();

      // Act
      final result = await http.Client()
          .get(Uri.parse("https://${app.address}:${app.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, "OK");
      await app.stop(force: true);
      HttpOverrides.global = null;
    });

    test('Should share hooks with child routes', () async {
      // Arrange
      final app = GazelleApp();
      int preRequestHooksCount = 0;
      int postResponseHooksCount = 0;

      // Act
      final route = GazelleRoute(
        name: "test",
        getHandler: (request, response) async => response.copyWith(
          statusCode: 200,
          body: "OK",
        ),
        preRequestHooks: [
          GazellePreRequestHook(
            (request, response) async {
              preRequestHooksCount += 1;
              return (request, response);
            },
            shareWithChildRoutes: true,
          ),
        ],
        postResponseHooks: [
          GazellePostResponseHook(
            (request, response) async {
              postResponseHooksCount += 1;
              return (request, response);
            },
          ),
        ],
        children: [
          GazelleRoute(
            name: "test_2",
            getHandler: (request, response) async => response.copyWith(
              statusCode: 200,
              body: "OK",
            ),
            postResponseHooks: [
              GazellePostResponseHook(
                (request, response) async {
                  postResponseHooksCount += 1;
                  return (request, response);
                },
              ),
            ],
          ),
        ],
      );

      app.addRoute(route);
      await app.start();
      final test =
          await http.get(Uri.parse("http://${app.address}:${app.port}/test"));
      final test2 = await http
          .get(Uri.parse("http://${app.address}:${app.port}/test/test_2"));

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
      final app = GazelleApp();
      await app.start();
      final uri = Uri.parse("http://${app.address}:${app.port}/test");

      for (final method in GazelleHttpMethod.values) {
        void Function()? insertRoute;
        Future<http.Response> Function()? sendRequest;
        switch (method) {
          case GazelleHttpMethod.get:
            insertRoute = () => app.addRoute(
                  GazelleRoute(
                    name: "test",
                    getHandler: (request, response) async => response.copyWith(
                      statusCode: 200,
                      body: "OK",
                    ),
                  ),
                );
            sendRequest = () => http.get(uri);
            break;
          case GazelleHttpMethod.head:
            insertRoute = () => app.addRoute(
                  GazelleRoute(
                    name: "test",
                    getHandler: (request, response) async => response.copyWith(
                      statusCode: 200,
                      body: "OK",
                    ),
                  ),
                );
            sendRequest = () => http.head(uri);
            break;
          case GazelleHttpMethod.put:
            insertRoute = () => app.addRoute(
                  GazelleRoute(
                    name: "test",
                    putHandler: (request, response) async => response.copyWith(
                      statusCode: 200,
                      body: "OK",
                    ),
                  ),
                );
            sendRequest = () => http.put(uri);
            break;
          case GazelleHttpMethod.post:
            insertRoute = () => app.addRoute(
                  GazelleRoute(
                    name: "test",
                    postHandler: (request, response) async => response.copyWith(
                      statusCode: 200,
                      body: "OK",
                    ),
                  ),
                );
            sendRequest = () => http.post(uri);
            break;
          case GazelleHttpMethod.patch:
            insertRoute = () => app.addRoute(
                  GazelleRoute(
                    name: "test",
                    patchHandler: (request, response) async =>
                        response.copyWith(
                      statusCode: 200,
                      body: "OK",
                    ),
                  ),
                );
            sendRequest = () => http.patch(uri);
            break;
          case GazelleHttpMethod.delete:
            insertRoute = () => app.addRoute(
                  GazelleRoute(
                    name: "test",
                    deleteHandler: (request, response) async =>
                        response.copyWith(
                      statusCode: 200,
                      body: "OK",
                    ),
                  ),
                );
            sendRequest = () => http.delete(uri);
            break;
          case GazelleHttpMethod.options:
            insertRoute = () => app.addRoute(
                  GazelleRoute(
                    name: "test",
                    getHandler: (request, response) async => response.copyWith(
                      statusCode: 200,
                      body: "OK",
                    ),
                  ),
                );
            sendRequest = () => http.Client()
                .send(http.Request("OPTIONS", uri))
                .then(http.Response.fromStream);
            break;
          default:
            fail("Unexpected method.");
        }

        insertRoute();
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
      final app = GazelleApp();
      final route = GazelleRoute(
        name: "test",
        getHandler: (request, response) async {
          return response.copyWith(
            statusCode: 200,
            body: "Hello, World!",
          );
        },
      );

      app.addRoute(route);
      await app.start();

      // Act
      final uri = Uri.parse("http://${app.address}:${app.port}/test");
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
      final app = GazelleApp();
      final route = GazelleRoute(
        name: "test",
        getHandler: (request, response) async {
          return response.copyWith(
            statusCode: 200,
            body: "Hello, World!",
          );
        },
      );

      app.addRoute(route);
      await app.start();

      // Act
      final uri = Uri.parse("http://${app.address}:${app.port}/test");
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
