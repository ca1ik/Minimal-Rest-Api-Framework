import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';

/// Settings screen — theme, game mode, about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;
    final currentTheme = ref.watch(themeProvider);
    final gameState = ref.watch(gameProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ayarlar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Tema, oyun tipi ve uygulama ayarları',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? KColors.darkTextSubtle : KColors.lightTextSubtle,
            ),
          ),
          const SizedBox(height: 24),

          // Theme Section
          _sectionCard(
            context,
            title: 'Tema',
            icon: Icons.palette_outlined,
            borderColor: borderColor,
            child: Row(
              children: [
                _themeOption(
                  context,
                  ref,
                  mode: AppThemeMode.dark,
                  label: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  color: const Color(0xFF3B82F6),
                  isSelected: currentTheme == AppThemeMode.dark,
                ),
                const SizedBox(width: 12),
                _themeOption(
                  context,
                  ref,
                  mode: AppThemeMode.light,
                  label: 'Light',
                  icon: Icons.light_mode_rounded,
                  color: const Color(0xFFF97316),
                  isSelected: currentTheme == AppThemeMode.light,
                ),
                const SizedBox(width: 12),
                _themeOption(
                  context,
                  ref,
                  mode: AppThemeMode.emerald,
                  label: 'Emerald',
                  icon: Icons.terminal_rounded,
                  color: const Color(0xFF22C55E),
                  isSelected: currentTheme == AppThemeMode.emerald,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Game Type Section
          _sectionCard(
            context,
            title: 'Oyun Tipi',
            icon: Icons.grid_4x4_rounded,
            borderColor: borderColor,
            child: Row(
              children: [
                _gameTypeOption(
                  context,
                  ref,
                  type: GameType.klasik,
                  label: 'Klasik (15×15)',
                  description: 'Standart Kelimelik tahtası',
                  isSelected: gameState.gameType == GameType.klasik,
                ),
                const SizedBox(width: 12),
                _gameTypeOption(
                  context,
                  ref,
                  type: GameType.beslik,
                  label: '5\'lik (9×9)',
                  description: 'Hızlı oyun modu',
                  isSelected: gameState.gameType == GameType.beslik,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About Section
          _sectionCard(
            context,
            title: 'Hakkında',
            icon: Icons.info_outline_rounded,
            borderColor: borderColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(context, 'Uygulama', 'Kelimelik Solver'),
                _infoRow(context, 'Sürüm', '2.0.0'),
                _infoRow(context, 'Platform', 'Flutter Desktop'),
                _infoRow(context, 'Motor', 'Trie + Prefix Optimization'),
                const SizedBox(height: 8),
                Text(
                  'Kelimelik (Scrabble) oyunu için gelişmiş hamle bulucu. '
                  'Tüm geçerli hamleleri hesaplar ve puan sırasına göre listeler.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? KColors.darkTextSubtle
                        : KColors.lightTextSubtle,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Keyboard shortcuts
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? KColors.darkCard : KColors.lightCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kısayol Tuşları',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _shortcut(context, 'F5', 'Hamle Bul'),
                    _shortcut(context, 'Ctrl+Del', 'Sıfırla'),
                    _shortcut(context, 'Ctrl+Enter', 'Oyna'),
                    _shortcut(context, 'Arrows', 'Gezin'),
                    _shortcut(context, 'Delete', 'Harf Sil'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color borderColor,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
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
                icon,
                size: 16,
                color: isDark ? KColors.darkTextMuted : KColors.lightTextMuted,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _themeOption(
    BuildContext context,
    WidgetRef ref, {
    required AppThemeMode mode,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(themeProvider.notifier).state = mode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : (isDark ? KColors.darkCardHover : KColors.lightCardHover),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: isSelected ? color : null),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? color : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameTypeOption(
    BuildContext context,
    WidgetRef ref, {
    required GameType type,
    required String label,
    required String description,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? KColors.darkAccent : KColors.lightAccent;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(gameProvider.notifier).setGameType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.08)
                : (isDark ? KColors.darkCardHover : KColors.lightCardHover),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? accent : Colors.transparent,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: isSelected ? accent : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? KColors.darkTextSubtle
                      : KColors.lightTextSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? KColors.darkTextSubtle
                    : KColors.lightTextSubtle,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcut(BuildContext context, String key, String desc) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark ? KColors.darkCardHover : KColors.lightCardHover,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDark ? KColors.darkBorder : KColors.lightBorder,
            ),
          ),
          child: Text(
            key,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(desc, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
