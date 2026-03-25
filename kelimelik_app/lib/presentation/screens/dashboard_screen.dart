import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../widgets/stats_card.dart';

/// Dashboard screen matching the shadcn/ui reference image.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalWords = ref.watch(totalWordsProvider);
    final movesFound = ref.watch(movesFoundProvider);
    final bestScore = ref.watch(bestScoreProvider);
    final gameState = ref.watch(gameProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Dashboard',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelimelik Pro oyun istatistiklerin',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? KColors.darkTextMuted : KColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 20),

          // Stats Cards Row
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Sözlük Boyutu',
                  value: _formatNumber(totalWords),
                  subtitle: 'Toplam Türkçe kelime',
                  icon: Icons.menu_book_rounded,
                  badge: 'Aktif',
                  trendColor: KColors.darkAccentGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Bulunan Hamleler',
                  value: '$movesFound',
                  subtitle: 'Son arama sonucu',
                  icon: Icons.search_rounded,
                  badge: movesFound > 0 ? '+$movesFound' : null,
                  trendColor: KColors.darkAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'En Yüksek Puan',
                  value: '$bestScore',
                  subtitle: 'Mevcut tahtadaki en iyi hamle',
                  icon: Icons.emoji_events_rounded,
                  badge: bestScore > 50 ? 'Güçlü' : null,
                  trendColor: KColors.darkAccentOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Kalan Harfler',
                  value: '${gameState.totalRemainingLetters}',
                  subtitle: 'Torbada kalan harf sayısı',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart area
          _buildChartCard(context, theme, isDark, gameState),

          const SizedBox(height: 24),

          // Top moves table
          _buildTopMovesCard(context, theme, isDark, gameState),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    GameState gameState,
  ) {
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;
    final cardBg = isDark ? KColors.darkCard : KColors.lightCard;
    final moves = gameState.moves;

    // Build score distribution data
    final scores = moves.take(30).map((m) => m.score.toDouble()).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Puan Dağılımı',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'İlk 30 hamlenin puan grafiği',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? KColors.darkTextMuted : KColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: scores.isEmpty
                ? Center(
                    child: Text(
                      'Hamle bulmak için oyun tahtasına geçin',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? KColors.darkTextSubtle
                            : KColors.lightTextSubtle,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: borderColor.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: scores
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: KColors.darkAccent,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                KColors.darkAccent.withValues(alpha: 0.25),
                                KColors.darkAccent.withValues(alpha: 0.0),
                              ],
                            ),
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

  Widget _buildTopMovesCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    GameState gameState,
  ) {
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;
    final cardBg = isDark ? KColors.darkCard : KColors.lightCard;
    final mutedColor = isDark ? KColors.darkTextMuted : KColors.lightTextMuted;
    final topMoves = gameState.moves.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(20),
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
                'En İyi Hamleler',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'İlk 10',
                style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (topMoves.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Henüz hamle hesaplanmadı',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? KColors.darkTextSubtle
                        : KColors.lightTextSubtle,
                  ),
                ),
              ),
            )
          else
            ...topMoves.asMap().entries.map((entry) {
              final i = entry.key;
              final move = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: i < 3
                            ? KColors.darkAccentOrange.withValues(alpha: 0.15)
                            : (isDark
                                  ? KColors.darkCardHover
                                  : KColors.lightCardHover),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: i < 3
                                ? KColors.darkAccentOrange
                                : mutedColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Text(
                        move.word.toUpperCase(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${move.score} pts',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        move.directionDisplay,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                    ),
                    Text(
                      move.position,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
