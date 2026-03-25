/// Production-grade Kelimelik solver engine ported from Python.
/// Uses Trie for O(L) prefix checks instead of Python's O(1) set + O(n) build.
/// Designed to run in a Dart Isolate for non-blocking computation.
import '../core/constants/board_constants.dart';
import '../domain/entities/board_cell.dart';
import '../domain/entities/game_move.dart';
import 'trie.dart';

class KelimelikSolver {
  final Trie _trie = Trie();
  Set<String> _words = {};

  void setWords(Set<String> words) {
    _words = words;
    _trie.insertAll(words);
  }

  int get wordCount => _trie.wordCount;

  // ─── Anchor Detection ─────────────────────────────────────────────

  List<(int, int)> _getAnchors(List<List<BoardChar>> board) {
    final size = board.length;
    final isEmpty = board.every((row) => row.every((c) => c.isEmpty));
    if (isEmpty) return [(size ~/ 2, size ~/ 2)];

    final anchors = <(int, int)>{};
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (board[r][c].isEmpty == false) continue;
        if ((r > 0 && board[r - 1][c].isEmpty == false) ||
            (r < size - 1 && board[r + 1][c].isEmpty == false) ||
            (c > 0 && board[r][c - 1].isEmpty == false) ||
            (c < size - 1 && board[r][c + 1].isEmpty == false)) {
          anchors.add((r, c));
        }
      }
    }
    return anchors.toList();
  }

  // ─── Board Transpose ──────────────────────────────────────────────

  List<List<T>> _transpose<T>(List<List<T>> matrix) {
    final rows = matrix.length;
    final cols = matrix[0].length;
    return List.generate(cols, (c) => List.generate(rows, (r) => matrix[r][c]));
  }

  // ─── Main Solve Entry ─────────────────────────────────────────────

  List<GameMove> solve(
    List<List<BoardChar>> board,
    String hand,
    List<List<String>> bonusMap, {
    Set<(int, int)>? userStars,
    bool isOpponent = false,
  }) {
    userStars ??= {};
    final boardIsEmpty = board.every((row) => row.every((c) => c.isEmpty));

    final moves = <GameMove>[];

    // Horizontal moves
    moves.addAll(
      _findAllForDirection(
        board,
        hand,
        bonusMap,
        'yatay',
        userStars,
        isOpponent,
        boardIsEmpty,
      ),
    );

    // Vertical moves (transpose, solve as horizontal, swap r/c back)
    final tBoard = _transpose(board);
    final tBonus = _transpose(bonusMap);
    final tStars = userStars.map((s) => (s.$2, s.$1)).toSet();

    final vertMoves = _findAllForDirection(
      tBoard,
      hand,
      tBonus,
      'dikey',
      tStars,
      isOpponent,
      boardIsEmpty,
    );
    for (final m in vertMoves) {
      moves.add(
        GameMove(
          word: m.word,
          score: m.score,
          row: m.col, // swap back
          col: m.row,
          direction: m.direction,
          lettersUsed: m.lettersUsed,
          bonusInfo: m.bonusInfo,
          jokerIndices: m.jokerIndices,
          starBonus: m.starBonus,
        ),
      );
    }

    // Deduplicate
    final unique = <String, GameMove>{};
    for (final m in moves) {
      final key = '${m.word}_${m.row}_${m.col}_${m.direction}';
      final existing = unique[key];
      if (existing == null || existing.score < m.score) {
        unique[key] = m;
      }
    }

    final result = unique.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return result;
  }

  // ─── Direction-Specific Search ────────────────────────────────────

  List<GameMove> _findAllForDirection(
    List<List<BoardChar>> board,
    String hand,
    List<List<String>> bonusMap,
    String yon,
    Set<(int, int)> userStars,
    bool isOpponent,
    bool boardIsEmpty,
  ) {
    final hamleler = <GameMove>[];
    final size = board.length;
    final anchors = _getAnchors(board);
    final startsToTry = <(int, int)>{};

    if (boardIsEmpty) {
      final center = size ~/ 2;
      final handLen = hand.length;
      for (
        var cStart = (center - handLen + 1).clamp(0, center);
        cStart <= center;
        cStart++
      ) {
        startsToTry.add((center, cStart));
      }
    } else {
      for (final (rAnchor, cAnchor) in anchors) {
        if (board[rAnchor][cAnchor].isEmpty == false) continue;
        var emptySeen = 0;
        for (var cc = cAnchor; cc >= 0; cc--) {
          if (cc < cAnchor && board[rAnchor][cc].isEmpty == false) {
            if (cc == 0 || board[rAnchor][cc - 1].isEmpty) {
              startsToTry.add((rAnchor, cc));
            }
            break;
          }
          if (board[rAnchor][cc].isEmpty) {
            emptySeen++;
            if (emptySeen > hand.length) break;
            if (cc == 0 || board[rAnchor][cc - 1].isEmpty) {
              startsToTry.add((rAnchor, cc));
            }
          }
        }
      }
      // Starting positions of every filled segment
      for (var r = 0; r < size; r++) {
        for (var c = 0; c < size; c++) {
          if (board[r][c].isEmpty == false &&
              (c == 0 || board[r][c - 1].isEmpty)) {
            startsToTry.add((r, c));
          }
        }
      }
    }

    final sorted = startsToTry.toList()
      ..sort((a, b) {
        final cmp = a.$1.compareTo(b.$1);
        return cmp != 0 ? cmp : a.$2.compareTo(b.$2);
      });

    for (final (r, cStart) in sorted) {
      _extendRight(
        '',
        hand,
        r,
        cStart,
        board,
        hamleler,
        bonusMap,
        yon,
        cStart,
        userStars,
        isOpponent,
        [],
        boardIsEmpty,
      );
    }
    return hamleler;
  }

  // ─── Recursive Extension ──────────────────────────────────────────

  void _extendRight(
    String prefix,
    String hand,
    int r,
    int cStart,
    List<List<BoardChar>> board,
    List<GameMove> hamleler,
    List<List<String>> bonusMap,
    String yon,
    int initialCStart,
    Set<(int, int)> userStars,
    bool isOpponent,
    List<bool> jokerIndicesUsed,
    bool boardIsEmpty,
  ) {
    if (prefix.isNotEmpty && !_trie.hasPrefix(prefix)) return;

    final cCurrent = initialCStart + prefix.length;
    final size = board.length;

    // Check if prefix is a valid complete word
    if (_trie.contains(prefix) && prefix.length > 1) {
      final isWordEnding = cCurrent > size - 1 || board[r][cCurrent].isEmpty;
      final isWordStarting =
          initialCStart == 0 || board[r][initialCStart - 1].isEmpty;

      if (isWordEnding && isWordStarting) {
        if (_checkValidityAndCrossWords(
          prefix,
          r,
          initialCStart,
          board,
          boardIsEmpty,
        )) {
          final result = _calculateScore(
            prefix,
            r,
            initialCStart,
            board,
            bonusMap,
            jokerIndicesUsed,
            userStars,
          );
          if (result.charsUsed > 0) {
            if (!(isOpponent && result.charsUsed > 7)) {
              hamleler.add(
                GameMove(
                  word: prefix,
                  score: result.totalScore,
                  row: r,
                  col: initialCStart,
                  direction: yon,
                  lettersUsed: result.charsUsed,
                  bonusInfo: result.bonusInfo,
                  jokerIndices: List.from(jokerIndicesUsed),
                  starBonus: result.starPoints,
                ),
              );
            }
          }
        }
      }
    }

    if (cCurrent > size - 1) return;

    if (board[r][cCurrent].isEmpty == false) {
      // Tile already on board — use it for free
      _extendRight(
        prefix + board[r][cCurrent].value,
        hand,
        r,
        cStart,
        board,
        hamleler,
        bonusMap,
        yon,
        initialCStart,
        userStars,
        isOpponent,
        [...jokerIndicesUsed, false],
        boardIsEmpty,
      );
    } else {
      if (hand.isEmpty) return;

      final uniqueChars = hand.split('').toSet();
      for (final char in uniqueChars) {
        if (char == '*') continue;
        final idx = hand.indexOf(char);
        final newHand = hand.substring(0, idx) + hand.substring(idx + 1);
        _extendRight(
          prefix + char,
          newHand,
          r,
          cStart,
          board,
          hamleler,
          bonusMap,
          yon,
          initialCStart,
          userStars,
          isOpponent,
          [...jokerIndicesUsed, false],
          boardIsEmpty,
        );
      }

      // Joker wildcard
      if (uniqueChars.contains('*')) {
        final idx = hand.indexOf('*');
        final newHand = hand.substring(0, idx) + hand.substring(idx + 1);
        for (final subChar in harfPuanlari.keys) {
          _extendRight(
            prefix + subChar,
            newHand,
            r,
            cStart,
            board,
            hamleler,
            bonusMap,
            yon,
            initialCStart,
            userStars,
            isOpponent,
            [...jokerIndicesUsed, true],
            boardIsEmpty,
          );
        }
      }
    }
  }

  // ─── Cross-word Validation ────────────────────────────────────────

  bool _checkValidityAndCrossWords(
    String kelime,
    int r,
    int cStart,
    List<List<BoardChar>> board,
    bool boardIsEmpty,
  ) {
    final size = board.length;
    var connects = false;

    if (boardIsEmpty) {
      final center = size ~/ 2;
      if (r == center && cStart <= center && center < cStart + kelime.length) {
        connects = true;
      }
    } else {
      for (var i = 0; i < kelime.length; i++) {
        final c = cStart + i;
        if (board[r][c].isEmpty == false) {
          if (board[r][c].value != kelime[i] && !board[r][c].isJoker) {
            return false;
          }
          connects = true;
          continue;
        }
        if ((r > 0 && board[r - 1][c].isEmpty == false) ||
            (r < size - 1 && board[r + 1][c].isEmpty == false) ||
            (c > 0 && board[r][c - 1].isEmpty == false) ||
            (c < size - 1 && board[r][c + 1].isEmpty == false)) {
          connects = true;
        }
      }
    }

    if (!connects) return false;

    for (var i = 0; i < kelime.length; i++) {
      final c = cStart + i;
      if (board[r][c].isEmpty) {
        final buf = StringBuffer(kelime[i]);
        var currR = r - 1;
        while (currR >= 0 && board[currR][c].isEmpty == false) {
          buf.write(board[currR][c].value);
          currR--;
        }
        // Reverse the prepended part
        final above = buf.toString().split('').reversed.join();
        final buf2 = StringBuffer(above);
        currR = r + 1;
        while (currR < size && board[currR][c].isEmpty == false) {
          buf2.write(board[currR][c].value);
          currR++;
        }
        final crossWord = buf2.toString();
        if (crossWord.length > 1 && !_words.contains(crossWord)) {
          return false;
        }
      }
    }
    return true;
  }

  // ─── Score Calculation ────────────────────────────────────────────

  _ScoreResult _calculateScore(
    String kelime,
    int r,
    int cStart,
    List<List<BoardChar>> board,
    List<List<String>> bonusMap,
    List<bool> isJokerPlaced,
    Set<(int, int)> userStars,
  ) {
    var totalScore = 0;
    var mainWordScore = 0;
    var mainWordMultiplier = 1;
    var newLettersPlaced = 0;
    var starsHit = 0;
    final bonusesHit = <String>[];

    for (var i = 0; i < kelime.length; i++) {
      final c = cStart + i;
      var charScore = harfPuanlari[kelime[i]] ?? 0;
      final isBoardJoker = board[r][c].isJoker;
      final jokerUsed = i < isJokerPlaced.length && isJokerPlaced[i];
      if (jokerUsed || isBoardJoker) charScore = 0;

      if (board[r][c].isEmpty) {
        newLettersPlaced++;
        if (userStars.contains((r, c))) starsHit++;
        final bonus = bonusMap[r][c];
        if (bonus != '__') bonusesHit.add(bonus);

        if (bonus == 'H2') {
          mainWordScore += charScore * 2;
        } else if (bonus == 'H3') {
          mainWordScore += charScore * 3;
        } else {
          mainWordScore += charScore;
        }

        if (bonus == 'K2' || bonus == 'START') {
          mainWordMultiplier *= 2;
        } else if (bonus == 'K3') {
          mainWordMultiplier *= 3;
        }
      } else {
        mainWordScore += charScore;
      }
    }

    totalScore += mainWordScore * mainWordMultiplier;

    // Cross-word scores
    final size = board.length;
    for (var i = 0; i < kelime.length; i++) {
      final c = cStart + i;
      if (board[r][c].isEmpty) {
        var startR = r;
        while (startR > 0 && board[startR - 1][c].isEmpty == false) {
          startR--;
        }
        var endR = r;
        while (endR < size - 1 && board[endR + 1][c].isEmpty == false) {
          endR++;
        }
        if (startR != endR) {
          var crossScore = 0;
          var crossMultiplier = 1;
          for (var currR = startR; currR <= endR; currR++) {
            final char = currR != r ? board[currR][c].value : kelime[i];
            var cScore = harfPuanlari[char] ?? 0;
            if (currR != r && board[currR][c].isJoker) cScore = 0;
            if (currR == r) {
              final jokerUsed = i < isJokerPlaced.length && isJokerPlaced[i];
              if (jokerUsed) cScore = 0;
              final bonus = bonusMap[r][c];
              if (bonus == 'H2') cScore *= 2;
              if (bonus == 'H3') cScore *= 3;
              if (bonus == 'K2' || bonus == 'START') crossMultiplier *= 2;
              if (bonus == 'K3') crossMultiplier *= 3;
            }
            crossScore += cScore;
          }
          totalScore += crossScore * crossMultiplier;
        }
      }
    }

    // Bingo bonus (all 7 tiles placed)
    if (newLettersPlaced == 7) totalScore += 30;
    // Star bonus
    totalScore += starsHit * 25;

    final bonusStr = bonusesHit.isNotEmpty
        ? (bonusesHit.toSet().toList()..sort()).join('+')
        : '-';

    return _ScoreResult(
      totalScore: totalScore,
      charsUsed: newLettersPlaced,
      bonusInfo: bonusStr,
      starPoints: starsHit * 25,
    );
  }
}

