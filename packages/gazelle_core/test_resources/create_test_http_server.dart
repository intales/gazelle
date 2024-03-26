import 'dart:io';

Future<HttpServer> createTestHttpServer() =>
    HttpServer.bind(InternetAddress.loopbackIPv4, 0);
