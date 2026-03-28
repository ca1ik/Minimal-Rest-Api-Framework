import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../widgets/stats_card.dart';

/// Analytics screen — score distribution, letter Usage, move patterns.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;
    final gameState = ref.watch(gameProvider);
    final moves = gameState.moves;

    // Compute analytics
    final avgScore = moves.isEmpty
        ? 0.0
        : moves.fold<int>(0, (s, m) => s + m.score) / moves.length;
    final maxScore = moves.isEmpty ? 0 : moves.first.score;
    final horizontalCount = moves.where((m) => m.direction == 'yatay').length;
    final verticalCount = moves.where((m) => m.direction == 'dikey').length;
    final avgWordLen = moves.isEmpty
        ? 0.0
        : moves.fold<int>(0, (s, m) => s + m.word.length) / moves.length;

    // Score distribution buckets
    final buckets = <String, int>{};
    for (final m in moves) {
      final bucket = '${(m.score ~/ 10) * 10}-${(m.score ~/ 10) * 10 + 9}';
      buckets[bucket] = (buckets[bucket] ?? 0) + 1;
    }
    final sortedBuckets = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Letter frequency in found moves
    final letterFreq = <String, int>{};
    for (final m in moves) {
      for (final ch in m.word.split('')) {
        letterFreq[ch] = (letterFreq[ch] ?? 0) + 1;
      }
    }
    final sortedLetters = letterFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.analytics,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            S.analyticsSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? KColors.darkTextSubtle : KColors.lightTextSubtle,
            ),
          ),
          const SizedBox(height: 16),

          // Stat cards row
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: S.totalMoves,
                  value: '${moves.length}',
                  subtitle: S.allFoundMoves,
                  icon: Icons.layers_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: S.highestScore,
                  value: '$maxScore',
                  subtitle: S.points,
                  icon: Icons.emoji_events_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: S.avgScore,
                  value: avgScore.toStringAsFixed(1),
                  subtitle: S.perMove,
                  icon: Icons.analytics_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: S.avgWordLength,
                  value: avgWordLen.toStringAsFixed(1),
                  subtitle: S.letters,
                  icon: Icons.text_fields_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Charts row
          Expanded(
            child: Row(
              children: [
                // Score distribution bar chart
                Expanded(
                  flex: 3,
                  child: _chartCard(
                    context,
                    title: S.scoreDistribution,
                    borderColor: borderColor,
                    child: moves.isEmpty
                        ? _emptyState(context, S.noMovesFound)
                        : Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 16,
                              top: 16,
                              bottom: 8,
                            ),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY:
                                    (sortedBuckets.fold<int>(
                                              0,
                                              (max, e) =>
                                                  e.value > max ? e.value : max,
                                            ) *
                                            1.2)
                                        .toDouble(),
                                barTouchData: BarTouchData(enabled: true),
                                titlesData: FlTitlesData(
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx < 0 ||
                                            idx >= sortedBuckets.length) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Text(
                                            sortedBuckets[idx].key,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(fontSize: 9),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                      getTitlesWidget: (value, meta) => Text(
                                        value.toInt().toString(),
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (_) => FlLine(
                                    color: borderColor.withValues(alpha: 0.5),
                                    strokeWidth: 0.5,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(
                                  sortedBuckets.length,
                                  (i) => BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: sortedBuckets[i].value.toDouble(),
                                        width: 16,
                                        borderRadius: BorderRadius.circular(4),
                                        color: KColors.darkAccent,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Direction pie + letter freq
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Direction pie
                      Expanded(
                        child: _chartCard(
                          context,
                          title: S.directionDist,
                          borderColor: borderColor,
                          child: moves.isEmpty
                              ? _emptyState(context, S.noData)
                              : Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 30,
                                      sections: [
                                        PieChartSectionData(
                                          value: horizontalCount.toDouble(),
                                          title:
                                              '${S.horizontal}\n$horizontalCount',
                                          color: KColors.darkAccentBlue,
                                          radius: 40,
                                          titleStyle: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                        ),
                                        PieChartSectionData(
                                          value: verticalCount.toDouble(),
                                          title:
                                              '${S.vertical}\n$verticalCount',
                                          color: KColors.darkAccentGreen,
                                          radius: 40,
                                          titleStyle: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Top letters
                      Expanded(
                        child: _chartCard(
                          context,
                          title: S.mostUsedLetters,
                          borderColor: borderColor,
                          child: sortedLetters.isEmpty
                              ? _emptyState(context, S.noData)
                              : ListView.builder(
                                  itemCount: sortedLetters.length.clamp(0, 10),
                                  padding: const EdgeInsets.all(8),
                                  itemBuilder: (_, i) {
                                    final entry = sortedLetters[i];
                                    final maxFreq = sortedLetters.first.value;
                                    final pct = entry.value / maxFreq;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            child: Text(
                                              entry.key,
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: pct,
                                              backgroundColor: borderColor
                                                  .withValues(alpha: 0.3),
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    KColors.darkAccent,
                                                  ),
                                              minHeight: 14,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 30,
                                            child: Text(
                                              '${entry.value}',
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard(
    BuildContext context, {
    required String title,
    required Color borderColor,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? KColors.darkCard : KColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? KColors.darkTextSubtle : KColors.lightTextSubtle,
        ),
      ),
    );
  }
}
