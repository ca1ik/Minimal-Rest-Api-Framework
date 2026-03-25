import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/board_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/turkish_string.dart';
import '../../domain/entities/board_cell.dart';
import '../../domain/entities/game_move.dart';
import '../../engine/kelimelik_solver.dart';

// ─── Theme Provider ─────────────────────────────────────────────────

final themeProvider = StateProvider<AppThemeMode>((ref) => AppThemeMode.dark);

// ─── Navigation Provider ────────────────────────────────────────────

final navigationIndexProvider = StateProvider<int>((ref) => 0);

// ─── Dictionary Provider ────────────────────────────────────────────

final dictionaryProvider = FutureProvider<Set<String>>((ref) async {
  final data = await rootBundle.loadString('Assets/Kelimelik/sozluk.txt');
  return data
      .split('\n')
      .map((line) => turkceLower(line.trim()))
      .where((w) => w.isNotEmpty)
      .toSet();
});

// ─── Search Filter Provider ─────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

// ─── Game Type ──────────────────────────────────────────────────────

enum GameType { klasik, beslik }

// ─── Game State ─────────────────────────────────────────────────────

class GameState {
  final GameType gameType;
  final List<List<BoardCell>> board;
  final String handLetters;
  final List<GameMove> moves;
  final Set<(int, int)> userStars;
  final int? selectedMoveIndex;
  final bool isSolving;
  final String? errorMessage;

  const GameState({
    this.gameType = GameType.klasik,
    required this.board,
    this.handLetters = '',
    this.moves = const [],
    this.userStars = const {},
    this.selectedMoveIndex,
    this.isSolving = false,
    this.errorMessage,
  });

  int get boardSize => gameType == GameType.klasik ? 15 : 9;

  List<List<String>> get bonusMap =>
      gameType == GameType.klasik ? bonusLayoutKlasik : bonusLayout5lik;

  GameState copyWith({
    GameType? gameType,
    List<List<BoardCell>>? board,
    String? handLetters,
    List<GameMove>? moves,
    Set<(int, int)>? userStars,
    int? Function()? selectedMoveIndex,
    bool? isSolving,
    String? Function()? errorMessage,
  }) => GameState(
    gameType: gameType ?? this.gameType,
    board: board ?? this.board,
    handLetters: handLetters ?? this.handLetters,
    moves: moves ?? this.moves,
    userStars: userStars ?? this.userStars,
    selectedMoveIndex: selectedMoveIndex != null
        ? selectedMoveIndex()
        : this.selectedMoveIndex,
    isSolving: isSolving ?? this.isSolving,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  /// Calculate remaining letter counts
  Map<String, int> get remainingLetters {
    final counts = Map<String, int>.from(harfSayilari);
    for (final row in board) {
      for (final cell in row) {
        if (cell.isFilled) {
          final upper = turkceUpper(cell.letter);
          if (cell.isJoker) {
            counts['*'] = (counts['*'] ?? 0) - 1;
          } else if (counts.containsKey(upper)) {
            counts[upper] = (counts[upper] ?? 0) - 1;
          } else {
            counts['*'] = (counts['*'] ?? 0) - 1;
          }
        }
      }
    }
    return counts;
  }

  int get totalRemainingLetters =>
      remainingLetters.values.fold(0, (sum, v) => sum + v.clamp(0, 999));
}

// ─── Game Notifier ──────────────────────────────────────────────────

class GameNotifier extends StateNotifier<GameState> {
  final Ref ref;

  GameNotifier(this.ref, GameType type)
    : super(
        GameState(
          gameType: type,
          board: _emptyBoard(type == GameType.klasik ? 15 : 9),
        ),
      );

  static List<List<BoardCell>> _emptyBoard(int size) =>
      List.generate(size, (_) => List.generate(size, (_) => const BoardCell()));

  // ─── Board Operations ───────────────────────────────────────────

  void setCellLetter(int r, int c, String letter) {
    final newBoard = _cloneBoard();
    newBoard[r][c] = newBoard[r][c].copyWith(letter: letter, isPreview: false);
    state = state.copyWith(board: newBoard);
  }

  void toggleJoker(int r, int c) {
    final newBoard = _cloneBoard();
    newBoard[r][c] = newBoard[r][c].copyWith(isJoker: !newBoard[r][c].isJoker);
    state = state.copyWith(board: newBoard);
  }

  void toggleStar(int r, int c) {
    final newStars = Set<(int, int)>.from(state.userStars);
    if (newStars.contains((r, c))) {
      newStars.remove((r, c));
    } else {
      newStars.add((r, c));
    }
    final newBoard = _cloneBoard();
    newBoard[r][c] = newBoard[r][c].copyWith(
      hasStar: newStars.contains((r, c)),
    );
    state = state.copyWith(board: newBoard, userStars: newStars);
  }

  void setHandLetters(String letters) {
    state = state.copyWith(handLetters: letters);
  }

  void clearBoard() {
    state = state.copyWith(
      board: _emptyBoard(state.boardSize),
      moves: [],
      userStars: {},
      selectedMoveIndex: () => null,
      errorMessage: () => null,
    );
  }

  void setGameType(GameType type) {
    if (type == state.gameType) return;
    final size = type == GameType.klasik ? 15 : 9;
    state = state.copyWith(
      gameType: type,
      board: _emptyBoard(size),
      moves: [],
      userStars: {},
      selectedMoveIndex: () => null,
      errorMessage: () => null,
    );
  }

