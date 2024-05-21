import 'dart:io';

import 'gazelle_context.dart';
import 'gazelle_http_method.dart';
import 'gazelle_message.dart';
import 'gazelle_plugin.dart';
import 'gazelle_route.dart';
import 'gazelle_ssl_certificate.dart';

/// A lightweight and flexible HTTP server framework for Dart.
///
/// Gazelle simplifies the development of web applications by providing an intuitive
/// API for setting up APIs, web servers, and microservices with minimal configuration.
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
    required List<GazelleRoute> routes,
    this.address = _localhost,
    int? port,
    this.sslCertificate,
  })  : _context = GazelleContext.create()..addRoutes(routes),
        _port = port ?? 0;

  /// The current server address that Gazelle is listening to.
  String get serverAddress {
    final path = "$address:$port";
    return sslCertificate != null ? "https://$path" : "http://$path";
  }

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

    final context = searchResult.route.context;

    GazelleRequest request = searchResult.request;
    GazelleResponse response = searchResult.response;
    final preRequestHooks = searchResult.route.preRequestHooks;
    final postResponseHooks = searchResult.route.postResponseHooks;
    final handler = switch (request.method) {
      GazelleHttpMethod.get => searchResult.route.getHandler,
      GazelleHttpMethod.head => searchResult.route.headHandler,
      GazelleHttpMethod.post => searchResult.route.postHandler,
      GazelleHttpMethod.put => searchResult.route.putHandler,
      GazelleHttpMethod.patch => searchResult.route.patchHandler,
      GazelleHttpMethod.delete => searchResult.route.deleteHandler,
      GazelleHttpMethod.options => searchResult.route.optionsHandler,
    };

    if (handler == null) return _send404Error(httpResponse);

    for (final hook in preRequestHooks) {
      (request, response) = await hook(context, request, response);
      if (response.statusCode >= 400 && response.statusCode <= 599) {
        return _sendResponse(httpResponse, response);
      }
    }

    response = await handler(context, request, response);

    for (final hook in postResponseHooks) {
      (request, response) = await hook(context, request, response);
      if (response.statusCode >= 400 && response.statusCode <= 599) {
        return _sendResponse(httpResponse, response);
      }
    }

    return _sendResponse(httpResponse, response);
  }

  void _sendResponse(
    HttpResponse httpResponse,
    GazelleResponse response,
  ) =>
      response.toHttpResponse(httpResponse);

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
