import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// shadcn/ui inspired theme system for Kelimelik Desktop.
/// Mirrors the dark dashboard aesthetic from the reference image.

// ─── Color Tokens ───────────────────────────────────────────────────

class KColors {
  KColors._();

  // Dark theme tokens (shadcn/ui zinc palette)
  static const darkBg = Color(0xFF09090B);
  static const darkCard = Color(0xFF0F0F12);
  static const darkCardHover = Color(0xFF18181B);
  static const darkBorder = Color(0xFF27272A);
  static const darkBorderSubtle = Color(0xFF1F1F23);
  static const darkText = Color(0xFFFAFAFA);
  static const darkTextMuted = Color(0xFFA1A1AA);
  static const darkTextSubtle = Color(0xFF71717A);
  static const darkAccent = Color(0xFF3B82F6); // Blue-500
  static const darkAccentGreen = Color(0xFF22C55E); // Green-500
  static const darkAccentRed = Color(0xFFEF4444); // Red-500
  static const darkAccentOrange = Color(0xFFF97316); // Orange-500
  static const darkAccentPurple = Color(0xFFA855F7); // Purple-500
  static const darkSurface = Color(0xFF131316);
  static const darkInput = Color(0xFF1C1C20);
  static const darkRing = Color(0xFF3B82F6);

  // Light theme tokens
  static const lightBg = Color(0xFFFAFAFA);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardHover = Color(0xFFF4F4F5);
  static const lightBorder = Color(0xFFE4E4E7);
  static const lightBorderSubtle = Color(0xFFF4F4F5);
  static const lightText = Color(0xFF09090B);
  static const lightTextMuted = Color(0xFF71717A);
  static const lightTextSubtle = Color(0xFFA1A1AA);
  static const lightAccent = Color(0xFF2563EB);
  static const lightAccentGreen = Color(0xFF16A34A);
  static const lightAccentRed = Color(0xFFDC2626);
  static const lightAccentOrange = Color(0xFFEA580C);
  static const lightAccentPurple = Color(0xFF9333EA);
  static const lightSurface = Color(0xFFF4F4F5);
  static const lightInput = Color(0xFFFFFFFF);
  static const lightRing = Color(0xFF2563EB);

  // Board-specific colors (consistent across themes)
  static const boardK3 = Color(0xFFE74C3C);
  static const boardK2 = Color(0xFFE67E22);
  static const boardH3 = Color(0xFF3498DB);
  static const boardH2 = Color(0xFF1ABC9C);
  static const boardStart = Color(0xFFF1C40F);
  static const boardFilled = Color(0xFFEACB7A);
  static const boardFilledText = Color(0xFF2C3E50);
  static const boardPreview = Color(0xFF9B59B6);
  static const boardStar = Color(0xFFF39C12);
  static const boardJokerBorder = Color(0xFFE74C3C);

  // Emerald theme (Hacker mode)
  static const emeraldBg = Color(0xFF021a0a);
  static const emeraldCard = Color(0xFF03210d);
  static const emeraldBorder = Color(0xFF064e23);
  static const emeraldText = Color(0xFF4ade80);
  static const emeraldTextMuted = Color(0xFF16a34a);
  static const emeraldAccent = Color(0xFF22c55e);
}

// ─── Theme Data Builders ────────────────────────────────────────────

enum AppThemeMode { dark, light, emerald }

class AppTheme {
  AppTheme._();

  static ThemeData build(AppThemeMode mode) => switch (mode) {
    AppThemeMode.dark => _buildDark(),
    AppThemeMode.light => _buildLight(),
    AppThemeMode.emerald => _buildEmerald(),
  };

  static ThemeData _buildDark() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: KColors.darkBg,
      canvasColor: KColors.darkBg,
      cardColor: KColors.darkCard,
      dividerColor: KColors.darkBorder,
      textTheme: textTheme.apply(
        bodyColor: KColors.darkText,
        displayColor: KColors.darkText,
      ),
      colorScheme: const ColorScheme.dark(
        surface: KColors.darkCard,
        primary: KColors.darkAccent,
        secondary: KColors.darkAccentPurple,
        error: KColors.darkAccentRed,
        onSurface: KColors.darkText,
        outline: KColors.darkBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: KColors.darkBg,
        foregroundColor: KColors.darkText,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KColors.darkInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KColors.darkRing, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: KColors.darkTextSubtle,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KColors.darkAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          KColors.darkTextSubtle.withValues(alpha: 0.3),
        ),
        radius: const Radius.circular(4),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: KColors.darkCardHover,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: KColors.darkBorder),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: KColors.darkText),
      ),
    );
  }

  static ThemeData _buildLight() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: KColors.lightBg,
      canvasColor: KColors.lightBg,
      cardColor: KColors.lightCard,
      dividerColor: KColors.lightBorder,
      textTheme: textTheme.apply(
        bodyColor: KColors.lightText,
        displayColor: KColors.lightText,
      ),
      colorScheme: const ColorScheme.light(
        surface: KColors.lightCard,
        primary: KColors.lightAccent,
        secondary: KColors.lightAccentPurple,
        error: KColors.lightAccentRed,
        onSurface: KColors.lightText,
        outline: KColors.lightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: KColors.lightBg,
        foregroundColor: KColors.lightText,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KColors.lightInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KColors.lightRing, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: KColors.lightTextSubtle,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KColors.lightAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  static ThemeData _buildEmerald() {
    final textTheme = GoogleFonts.jetBrainsMonoTextTheme(
      ThemeData.dark().textTheme,
    );
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: KColors.emeraldBg,
      canvasColor: KColors.emeraldBg,
      cardColor: KColors.emeraldCard,
      dividerColor: KColors.emeraldBorder,
      textTheme: textTheme.apply(
        bodyColor: KColors.emeraldText,
        displayColor: KColors.emeraldText,
      ),
      colorScheme: const ColorScheme.dark(
        surface: KColors.emeraldCard,
        primary: KColors.emeraldAccent,
        secondary: KColors.emeraldAccent,
        onSurface: KColors.emeraldText,
        outline: KColors.emeraldBorder,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KColors.emeraldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KColors.emeraldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KColors.emeraldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KColors.emeraldAccent, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: KColors.emeraldTextMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KColors.emeraldAccent,
          foregroundColor: KColors.emeraldBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
