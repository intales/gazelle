import 'gazelle_context.dart';
import 'gazelle_hooks.dart';
import 'gazelle_message.dart';

/// Represents a handler for a Gazelle route.
///
/// It is a function thpat takes a [GazelleRequest] as input and returns a [Future] of [GazelleResponse].
typedef GazelleRouteHandler = Future<GazelleResponse> Function(
  GazelleContext context,
  GazelleRequest request,
  GazelleResponse response,
);

/// Represents a callback to build a list of pre-request hooks.
typedef GazellePreRequestHooksBuilder = List<GazellePreRequestHook> Function(
  GazelleContext context,
);

/// Represents a callback to build a list of post-response hooks.
typedef GazellePostResponseHooksBuilder = List<GazellePostResponseHook>
    Function(
  GazelleContext context,
);

/// Represents a route for your backend.
class GazelleRoute {
  /// The name of the route.
  final String name;

  /// The handler for the GET method.
  final GazelleRouteHandler? getHandler;

  /// The handler for the POST method.
  final GazelleRouteHandler? postHandler;

  /// The handler for the PUT method.
  final GazelleRouteHandler? putHandler;

  /// The handler for the PATCH method.
  final GazelleRouteHandler? patchHandler;

  /// The handler for the DELETE method.
  final GazelleRouteHandler? deleteHandler;

  /// The pre-request hooks associated with the route.
  final GazellePreRequestHooksBuilder? preRequestHooks;

  /// The post-response hooks associated with the route.
  final GazellePostResponseHooksBuilder? postResponseHooks;

  /// The sub-routes of this route.
  final List<GazelleRoute> children;

  /// Constructs a GazelleRoute instance.
  const GazelleRoute({
    required this.name,
    this.getHandler,
    this.postHandler,
    this.putHandler,
    this.patchHandler,
    this.deleteHandler,
    this.preRequestHooks,
    this.postResponseHooks,
    this.children = const [],
  });
}
