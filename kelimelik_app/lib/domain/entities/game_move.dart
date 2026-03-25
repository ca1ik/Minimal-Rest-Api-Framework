/// Domain entity: a solved move returned by the solver engine.
class GameMove {
  final String word;
  final int score;
  final int row;
  final int col;
  final String direction; // 'yatay' or 'dikey'
  final int lettersUsed;
  final String bonusInfo;
  final List<bool> jokerIndices;
  final int starBonus;

  const GameMove({
    required this.word,
    required this.score,
    required this.row,
    required this.col,
    required this.direction,
    required this.lettersUsed,
    this.bonusInfo = '-',
    this.jokerIndices = const [],
    this.starBonus = 0,
  });

  /// Base score without star bonus
  int get baseScore => score - starBonus;

  /// Display position like "A1"
  String get position => '${String.fromCharCode(65 + row)}${col + 1}';

  /// Human-readable direction
  String get directionDisplay => direction == 'yatay' ? 'Yatay' : 'Dikey';
}
