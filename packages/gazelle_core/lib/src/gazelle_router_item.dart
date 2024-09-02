import 'gazelle_context.dart';
import 'gazelle_handler.dart';
import 'gazelle_hooks.dart';
import 'gazelle_http_method.dart';
import 'gazelle_router.dart';

/// Represents a route inside [GazelleRouter].
class GazelleRouterItem {
  /// The route's context.
  final GazelleContext context;

  /// The name of the route.
  final String name;

  /// The handler for the GET method.
  final GazelleGetHandler? get;

  /// The handler for the POST method.
  final GazellePostHandler? post;

  /// The handler for the PUT method.
  final GazellePutHandler? put;

  /// The handler for the PATCH method.
  final GazellePatchHandler? patch;

  /// The handler for the DELETE method.
  final GazelleDeleteHandler? delete;

  /// The pre-request hooks associated with the route.
  final List<GazellePreRequestHook> preRequestHooks;

  /// The post-response hooks associated with the route.
  final List<GazellePostResponseHook> postResponseHooks;

  /// Constructs a GazelleRouterItem instance.
  const GazelleRouterItem({
    required this.context,
    required this.name,
    this.get,
    this.post,
    this.put,
    this.patch,
    this.delete,
    this.preRequestHooks = const [],
    this.postResponseHooks = const [],
  });

  /// Retrieves the correct handler.
  GazelleHandler? getHandler(GazelleHttpMethod method) => switch (method) {
        GazelleHttpMethod.get => get as GazelleHandler,
        GazelleHttpMethod.post => post as GazelleHandler,
        GazelleHttpMethod.patch => patch as GazelleHandler,
        GazelleHttpMethod.put => put as GazelleHandler,
        GazelleHttpMethod.delete => delete as GazelleHandler,
        _ => get as GazelleHandler,
      };

  /// Creates a copy of this GazelleRoute with the specified attributes overridden.
  GazelleRouterItem copyWith({
    String? name,
    GazelleGetHandler? get,
    GazellePostHandler? post,
    GazellePutHandler? put,
    GazellePatchHandler? patch,
    GazelleDeleteHandler? delete,
    List<GazellePreRequestHook>? preRequestHooks,
    List<GazellePostResponseHook>? postResponseHooks,
    GazelleContext? context,
  }) =>
      GazelleRouterItem(
        name: name ?? this.name,
        get: get ?? this.get,
        post: post ?? this.post,
        put: put ?? this.put,
        patch: patch ?? this.patch,
        delete: delete ?? this.delete,
        preRequestHooks: preRequestHooks ?? this.preRequestHooks,
        postResponseHooks: postResponseHooks ?? this.postResponseHooks,
        context: context ?? this.context,
      );
}
