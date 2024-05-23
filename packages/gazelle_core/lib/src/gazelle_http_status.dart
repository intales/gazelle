/// Represents an HTTP status code.
class GazelleHttpStatus {
  /// The HTTP status code.
  final int code;

  /// Builds an HTTP status.
  const GazelleHttpStatus(this.code);

  /// Informational HTTP status.
  static const informational = _GazelleInformationalHttpStatus();

  /// Successful HTTP status.
  static const success = _GazelleSuccessfulHttpStatus();

  /// Redirection HTTP status.
  static const redirection = _GazelleRedirectionHttpStatus();

  /// Client error HTTP status.
  static const clientError = _GazelleClientErrorHttpStatus();

  /// Server error HTTP status.
  static const serverError = _GazelleServerErrorHttpStatus();
}

/// Informational HTTP status.
class _GazelleInformationalHttpStatus {
  const _GazelleInformationalHttpStatus();

  /// Indicates that the initial part of a request has been received and has not yet been rejected by the server.
  final continueStatus_100 = const GazelleHttpStatus(100);

  /// Indicates that the server is willing to switch protocols as specified by the client.
  final switchingProtocols_101 = const GazelleHttpStatus(101);

  /// Indicates that the server has received and is processing the request, but no response is available yet.
  final processing_102 = const GazelleHttpStatus(102);

  /// A suggestion that the client can start preloading resources while the server prepares the response.
  final earlyHints_103 = const GazelleHttpStatus(103);
}

/// Successful HTTP status.
class _GazelleSuccessfulHttpStatus {
  const _GazelleSuccessfulHttpStatus();

  /// Indicates that the request has succeeded.
  final ok_200 = const GazelleHttpStatus(200);

  /// Indicates that the request has been fulfilled and a new resource has been created.
  final created_201 = const GazelleHttpStatus(201);

  /// Indicates that the request has been accepted for processing, but the processing is not complete.
  final accepted_202 = const GazelleHttpStatus(202);

  /// Indicates that the request was successful but the information may be from a different source.
  final nonAuthoritativeInformation_203 = const GazelleHttpStatus(203);

  /// Indicates that the server successfully processed the request, but is not returning any content.
  final noContent_204 = const GazelleHttpStatus(204);

  /// Indicates that the server successfully processed the request and is not returning any content, but requires the requester to reset the document view.
  final resetContent_205 = const GazelleHttpStatus(205);

  /// Indicates that the server is delivering only part of the resource due to a range header sent by the client.
  final partialContent_206 = const GazelleHttpStatus(206);

  /// Provides status for multiple independent operations.
  final multiStatus_207 = const GazelleHttpStatus(207);

  /// Used inside a <dav:propstat> response element to avoid enumerating the internal members of multiple bindings to the same collection repeatedly.
  final alreadyReported_208 = const GazelleHttpStatus(208);

  /// Indicates that the server has fulfilled a GET request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.
  final imUsed_226 = const GazelleHttpStatus(226);
}

/// Redirection HTTP status.
class _GazelleRedirectionHttpStatus {
  const _GazelleRedirectionHttpStatus();

  /// Indicates multiple options for the resource from which the client may choose.
  final multipleChoices_300 = const GazelleHttpStatus(300);

  /// Indicates that the resource requested has been definitively moved to the URL given by the Location headers.
  final movedPermanently_301 = const GazelleHttpStatus(301);

  /// Indicates that the resource requested has been temporarily moved to the URL given by the Location headers.
  final found_302 = const GazelleHttpStatus(302);

  /// Indicates that the server is redirecting to a different resource, as indicated by the Location headers.
  final seeOther_303 = const GazelleHttpStatus(303);

  /// Indicates that the resource has not been modified since the last request.
  final notModified_304 = const GazelleHttpStatus(304);

  /// Indicates that the requested resource is available only through a proxy, the address for which is provided in the response.
  final useProxy_305 = const GazelleHttpStatus(305);

  /// Indicates that the request should be repeated with another URI, but future requests should still use the original URI.
  final temporaryRedirect_307 = const GazelleHttpStatus(307);

  /// Indicates that the request should be repeated with another URI and future requests should use the new URI.
  final permanentRedirect_308 = const GazelleHttpStatus(308);
}

/// Client error HTTP status.
class _GazelleClientErrorHttpStatus {
  const _GazelleClientErrorHttpStatus();

  /// Indicates that the server cannot or will not process the request due to something that is perceived to be a client error.
  final badRequest_400 = const GazelleHttpStatus(400);

  /// Indicates that the request requires user authentication.
  final unauthorized_401 = const GazelleHttpStatus(401);

  /// Reserved for future use. Originally meant "Payment required."
  final paymentRequired_402 = const GazelleHttpStatus(402);

  /// Indicates that the server understood the request but refuses to authorize it.
  final forbidden_403 = const GazelleHttpStatus(403);

  /// Indicates that the server has not found anything matching the request URI.
  final notFound_404 = const GazelleHttpStatus(404);

  /// Indicates that the request method is not allowed for the requested resource.
  final methodNotAllowed_405 = const GazelleHttpStatus(405);

  /// Indicates that the requested resource is capable of generating only content not acceptable according to the Accept headers sent in the request.
  final notAcceptable_406 = const GazelleHttpStatus(406);

