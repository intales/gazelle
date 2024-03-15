import 'dart:io';

import 'package:gazelle/src/gazelle_context.dart';
import 'package:gazelle/src/gazelle_router.dart';

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

    _server.listen((request) async {
      final searchResult = _context.router.search(request);

      if (searchResult.handler == null) {
        request.response.statusCode = 404;
        request.response.write(_get404ErrorMessage(request.uri.path));
        request.response.close();

        return;
      }

      final result = await searchResult.handler!(searchResult.request);

      request.response.statusCode = result.statusCode;
      request.response.write(result.response);
      request.response.close();

      return;
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

  String _get404ErrorMessage(String path) => "Resource [$path] not found.";
}
