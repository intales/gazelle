import 'dart:async';
import 'dart:convert';

import 'package:gazelle_serialization/gazelle_serialization.dart';

import 'gazelle_context.dart';
import 'gazelle_message.dart';

/// Defines a handler function.
typedef GazelleHandlerFunction<RequestType, ResponseType>
    = FutureOr<GazelleResponse<ResponseType>> Function(
  GazelleContext context,
  GazelleRequest<RequestType> request,
);

/// A class that runs the given handler function with typed requests and responses.
class GazelleHandler<RequestType, ResponseType> {
  final GazelleHandlerFunction<RequestType, ResponseType> _handlerFunction;

  /// Builds a [GazelleHandler].
  const GazelleHandler(this._handlerFunction);

  /// Returns the [RequestType].
  Type get requestType => RequestType;

  /// Returns the [ResponseType].
  Type get responseType => ResponseType;

  /// Runs the handler function.
  FutureOr<GazelleResponse<ResponseType>> call(
    GazelleContext context,
    GazelleRequest request,
  ) async {
    final typedBody = await utf8.decodeStream(request.bodyStream).then((body) {
      if (body.trim().isEmpty) return null;

      late final dynamic jsonObject;
      try {
        jsonObject = jsonDecode(body);
      } on FormatException {
        jsonObject = body;
      }

      return deserialize<RequestType>(
        jsonObject: jsonObject,
        modelProvider: context.modelProvider,
      );
    });

    final typedRequest = GazelleRequest<RequestType>(
      uri: request.uri,
      method: request.method,
      pathParameters: request.pathParameters,
      metadata: request.metadata,
      headers: request.headers,
      body: typedBody,
      bodyStream: request.bodyStream,
    );

    final response = await _handlerFunction(
      context,
      typedRequest,
    );

    return response;
  }
}
