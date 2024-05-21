import 'gazelle_context.dart';
import 'gazelle_message.dart';

/// Represents the result of a [GazellePreRequestHookCallback] or a [GazellePostResponseHookCallback].
typedef GazelleHookCallbackResult = (
  GazelleRequest request,
  GazelleResponse response,
);

/// A function type representing a pre-request hook, which is executed before handling an incoming request.
///
/// It takes a [GazelleRequest] as input and returns a [GazelleMessage].
/// Pre-request hooks can be used to modify or validate the request before it is processed.
///
/// Example:
/// ```dart
/// Future<GazelleHookCallbackResult> myPreRequestHook(GazelleRequest request, GazelleResponse response) async {
///   // Perform some validation
///   if (!isValidRequest(request)) {
///     return (request, response.copyWith(
///       statusCode: 400,
///       body: 'Bad Request',
///     ));
///   }
///
///   // If validation passes, continue processing the request
///   return (request, response);
/// }
/// ```
typedef GazellePreRequestHookCallback = Future<GazelleHookCallbackResult>
    Function(
  GazelleContext context,
  GazelleRequest request,
  GazelleResponse response,
);

/// Represents a pre-request hook for Gazelle routes.
///
/// A pre-request hook allows developers to execute custom logic before processing an incoming HTTP request.
/// This can be used, for example, for authentication, authorization, request validation, or any other pre-processing task.
///
/// The [hook] parameter is a callback function that takes a [GazelleRequest] as input and returns a [Future] of [GazelleHookCallbackResult].
///
/// The optional parameter [shareWithChildRoutes] determines whether the hook should be shared with child routes.
/// If set to true, the hook will be executed for all child routes of the route to which it is attached.
/// If set to false (default), the hook will only be executed for the specific route to which it is attached.
///
/// Example:
/// ```dart
/// final preRequestHook = GazellePreRequestHook((request, response) async {
///   // Perform custom pre-processing logic here, such as authentication or validation.
/// }, shareWithChildRoutes: true,
/// );
///
/// final postRoute = GazelleRoute(
///   (request, response) async {
///     // Handle the request...
///   },
///   preRequestHooks: [preRequestHook],
/// );
/// ```
class GazellePreRequestHook {
  /// The hook to run before a request.
  final GazellePreRequestHookCallback hook;

  /// Determines whether the hook should be shared with child routes.
  final bool shareWithChildRoutes;

  /// Creates a GazellePreRequestHook instance.
  ///
  /// The [hook] parameter is the function to be executed before a request.
  /// The optional parameter [shareWithChildRoutes] determines whether the hook
  /// should be shared with child routes. By default, it's set to `false`.
  const GazellePreRequestHook(
    this.hook, {
    this.shareWithChildRoutes = false,
  });

  /// Invokes the pre-request hook with the provided [request].
  ///
  /// Returns a future that completes with a [GazelleMessage] representing
  /// the result of the hook execution.
  Future<GazelleHookCallbackResult> call(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse response,
  ) =>
      hook(context, request, response);
}

/// A function type representing a post-response hook, which is executed after handling an incoming request.
///
/// It takes a [GazelleRequest] and a [GazelleResponse] as input and returns a [GazelleHookCallbackResult].
/// Post-response hooks can be used to modify the response before it is sent back to the client.
///
/// Example:
/// ```dart
/// Future<GazelleHookCallbackResult> myPostResponseHook(GazelleRequest request, GazelleResponse response) async {
///   // Optionally modify the response body or status code
///   // Return the modified response
///   return response.copyWith(
///	statusCode: 200,
///	body: "$body (modified)",
///   );
/// }
/// ```
typedef GazellePostResponseHookCallback = Future<GazelleHookCallbackResult>
    Function(
  GazelleContext context,
  GazelleRequest request,
  GazelleResponse response,
);

/// Represents a post-response hook for Gazelle routes.
///
/// A post-response hook allows developers to execute custom logic after processing an incoming HTTP request and generating a response.
/// This can be used, for example, for logging, response modification, or any other post-processing task.
///
/// The [hook] parameter is a callback function that takes a [GazelleRequest] and a [GazelleResponse] as input and returns a [Future] of [GazelleHookCallbackResult].
///
/// The optional parameter [shareWithChildRoutes] determines whether the hook should be shared with child routes.
/// If set to true, the hook will be executed for all child routes of the route to which it is attached.
/// If set to false (default), the hook will only be executed for the specific route to which it is attached.
///
/// Example:
/// ```dart
/// final postResponseHook = GazellePostResponseHook((request, response) async {
///   // Perform custom post-processing logic here, such as logging or response modification.
/// }, shareWithChildRoutes: true,
/// );
///
/// final postRoute = GazelleRoute(
///   (request) async {
///     // Handle the request...
///   },
///   postResponseHooks: [postResponseHook],
/// );
/// ```
class GazellePostResponseHook {
  /// The function to run after a response.
  final GazellePostResponseHookCallback hook;

  /// Determines whether the hook should be shared with child routes.
  final bool shareWithChildRoutes;

  /// Creates a GazellePostResponseHook instance.
  ///
  /// The [hook] parameter is the function to be executed after a response.
  /// The optional parameter [shareWithChildRoutes] determines whether the hook
  /// should be shared with child routes. By default, it's set to `false`.
  const GazellePostResponseHook(
    this.hook, {
    this.shareWithChildRoutes = false,
  });

  /// Invokes the post-response hook with the provided [response].
  ///
  /// Returns a future that completes with a [GazelleResponse] representing
  /// the result of the hook execution.
  Future<GazelleHookCallbackResult> call(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse response,
  ) =>
      hook(context, request, response);
}
