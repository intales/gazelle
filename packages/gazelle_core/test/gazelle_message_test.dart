import 'package:gazelle_core/gazelle_core.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../test_resources/create_test_http_server.dart';

void main() {
  group('GazelleMessage tests', () {
    group('GazelleRequest tests', () {
      test('Should return a GazelleRequest from an HttpRequest', () async {
        // Arrange
        final server = await createTestHttpServer();
        final uri =
            Uri.parse('http://${server.address.address}:${server.port}/test');

        GazelleRequest? request;
        server.listen(
          (httpRequest) async {
            request = GazelleRequest.fromHttpRequest(httpRequest);
            httpRequest.response.statusCode = 200;
            httpRequest.response.write("OK");
            httpRequest.response.close();
          },
        );

        // Act
        await http.post(uri, body: "test");

        // Assert
        await server.close(force: true);
        expect(request?.uri.path, uri.path);
        expect(request?.headers.isNotEmpty, isTrue);
        expect(request?.method, GazelleHttpMethod.post);
      });
    });

    group('GazelleMessageHeaderExtension tests', () {
      final headerGetters =
          <String, GazelleHttpHeader? Function(List<GazelleHttpHeader>)>{
        'accept': (headers) => headers.accept,
        'acceptcharset': (headers) => headers.acceptCharset,
        'acceptencoding': (headers) => headers.acceptEncoding,
        'acceptlanguage': (headers) => headers.acceptLanguage,
        'acceptranges': (headers) => headers.acceptRanges,
        'accesscontrolallowcredentials': (headers) =>
            headers.accessControlAllowCredentials,
        'accesscontrolallowheaders': (headers) =>
            headers.accessControlAllowHeaders,
        'accesscontrolallowmethods': (headers) =>
            headers.accessControlAllowMethods,
        'accesscontrolalloworigin': (headers) =>
            headers.accessControlAllowOrigin,
        'accesscontrolexposeheaders': (headers) =>
            headers.accessControlExposeHeaders,
        'accesscontrolmaxage': (headers) => headers.accessControlMaxAge,
        'accesscontrolrequestheaders': (headers) =>
            headers.accessControlRequestHeaders,
        'accesscontrolrequestmethod': (headers) =>
            headers.accessControlRequestMethod,
        'age': (headers) => headers.age,
        'allow': (headers) => headers.allow,
        'authorization': (headers) => headers.authorization,
        'cachecontrol': (headers) => headers.cacheControl,
        'connection': (headers) => headers.connection,
        'contentdisposition': (headers) => headers.contentDisposition,
        'contentencoding': (headers) => headers.contentEncoding,
        'contentlanguage': (headers) => headers.contentLanguage,
        'contentlength': (headers) => headers.contentLength,
        'contentlocation': (headers) => headers.contentLocation,
        'contentrange': (headers) => headers.contentRange,
        'contenttype': (headers) => headers.contentType,
        'cookie': (headers) => headers.cookie,
        'date': (headers) => headers.date,
        'etag': (headers) => headers.etag,
        'expect': (headers) => headers.expect,
        'expires': (headers) => headers.expires,
        'forwarded': (headers) => headers.forwarded,
        'from': (headers) => headers.from,
        'host': (headers) => headers.host,
        'ifmatch': (headers) => headers.ifMatch,
        'ifmodifiedsince': (headers) => headers.ifModifiedSince,
        'ifnonematch': (headers) => headers.ifNoneMatch,
        'ifrange': (headers) => headers.ifRange,
        'ifunmodifiedsince': (headers) => headers.ifUnmodifiedSince,
        'lastmodified': (headers) => headers.lastModified,
        'link': (headers) => headers.link,
        'location': (headers) => headers.location,
        'maxforwards': (headers) => headers.maxForwards,
        'origin': (headers) => headers.origin,
        'pragma': (headers) => headers.pragma,
        'proxyauthenticate': (headers) => headers.proxyAuthenticate,
        'proxyauthorization': (headers) => headers.proxyAuthorization,
        'range': (headers) => headers.range,
        'referer': (headers) => headers.referer,
        'retryafter': (headers) => headers.retryAfter,
        'secwebsocketaccept': (headers) => headers.secWebSocketAccept,
        'secwebsocketextensions': (headers) => headers.secWebSocketExtensions,
        'secwebsocketkey': (headers) => headers.secWebSocketKey,
        'secwebsocketprotocol': (headers) => headers.secWebSocketProtocol,
        'secwebsocketversion': (headers) => headers.secWebSocketVersion,
        'server': (headers) => headers.server,
        'setcookie': (headers) => headers.setCookie,
        'stricttransportsecurity': (headers) => headers.strictTransportSecurity,
        'te': (headers) => headers.te,
        'trailer': (headers) => headers.trailer,
        'transferencoding': (headers) => headers.transferEncoding,
        'upgrade': (headers) => headers.upgrade,
        'useragent': (headers) => headers.userAgent,
        'vary': (headers) => headers.vary,
        'via': (headers) => headers.via,
        'wwwauthenticate': (headers) => headers.wwwAuthenticate,
      };

      test('All header getters should work correctly ', () {
        final headers = GazelleHttpHeader.predefinedValues
            .map((header) => GazelleHttpHeader.fromString(header.header,
                values: ['test-value']))
            .toList();

        for (final predefinedHeader in GazelleHttpHeader.predefinedValues) {
          final headerName =
              predefinedHeader.header.toLowerCase().replaceAll('-', '');
          final getter = headerGetters[headerName];

          expect(
            getter,
            isNotNull,
            reason: 'Getter for $headerName should exist',
          );

          final result = getter!(headers);
          expect(
            result,
            isNotNull,
            reason: 'Getter for $headerName should not return null',
          );
          expect(
            result!.header.replaceAll("-", "").toLowerCase(),
            headerName.toLowerCase(),
            reason: 'Header name mismatch for $headerName',
          );
          expect(
            result.values,
            ['test-value'],
            reason: 'Header value mismatch for $headerName',
          );
        }

        for (final predefinedHeader in GazelleHttpHeader.predefinedValues) {
          final headerName =
              predefinedHeader.header.toLowerCase().replaceAll('-', '');
          final getter = headerGetters[headerName];

          final result = getter!(<GazelleHttpHeader>[]);
          expect(
            result,
            isNull,
            reason: 'Getter for $headerName should return null for empty list',
          );
        }
      });
    });
  });
}
