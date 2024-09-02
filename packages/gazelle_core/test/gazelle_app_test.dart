import 'dart:async';
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

class _TestStringGetHandler extends GazelleGetHandler<String> {
  final String _string;

  const _TestStringGetHandler(this._string);

  @override
  FutureOr<String> call(
    GazelleContext context,
    Null body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  ) =>
      _string;
}

class _TestStringPostHandler extends GazellePostHandler<String, String> {
  final String _string;

  const _TestStringPostHandler(this._string);

  @override
  FutureOr<String> call(
    GazelleContext context,
    String? body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  ) =>
      _string;
}

class _TestStringPutHandler extends GazellePutHandler<String, String> {
  final String _string;

  const _TestStringPutHandler(this._string);

  @override
  FutureOr<String> call(
    GazelleContext context,
    String? body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  ) =>
      _string;
}

class _TestStringPatchHandler extends GazellePatchHandler<String, String> {
  final String _string;

  const _TestStringPatchHandler(this._string);

  @override
  FutureOr<String> call(
    GazelleContext context,
    String? body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  ) =>
      _string;
}

class _TestStringDeleteHandler extends GazelleDeleteHandler<String, String> {
  final String _string;

  const _TestStringDeleteHandler(this._string);

  @override
  FutureOr<String> call(
    GazelleContext context,
    String? body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  ) =>
      _string;
}

class _TestExceptionHandler extends GazelleGetHandler<String> {
  final String _string;

  const _TestExceptionHandler(this._string);

  @override
  FutureOr<String> call(
    GazelleContext context,
    Null body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  ) =>
      throw Exception(_string);
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

    test('Should start a GazelleApp and export routes structure', () async {
      // Arrange
      final app = GazelleApp(routes: [
        GazelleRoute(name: "users"),
      ]);

      // Act
      await app.start(args: ["--export-routes"]);

      // Assert
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
          get: const _TestExceptionHandler("error"),
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
            get: const _TestStringGetHandler("OK"),
          ),
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
            get: const _TestStringGetHandler("OK"),
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
                get: const _TestStringGetHandler("OK"),
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
          get: _TestStringGetHandler("OK"),
          post: _TestStringPostHandler("OK"),
          put: _TestStringPutHandler("OK"),
          patch: _TestStringPatchHandler("OK"),
          delete: _TestStringDeleteHandler("OK"),
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
          default:
            fail("Unexpected method.");
        }

        final result = await sendRequest();

        // Assert
        expect(result.statusCode, 200);
        expect(result.body, "OK");
      }

      await app.stop(force: true);
    });
  });
}
