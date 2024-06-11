import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_cors/src/gazelle_cors_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('GazelleCorsPlugin tests', () {
    test('Should add CORS headers', () async {
      // Arrange
      final app = GazelleApp(
        routes: [
          GazelleRoute(
            name: "",
            get: (context, request, response) async {
              return GazelleResponse(
                statusCode: GazelleHttpStatusCode.success.ok_200,
                body: "Hello, Gazelle!",
              );
            },
            preRequestHooks: (context) => [
              context.getPlugin<GazelleCorsPlugin>().corsHook,
            ],
          ),
        ],
        plugins: [
          GazelleCorsPlugin(corsHeaders: [
            GazelleHttpHeader.accessControlAllowOrigin.addValue("example.com"),
          ])
        ],
      );

      await app.start();

      // Act
      final url = Uri.parse("http://${app.address}:${app.port}/");
      final result = await http.get(url, headers: {'origin': 'example.com'});

      // Assert
      expect(result.statusCode, 200);
      final corsHeaders = [
        GazelleHttpHeader.accessControlAllowOrigin,
        GazelleHttpHeader.accessControlExposeHeaders,
        GazelleHttpHeader.accessControlAllowCredentials,
        GazelleHttpHeader.accessControlAllowHeaders,
        GazelleHttpHeader.accessControlAllowMethods,
        GazelleHttpHeader.accessControlMaxAge,
        GazelleHttpHeader.vary,
      ].map((e) => e.header.toLowerCase());
      final resultHeaders = result.headers.keys.map((e) => e.toLowerCase());
      for (final corsHeader in corsHeaders) {
        expect(resultHeaders.contains(corsHeader), isTrue);
      }

      await app.stop();
    });
  });
}
