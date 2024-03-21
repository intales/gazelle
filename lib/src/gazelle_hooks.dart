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
typedef GazellePreRequestHook = Future<GazelleMessage> Function(
  GazelleRequest request,
);

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
typedef GazellePostResponseHook = Future<GazelleResponse> Function(
  GazelleResponse response,
);
