import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';

/// Opponent analysis screen — shows what moves the opponent could make.
class OpponentAnalysisScreen extends ConsumerWidget {
  const OpponentAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;
    final gameState = ref.watch(gameProvider);
    final remaining = gameState.remainingLetters;
    final totalRemaining = remaining.values.fold<int>(0, (s, v) => s + v);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.opponentAnalysis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            S.opponentSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? KColors.darkTextSubtle : KColors.lightTextSubtle,
            ),
          ),
          const SizedBox(height: 20),

          // Remaining tiles overview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? KColors.darkCard : KColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 18,
                      color: isDark
                          ? KColors.darkTextMuted
                          : KColors.lightTextMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      S.bagStatus,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: KColors.darkAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        S.tilesRemaining(totalRemaining),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: KColors.darkAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: remaining.entries
                      .where((e) => e.value > 0)
                      .map((e) => _tileBadge(context, e.key, e.value))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: gameState.isSolving
                  ? null
                  : () => ref
                        .read(gameProvider.notifier)
                        .findMoves(isOpponent: true),
              icon: gameState.isSolving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search_rounded, size: 18),
              label: Text(
                gameState.isSolving ? S.calculating : S.findOpponentMoves,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Results
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? KColors.darkCard : KColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: gameState.moves.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 48,
                            color: isDark
                                ? KColors.darkTextSubtle
                                : KColors.lightTextSubtle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            S.runOpponentAnalysis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? KColors.darkTextSubtle
                                  : KColors.lightTextSubtle,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Text(
                                S.possibleOpponentMoves,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                S.bestNMoves(gameState.moves.length),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark
                                      ? KColors.darkTextSubtle
                                      : KColors.lightTextSubtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: gameState.moves.length,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemBuilder: (_, i) {
                              final move = gameState.moves[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                decoration: BoxDecoration(
                                  color: i.isEven
                                      ? Colors.transparent
                                      : (isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.02,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.02,
                                              )),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: _threatColor(
                                      move.score,
                                    ).withValues(alpha: 0.15),
                                    child: Text(
                                      '${i + 1}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: _threatColor(move.score),
                                          ),
                                    ),
                                  ),
                                  title: Text(
                                    move.word,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${move.position} • ${move.directionDisplay}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? KColors.darkTextSubtle
                                          : KColors.lightTextSubtle,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _threatColor(
                                        move.score,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${move.score}',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: _threatColor(move.score),
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tileBadge(BuildContext context, String letter, int count) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? KColors.darkCardHover : KColors.lightCardHover,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? KColors.darkBorder : KColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            letter == '*' ? '★' : letter,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '×$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? KColors.darkTextSubtle : KColors.lightTextSubtle,
            ),
          ),
        ],
      ),
    );
  }

  Color _threatColor(int score) {
    if (score >= 40) return KColors.darkAccentRed;
    if (score >= 20) return KColors.darkAccentOrange;
    return KColors.darkAccentGreen;
  }
}
