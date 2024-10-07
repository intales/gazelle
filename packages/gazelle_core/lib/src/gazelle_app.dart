import 'dart:convert';
import 'dart:io';

import 'package:gazelle_serialization/gazelle_serialization.dart';

import 'gazelle_context.dart';
import 'gazelle_http_status_code.dart';
import 'gazelle_message.dart';
import 'gazelle_plugin.dart';
import 'gazelle_response_to_http_response.dart';
import 'gazelle_route.dart';
import 'gazelle_ssl_certificate.dart';

/// The running modes of a Gazelle applications.
enum GazelleAppMode {
  /// This enables a Gazelle app to act as a server.
  server,

  /// This enables a Gazelle app to export its routes to JSON.
  exportRoutes,
}

/// A lightweight and flexible HTTP server framework for Dart.
///
/// Gazelle simplifies the development of web applications by providing an intuitive
/// API for setting up APIs, web servers, and microservices with minimal configuration.
class GazelleApp {
  /// The default address for the server.
  static const _localhost = "0.0.0.0";

  /// Error message for resource not found.
  static const _error404 = "Resource not found.";

  /// Error message for internal server error.
  static const _error500 = "Internal server error.";

  final List<GazellePlugin> _plugins;
  final List<GazelleRoute> _routes;
  final GazelleModelProvider? _modelProvider;

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
    List<GazellePlugin>? plugins,
    this.address = _localhost,
    int? port,
    this.sslCertificate,
    GazelleModelProvider? modelProvider,
  })  : _context = GazelleContext.create(modelProvider: modelProvider),
        _routes = routes,
        _plugins = plugins ?? const [],
        _port = port ?? 0,
        _modelProvider = modelProvider;

  /// The current server address that Gazelle is listening to.
  String get serverAddress {
    final path = "$address:$port";
    return sslCertificate != null ? "https://$path" : "http://$path";
  }

  /// Starts the HTTP server.
  ///
  /// Binds the server to the specified [address] and [port], and listens for
  /// incoming requests. Once the server is started, it will continue listening
  /// until stopped using the [stop] method.
  Future<void> start({List<String>? args}) async {
    await _context.registerPlugins(_plugins.toSet());
    _context.addRoutes(_routes);

    final mode = args?.contains("--export-routes") ?? false
        ? GazelleAppMode.exportRoutes
        : GazelleAppMode.server;

    switch (mode) {
      case GazelleAppMode.server:
        return _startServerMode();
      case GazelleAppMode.exportRoutes:
        return _startExportRoutesMode();
      default:
    }
  }

  Future<void> _startServerMode() async {
    _server = await _createServer();
    _port = _server.port;

    _server.listen((httpRequest) async {
      try {
        await _handleHttpRequest(httpRequest);
      } catch (e, stack) {
        print(e);
        print(stack);
        return _send500Error(httpRequest.response);
      }
    });

    _isListening = true;
  }

  Future<void> _startExportRoutesMode() async {
    final routes = _context.routesStructure;
    print(jsonEncode(routes));
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

    final handler = searchResult.route.getHandler(request.method);
    final preRequestHooks = searchResult.route.preRequestHooks;
    final postResponseHooks = searchResult.route.postResponseHooks;

    if (handler == null) return _send404Error(httpResponse);

    for (final hook in preRequestHooks) {
      final (hookRequest, hookResponse) =
          await hook(context, request, response);
      request = GazelleRequest(
        uri: hookRequest.uri,
        body: hookRequest.body,
        bodyStream: hookRequest.bodyStream,
        method: hookRequest.method,
        headers: [...request.headers, ...hookRequest.headers],
        pathParameters: hookRequest.pathParameters,
      );
      response = GazelleResponse(
        headers: [...response.headers, ...hookResponse.headers],
        body: hookResponse.body,
        statusCode: hookResponse.statusCode,
      );
      if (response.statusCode.code >= 400 && response.statusCode.code <= 599) {
        return _sendResponse(httpResponse, response);
      }
    }

    final handlerResponse = await handler(context, request);
    response = GazelleResponse(
      headers: [...response.headers, ...handlerResponse.headers],
      body: handlerResponse.body,
      statusCode: handlerResponse.statusCode,
    );

    for (final hook in postResponseHooks) {
      final (hookRequest, hookResponse) =
          await hook(context, request, response);
      request = GazelleRequest(
        uri: hookRequest.uri,
        body: hookRequest.body,
        bodyStream: hookRequest.bodyStream,
        method: hookRequest.method,
        headers: [...request.headers, ...hookRequest.headers],
        pathParameters: hookRequest.pathParameters,
      );
      response = GazelleResponse(
        headers: [...response.headers, ...hookResponse.headers],
        body: hookResponse.body,
        statusCode: hookResponse.statusCode,
      );
      if (response.statusCode.code >= 400 && response.statusCode.code <= 599) {
        return _sendResponse(httpResponse, response);
      }
    }

    return _sendResponse(httpResponse, response);
  }

  void _sendResponse(
    HttpResponse httpResponse,
    GazelleResponse response,
  ) =>
      gazelleResponseToHttpResponse(
        gazelleResponse: response,
        httpResponse: httpResponse,
        modelProvider: _modelProvider,
      );

  void _send404Error(HttpResponse response) => _sendResponse(
      response,
      GazelleResponse(
        statusCode: GazelleHttpStatusCode.error.notFound_404,
        body: _error404,
      ));

  void _send500Error(HttpResponse response) => _sendResponse(
      response,
      GazelleResponse(
        statusCode: GazelleHttpStatusCode.error.internalServerError_500,
        body: _error500,
      ));
}
