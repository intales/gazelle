import 'package:path/path.dart' as p;

/// Calculates relative path between [from] and [to].
String calculateRelativePath(String from, String to) {
  from = p.absolute(from);
  to = p.absolute(to);

  List<String> fromParts = p.split(from);
  List<String> toParts = p.split(to);

  int commonLength = 0;
  for (int i = 0; i < fromParts.length && i < toParts.length; i++) {
    if (fromParts[i] == toParts[i]) {
      commonLength++;
    } else {
      break;
    }
  }

  int levelsUp = fromParts.length - commonLength - 1;

  List<String> relativePathParts = List.filled(levelsUp, '..', growable: true);
  relativePathParts.addAll(toParts.sublist(commonLength));

  final result = p.joinAll(relativePathParts);

  return result;
}
