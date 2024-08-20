import 'gazelle_context.dart';
import 'gazelle_generic_type_parameter.dart';
import 'gazelle_hooks.dart';
import 'gazelle_http_header.dart';
import 'gazelle_http_method.dart';
import 'gazelle_http_status_code.dart';
import 'gazelle_message.dart';
import 'gazelle_route.dart';
import 'gazelle_router.dart';

/// Represents a route inside [GazelleRouter].
class GazelleRouterItem<T> with GazelleGenericTypeParameter<T> {
  /// The route's context.
  final GazelleContext context;

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

  /// The handler for the HEAD method.
  GazelleRouteHandler<T>? get head {
    if (get == null) return null;
    return (context, request, response) async {
      final getResponse = await get!(context, request, response);
      return GazelleResponse<T>(
        statusCode: getResponse.statusCode,
        headers: getResponse.headers,
        metadata: getResponse.metadata,
      );
    };
  }

  /// The handler for the OPTIONS method.
  Future<GazelleResponse<T>> options(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse response,
  ) async {
    final availableMethods = <String>[];

    if (get != null) availableMethods.add(GazelleHttpMethod.get.name);
    if (head != null) availableMethods.add(GazelleHttpMethod.head.name);
    if (post != null) availableMethods.add(GazelleHttpMethod.post.name);
    if (put != null) availableMethods.add(GazelleHttpMethod.put.name);
    if (patch != null) {
      availableMethods.add(GazelleHttpMethod.patch.name);
    }
    if (delete != null) {
      availableMethods.add(GazelleHttpMethod.delete.name);
    }

    availableMethods.add(GazelleHttpMethod.options.name);

    return GazelleResponse<T>(
      statusCode: GazelleHttpStatusCode.success.noContent_204,
      headers: [GazelleHttpHeader.allow.addValues(availableMethods)],
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
    this.get,
    this.post,
    this.put,
    this.patch,
    this.delete,
    this.preRequestHooks = const [],
    this.postResponseHooks = const [],
  });

  /// Retrieves the correct handler.
  GazelleRouteHandler? getHandler(GazelleHttpMethod method) => switch (method) {
        GazelleHttpMethod.get => get,
        GazelleHttpMethod.post => post,
        GazelleHttpMethod.patch => patch,
        GazelleHttpMethod.put => put,
        GazelleHttpMethod.delete => delete,
        GazelleHttpMethod.head => head,
        GazelleHttpMethod.options => options,
      };

  /// Creates a copy of this GazelleRoute with the specified attributes overridden.
  GazelleRouterItem<T> copyWith({
    String? name,
    GazelleRouteHandler<T>? get,
    GazelleRouteHandler<T>? post,
    GazelleRouteHandler<T>? put,
    GazelleRouteHandler<T>? patch,
    GazelleRouteHandler<T>? delete,
    List<GazellePreRequestHook>? preRequestHooks,
    List<GazellePostResponseHook>? postResponseHooks,
    GazelleContext? context,
  }) =>
      GazelleRouterItem<T>(
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
