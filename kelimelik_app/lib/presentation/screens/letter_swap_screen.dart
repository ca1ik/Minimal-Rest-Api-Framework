import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/board_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';

/// Letter swap analysis screen — shows optimal letter combinations to swap.
class LetterSwapScreen extends ConsumerStatefulWidget {
  const LetterSwapScreen({super.key});

  @override
  ConsumerState<LetterSwapScreen> createState() => _LetterSwapScreenState();
}

class _LetterSwapScreenState extends ConsumerState<LetterSwapScreen> {
  final Set<int> _selectedIndices = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;
    final gameState = ref.watch(gameProvider);
    final hand = gameState.handLetters.toUpperCase();
    final handChars = hand.split('').where((c) => c.trim().isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.letterSwap,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            S.letterSwapSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? KColors.darkTextSubtle : KColors.lightTextSubtle,
            ),
          ),
          const SizedBox(height: 20),

          if (handChars.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.back_hand_outlined,
                      size: 48,
                      color: isDark
                          ? KColors.darkTextSubtle
                          : KColors.lightTextSubtle,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      S.enterHandFirst,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? KColors.darkTextSubtle
                            : KColors.lightTextSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Hand tiles
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
                  Text(
                    S.yourLetters,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.tapToSwap,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? KColors.darkTextSubtle
                          : KColors.lightTextSubtle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(handChars.length, (i) {
                      final ch = handChars[i];
                      final selected = _selectedIndices.contains(i);
                      final score = ch == '*'
                          ? 0
                          : (activeLetterScores[ch.toUpperCase()] ?? 0);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedIndices.remove(i);
                            } else {
                              _selectedIndices.add(i);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: selected
                                ? KColors.darkAccentRed.withValues(alpha: 0.2)
                                : (isDark
                                      ? KColors.darkCardHover
                                      : KColors.lightCardHover),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? KColors.darkAccentRed
                                  : borderColor,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  ch == '*' ? '★' : ch,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: selected
                                        ? KColors.darkAccentRed
                                        : null,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                bottom: 2,
                                child: Text(
                                  '$score',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    color: isDark
                                        ? KColors.darkTextSubtle
                                        : KColors.lightTextSubtle,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: KColors.darkAccentRed,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Analysis
            Expanded(
              child: Container(
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
                        Text(
                          S.swapAnalysis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedIndices.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: KColors.darkAccentRed.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              S.lettersSelected(_selectedIndices.length),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: KColors.darkAccentRed,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_selectedIndices.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            S.selectLettersToSwap,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? KColors.darkTextSubtle
                                  : KColors.lightTextSubtle,
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: _buildSwapAnalysis(
                          context,
                          handChars,
                          _selectedIndices,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwapAnalysis(
    BuildContext context,
    List<String> handChars,
    Set<int> selected,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final remaining = ref.read(gameProvider).remainingLetters;

    // Calculate points being discarded
    int discardedPoints = 0;
    final discardedLetters = <String>[];
    for (final i in selected) {
      final ch = handChars[i].toUpperCase();
      discardedLetters.add(ch);
      discardedPoints += ch == '*' ? 0 : (activeLetterScores[ch] ?? 0);
    }

    // Pool stats
    int totalPoolTiles = remaining.values.fold(0, (s, v) => s + v);
    double avgPoolValue = 0;
    if (totalPoolTiles > 0) {
      int totalPoolPoints = 0;
      for (final e in remaining.entries) {
        totalPoolPoints += (activeLetterScores[e.key] ?? 0) * e.value;
      }
      avgPoolValue = totalPoolPoints / totalPoolTiles;
    }

    return ListView(
      children: [
        _analysisRow(
          context,
          S.discardedLetters,
          discardedLetters.join(', '),
          KColors.darkAccentRed,
        ),
        _analysisRow(
          context,
          S.lostPoints,
          '$discardedPoints ${S.points}',
          KColors.darkAccentOrange,
        ),
        _analysisRow(
          context,
          S.tilesInBag,
          '$totalPoolTiles',
          KColors.darkAccentBlue,
        ),
        _analysisRow(
          context,
          S.bagAvgValue,
          avgPoolValue.toStringAsFixed(1),
          KColors.darkAccentGreen,
        ),
        const SizedBox(height: 16),
        Text(
          S.swapNote(selected.length, avgPoolValue.toStringAsFixed(1)),
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? KColors.darkTextSubtle : KColors.lightTextSubtle,
          ),
        ),
      ],
    );
  }

  Widget _analysisRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? KColors.darkTextMuted : KColors.lightTextMuted,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