class _ScoreResult {
  final int totalScore;
  final int charsUsed;
  final String bonusInfo;
  final int starPoints;

  const _ScoreResult({
    required this.totalScore,
    required this.charsUsed,
    required this.bonusInfo,
    required this.starPoints,
  });
}

/// Isolate entry point for background solving.
/// Receives a [SolverRequest] and returns a list of [GameMove].
class SolverRequest {
  final Set<String> words;
  final List<List<Map<String, dynamic>>> boardData;
  final String hand;
  final List<List<String>> bonusMap;
  final Set<(int, int)> userStars;
  final bool isOpponent;

  const SolverRequest({
    required this.words,
    required this.boardData,
    required this.hand,
    required this.bonusMap,
    this.userStars = const {},
    this.isOpponent = false,
  });
}

/// Run solver in an isolate-friendly top-level function.
List<GameMove> runSolver(SolverRequest request) {
  final solver = KelimelikSolver();
  solver.setWords(request.words);

  final board = request.boardData
      .map(
        (row) => row
            .map(
              (cell) => BoardChar(
                cell['value'] as String? ?? '',
                isJoker: cell['isJoker'] as bool? ?? false,
              ),
            )
            .toList(),
      )
      .toList();

  return solver.solve(
    board,
    request.hand,
    request.bonusMap,
    userStars: request.userStars,
    isOpponent: request.isOpponent,
  );
}
