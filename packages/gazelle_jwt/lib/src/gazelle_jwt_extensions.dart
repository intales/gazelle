import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:gazelle_core/gazelle_core.dart';

/// An extension providing JWT-related functionality to GazelleRequest instances.
extension GazelleJwtRequestExtension on GazelleRequest {
  /// Retrieves the [JWT] from the request.
  JWT? get jwt => context<JWT>();

  /// Sets the [jwt].
  void setJwt(JWT jwt) => context.add<JWT>(jwt);
}
