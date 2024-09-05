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
  final GazelleHandler? get;

  /// The handler for the POST method.
  final GazelleHandler? post;

  /// The handler for the PUT method.
  final GazelleHandler? put;

  /// The handler for the PATCH method.
  final GazelleHandler? patch;

  /// The handler for the DELETE method.
  final GazelleHandler? delete;

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
        GazelleHttpMethod.get => get,
        GazelleHttpMethod.post => post,
        GazelleHttpMethod.patch => patch,
        GazelleHttpMethod.put => put,
        GazelleHttpMethod.delete => delete,
        _ => null,
      };

  /// Creates a copy of this GazelleRoute with the specified attributes overridden.
  GazelleRouterItem copyWith({
    String? name,
    GazelleHandler? get,
    GazelleHandler? post,
    GazelleHandler? put,
    GazelleHandler? patch,
    GazelleHandler? delete,
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
