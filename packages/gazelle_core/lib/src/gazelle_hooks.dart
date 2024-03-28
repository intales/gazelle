import 'gazelle_message.dart';

/// A function type representing a pre-request hook, which is executed before handling an incoming request.
///
/// It takes a [GazelleRequest] as input and returns a [GazelleMessage].
/// Pre-request hooks can be used to modify or validate the request before it is processed.
///
/// Example:
/// ```dart
/// Future<GazelleMessage> myPreRequestHook(GazelleRequest request) async {
///   // Perform some validation
///   if (!isValidRequest(request)) {
///     return GazelleResponse(
///       statusCode: 400,
///       body: 'Bad Request',
///     );
///   }
///
///   // If validation passes, continue processing the request
///   return request;
/// }
/// ```
typedef GazellePreRequestHookCallback = Future<GazelleMessage> Function(
  GazelleRequest request,
);

/// Represents a pre-request hook for Gazelle routes.
///
/// A pre-request hook allows developers to execute custom logic before processing an incoming HTTP request.
/// This can be used, for example, for authentication, authorization, request validation, or any other pre-processing task.
///
/// The [hook] parameter is a callback function that takes a [GazelleRequest] as input and returns a [Future] of [void].
///
/// The optional parameter [shareWithChildRoutes] determines whether the hook should be shared with child routes.
/// If set to true, the hook will be executed for all child routes of the route to which it is attached.
/// If set to false (default), the hook will only be executed for the specific route to which it is attached.
///
/// Example:
/// ```dart
/// final preRequestHook = GazellePreRequestHook((request) async {
///   // Perform custom pre-processing logic here, such as authentication or validation.
/// }, shareWithChildRoutes: true,
/// );
///
/// final postRoute = GazelleRoute(
///   (request) async {
///     // Handle the request...
///   },
///   preRequestHooks: [preRequestHook],
/// );
/// ```
class GazellePreRequestHook {
  final GazellePreRequestHookCallback hook;
  final bool shareWithChildRoutes;

  const GazellePreRequestHook(
    this.hook, {
    this.shareWithChildRoutes = false,
  });

  Future<GazelleMessage> call(GazelleRequest request) => hook(request);
}

/// A function type representing a post-response hook, which is executed after handling an incoming request.
///
/// It takes a [GazelleResponse] as input and returns a [GazelleResponse].
/// Post-response hooks can be used to modify the response before it is sent back to the client.
///
/// Example:
/// ```dart
/// Future<GazelleResponse> myPostResponseHook(GazelleResponse response) async {
///   // Add custom headers to the response
///   response.headers['X-Custom-Header'] = 'Value';
///
///   // Optionally modify the response body or status code
///   response.body += ' (modified)';
///   response.statusCode = 200;
///
///   // Return the modified response
///   return response;
/// }
/// ```
typedef GazellePostResponseHookCallback = Future<GazelleResponse> Function(
  GazelleResponse response,
);

/// Represents a post-response hook for Gazelle routes.
///
/// A post-response hook allows developers to execute custom logic after processing an incoming HTTP request and generating a response.
/// This can be used, for example, for logging, response modification, or any other post-processing task.
///
/// The [hook] parameter is a callback function that takes a [GazelleRequest] and a [GazelleResponse] as input and returns a [Future] of [void].
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
  final GazellePostResponseHookCallback hook;
  final bool shareWithChildRoutes;

  const GazellePostResponseHook(
    this.hook, {
    this.shareWithChildRoutes = false,
  });

  Future<GazelleResponse> call(GazelleResponse response) => hook(response);
}
