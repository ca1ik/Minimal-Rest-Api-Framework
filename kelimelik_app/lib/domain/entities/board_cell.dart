/// Domain entity: a single cell on the game board.
class BoardCell {
  final String letter;
  final bool isJoker;
  final bool isPreview;
  final bool hasStar;

  const BoardCell({
    this.letter = '',
    this.isJoker = false,
    this.isPreview = false,
    this.hasStar = false,
  });

  bool get isEmpty => letter.isEmpty;
  bool get isFilled => letter.isNotEmpty && !isPreview;

  BoardCell copyWith({
    String? letter,
    bool? isJoker,
    bool? isPreview,
    bool? hasStar,
  }) => BoardCell(
    letter: letter ?? this.letter,
    isJoker: isJoker ?? this.isJoker,
    isPreview: isPreview ?? this.isPreview,
    hasStar: hasStar ?? this.hasStar,
  );
}

/// A string subtype that carries joker metadata, mirroring Python's BoardChar.
class BoardChar {
  final String value;
  final bool isJoker;

  const BoardChar(this.value, {this.isJoker = false});

  bool get isEmpty => value.isEmpty;

  @override
  String toString() => value;
}
