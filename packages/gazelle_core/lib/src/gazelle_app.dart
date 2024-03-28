import 'dart:io';

import 'gazelle_context.dart';
import 'gazelle_hooks.dart';
import 'gazelle_http_method.dart';
import 'gazelle_message.dart';
import 'gazelle_plugin.dart';
import 'gazelle_route.dart';
import 'gazelle_ssl_certificate.dart';

/// A lightweight and flexible HTTP server framework for Dart.
///
/// Gazelle simplifies the development of web applications by providing an intuitive
/// API for setting up APIs, web servers, and microservices with minimal configuration.
///
/// Usage:
/// ```dart
/// import 'package:gazelle/gazelle.dart';
///
/// void main() async {
///   final app = GazelleApp();
///
///   // Define routes
///   app.get('/', (request) async => GazelleResponse(
///         statusCode: 200,
///         body: 'Hello, Gazelle!',
///       ));
///
///   // Start the server
///   await app.start();
///   print('Server is running at http://${app.address}:${app.port}');
/// }
/// ```
class GazelleApp {
  /// The default address for the server.
  static const _localhost = "localhost";

  /// Error message for resource not found.
  static const _error404 = "Resource not found.";

  /// Error message for internal server error.
  static const _error500 = "Internal server error.";

  /// The address on which the server will listen.
  final String address;

  /// The SSL certificate configuration for HTTPS support.
  final GazelleSSLCertificate? sslCertificate;

  /// The context for managing routes and plugins.
  late final GazelleContext _context;

  /// The HTTP server instance.
  late final HttpServer _server;

  /// The port on which the server will listen.
  int get port => _port;
  int _port;

  /// Flag indicating whether the server is currently listening.
  bool get isListening => _isListening;
  bool _isListening = false;

  /// Creates an instance of [GazelleApp].
  ///
  /// The [address] defaults to "localhost" and the [port] defaults to 0.
  /// If [port] is not provided, the system will choose an available port.
  /// Optionally, you can provide an [sslCertificate] for HTTPS support.
  ///
  /// Example:
  /// ```dart
  /// final sslCertificate = GazelleSSLCertificate(
  ///   certificatePath: 'path/to/certificate.crt',
  ///   privateKeyPath: 'path/to/privateKey.key',
  /// );
  ///
  /// final app = GazelleApp(
  ///   sslCertificate: sslCertificate,
  /// );
  /// ```
  GazelleApp({
    this.address = _localhost,
    int? port,
    this.sslCertificate,
  })  : _context = GazelleContext.create(),
        _port = port ?? 0;

  /// Registers a plugin with the application context.
  ///
  /// Plugins extend Gazelle's functionality, allowing integration of
  /// authentication, logging, and other common features into the application.
  Future<void> registerPlugin<T extends GazellePlugin>(T plugin) =>
      _context.register(plugin);

  /// Retrieves a plugin of the specified type from the context.
  ///
  /// Throws an exception if the plugin is not found.
  ///
  /// Example:
  /// ```dart
  /// final app = GazelleApp();
  /// final authPlugin = app.getPlugin<AuthenticationPlugin>();
  /// ```
  T getPlugin<T extends GazellePlugin>() => _context.getPlugin<T>();

