import 'package:gazelle/src/gazelle_context.dart';
import 'package:gazelle/src/gazelle_plugin.dart';
import 'package:gazelle/src/gazelle_router.dart';
import 'package:test/test.dart';

class TestPlugin extends GazellePlugin {
  const TestPlugin();

  @override
  Future<void> initialize(GazelleContext context) async {}

  bool get foo => true;
}

class TestPlugin2 extends GazellePlugin {
  const TestPlugin2();

  @override
  Future<void> initialize(GazelleContext context) async {}

  bool get foo => true;
}

void main() {
  group('GazelleContext tests', () {
    test('Should find a plugin registered at root context', () async {
      // Arrange
      final context = GazelleContext.create();

      // Act
      await context.register(TestPlugin());

      // Assert
      expect(context.getPlugin<TestPlugin>().foo, isTrue);
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
      await parentContext.register(TestPlugin());
      await childContext.register(TestPlugin2());

      // Assert
      expect(childContext.getPlugin<TestPlugin2>().foo, isTrue);
      expect(childContext.getPlugin<TestPlugin>().foo, isTrue);

      try {
        parentContext.getPlugin<TestPlugin2>();
        fail('Should not be able to find plugin.');
      } catch (_) {}
    });
  });
}
