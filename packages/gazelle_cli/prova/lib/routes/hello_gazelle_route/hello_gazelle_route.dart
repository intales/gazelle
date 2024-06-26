import 'package:gazelle_core/gazelle_core.dart';
import 'handlers/hello_gazelle_get_handler.dart';

const helloGazelleRoute = GazelleRoute(
  name: "hello_gazelle",
  get: helloGazelleGet,
);
