import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/board_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/turkish_string.dart';
import '../providers/game_provider.dart';

/// Remaining letters grid widget, showing counts per letter.
class RemainingLettersWidget extends ConsumerWidget {
  const RemainingLettersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final remaining = gameState.remainingLetters;
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;
    final cardBg = isDark ? KColors.darkCard : KColors.lightCard;

    final isTr = S.currentLanguage == AppLanguage.tr;
    String toUpper(String s) => isTr ? turkceUpper(s) : s.toUpperCase();
    String toLower(String s) => isTr ? turkceLower(s) : s.toLowerCase();

    final orderedLetters = [...activeAlphabet.map((l) => toUpper(l)), '*'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                S.remainingLetters,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${gameState.totalRemainingLetters}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: orderedLetters.map((letter) {
              final count = (remaining[letter] ?? 0).clamp(0, 99);
              final score = letter == '*'
                  ? 0
                  : activeLetterScores[toLower(letter)] ?? 0;
              final isZero = count == 0;

              return Container(
                width: 52,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: isZero
                      ? (isDark
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.05))
                      : (isDark
                            ? KColors.darkCardHover
                            : KColors.lightCardHover),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isZero
                        ? Colors.red.withValues(alpha: 0.3)
                        : borderColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      letter,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isZero
                            ? (isDark
                                  ? KColors.darkAccentRed
                                  : KColors.lightAccentRed)
                            : null,
                        decoration: isZero ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$count',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isZero
                                ? (isDark
                                      ? KColors.darkAccentRed
                                      : KColors.lightAccentRed)
                                : theme.colorScheme.primary,
                            fontSize: 10,
                          ),
                        ),
                        if (score > 0) ...[
                          const SizedBox(width: 3),
                          Text(
                            '($score)',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 8,
                              color: isDark
                                  ? KColors.darkTextSubtle
                                  : KColors.lightTextSubtle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
