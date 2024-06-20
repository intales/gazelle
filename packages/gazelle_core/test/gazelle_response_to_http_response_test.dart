import 'dart:convert';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:gazelle_core/src/gazelle_response_to_http_response.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../test_resources/create_test_http_server.dart';

class TestEntity {
  final String testProp1;
  final String testProp2;

  const TestEntity({
    required this.testProp1,
    required this.testProp2,
  });
}

class TestEntityModelType extends GazelleModelType<TestEntity> {
  const TestEntityModelType();

  @override
  Map<String, dynamic> toJson(TestEntity value) => {
        "testProp1": value.testProp1,
        "testProp2": value.testProp2,
      };

  @override
  TestEntity fromJson(Map<String, dynamic> json) => TestEntity(
        testProp1: json["testProp1"],
        testProp2: json["testProp2"],
      );
}

class TestModelProvider extends GazelleModelProvider {
  const TestModelProvider();

  @override
  Map<Type, GazelleModelType> get modelTypes => {
        TestEntity: const TestEntityModelType(),
      };
}

void main() {
  group('GazelleResponseToHttpResonse tests', () {
    test('Should serialize custom data inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      const testEntity = TestEntity(
        testProp1: "testValue1",
        testProp2: "testValue2",
      );
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: testEntity,
      );
      final expected = const TestEntityModelType().toJson(testEntity);
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.headers["content-type"], contains("application/json"));
      expect(result.body, jsonEncode(expected));
      await server.close(force: true);
    });

    test('Should serialize a list of custom data inside an HttpResponse',
        () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      const testEntity1 = TestEntity(
        testProp1: "1testValue1",
        testProp2: "1testValue2",
      );
      const testEntity2 = TestEntity(
        testProp1: "2testValue1",
        testProp2: "2testValue2",
      );
      const testEntityModelType = TestEntityModelType();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: [testEntity1, testEntity2],
      );
      final expected = [
        testEntityModelType.toJson(testEntity1),
        testEntityModelType.toJson(testEntity2),
      ];
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, jsonEncode(expected));
      await server.close(force: true);
    });

    test('Should serialize a num inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: 10,
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.headers["content-type"], contains("text/plain"));
      expect(result.body, jsonEncode(10));
      await server.close(force: true);
    });

    test('Should serialize a list of num inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: [1, 2, 3],
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, jsonEncode([1, 2, 3]));
      await server.close(force: true);
    });

    test('Should serialize a String inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: "Hello, World!",
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, jsonEncode("Hello, World!"));
      await server.close(force: true);
    });

    test('Should serialize a list of String inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: ["Hello", "World!"],
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, jsonEncode(["Hello", "World!"]));
      await server.close(force: true);
    });

    test('Should serialize a bool inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: true,
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, jsonEncode(true));
      await server.close(force: true);
    });

    test('Should serialize a list of bool inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: [true, false],
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, jsonEncode([true, false]));
      await server.close(force: true);
    });

    test('Should serialize a Duration inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: const Duration(seconds: 2),
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(
          result.body, jsonEncode(const Duration(seconds: 2).inMicroseconds));
      await server.close(force: true);
    });

    test('Should serialize a BigInt inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: BigInt.from(10),
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, jsonEncode(BigInt.from(10).toString()));
      await server.close(force: true);
    });

    test('Should serialize a Uri inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: Uri.dataFromString("https://www.google.com/"),
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body,
          jsonEncode(Uri.dataFromString("https://www.google.com/").toString()));
      await server.close(force: true);
    });

    test('Should serialize a DateTime inside an HttpResponse', () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: DateTime(2024),
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, jsonEncode(DateTime(2024).toIso8601String()));
      await server.close(force: true);
    });

    test('Should serialize a list of DateTime inside an HttpResponse',
        () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: [
          DateTime(2024),
          DateTime(2025),
        ],
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(
          result.body,
          jsonEncode([
            DateTime(2024).toIso8601String(),
            DateTime(2025).toIso8601String(),
          ]));
      await server.close(force: true);
    });

    test('Should serialize a Map<String, TestEntity> inside an HttpResponse',
        () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      const modelType = TestEntityModelType();
      final body = {
        "testEntity1": modelType.toJson(TestEntity(
          testProp1: "testValue1",
          testProp2: "testValue2",
        )),
        "testEntity2": modelType.toJson(TestEntity(
          testProp1: "testValue1",
          testProp2: "testValue2",
        )),
      };
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: body,
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, jsonEncode(body));
      await server.close(force: true);
    });

    test('Should serialize a Map<TestEntity, int> inside an HttpResponse',
        () async {
      // Arrange
      const testModelProvider = TestModelProvider();
      const modelType = TestEntityModelType();
      final body = {
        modelType
            .toJson(TestEntity(
              testProp1: "testValue1",
              testProp2: "testValue2",
            ))
            .toString(): 1,
        modelType
            .toJson(TestEntity(
              testProp1: "testValue1",
              testProp2: "testValue2",
            ))
            .toString(): 2,
      };
      final response = GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: body,
      );
      final server = await createTestHttpServer();
      server.listen((httpRequest) => gazelleResponseToHttpResponse(
            gazelleResponse: response,
            httpResponse: httpRequest.response,
            modelProvider: testModelProvider,
          ));

      // Act
      final result = await http.get(
          Uri.parse("http://${server.address.address}:${server.port}/test"));

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, jsonEncode(body));
      await server.close(force: true);
    });
  });
}
