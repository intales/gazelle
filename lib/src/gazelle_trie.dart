class GazelleTrieSearchResult<T> {
  final T? value;
  final Map<String, String> wildcardValues;

  const GazelleTrieSearchResult({
    required this.value,
    this.wildcardValues = const {},
  });
}

class GazelleTrieNode<T> {
  Map<String, GazelleTrieNode<T>> children = {};
  T? value;

  String? _wildcardName;
  set wildcardName(String name) => _wildcardName = name;
  String get wildcardName =>
      _wildcardName == null ? throw "Wildcard name is null" : _wildcardName!;

  bool get isWildcard => _wildcardName != null;
  bool get hasWildcardChild => children.values.any((e) => e.isWildcard);

  GazelleTrieNode<T> get wildcardChild =>
      children.values.singleWhere((e) => e.isWildcard);
}

class GazelleTrie<T> {
  final String wildcard;

  GazelleTrieNode<T> root = GazelleTrieNode<T>();

  GazelleTrie({
    required this.wildcard,
  });

  void insert(List<String> strings, T value) {
    GazelleTrieNode<T> current = root;

    for (final string in strings) {
      if (string.startsWith(wildcard)) {
        final wildcardName = string.replaceAll(wildcard, "");
        if (!current.children.containsKey(wildcardName)) {
          current.children[wildcardName] = GazelleTrieNode<T>();
        }
        current = current.children[wildcardName]!;

        current.wildcardName = wildcardName;
        continue;
      }

      if (!current.children.containsKey(string)) {
        current.children[string] = GazelleTrieNode<T>();
      }
      current = current.children[string]!;
    }

    current.value = value;
  }

  GazelleTrieSearchResult<T> search(List<String> strings) {
    GazelleTrieNode<T> current = root;
    Map<String, String> wildcards = {};

    for (final string in strings) {
      if (current.children.containsKey(string)) {
        current = current.children[string]!;
      } else if (current.hasWildcardChild) {
        current = current.wildcardChild;
        wildcards[current.wildcardName] = string;
      } else {
        return GazelleTrieSearchResult(
          value: null,
          wildcardValues: wildcards,
        );
      }
    }

    return GazelleTrieSearchResult(
      value: current.value,
      wildcardValues: wildcards,
    );
  }
}
