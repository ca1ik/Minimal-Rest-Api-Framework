import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';

/// Custom title bar that matches the app theme.
/// Replaces the system white title bar with a theme-colored one.
class CustomTitleBar extends ConsumerWidget {
  const CustomTitleBar({super.key});

  static const double height = 36;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);

    final Color bgColor;
    final Color textColor;
    final Color iconColor;
    final Color borderColor;

    switch (themeMode) {
      case AppThemeMode.dark:
        bgColor = KColors.darkBg;
        textColor = KColors.darkTextMuted;
        iconColor = KColors.darkTextSubtle;
        borderColor = KColors.darkBorder;
      case AppThemeMode.light:
        bgColor = KColors.lightBg;
        textColor = KColors.lightTextMuted;
        iconColor = KColors.lightTextSubtle;
        borderColor = KColors.lightBorder;
      case AppThemeMode.emerald:
        bgColor = KColors.emeraldBg;
        textColor = KColors.emeraldTextMuted;
        iconColor = KColors.emeraldTextMuted;
        borderColor = KColors.emeraldBorder;
    }

    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      onDoubleTap: () async {
        if (await windowManager.isMaximized()) {
          await windowManager.unmaximize();
        } else {
          await windowManager.maximize();
        }
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            // App icon
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'K',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              S.appTitle,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Expanded(child: SizedBox.shrink()),
            // Window controls
            _WindowButton(
              icon: Icons.remove,
              iconColor: iconColor,
              hoverColor: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.08,
              ),
              onTap: () => windowManager.minimize(),
            ),
            _WindowButton(
              icon: Icons.crop_square,
              iconColor: iconColor,
              hoverColor: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.08,
              ),
              onTap: () async {
                if (await windowManager.isMaximized()) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
            ),
            _WindowButton(
              icon: Icons.close,
              iconColor: iconColor,
              hoverColor: const Color(0xFFE81123),
              hoverIconColor: Colors.white,
              onTap: () => windowManager.close(),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color hoverColor;
  final Color? hoverIconColor;
  final VoidCallback onTap;

  const _WindowButton({
    required this.icon,
    required this.iconColor,
    required this.hoverColor,
    this.hoverIconColor,
    required this.onTap,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 46,
          height: CustomTitleBar.height,
          color: _hovering ? widget.hoverColor : Colors.transparent,
          child: Icon(
            widget.icon,
            size: 16,
            color: _hovering
                ? (widget.hoverIconColor ?? widget.iconColor)
                : widget.iconColor,
          ),
        ),
      ),
    );
  }
}
