import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:gazelle_core/gazelle_core.dart';
import 'gazelle_jwt_consts.dart';

/// An extension providing JWT-related functionality to GazelleRequest instances.
extension GazelleJwtRequestExtension on GazelleRequest {
  /// Retrieves the JWT from the request metadata.
  JWT get jwt => metadata[jwtKeyword]!;
}
