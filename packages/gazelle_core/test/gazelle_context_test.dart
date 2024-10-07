import 'dart:io';

import 'package:gazelle_core/gazelle_core.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class _TestPlugin extends GazellePlugin {
  const _TestPlugin();

  @override
  Future<void> initialize(GazelleContext context) async {}

  bool get foo => true;
}

class _TestPlugin2 extends GazellePlugin {
  const _TestPlugin2();

  @override
  Future<void> initialize(GazelleContext context) async {}

  bool get foo => true;
}

class _TestModelProvider extends GazelleModelProvider {
  @override
  Map<Type, GazelleModelType> get modelTypes => {};
}

void main() {
  group('GazelleContext tests', () {
    test('Should find a plugin registered at root context', () async {
      // Arrange
      final context = GazelleContext.create();

      // Act
      await context.register(_TestPlugin());

      // Assert
      expect(context.getPlugin<_TestPlugin>().foo, isTrue);
    });

    test('Should find a plugin registered in a parent context', () async {
      // Arrange
      final router = GazelleRouter();
      final parentContext = GazelleContext(
        router: router,
        plugins: {},
      );
      final childContext = GazelleContext(
        router: router,
        plugins: {},
        context: parentContext,
      );

      // Act
      await parentContext.register(const _TestPlugin());
      await childContext.register(const _TestPlugin2());

      // Assert
      expect(childContext.getPlugin<_TestPlugin2>().foo, isTrue);
      expect(childContext.getPlugin<_TestPlugin>().foo, isTrue);

      try {
        parentContext.getPlugin<_TestPlugin2>();
        fail('Should not be able to find plugin.');
      } catch (_) {}
    });

    test('Should create a new context', () {
      // Arrange
      final modelProvider = _TestModelProvider();

      // Act
      final context = GazelleContext.create(modelProvider: modelProvider);

      // Assert
      expect(context.modelProvider, isNotNull);
    });

    test('Should add and find routes', () async {
      // Arrange
      final routes = [GazelleRoute(name: 'a')];
      final context = GazelleContext.create();
      final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);

      GazelleRouterSearchResult? result;
      server.listen((request) {
        result = context.searchRoute(request);
        request.response.close();
      });

      // Act
      context.addRoutes(routes);
      await http
          .get(Uri.parse("http://${server.address.address}:${server.port}/a"));

      // Assert
      expect(result?.route.name, "a");

      // Teardown
      await server.close(force: true);
    });

    test('Should register a list of plugins', () async {
      // Arrange
      const plugins = {
        _TestPlugin(),
        _TestPlugin2(),
      };
      final context = GazelleContext.create();

      // Act
      await context.registerPlugins(plugins);

      // Assert
      expect(context.getPlugin<_TestPlugin>(), plugins.first);
      expect(context.getPlugin<_TestPlugin2>(), plugins.last);
    });
  });
}
