import 'gazelle_hooks.dart';
import 'gazelle_message.dart';

/// Represents a handler for a Gazelle route.
///
/// It is a function that takes a [GazelleRequest] as input and returns a [Future] of [GazelleResponse].
typedef GazelleRouteHandler = Future<GazelleResponse> Function(
  GazelleRequest request,
);

/// Represents a route in the Gazelle router.
///
/// Contains a [handler] for processing requests, along with optional pre-request and post-response hooks.
class GazelleRoute {
  final GazelleRouteHandler handler;
  final List<GazellePreRequestHook> preRequestHooks;
  final List<GazellePostResponseHook> postResponseHooks;

  const GazelleRoute(
    this.handler, {
    this.preRequestHooks = const [],
    this.postResponseHooks = const [],
  });

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
