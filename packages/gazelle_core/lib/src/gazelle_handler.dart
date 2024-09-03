import 'dart:async';
import 'dart:convert';

import 'package:gazelle_serialization/gazelle_serialization.dart';

import 'gazelle_context.dart';
import 'gazelle_message.dart';

/// Represents a handler for a Gazelle route.
abstract class GazelleHandler<RequestType, ResponseType> {
  /// Builds a [GazelleHandler].
  const GazelleHandler();

  /// Returns the handler's [RequestType].
  Type get requestType => RequestType;

  /// Returns the handler's [ResponseType].
  Type get responseType => ResponseType;

  /// Runs the handler.
  FutureOr<GazelleResponse<ResponseType>> call(
    GazelleContext context,
    GazelleRequest<RequestType> request,
  );

  /// Internal method to run the handler.
  ///
  /// Used by `GazelleApp`.
  FutureOr<GazelleResponse<ResponseType>> internal(
    GazelleContext context,
    GazelleRequest request,
  ) async {
    if (request.body == null) {
      final response = await call(
        context,
        GazelleRequest(
          uri: request.uri,
          method: request.method,
          pathParameters: request.pathParameters,
          headers: request.headers,
          metadata: request.metadata,
          body: null,
          bodyStream: request.bodyStream,
        ),
      );

      return response;
    }

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

    final response = await call(
      context,
      typedRequest,
    );

    return response;
  }
}

/// Represents a GET method handler for a Gazelle route.
abstract class GazelleGetHandler<ResponseType>
    extends GazelleHandler<Null, ResponseType> {
  /// Builds a [GazelleGetHandler].
  const GazelleGetHandler();
}

/// Represents a POST method handler for a Gazelle route.
abstract class GazellePostHandler<RequestType, ResponseType>
    extends GazelleHandler<RequestType, ResponseType> {
  /// Builds a [GazellePostHandler].
  const GazellePostHandler();
}

/// Represents a PUT method handler for a Gazelle route.
abstract class GazellePutHandler<RequestType, ResponseType>
    extends GazelleHandler<RequestType, ResponseType> {
  /// Builds a [GazellePutHandler].
  const GazellePutHandler();
}

/// Represents a PATCH method handler for a Gazelle route.
abstract class GazellePatchHandler<RequestType, ResponseType>
    extends GazelleHandler<RequestType, ResponseType> {
  /// Builds a [GazellePatchHandler].
  const GazellePatchHandler();
}

/// Represents a DELETE method handler for a Gazelle route.
abstract class GazelleDeleteHandler<RequestType, ResponseType>
    extends GazelleHandler<RequestType, ResponseType> {
  /// Builds a [GazelleDeleteHandler].
  const GazelleDeleteHandler();
}
