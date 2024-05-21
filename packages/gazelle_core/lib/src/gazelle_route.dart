import 'gazelle_context.dart';
import 'gazelle_hooks.dart';
import 'gazelle_http_method.dart';
import 'gazelle_message.dart';

/// Represents a handler for a Gazelle route.
///
/// It is a function thpat takes a [GazelleRequest] as input and returns a [Future] of [GazelleResponse].
typedef GazelleRouteHandler = Future<GazelleResponse> Function(
  GazelleContext context,
  GazelleRequest request,
  GazelleResponse response,
);

/// Represents a route in the Gazelle router.
///
/// Contains a [getHandler] for processing requests, along with optional pre-request and post-response hooks.
class GazelleRoute {
  /// The route's context.
  final GazelleContext? context;

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

  /// The handler for the HEAD method.
  GazelleRouteHandler? get headHandler {
    if (getHandler == null) return null;
    return (context, request, response) async {
      final getResponse = await getHandler!(context, request, response);
      return getResponse.copyWith(body: "");
    };
  }

  /// The handler for the OPTIONS method.
  Future<GazelleResponse> optionsHandler(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse response,
  ) async {
    final availableMethods = <String>[];

    if (getHandler != null) availableMethods.add(GazelleHttpMethod.get.name);
    if (headHandler != null) availableMethods.add(GazelleHttpMethod.head.name);
    if (postHandler != null) availableMethods.add(GazelleHttpMethod.post.name);
    if (putHandler != null) availableMethods.add(GazelleHttpMethod.put.name);
    if (patchHandler != null) {
      availableMethods.add(GazelleHttpMethod.patch.name);
    }
    if (deleteHandler != null) {
      availableMethods.add(GazelleHttpMethod.delete.name);
    }

    availableMethods.add(GazelleHttpMethod.options.name);

    return response.copyWith(headers: {
      'allow': availableMethods,
    });
  }

  /// The pre-request hooks associated with the route.
  final List<GazellePreRequestHook> preRequestHooks;

  /// The post-response hooks associated with the route.
  final List<GazellePostResponseHook> postResponseHooks;

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
    this.preRequestHooks = const [],
    this.postResponseHooks = const [],
    this.children = const [],
    this.context,
  });

  /// Creates a copy of this GazelleRoute with the specified attributes overridden.
  GazelleRoute copyWith({
    String? name,
    GazelleRouteHandler? getHandler,
    GazelleRouteHandler? postHandler,
    GazelleRouteHandler? putHandler,
    GazelleRouteHandler? patchHandler,
    GazelleRouteHandler? deleteHandler,
    List<GazellePreRequestHook>? preRequestHooks,
    List<GazellePostResponseHook>? postResponseHooks,
    List<GazelleRoute>? children,
    GazelleContext? context,
  }) =>
      GazelleRoute(
        name: name ?? this.name,
        getHandler: getHandler ?? this.getHandler,
        postHandler: postHandler ?? this.postHandler,
        putHandler: putHandler ?? this.putHandler,
        patchHandler: patchHandler ?? this.patchHandler,
        deleteHandler: deleteHandler ?? this.deleteHandler,
        preRequestHooks: preRequestHooks ?? this.preRequestHooks,
        postResponseHooks: postResponseHooks ?? this.postResponseHooks,
        children: children ?? this.children,
        context: context ?? this.context,
      );
}