  /// Indicates that the client must first authenticate itself with the proxy.
  final proxyAuthenticationRequired_407 = const GazelleHttpStatus(407);

  /// Indicates that the server did not receive a complete request message within the time that it was prepared to wait.
  final requestTimeout_408 = const GazelleHttpStatus(408);

  /// Indicates that the request could not be processed because of conflict in the request.
  final conflict_409 = const GazelleHttpStatus(409);

  /// Indicates that the resource requested is no longer available and will not be available again.
  final gone_410 = const GazelleHttpStatus(410);

  /// Indicates that the request did not specify the length of its content, which is required by the requested resource.
  final lengthRequired_411 = const GazelleHttpStatus(411);

  /// Indicates that the server does not meet one of the preconditions that the requester put on the request.
  final preconditionFailed_412 = const GazelleHttpStatus(412);

  /// Indicates that the server is refusing to process a request because the request payload is larger than the server is willing or able to process.
  final payloadTooLarge_413 = const GazelleHttpStatus(413);

  /// Indicates that the server is refusing to service the request because the request-target is longer than the server is willing to interpret.
  final uriTooLong_414 = const GazelleHttpStatus(414);

  /// Indicates that the server is refusing to service the request because the payload format is in an unsupported format.
  final unsupportedMediaType_415 = const GazelleHttpStatus(415);

  /// Indicates that none of the ranges in the request's Range header field overlap the current extent of the selected resource or that the set of ranges requested has been rejected due to invalid ranges.
  final rangeNotSatisfiable_416 = const GazelleHttpStatus(416);

  /// Indicates that the expectation given in the request's Expect header field could not be met by at least one of the inbound servers.
  final expectationFailed_417 = const GazelleHttpStatus(417);

  /// A playful response code that was implemented as an April Fools' joke.
  final imATeapot_418 = const GazelleHttpStatus(418);

  /// Indicates that the server is unable to produce a response for the request.
  final misdirectedRequest_421 = const GazelleHttpStatus(421);

  /// Indicates that the server understands the content type of the request entity, but was unable to process the contained instructions.
  final unprocessableEntity_422 = const GazelleHttpStatus(422);

  /// Indicates that the source or destination resource of a method is locked.
  final locked_423 = const GazelleHttpStatus(423);

  /// Indicates that the request failed due to failure of a previous request.
  final failedDependency_424 = const GazelleHttpStatus(424);

  /// Indicates that the server is unwilling to risk processing a request that might be replayed.
  final tooEarly_425 = const GazelleHttpStatus(425);

  /// Indicates that the client should switch to a different protocol, such as TLS/1.0, given in the Upgrade header field.
  final upgradeRequired_426 = const GazelleHttpStatus(426);

  /// Indicates that the origin server requires the request to be conditional.
  final preconditionRequired_428 = const GazelleHttpStatus(428);

  /// Indicates that the user has sent too many requests in a given amount of time.
  final tooManyRequests_429 = const GazelleHttpStatus(429);

  /// Indicates that the server is unwilling to process the request because its header fields are too large.
  final requestHeaderFieldsTooLarge_431 = const GazelleHttpStatus(431);

  /// Indicates that the server is denying access to the resource as a consequence of a legal demand.
  final unavailableForLegalReasons_451 = const GazelleHttpStatus(451);
}

/// Server error HTTP status.
class _GazelleServerErrorHttpStatus {
  const _GazelleServerErrorHttpStatus();

  /// Indicates that the server encountered an unexpected condition that prevented it from fulfilling the request.
  final internalServerError_500 = const GazelleHttpStatus(500);

  /// Indicates that the server does not support the functionality required to fulfill the request.
  final notImplemented_501 = const GazelleHttpStatus(501);

  /// Indicates that the server, while acting as a gateway or proxy, received an invalid response from an inbound server it accessed while attempting to fulfill the request.
  final badGateway_502 = const GazelleHttpStatus(502);

  /// Indicates that the server is currently unable to handle the request due to a temporary overload or scheduled maintenance.
  final serviceUnavailable_503 = const GazelleHttpStatus(503);

  /// Indicates that the server, while acting as a gateway or proxy, did not receive a timely response from an upstream server.
  final gatewayTimeout_504 = const GazelleHttpStatus(504);

  /// Indicates that the server does not support the HTTP protocol version used in the request.
  final httpVersionNotSupported_505 = const GazelleHttpStatus(505);

  /// Indicates that the server has an internal configuration error: the chosen variant resource is configured to engage in transparent content negotiation itself, and is therefore not a proper end point in the negotiation process.
  final variantAlsoNegotiates_506 = const GazelleHttpStatus(506);

  /// Indicates that the method could not be performed on the resource because the server is unable to store the representation needed to successfully complete the request.
  final insufficientStorage_507 = const GazelleHttpStatus(507);

  /// Indicates that the server detected an infinite loop while processing a request.
  final loopDetected_508 = const GazelleHttpStatus(508);

  /// Indicates that further extensions to the request are required for the server to fulfill it.
  final notExtended_510 = const GazelleHttpStatus(510);

  /// Indicates that the client needs to authenticate to gain network access.
  final networkAuthenticationRequired_511 = const GazelleHttpStatus(511);
}
