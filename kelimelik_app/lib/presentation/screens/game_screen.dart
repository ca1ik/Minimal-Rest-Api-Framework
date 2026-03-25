import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../widgets/board_widget.dart';
import '../widgets/remaining_letters.dart';
import '../widgets/results_table.dart';

/// Main game screen with board, controls, and results.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final _handController = TextEditingController();

  @override
  void dispose() {
    _handController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gameState = ref.watch(gameProvider);
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f5): () =>
            ref.read(gameProvider.notifier).findMoves(),
        const SingleActivator(LogicalKeyboardKey.delete, control: true): () =>
            ref.read(gameProvider.notifier).clearBoard(),
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
            ref.read(gameProvider.notifier).playSelectedMove(),
      },
      child: Focus(
        autofocus: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Board
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title bar
                    Row(
                      children: [
                        Text(
                          'Oyun Tahtası',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        _chipButton(
                          context,
                          label: gameState.gameType == GameType.klasik
                              ? '15×15 Klasik'
                              : '9×9 5\'lik',
                          icon: Icons.grid_4x4_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Board
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? KColors.darkCard
                                  : KColors.lightCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const GameBoardWidget(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Right: Controls + Results
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    // Hand input
                    Container(
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
                            'Elimdeki Harfler',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Joker için * kullanın',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? KColors.darkTextSubtle
                                  : KColors.lightTextSubtle,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _handController,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Harfleri girin...',
                              prefixIcon: Icon(Icons.keyboard_rounded),
                            ),
                            onChanged: (v) => ref
                                .read(gameProvider.notifier)
                                .setHandLetters(v),
                            onSubmitted: (_) =>
                                ref.read(gameProvider.notifier).findMoves(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: gameState.isSolving
                                      ? null
                                      : () => ref
                                            .read(gameProvider.notifier)
                                            .findMoves(),
                                  icon: gameState.isSolving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.rocket_launch_rounded,
                                          size: 18,
                                        ),
                                  label: Text(
                                    gameState.isSolving
                                        ? 'Hesaplanıyor...'
                                        : 'Hamle Bul',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _iconButton(
                                context,
                                icon: Icons.people_outline,
                                tooltip: 'Rakip Analizi (F6)',
                                color: KColors.darkAccentGreen,
                                onTap: gameState.isSolving
                                    ? null
                                    : () => ref
                                          .read(gameProvider.notifier)
                                          .findMoves(isOpponent: true),
                              ),
                              const SizedBox(width: 8),
                              _iconButton(
                                context,
                                icon: Icons.delete_outline,
                                tooltip: 'Tahtayı Sıfırla (Ctrl+Del)',
                                color: KColors.darkAccentRed,
                                onTap: () => ref
                                    .read(gameProvider.notifier)
                                    .clearBoard(),
                              ),
                            ],
                          ),
                          if (gameState.selectedMoveIndex != null) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => ref
                                    .read(gameProvider.notifier)
                                    .playSelectedMove(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KColors.darkAccentGreen,
                                ),
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                ),
                                label: const Text('Seçili Hamleyi Oyna'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Error message
                    if (gameState.errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: KColors.darkAccentRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: KColors.darkAccentRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          gameState.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: KColors.darkAccentRed,
                          ),
                        ),
                      ),

                    // Results table
                    const Expanded(child: ResultsTable()),

                    const SizedBox(height: 6),

                    // Remaining letters
                    const RemainingLettersWidget(),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipButton(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? KColors.darkCardHover : KColors.lightCardHover,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? KColors.darkBorder : KColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? KColors.darkTextMuted : KColors.lightTextMuted,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
