import 'dart:async';

import 'gazelle_context.dart';
import 'gazelle_hooks.dart';
import 'gazelle_message.dart';
import 'gazelle_router.dart';
import 'gazelle_router_item.dart';

/// Represents a handler for a Gazelle route.
///
/// It is a function thpat takes a [GazelleRequest] as input and returns a [Future] of [GazelleResponse].
typedef GazelleRouteHandler<T> = FutureOr<GazelleResponse<T>> Function(
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
class GazelleRoute<T> {
  /// The name of the route.
  final String name;

  /// The handler for the GET method.
  final GazelleRouteHandler<T>? get;

  /// The handler for the POST method.
  final GazelleRouteHandler<T>? post;

  /// The handler for the PUT method.
  final GazelleRouteHandler<T>? put;

  /// The handler for the PATCH method.
  final GazelleRouteHandler<T>? patch;

  /// The handler for the DELETE method.
  final GazelleRouteHandler<T>? delete;

  /// The pre-request hooks associated with the route.
  final GazellePreRequestHooksBuilder? preRequestHooks;

  /// The post-response hooks associated with the route.
  final GazellePostResponseHooksBuilder? postResponseHooks;

  /// The sub-routes of this route.
  final List<GazelleRoute> children;

  /// Constructs a [GazelleRoute] instance.
  const GazelleRoute({
    required this.name,
    this.get,
    this.post,
    this.put,
    this.patch,
    this.delete,
    this.preRequestHooks,
    this.postResponseHooks,
    this.children = const [],
  });

  /// Constructs a parametric [GazelleRoute] instance.
  const GazelleRoute.parameter({
    required String name,
    this.get,
    this.post,
    this.put,
    this.patch,
    this.delete,
    this.preRequestHooks,
    this.postResponseHooks,
    this.children = const [],
  }) : name = "${GazelleRouter.wildcard}$name";

  /// Converts this route to a router item.
  GazelleRouterItem<T> toRouterItem(GazelleContext context) =>
      GazelleRouterItem<T>(
        context: context,
        name: name,
        get: get,
        post: post,
        put: put,
        patch: patch,
        delete: delete,
        preRequestHooks:
            preRequestHooks != null ? preRequestHooks!(context) : const [],
        postResponseHooks:
            postResponseHooks != null ? postResponseHooks!(context) : const [],
      );
}
