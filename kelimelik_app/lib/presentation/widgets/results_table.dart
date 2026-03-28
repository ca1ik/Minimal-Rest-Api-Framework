import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/turkish_string.dart';
import '../../domain/entities/game_move.dart';
import '../providers/game_provider.dart';

/// shadcn-style results table with sortable columns.
class ResultsTable extends ConsumerStatefulWidget {
  const ResultsTable({super.key});

  @override
  ConsumerState<ResultsTable> createState() => _ResultsTableState();
}

class _ResultsTableState extends ConsumerState<ResultsTable> {
  int _sortColumnIndex = 1; // default sort by score
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;
    final cardBg = isDark ? KColors.darkCard : KColors.lightCard;

    final moves = List<GameMove>.from(gameState.moves);
    _sortMoves(moves);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(
                  S.results,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${moves.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                if (gameState.isSolving)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Divider(color: borderColor, height: 1),

          // Column headers
          _buildColumnHeaders(theme, isDark, borderColor),
          Divider(color: borderColor, height: 1),

          // Data rows
          Expanded(
            child: moves.isEmpty
                ? Center(
                    child: Text(
                      gameState.isSolving
                          ? S.calculating
                          : S.enterLettersToFind,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? KColors.darkTextSubtle
                            : KColors.lightTextSubtle,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: moves.length,
                    itemBuilder: (context, index) => _buildRow(
                      context,
                      theme,
                      isDark,
                      borderColor,
                      moves[index],
                      index,
                      gameState.selectedMoveIndex ==
                          gameState.moves.indexOf(moves[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders(ThemeData theme, bool isDark, Color borderColor) {
    final headerStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: isDark ? KColors.darkTextMuted : KColors.lightTextMuted,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _sortableHeader(S.colWord, 0, headerStyle, flex: 3),
          _sortableHeader(S.colScore, 1, headerStyle, flex: 2),
          _sortableHeader(S.colDirection, 2, headerStyle, flex: 1),
          _sortableHeader(S.colLetters, 3, headerStyle, flex: 1),
          _sortableHeader(S.colBonus, 4, headerStyle, flex: 2),
        ],
      ),
    );
  }

  Widget _sortableHeader(
    String label,
    int index,
    TextStyle? style, {
    int flex = 1,
  }) {
    final isActive = _sortColumnIndex == index;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => setState(() {
          if (_sortColumnIndex == index) {
            _sortAscending = !_sortAscending;
          } else {
            _sortColumnIndex = index;
            _sortAscending = false;
          }
        }),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: style),
            if (isActive)
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: style?.color,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Color borderColor,
    GameMove move,
    int displayIndex,
    bool isSelected,
  ) {
    final originalIndex = ref.read(gameProvider).moves.indexOf(move);
    final starColor = const Color(0xFFF1C40F);
    final bonusColor = move.bonusInfo != '-' ? starColor : null;

    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).selectMove(originalIndex),
      onDoubleTap: () {
        ref.read(gameProvider.notifier).selectMove(originalIndex);
        ref.read(gameProvider.notifier).playSelectedMove();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? KColors.darkAccent.withValues(alpha: 0.15)
                    : KColors.lightAccent.withValues(alpha: 0.1))
              : (displayIndex.isEven
                    ? Colors.transparent
                    : (isDark
                          ? KColors.darkBg.withValues(alpha: 0.3)
                          : KColors.lightBorderSubtle.withValues(alpha: 0.3))),
          border: Border(
            bottom: BorderSide(color: borderColor.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          children: [
            // Word
            Expanded(
              flex: 3,
              child: Text(
                turkceUpper(move.word),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Score
            Expanded(
              flex: 2,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${move.score}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: move.starBonus > 0 ? starColor : null,
                      ),
                    ),
                    if (move.starBonus > 0)
                      TextSpan(
                        text: ' ★',
                        style: TextStyle(color: starColor, fontSize: 11),
                      ),
                  ],
                ),
              ),
            ),
            // Direction
            Expanded(
              flex: 1,
              child: Text(
                move.directionDisplay,
                style: theme.textTheme.bodySmall,
              ),
            ),
            // Letters used
            Expanded(
              flex: 1,
              child: Text(
                '${move.lettersUsed}',
                style: theme.textTheme.bodySmall,
              ),
            ),
            // Bonus
            Expanded(
              flex: 2,
              child: Text(
                move.bonusInfo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: bonusColor,
                  fontWeight: bonusColor != null ? FontWeight.w700 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sortMoves(List<GameMove> moves) {
    final multiplier = _sortAscending ? 1 : -1;
    moves.sort((a, b) {
      return multiplier *
          switch (_sortColumnIndex) {
            0 => a.word.compareTo(b.word),
            1 => a.score.compareTo(b.score),
            2 => a.direction.compareTo(b.direction),
            3 => a.lettersUsed.compareTo(b.lettersUsed),
            4 => a.bonusInfo.compareTo(b.bonusInfo),
            _ => 0,
          };
    });
  }
}
