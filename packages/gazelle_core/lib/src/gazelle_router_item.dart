import 'gazelle_context.dart';
import 'gazelle_hooks.dart';
import 'gazelle_http_method.dart';
import 'gazelle_http_status_code.dart';
import 'gazelle_message.dart';
import 'gazelle_route.dart';
import 'gazelle_router.dart';

/// Represents a route inside [GazelleRouter].
class GazelleRouterItem {
  /// The route's context.
  final GazelleContext context;

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

    return response.copyWith(
      statusCode: GazelleHttpStatusCode.success.noContent_204,
      headers: {
        'allow': availableMethods,
      },
    );
  }

  /// The pre-request hooks associated with the route.
  final List<GazellePreRequestHook> preRequestHooks;

  /// The post-response hooks associated with the route.
  final List<GazellePostResponseHook> postResponseHooks;

  /// Constructs a GazelleRouterItem instance.
  const GazelleRouterItem({
    required this.context,
    required this.name,
    this.getHandler,
    this.postHandler,
    this.putHandler,
    this.patchHandler,
    this.deleteHandler,
    this.preRequestHooks = const [],
    this.postResponseHooks = const [],
  });

  /// Creates a copy of this GazelleRoute with the specified attributes overridden.
  GazelleRouterItem copyWith({
    String? name,
    GazelleRouteHandler? getHandler,
    GazelleRouteHandler? postHandler,
    GazelleRouteHandler? putHandler,
    GazelleRouteHandler? patchHandler,
    GazelleRouteHandler? deleteHandler,
    List<GazellePreRequestHook>? preRequestHooks,
    List<GazellePostResponseHook>? postResponseHooks,
    GazelleContext? context,
  }) =>
      GazelleRouterItem(
        name: name ?? this.name,
        getHandler: getHandler ?? this.getHandler,
        postHandler: postHandler ?? this.postHandler,
        putHandler: putHandler ?? this.putHandler,
        patchHandler: patchHandler ?? this.patchHandler,
        deleteHandler: deleteHandler ?? this.deleteHandler,
        preRequestHooks: preRequestHooks ?? this.preRequestHooks,
        postResponseHooks: postResponseHooks ?? this.postResponseHooks,
        context: context ?? this.context,
      );
}
