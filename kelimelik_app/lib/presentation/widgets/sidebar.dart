import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';

/// shadcn-style sidebar navigation, matching the reference dashboard image.
class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.dividerColor;
    final bgColor = isDark ? KColors.darkCard : KColors.lightCard;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          // Logo / Brand
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'K',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Kelimelik Pro',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
              style: theme.textTheme.bodySmall,
              decoration: InputDecoration(
                hintText: 'Ara...',
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: isDark
                      ? KColors.darkTextSubtle
                      : KColors.lightTextSubtle,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Main navigation
          _SectionLabel('Oyun', theme),
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            index: 0,
            selected: index,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 0,
          ),
          _NavItem(
            icon: Icons.grid_on_rounded,
            label: 'Oyun Tahtası',
            index: 1,
            selected: index,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 1,
          ),
          _NavItem(
            icon: Icons.analytics_outlined,
            label: 'Analiz',
            index: 2,
            selected: index,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
          ),

          const SizedBox(height: 12),
          _SectionLabel('Araçlar', theme),
          _NavItem(
            icon: Icons.book_outlined,
            label: 'Sözlük',
            index: 3,
            selected: index,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
          ),
          _NavItem(
            icon: Icons.swap_horiz_rounded,
            label: 'Harf Değişim',
            index: 4,
            selected: index,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 4,
          ),
          _NavItem(
            icon: Icons.people_outline_rounded,
            label: 'Rakip Analizi',
            index: 5,
            selected: index,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 5,
          ),

          const Spacer(),

          // Settings at bottom
          Divider(color: borderColor, height: 1),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Ayarlar',
            index: 6,
            selected: index,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 6,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _SectionLabel(this.label, this.theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.brightness == Brightness.dark
              ? KColors.darkTextSubtle
              : KColors.lightTextSubtle,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = index == selected;
    final isDark = theme.brightness == Brightness.dark;

    final selectedBg = isDark ? KColors.darkCardHover : KColors.lightCardHover;
    final textColor = isSelected
        ? (isDark ? KColors.darkText : KColors.lightText)
        : (isDark ? KColors.darkTextMuted : KColors.lightTextMuted);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: isSelected ? selectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: selectedBg.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
