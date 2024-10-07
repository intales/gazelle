import 'package:gazelle_core/gazelle_core.dart';
import 'package:test/test.dart';

GazelleResponse handler(
  GazelleContext context,
  GazelleRequest request,
) =>
    GazelleResponse(
      statusCode: GazelleHttpStatusCode.success.ok_200,
      body: "Test",
    );

void main() {
  group('GazelleRoute tests', () {
    test('Should return a route with a get handler', () {
      // Arrange
      final context = GazelleContext.create();
      final route = GazelleRoute(name: "test");

      for (final method in GazelleHttpMethod.values.toList()
        ..remove(GazelleHttpMethod.options)) {
        // Act
        final updatedRoute = switch (method) {
          GazelleHttpMethod.get => route.get(handler),
          GazelleHttpMethod.post => route.post(handler),
          GazelleHttpMethod.put => route.put(handler),
          GazelleHttpMethod.patch => route.patch(handler),
          GazelleHttpMethod.delete => route.delete(handler),
          _ => fail("Unexpected HTTP method."),
        };

        // Assert
        final routerItem = updatedRoute.toRouterItem(context);
        final routerItemHandler = switch (method) {
          GazelleHttpMethod.get => routerItem.get,
          GazelleHttpMethod.post => routerItem.post,
          GazelleHttpMethod.put => routerItem.put,
          GazelleHttpMethod.patch => routerItem.patch,
          GazelleHttpMethod.delete => routerItem.delete,
          _ => fail("Unexpected HTTP method."),
        };

        expect(routerItemHandler, isNotNull);
      }
    });
  });
}
