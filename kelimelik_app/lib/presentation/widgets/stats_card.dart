import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// shadcn-style stats card, matching the reference dashboard.
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? trendColor;
  final String? badge;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.trendColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? KColors.darkCard : KColors.lightCard;
    final borderColor = isDark ? KColors.darkBorder : KColors.lightBorder;
    final mutedColor = isDark ? KColors.darkTextMuted : KColors.lightTextMuted;

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
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: (trendColor ?? KColors.darkAccentGreen).withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 12,
                        color: trendColor ?? KColors.darkAccentGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        badge!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: trendColor ?? KColors.darkAccentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 14, color: mutedColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: mutedColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
