import 'dart:io';

import 'gazelle_context.dart';
import 'gazelle_http_method.dart';
import 'gazelle_message.dart';
import 'gazelle_plugin.dart';
import 'gazelle_router.dart';
import 'gazelle_ssl_certificate.dart';

class GazelleApp {
  final String address;
  final int port;
  final GazelleSSLCertificate? sslCertificate;

  late final GazelleContext _context;
  late final HttpServer _server;

  GazelleApp({
    required this.address,
    required this.port,
    this.sslCertificate,
  }) : _context = GazelleContext.create();

  Future<void> registerPlugin(GazellePlugin plugin) =>
      _context.register(plugin);

  void insertRoute(
    GazelleHttpMethod method,
    String route,
    GazelleRouteHandler handler,
  ) =>
      _context.insertRoute(method, route, handler);

  void get(String route, GazelleRouteHandler handler) =>
      _context.get(route, handler);

  void post(String route, GazelleRouteHandler handler) =>
      _context.post(route, handler);

  void put(String route, GazelleRouteHandler handler) =>
      _context.put(route, handler);

  void patch(String route, GazelleRouteHandler handler) =>
      _context.patch(route, handler);

  void delete(String route, GazelleRouteHandler handler) =>
      _context.delete(route, handler);

  Future<void> start() async {
    _server = await _createServer();

    _server.listen((httpRequest) async {
      try {
        await _handleHttpRequest(httpRequest);
      } catch (_) {
        return _send500Error(httpRequest.response);
      }
    });
  }

  Future<void> stop({
    bool force = false,
  }) =>
      _server.close(force: force);

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

  Future<void> _handleHttpRequest(HttpRequest httpRequest) async {
    final httpResponse = httpRequest.response;
    final searchResult = await _context.router.search(httpRequest);
    if (searchResult == null) return _send404Error(httpResponse);

    GazelleRequest request = searchResult.request;
    final preRequestHooks = searchResult.route.preRequestHooks;
    final postRequestHooks = searchResult.route.postRequestHooks;
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
        ),
      );

  static const String _error404 = "Resource not found.";
  static const String _error500 = "Internal server error.";
}
