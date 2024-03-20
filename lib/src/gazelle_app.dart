import 'dart:io';

import 'gazelle_context.dart';
import 'gazelle_http_method.dart';
import 'gazelle_message.dart';
import 'gazelle_plugin.dart';
import 'gazelle_router.dart';

class GazelleSSLCertificate {
  final String certificatePath;
  final String privateKeyPath;
  final String? privateKeyPassword;

  GazelleSSLCertificate({
    required this.certificatePath,
    required this.privateKeyPath,
    this.privateKeyPassword,
  });
}

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
      _context.router.insert(method, route, handler);

  void get(String route, GazelleRouteHandler handler) =>
      _context.router.get(route, handler);

  void post(String route, GazelleRouteHandler handler) =>
      _context.router.post(route, handler);

  void put(String route, GazelleRouteHandler handler) =>
      _context.router.put(route, handler);

  void patch(String route, GazelleRouteHandler handler) =>
      _context.router.patch(route, handler);

  void delete(String route, GazelleRouteHandler handler) =>
      _context.router.delete(route, handler);

  Future<void> start() async {
    _server = await _createServer();

    _server.listen((httpRequest) async {
      try {
        await _handleHttpRequest(httpRequest);
      } catch (_) {
        return _send500Error(httpRequest);
      }
    });
  }

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
    final searchResult = await _context.router.search(httpRequest);
    if (searchResult == null) return _send404Error(httpRequest);

    GazelleRequest request = searchResult.request;
    final preRequestHooks = searchResult.route.preRequestHooks;
    final postRequestHooks = searchResult.route.postRequestHooks;
    final handler = searchResult.route.handler;

    for (final hook in preRequestHooks) {
      final message = await hook(request);
      if (message is GazelleResponse) {
        return _sendResponse(httpRequest, message);
      }
      request = message as GazelleRequest;
    }

    GazelleResponse result = await handler(request);

    for (final hook in postRequestHooks) {
      result = await hook(result);
      if (result.statusCode >= 400 && result.statusCode <= 599) {
        return _sendResponse(httpRequest, result);
      }
    }

    return _sendResponse(httpRequest, result);
  }

  void _sendResponse(HttpRequest request, GazelleResponse response) {
    request.response.statusCode = response.statusCode;
    request.response.write(response.body);
    request.response.close();
  }

  void _send404Error(HttpRequest request) => _sendResponse(
      request,
      GazelleResponse(
        statusCode: 404,
        body: _get404ErrorMessage(request.uri.path),
      ));

  void _send500Error(HttpRequest request) => _sendResponse(
        request,
        GazelleResponse(
          statusCode: 500,
          body: _get500ErrorMessage(),
        ),
      );

  String _get404ErrorMessage(String path) => "Resource [$path] not found.";
  String _get500ErrorMessage() => "Internal server error.";
}
