import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_logger/gazelle_logger.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class TestLogOutput extends LogOutput {
  String outputValue = "";

  @override
  void output(OutputEvent event) => outputValue += event.lines.join("\n");
}

void main() {
  group('GazelleLoggerPlugin tests', () {
    test('Should log incoming request', () async {
      // Arrange
      final app = GazelleApp();
      final logOutput = TestLogOutput();
      await app.registerPlugin(GazelleLoggerPlugin(logOutput: logOutput));
      app.get(
        "/",
        (request, resonse) async {
          return resonse.copyWith(
            statusCode: 200,
            body: "Hello, World!",
          );
        },
        preRequestHooks: [
          app.getPlugin<GazelleLoggerPlugin>().logRequestHook,
        ],
        postRequestHooks: [
          app.getPlugin<GazelleLoggerPlugin>().logResponseHook,
        ],
      );

      await app.start();

      // Act
      await http.get(Uri.parse("http://${app.address}:${app.port}/"));

      // Assert
      expect(logOutput.outputValue.contains("INCOMING REQUEST"), isTrue);
      expect(logOutput.outputValue.contains("OUTGOING RESPONSE"), isTrue);
      await app.stop(force: true);
    });
  });
}
