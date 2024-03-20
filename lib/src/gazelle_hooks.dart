import 'gazelle_message.dart';

typedef GazellePreRequestHook = Future<GazelleMessage> Function(
  GazelleRequest request,
);

typedef GazellePostResponseHook = Future<GazelleResponse> Function(
  GazelleResponse response,
);
