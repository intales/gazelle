import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_cors/src/gazelle_cors_headers.dart';
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
            getHandler: (context, request, response) async {
              return response.copyWith(
                statusCode: GazelleHttpStatus.success.ok_200,
                body: "Hello, Gazelle!",
              );
            },
            preRequestHooks: (context) => [
              context.getPlugin<GazelleCorsPlugin>().corsHook,
            ],
          ),
        ],
        plugins: {
          GazelleCorsPlugin(corsHeaders: {
            GazelleCorsHeaders.accessControlAllowOrigin.name: ["example.com"],
          })
        },
      );

      await app.start();

      // Act
      final url = Uri.parse("http://${app.address}:${app.port}/");
      final result = await http.get(url, headers: {'origin': 'example.com'});

      // Assert
      expect(result.statusCode, 200);
      for (final corsHeader in GazelleCorsHeaders.values) {
        expect(result.headers.keys.contains(corsHeader.name), isTrue);
      }

      await app.stop();
    });
  });
}
