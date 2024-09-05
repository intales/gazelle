import 'gazelle_context.dart';
import 'gazelle_handler.dart';
import 'gazelle_hooks.dart';
import 'gazelle_router.dart';
import 'gazelle_router_item.dart';

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
  final GazelleHandler? _get;

  /// The handler for the POST method.
  final GazelleHandler? _post;

  /// The handler for the PUT method.
  final GazelleHandler? _put;

  /// The handler for the PATCH method.
  final GazelleHandler? _patch;

  /// The handler for the DELETE method.
  final GazelleHandler? _delete;

  /// The pre-request hooks associated with the route.
  final GazellePreRequestHooksBuilder? preRequestHooks;

  /// The post-response hooks associated with the route.
  final GazellePostResponseHooksBuilder? postResponseHooks;

  /// The sub-routes of this route.
  final List<GazelleRoute> children;

  /// Constructs a [GazelleRoute] instance.
  const GazelleRoute({
    required this.name,
    this.preRequestHooks,
    this.postResponseHooks,
    this.children = const [],
  })  : _delete = null,
        _patch = null,
        _put = null,
        _post = null,
        _get = null;

  const GazelleRoute._({
    required this.name,
    GazelleHandler? get,
    GazelleHandler? post,
    GazelleHandler? put,
    GazelleHandler? patch,
    GazelleHandler? delete,
    this.preRequestHooks,
    this.postResponseHooks,
    this.children = const [],
  })  : _get = get,
        _post = post,
        _put = put,
        _patch = patch,
        _delete = delete;

  /// Adds a GET [handler] to this route.
  GazelleRoute get<ResponseType>(
    GazelleHandlerFunction<dynamic, ResponseType> handler,
  ) =>
      GazelleRoute._(
        name: name,
        get: GazelleHandler<dynamic, ResponseType>(handler),
        post: _post,
        put: _put,
        patch: _patch,
        delete: _delete,
        preRequestHooks: preRequestHooks,
        postResponseHooks: postResponseHooks,
        children: children,
      );

  /// Adds a POST [handler] to this route.
  GazelleRoute post<RequestType, ResponseType>(
    GazelleHandlerFunction<RequestType, ResponseType> handler,
  ) =>
      GazelleRoute._(
        name: name,
        get: _get,
        post: GazelleHandler<RequestType, ResponseType>(handler),
        put: _put,
        patch: _patch,
        delete: _delete,
        preRequestHooks: preRequestHooks,
        postResponseHooks: postResponseHooks,
        children: children,
      );

  /// Adds a PUT [handler] to this route.
  GazelleRoute put<RequestType, ResponseType>(
    GazelleHandlerFunction<RequestType, ResponseType> handler,
  ) =>
      GazelleRoute._(
        name: name,
        get: _get,
        post: _post,
        put: GazelleHandler<RequestType, ResponseType>(handler),
        patch: _patch,
        delete: _delete,
        preRequestHooks: preRequestHooks,
        postResponseHooks: postResponseHooks,
        children: children,
      );

  /// Adds a PATCH [handler] to this route.
  GazelleRoute patch<RequestType, ResponseType>(
    GazelleHandlerFunction<RequestType, ResponseType> handler,
  ) =>
      GazelleRoute._(
        name: name,
        get: _get,
        post: _post,
        put: _put,
        patch: GazelleHandler<RequestType, ResponseType>(handler),
        delete: _delete,
        preRequestHooks: preRequestHooks,
        postResponseHooks: postResponseHooks,
        children: children,
      );

  /// Adds a DELETE [handler] to this route.
  GazelleRoute delete<RequestType, ResponseType>(
    GazelleHandlerFunction<RequestType, ResponseType> handler,
  ) =>
      GazelleRoute._(
        name: name,
        get: _get,
        post: _post,
        put: _put,
        patch: _patch,
        delete: GazelleHandler<RequestType, ResponseType>(handler),
        preRequestHooks: preRequestHooks,
        postResponseHooks: postResponseHooks,
        children: children,
      );

  /// Constructs a parametric [GazelleRoute] instance.
  const GazelleRoute.parameter({
    required String name,
    this.preRequestHooks,
    this.postResponseHooks,
    this.children = const [],
  })  : _delete = null,
        _patch = null,
        _put = null,
        _post = null,
        _get = null,
        name = "${GazelleRouter.wildcard}$name";

  /// Converts this route to a router item.
  GazelleRouterItem toRouterItem(GazelleContext context) {
    return GazelleRouterItem(
      context: context,
      name: name,
      get: _get,
      post: _post,
      put: _put,
      patch: _patch,
      delete: _delete,
      preRequestHooks:
          preRequestHooks != null ? preRequestHooks!(context) : const [],
      postResponseHooks:
          postResponseHooks != null ? postResponseHooks!(context) : const [],
    );
  }
}
