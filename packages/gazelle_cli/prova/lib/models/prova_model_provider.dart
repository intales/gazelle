import 'package:gazelle_core/gazelle_core.dart';
import '../entities/post.dart';
import '../entities/user.dart';
import 'post_model_type.dart';
import 'user_model_type.dart';

class ProvaModelProvider extends GazelleModelProvider {
  @override
  Map<Type, GazelleModelType> get modelTypes => {
        Post: PostModelType(),
        User: UserModelType(),
      };
}
