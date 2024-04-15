import 'gazelle_hooks.dart';
import 'gazelle_message.dart';

/// Represents a handler for a Gazelle route.
///
/// It is a function thpat takes a [GazelleRequest] as input and returns a [Future] of [GazelleResponse].
typedef GazelleRouteHandler = Future<GazelleResponse> Function(
  GazelleRequest request,
  GazelleResponse response,
);

/// Represents a route in the Gazelle router.
///
/// Contains a [handler] for processing requests, along with optional pre-request and post-response hooks.
class GazelleRoute {
  /// The handler for the route.
  final GazelleRouteHandler handler;

  /// The pre-request hooks associated with the route.
  final List<GazellePreRequestHook> preRequestHooks;

  /// The post-response hooks associated with the route.
  final List<GazellePostResponseHook> postResponseHooks;

  /// Constructs a GazelleRoute instance.
  ///
  /// The [handler] parameter represents the handler for the route.
  /// The optional [preRequestHooks] parameter represents the pre-request hooks
  /// associated with the route, defaulting to an empty list if not provided.
  /// The optional [postResponseHooks] parameter represents the post-response hooks
  /// associated with the route, defaulting to an empty list if not provided.
  const GazelleRoute(
    this.handler, {
    this.preRequestHooks = const [],
    this.postResponseHooks = const [],
  });

  /// Creates a copy of this GazelleRoute with the specified attributes overridden.
  GazelleRoute copyWith({
    GazelleRouteHandler? handler,
    List<GazellePreRequestHook>? preRequestHooks,
    List<GazellePostResponseHook>? postResponseHooks,
  }) =>
      GazelleRoute(
        handler ?? this.handler,
        preRequestHooks: preRequestHooks ?? this.preRequestHooks,
        postResponseHooks: postResponseHooks ?? this.postResponseHooks,
      );
}
