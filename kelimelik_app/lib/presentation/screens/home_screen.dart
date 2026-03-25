import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../widgets/ai_chat_widget.dart';
import '../widgets/custom_title_bar.dart';
import '../widgets/sidebar.dart';
import 'analytics_screen.dart';
import 'dashboard_screen.dart';
import 'dictionary_screen.dart';
import 'game_screen.dart';
import 'letter_swap_screen.dart';
import 'opponent_analysis_screen.dart';
import 'settings_screen.dart';

/// Root shell — custom title bar + sidebar + content area + AI chat.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _screens = <Widget>[
    DashboardScreen(), // 0
    GameScreen(), // 1
    AnalyticsScreen(), // 2
    DictionaryScreen(), // 3
    LetterSwapScreen(), // 4
    OpponentAnalysisScreen(), // 5
    SettingsScreen(), // 6
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navigationIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? KColors.darkBg : KColors.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Custom title bar (matches theme)
          const CustomTitleBar(),

          // Main content area
          Expanded(
            child: Stack(
              children: [
                // Sidebar + content
                Row(
                  children: [
                    const AppSidebar(),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: isDark ? KColors.darkBorder : KColors.lightBorder,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: KeyedSubtree(
                          key: ValueKey(index),
                          child: _screens[index.clamp(0, _screens.length - 1)],
                        ),
                      ),
                    ),
                  ],
                ),

                // Background overlay — on top of content, pass-through clicks
                Positioned.fill(
                  child: IgnorePointer(child: _BackgroundImage(isDark: isDark)),
                ),

                // AI Chat floating widget (bottom-right)
                const Positioned(right: 16, bottom: 16, child: AiChatWidget()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Background image widget that loads scrabble_PP4.jpg with high transparency.
class _BackgroundImage extends StatelessWidget {
  final bool isDark;

  const _BackgroundImage({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDark ? 0.10 : 0.14,
      child: Image.asset(
        'Assets/images/scrabble_PP4.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => const SizedBox.shrink(),
      ),
    );
  }
}