  void selectMove(int? index) {
    // Clear previous preview
    final newBoard = _cloneBoard();
    for (var r = 0; r < state.boardSize; r++) {
      for (var c = 0; c < state.boardSize; c++) {
        if (newBoard[r][c].isPreview) {
          newBoard[r][c] = newBoard[r][c].copyWith(
            letter: '',
            isPreview: false,
          );
        }
      }
    }

    // Apply new preview
    if (index != null && index < state.moves.length) {
      final move = state.moves[index];
      for (var i = 0; i < move.word.length; i++) {
        final cr = move.direction == 'dikey' ? move.row + i : move.row;
        final cc = move.direction == 'yatay' ? move.col + i : move.col;
        if (cr < state.boardSize &&
            cc < state.boardSize &&
            newBoard[cr][cc].isEmpty) {
          newBoard[cr][cc] = newBoard[cr][cc].copyWith(
            letter: move.word[i],
            isPreview: true,
          );
        }
      }
    }

    state = state.copyWith(board: newBoard, selectedMoveIndex: () => index);
  }

  void playSelectedMove() {
    if (state.selectedMoveIndex == null) return;
    final move = state.moves[state.selectedMoveIndex!];
    final newBoard = _cloneBoard();
    final jokers = move.jokerIndices;

    for (var i = 0; i < move.word.length; i++) {
      final cr = move.direction == 'dikey' ? move.row + i : move.row;
      final cc = move.direction == 'yatay' ? move.col + i : move.col;
      if (cr < state.boardSize && cc < state.boardSize) {
        final isJoker = i < jokers.length && jokers[i];
        newBoard[cr][cc] = BoardCell(
          letter: move.word[i],
          isJoker: isJoker,
          isPreview: false,
          hasStar: newBoard[cr][cc].hasStar,
        );
      }
    }

    state = state.copyWith(
      board: newBoard,
      moves: [],
      selectedMoveIndex: () => null,
    );
  }

  void enterWord(int r, int c, String word, bool horizontal) {
    final newBoard = _cloneBoard();
    final upper = turkceUpper(word);
    for (var i = 0; i < upper.length; i++) {
      final cr = horizontal ? r : r + i;
      final cc = horizontal ? c + i : c;
      if (cr < state.boardSize && cc < state.boardSize) {
        newBoard[cr][cc] = newBoard[cr][cc].copyWith(
          letter: upper[i],
          isPreview: false,
        );
      }
    }
    state = state.copyWith(board: newBoard);
  }

  // ─── Solver ─────────────────────────────────────────────────────

  Future<void> findMoves({bool isOpponent = false}) async {
    final dict = ref.read(dictionaryProvider).valueOrNull;
    if (dict == null || dict.isEmpty) {
      state = state.copyWith(errorMessage: () => 'Sözlük yüklenemedi');
      return;
    }

    String hand;
    if (isOpponent) {
      final counts = state.remainingLetters;
      // Also subtract hand letters from pool
      for (final ch in turkceUpper(state.handLetters).split('')) {
        if (ch == '*') {
          counts['*'] = (counts['*'] ?? 0) - 1;
        } else if (counts.containsKey(ch)) {
          counts[ch] = (counts[ch] ?? 0) - 1;
        }
      }
      final buf = StringBuffer();
      for (final entry in counts.entries) {
        final count = entry.value.clamp(0, 7);
        buf.write(turkceLower(entry.key) * count);
      }
      hand = buf.toString();
    } else {
      hand = turkceLower(state.handLetters.trim());
      if (hand.isEmpty) {
        state = state.copyWith(
          errorMessage: () => 'Lütfen elinizdeki harfleri girin',
        );
        return;
      }
    }

    state = state.copyWith(isSolving: true, errorMessage: () => null);

    try {
      // Build serializable board data
      final boardData = state.board
          .map(
            (row) => row
                .map(
                  (cell) => {
                    'value': cell.isFilled ? turkceLower(cell.letter) : '',
                    'isJoker': cell.isJoker,
                  },
                )
                .toList(),
          )
          .toList();

      final request = SolverRequest(
        words: dict,
        boardData: boardData,
        hand: hand,
        bonusMap: state.bonusMap,
        userStars: state.userStars,
        isOpponent: isOpponent,
      );

      // Run in isolate
      final moves = await Isolate.run(() => runSolver(request));

      state = state.copyWith(
        moves: isOpponent ? moves.take(50).toList() : moves,
        isSolving: false,
        selectedMoveIndex: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isSolving: false,
        errorMessage: () => 'Çözüm hatası: $e',
      );
    }
  }

  List<List<BoardCell>> _cloneBoard() =>
      state.board.map((row) => row.map((c) => c).toList()).toList();
}

// ─── Provider ───────────────────────────────────────────────────────

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref, GameType.klasik);
});

// ─── Stats Providers (Dashboard) ────────────────────────────────────

final totalWordsProvider = Provider<int>((ref) {
  return ref.watch(dictionaryProvider).valueOrNull?.length ?? 0;
});

final movesFoundProvider = Provider<int>((ref) {
  return ref.watch(gameProvider).moves.length;
});

final bestScoreProvider = Provider<int>((ref) {
  final moves = ref.watch(gameProvider).moves;
  return moves.isNotEmpty ? moves.first.score : 0;
});
