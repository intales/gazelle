import 'dart:async';
import 'dart:convert';

import 'package:gazelle_serialization/gazelle_serialization.dart';

import 'gazelle_context.dart';
import 'gazelle_http_header.dart';
import 'gazelle_http_status_code.dart';
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
  FutureOr<ResponseType> call(
    GazelleContext context,
    RequestType? body,
    List<GazelleHttpHeader> headers,
    Map<String, String> pathParameters,
  );

  /// Internal method to run the handler.
  ///
  /// Used by `GazelleApp`.
  FutureOr<GazelleResponse<ResponseType>> internal(
    GazelleContext context,
    GazelleRequest request,
    GazelleResponse response,
  ) async {
    if (request.body == null) {
      final responseBody = await call(
        context,
        null,
        request.headers,
        request.pathParameters,
      );

      return GazelleResponse(
        statusCode: GazelleHttpStatusCode.success.ok_200,
        body: responseBody,
      );
    }

    final requestBody = await request.body!.then((body) {
      if (RequestType == Null) return null;
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

    final responseBody = await call(
      context,
      requestBody,
      request.headers,
      request.pathParameters,
    );

    return GazelleResponse<ResponseType>(
      statusCode: GazelleHttpStatusCode.success.ok_200,
      body: responseBody,
    );
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