  /// Inserts a custom route with the specified HTTP [method], URL [route],
  /// and request handler [handler].
  ///
  /// Optionally, you can provide pre-request and post-response hooks to
  /// customize request handling.
  ///
  /// Example:
  /// ```dart
  /// final app = GazelleApp();
  /// app.insertRoute(
  ///   GazelleHttpMethod.get,
  ///   '/hello',
  ///   (request) async {
  ///     return GazelleResponse(
  ///       statusCode: 200,
  ///       body: 'Hello, Gazelle!',
  ///     );
  ///   },
  /// );
  /// await app.start();
  /// ```
  void insertRoute(
    GazelleHttpMethod method,
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      _context.insertRoute(
        method,
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Registers a GET route with the specified URL [route] and handler [handler].
  ///
  /// Optionally, you can provide pre-request and post-response hooks to
  /// customize request handling.
  ///
  /// Example:
  /// ```dart
  /// app.get('/hello', (request) async {
  ///   return GazelleResponse(
  ///     statusCode: 200,
  ///     body: 'Hello, Gazelle!',
  ///   );
  /// });
  /// await app.start();
  /// ```
  void get(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      _context.get(
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Registers a POST route with the specified URL [route] and handler [handler].
  ///
  /// Optionally, you can provide pre-request and post-response hooks to
  /// customize request handling.
  ///
  /// Example:
  /// ```dart
  /// final app = GazelleApp();
  /// app.post('/hello', (request) async {
  ///   return GazelleResponse(
  ///     statusCode: 200,
  ///     body: 'Hello, Gazelle!',
  ///   );
  /// });
  /// await app.start();
  /// ```
  void post(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      _context.post(
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Registers a PUT route with the specified URL [route] and handler [handler].
  ///
  /// Optionally, you can provide pre-request and post-response hooks to
  /// customize request handling.
  ///
  /// Example:
  /// ```dart
  /// final app = GazelleApp();
  /// app.put('/hello', (request) async {
  ///   return GazelleResponse(
  ///     statusCode: 200,
  ///     body: 'Hello, Gazelle!',
  ///   );
  /// });
  /// await app.start();
  /// ```
  void put(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      _context.put(
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Registers a PATCH route with the specified URL [route] and handler [handler].
  ///
  /// Optionally, you can provide pre-request and post-response hooks to
  /// customize request handling.
  ///
  /// Example:
  /// ```dart
  /// final app = GazelleApp();
  /// app.patch('/hello', (request) async {
  ///   return GazelleResponse(
  ///     statusCode: 200,
  ///     body: 'Hello, Gazelle!',
  ///   );
  /// });
  /// await app.start();
  /// ```
  void patch(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      _context.patch(
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Registers a DELETE route with the specified URL [route] and handler [handler].
  ///
  /// Optionally, you can provide pre-request and post-response hooks to
  /// customize request handling.
  ///
  /// Example:
  /// ```dart
  /// final app = GazelleApp();
  /// app.delete('/hello', (request) async {
  ///   return GazelleResponse(
  ///     statusCode: 200,
  ///     body: 'Hello, Gazelle!',
  ///   );
  /// });
  /// await app.start();
  /// ```
  void delete(
    String route,
    GazelleRouteHandler handler, {
    List<GazellePreRequestHook> preRequestHooks = const [],
    List<GazellePostResponseHook> postRequestHooks = const [],
  }) =>
      _context.delete(
        route,
        handler,
        preRequestHooks: preRequestHooks,
        postRequestHooks: postRequestHooks,
      );

  /// Starts the HTTP server.
  ///
  /// Binds the server to the specified [address] and [port], and listens for
  /// incoming requests. Once the server is started, it will continue listening
  /// until stopped using the [stop] method.
  Future<void> start() async {
    _server = await _createServer();
    _port = _server.port;

    _server.listen((httpRequest) async {
      try {
        await _handleHttpRequest(httpRequest);
      } catch (_) {
        return _send500Error(httpRequest.response);
      }
    });

    _isListening = true;
  }

  /// Stops the HTTP server.
  ///
  /// If [force] is true, the server will be forcefully stopped, closing all
  /// connections immediately.
  Future<void> stop({
    bool force = false,
  }) =>
      _server.close(force: force).then((_) => _isListening = false);

  Future<HttpServer> _createServer() async {
    if (sslCertificate != null) {
      final securityContext = SecurityContext()
        ..useCertificateChain(sslCertificate!.certificatePath)
        ..usePrivateKey(
          sslCertificate!.privateKeyPath,
          password: sslCertificate!.privateKeyPassword,
        );

      return HttpServer.bindSecure(address, port, securityContext);
    }

    return HttpServer.bind(address, port);
  }

  /// Handles incoming HTTP requests by searching for the appropriate route,
  /// executing pre-request hooks, handling the request, and executing
  /// post-response hooks.
  ///
  /// If no route is found, a 404 error response is sent.
  Future<void> _handleHttpRequest(HttpRequest httpRequest) async {
    final httpResponse = httpRequest.response;
    final searchResult = _context.searchRoute(httpRequest);
    if (searchResult == null) return _send404Error(httpResponse);

    GazelleRequest request = searchResult.request;
    final preRequestHooks = searchResult.route.preRequestHooks;
    final postRequestHooks = searchResult.route.postResponseHooks;
    final handler = searchResult.route.handler;

    for (final hook in preRequestHooks) {
      final message = await hook(request);
      if (message is GazelleResponse) {
        return _sendResponse(httpResponse, message);
      }
      request = message as GazelleRequest;
    }

    GazelleResponse result = await handler(request);

    for (final hook in postRequestHooks) {
      result = await hook(result);
      if (result.statusCode >= 400 && result.statusCode <= 599) {
        return _sendResponse(httpResponse, result);
      }
    }

    return _sendResponse(httpResponse, result);
  }

  void _sendResponse(
    HttpResponse httpResponseresponse,
    GazelleResponse response,
  ) =>
      response.toHttpResponse(httpResponseresponse);

  void _send404Error(HttpResponse response) => _sendResponse(
      response,
      GazelleResponse(
        statusCode: 404,
        body: _error404,
      ));

  void _send500Error(HttpResponse response) => _sendResponse(
      response,
      GazelleResponse(
        statusCode: 500,
        body: _error500,
      ));
}
