import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared color tokens for Finance AI (from the splash visual system).
abstract final class AppColors {
  static const backgroundDeep = Color(0xFF07090F);
  static const background = Color(0xFF0A0E1A);
  static const backgroundMid = Color(0xFF0F1A15);
  static const surface = Color(0xFF121A22);
  static const surfaceElevated = Color(0xFF18242E);

  static const primary = Color(0xFF2FE6A0);
  static const primarySoft = Color(0xFF5CF2C0);
  static const primaryDark = Color(0xFF279D6E);
  static const primaryMuted = Color(0xFF22694F);
  static const ring = Color(0xFF1B4C3C);

  static const ink = Color(0xFFEAFFF6);
  static const muted = Color(0xFF7FA593);
  static const onPrimary = Color(0xFF062016);
  static const error = Color(0xFFFF6B7A);
  static const outline = Color(0xFF2A3D36);

  static const barColors = [
    Color(0xFF173B2E),
    Color(0xFF1D5342),
    Color(0xFF22694F),
    Color(0xFF279D6E),
    Color(0xFF2FE6A0),
  ];

  static const splashGradient = RadialGradient(
    center: Alignment(0, -0.15),
    radius: 0.9,
    colors: [backgroundMid, background, backgroundDeep],
    stops: [0.0, 0.55, 1.0],
  );
}

/// App-wide Material theme built on [AppColors].
abstract final class AppTheme {
  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryMuted,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.primarySoft,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: AppColors.primaryDark,
      onSecondaryContainer: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
      error: AppColors.error,
      onError: AppColors.ink,
      outline: AppColors.outline,
      outlineVariant: AppColors.ring,
      scrim: AppColors.backgroundDeep,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.outline,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.backgroundDeep,
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primarySoft,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        hintStyle: const TextStyle(color: AppColors.muted),
        labelStyle: const TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.ring,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: AppColors.ink),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
      primaryIconTheme: const IconThemeData(color: AppColors.onPrimary),
      textTheme: _textTheme,
      primaryTextTheme: _textTheme,
    );
  }

  static const _textTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
    displayMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
    displaySmall: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
    headlineLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(color: AppColors.ink),
    bodyMedium: TextStyle(color: AppColors.ink),
    bodySmall: TextStyle(color: AppColors.muted),
    labelLarge: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(
      color: AppColors.muted,
      fontWeight: FontWeight.w500,
      letterSpacing: 2.2,
    ),
  );
}
