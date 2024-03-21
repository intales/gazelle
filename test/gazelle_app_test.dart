import 'dart:io';

import 'package:gazelle/src/gazelle_app.dart';
import 'package:gazelle/src/gazelle_context.dart';
import 'package:gazelle/src/gazelle_http_method.dart';
import 'package:gazelle/src/gazelle_message.dart';
import 'package:gazelle/src/gazelle_plugin.dart';
import 'package:gazelle/src/gazelle_ssl_certificate.dart';
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
      await app.start();
      app.insertRoute(
        GazelleHttpMethod.get,
        "/test",
        (request) async => throw Exception("error"),
      );
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

      app.get(
        "/test",
        (request) async => GazelleResponse(
          statusCode: 200,
          body: "OK",
        ),
      );

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

    test('Should insert a route and get a response', () async {
      // Arrange
      final app = GazelleApp();
      int preRequestHooksCount = 0;
      int postResponseHooksCount = 0;

      // Act
      app.insertRoute(
        GazelleHttpMethod.get,
        "/test",
        (request) async => GazelleResponse(
          statusCode: 200,
          body: "OK",
        ),
        preRequestHooks: [
          (request) async {
            preRequestHooksCount += 1;
            return request;
          },
        ],
        postRequestHooks: [
          (response) async {
            postResponseHooksCount += 1;
            return response;
          },
        ],
      );

      await app.start();
      final result =
          await http.get(Uri.parse("http://${app.address}:${app.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, "OK");
      expect(preRequestHooksCount, 1);
      expect(postResponseHooksCount, 1);
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
            insertRoute = () => app.get(
                  "/test",
                  (request) async => GazelleResponse(
                    statusCode: 200,
                    body: "OK",
                  ),
                );
            sendRequest = () => http.get(uri);
            break;
          case GazelleHttpMethod.put:
            insertRoute = () => app.put(
                  "/test",
                  (request) async => GazelleResponse(
                    statusCode: 200,
                    body: "OK",
                  ),
                );
            sendRequest = () => http.put(uri);
            break;
          case GazelleHttpMethod.post:
            insertRoute = () => app.post(
                  "/test",
                  (request) async => GazelleResponse(
                    statusCode: 200,
                    body: "OK",
                  ),
                );
            sendRequest = () => http.post(uri);
            break;
          case GazelleHttpMethod.patch:
            insertRoute = () => app.patch(
                  "/test",
                  (request) async => GazelleResponse(
                    statusCode: 200,
                    body: "OK",
                  ),
                );
            sendRequest = () => http.patch(uri);
            break;
          case GazelleHttpMethod.delete:
            insertRoute = () => app.delete(
                  "/test",
                  (request) async => GazelleResponse(
                    statusCode: 200,
                    body: "OK",
                  ),
                );
            sendRequest = () => http.delete(uri);
            break;
          default:
            fail("Unexpected method.");
        }

        insertRoute();
        final result = await sendRequest();

        // Assert
        expect(result.statusCode, 200);
        expect(result.body, "OK");
      }

      await app.stop(force: true);
    });
  });
}
