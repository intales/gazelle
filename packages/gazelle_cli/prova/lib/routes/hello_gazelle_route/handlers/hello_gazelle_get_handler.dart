import 'package:gazelle_core/gazelle_core.dart';

import '../../../entities/post.dart';
import '../../../entities/user.dart';

GazelleResponse helloGazelleGet(
  GazelleContext context,
  GazelleRequest request,
  GazelleResponse response,
) {
  final user = User(
    id: "user_id",
    name: "Filippo",
    surname: "Menchini",
    username: "f.menchini",
    createdAt: DateTime.now(),
  );
  final post = Post(
    id: "post_id",
    content: "my first post",
    user: user,
    createdAt: DateTime.now(),
  );
  return GazelleResponse(
    statusCode: GazelleHttpStatusCode.success.ok_200,
    body: post,
  );
}
