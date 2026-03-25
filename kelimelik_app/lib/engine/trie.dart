/// High-performance Trie data structure for Turkish word lookup.
/// Replaces the Python prefix-set approach with O(L) lookup per word.
class TrieNode {
  final Map<int, TrieNode> children = {};
  bool isWord = false;
}

class Trie {
  final TrieNode _root = TrieNode();
  int _wordCount = 0;

  int get wordCount => _wordCount;

  /// Insert a word into the trie.
  void insert(String word) {
    var node = _root;
    for (final codeUnit in word.codeUnits) {
      node = node.children.putIfAbsent(codeUnit, TrieNode.new);
    }
    if (!node.isWord) {
      node.isWord = true;
      _wordCount++;
    }
  }

  /// Check if an exact word exists in the trie.
  bool contains(String word) {
    final node = _getNode(word);
    return node != null && node.isWord;
  }

  /// Check if any word in the trie starts with this prefix.
  bool hasPrefix(String prefix) => _getNode(prefix) != null;

  TrieNode? _getNode(String s) {
    var node = _root;
    for (final codeUnit in s.codeUnits) {
      final child = node.children[codeUnit];
      if (child == null) return null;
      node = child;
    }
    return node;
  }

  /// Build from a set of words (bulk insert).
  void insertAll(Iterable<String> words) {
    for (final word in words) {
      insert(word);
    }
  }
}
