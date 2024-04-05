import 'package:gazelle_benchmark/gazelle_benchmark.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  test('Should start and stop benchmark server', () async {
    await startGazelleServer();

    final response = await get(Uri.parse("http://localhost:3000/"));

    expect(response.statusCode, 200);
    expect(response.body, "Hello, World!");

    await stopGazelleServer();
  });
}
