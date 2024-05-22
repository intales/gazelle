/// Represents HTTP status codes as an enum.
/// Each value corresponds to a specific HTTP status code.
enum GazelleHttpStatus {
  // Informational responses

  /// Indicates that the initial part of a request has been received and has not yet been rejected by the server.
  continueStatus(100),

  /// Indicates that the server is willing to switch protocols as specified by the client.
  switchingProtocols(101),

  /// Indicates that the server has received and is processing the request, but no response is available yet.
  processing(102),

  /// A suggestion that the client can start preloading resources while the server prepares the response.
  earlyHints(103),

  // Successful responses

  /// Indicates that the request has succeeded.
  ok(200),

  /// Indicates that the request has been fulfilled and a new resource has been created.
  created(201),

  /// Indicates that the request has been accepted for processing, but the processing is not complete.
  accepted(202),

  /// Indicates that the request was successful but the information may be from a different source.
  nonAuthoritativeInformation(203),

  /// Indicates that the server successfully processed the request, but is not returning any content.
  noContent(204),

  /// Indicates that the server successfully processed the request and is not returning any content, but requires the requester to reset the document view.
  resetContent(205),

  /// Indicates that the server is delivering only part of the resource due to a range header sent by the client.
  partialContent(206),

  /// Provides status for multiple independent operations.
  multiStatus(207),

  /// Used inside a <dav:propstat> response element to avoid enumerating the internal members of multiple bindings to the same collection repeatedly.
  alreadyReported(208),

  /// Indicates that the server has fulfilled a GET request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.
  imUsed(226),

  // Redirection messages

  /// Indicates multiple options for the resource from which the client may choose.
  multipleChoices(300),

  /// Indicates that the resource requested has been definitively moved to the URL given by the Location headers.
  movedPermanently(301),

  /// Indicates that the resource requested has been temporarily moved to the URL given by the Location headers.
  found(302),

  /// Indicates that the server is redirecting to a different resource, as indicated by the Location headers.
  seeOther(303),

  /// Indicates that the resource has not been modified since the last request.
  notModified(304),

  /// Indicates that the requested resource is available only through a proxy, the address for which is provided in the response.
  useProxy(305),

  /// No longer used. Originally meant "Subsequent requests should use the specified proxy."
  switchProxy(306),

  /// Indicates that the request should be repeated with another URI, but future requests should still use the original URI.
  temporaryRedirect(307),

  /// Indicates that the request should be repeated with another URI and future requests should use the new URI.
  permanentRedirect(308),

  // Client error responses

  /// Indicates that the server cannot or will not process the request due to something that is perceived to be a client error.
  badRequest(400),

  /// Indicates that the request requires user authentication.
  unauthorized(401),

  /// Reserved for future use. Originally meant "Payment required."
  paymentRequired(402),

  /// Indicates that the server understood the request but refuses to authorize it.
  forbidden(403),

  /// Indicates that the server has not found anything matching the request URI.
  notFound(404),

  /// Indicates that the request method is not allowed for the requested resource.
  methodNotAllowed(405),

  /// Indicates that the requested resource is capable of generating only content not acceptable according to the Accept headers sent in the request.
  notAcceptable(406),

  /// Indicates that the client must first authenticate itself with the proxy.
  proxyAuthenticationRequired(407),

  /// Indicates that the server did not receive a complete request message within the time that it was prepared to wait.
  requestTimeout(408),

  /// Indicates that the request could not be processed because of conflict in the request.
  conflict(409),

  /// Indicates that the resource requested is no longer available and will not be available again.
  gone(410),

  /// Indicates that the request did not specify the length of its content, which is required by the requested resource.
  lengthRequired(411),

  /// Indicates that the server does not meet one of the preconditions that the requester put on the request.
  preconditionFailed(412),

  /// Indicates that the server is refusing to process a request because the request payload is larger than the server is willing or able to process.
  payloadTooLarge(413),

  /// Indicates that the server is refusing to service the request because the request-target is longer than the server is willing to interpret.
  uriTooLong(414),

  /// Indicates that the server is refusing to service the request because the payload format is in an unsupported format.
  unsupportedMediaType(415),

  /// Indicates that none of the ranges in the request's Range header field overlap the current extent of the selected resource or that the set of ranges requested has been rejected due to invalid ranges.
  rangeNotSatisfiable(416),

  /// Indicates that the expectation given in the request's Expect header field could not be met by at least one of the inbound servers.
  expectationFailed(417),

  /// A playful response code that was implemented as an April Fools' joke.
  imATeapot(418),

  /// Indicates that the server is unable to produce a response for the request.
  misdirectedRequest(421),

  /// Indicates that the server understands the content type of the request entity, but was unable to process the contained instructions.
  unprocessableEntity(422),

  /// Indicates that the source or destination resource of a method is locked.
  locked(423),

  /// Indicates that the request failed due to failure of a previous request.
  failedDependency(424),

  /// Indicates that the server is unwilling to risk processing a request that might be replayed.
  tooEarly(425),

  /// Indicates that the client should switch to a different protocol, such as TLS/1.0, given in the Upgrade header field.
  upgradeRequired(426),

  /// Indicates that the origin server requires the request to be conditional.
  preconditionRequired(428),

  /// Indicates that the user has sent too many requests in a given amount of time.
  tooManyRequests(429),

  /// Indicates that the server is unwilling to process the request because its header fields are too large.
  requestHeaderFieldsTooLarge(431),

  /// Indicates that the server is denying access to the resource as a consequence of a legal demand.
  unavailableForLegalReasons(451),

  // Server error responses

  /// Indicates that the server encountered an unexpected condition that prevented it from fulfilling the request.
  internalServerError(500),

  /// Indicates that the server does not support the functionality required to fulfill the request.
  notImplemented(501),

  /// Indicates that the server, while acting as a gateway or proxy, received an invalid response from an inbound server it accessed while attempting to fulfill the request.
  badGateway(502),

  /// Indicates that the server is currently unable to handle the request due to a temporary overload or scheduled maintenance.
  serviceUnavailable(503),

  /// Indicates that the server, while acting as a gateway or proxy, did not receive a timely response from an upstream server.
  gatewayTimeout(504),

  /// Indicates that the server does not support the HTTP protocol version used in the request.
  httpVersionNotSupported(505),

  /// Indicates that the server has an internal configuration error: the chosen variant resource is configured to engage in transparent content negotiation itself, and is therefore not a proper end point in the negotiation process.
  variantAlsoNegotiates(506),

  /// Indicates that the method could not be performed on the resource because the server is unable to store the representation needed to successfully complete the request.
  insufficientStorage(507),

  /// Indicates that the server detected an infinite loop while processing a request.
  loopDetected(508),

  /// Indicates that further extensions to the request are required for the server to fulfill it.
  notExtended(510),

  /// Indicates that the client needs to authenticate to gain network access.
  networkAuthenticationRequired(511);

  /// The integer status code associated with the HTTP status.
  final int code;

  /// Creates an enum value with the associated status code.
  const GazelleHttpStatus(this.code);

  /// Returns the enum value for a given status code, or `null` if the code is not found.
  static GazelleHttpStatus? fromCode(int code) {
    return GazelleHttpStatus.values.where((e) => e.code == code).firstOrNull;
  }
}
