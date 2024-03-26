import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:gazelle_core/gazelle_core.dart';
import 'gazelle_jwt_consts.dart';

extension GazelleJwtRequestExtension on GazelleRequest {
  JWT get jwt => metadata[jwtKeyword]!;
}
