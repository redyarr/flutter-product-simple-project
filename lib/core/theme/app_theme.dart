import 'package:flutter/material.dart';
import 'package:flutter_testapp/core/theme/app_colors.dart';
import 'package:flutter_testapp/core/theme/app_radius.dart';
import 'package:flutter_testapp/core/theme/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.indigoPrimary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.indigoContainerLight,
    onPrimaryContainer: AppColors.indigoOnContainerLight,
    secondary: AppColors.lightSecondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.lightSurfaceContainer,
    onSecondaryContainer: AppColors.lightOnSurface,
    tertiary: AppColors.amberTint,
    onTertiary: AppColors.slateInk,
    error: AppColors.lightError,
    onError: AppColors.white,
    errorContainer: AppColors.lightErrorContainer,
    onErrorContainer: AppColors.lightOnErrorContainer,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
    surfaceContainer: AppColors.lightSurfaceContainer,
    surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
    outline: AppColors.lightOnSurfaceVariant,
    outlineVariant: AppColors.lightOutlineVariant,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.indigoLightAccent,
    onPrimary: AppColors.slateInk,
    primaryContainer: AppColors.indigoContainerDark,
    onPrimaryContainer: AppColors.indigoOnContainerDark,
    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.slateInk,
    secondaryContainer: AppColors.darkSurfaceContainer,
    onSecondaryContainer: AppColors.darkOnSurface,
    tertiary: AppColors.amberTint,
    onTertiary: AppColors.slateInk,
    error: AppColors.darkError,
    onError: AppColors.slateInk,
    errorContainer: AppColors.darkErrorContainer,
    onErrorContainer: AppColors.darkOnErrorContainer,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
    surfaceContainer: AppColors.darkSurfaceContainer,
    surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
    outline: AppColors.darkOnSurfaceVariant,
    outlineVariant: AppColors.darkOutlineVariant,
  );

  static ThemeData get lightTheme => _buildTheme(_lightColorScheme);

  static ThemeData get darkTheme => _buildTheme(_darkColorScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
    );

    final TextTheme textTheme = _buildTextTheme(base.textTheme, colorScheme);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardTheme(
        color: colorScheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderLg,
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderLg,
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderLg,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, ColorScheme colorScheme) {
    final TextTheme bodyTheme = GoogleFonts.interTextTheme(base).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    final TextTheme headingTheme =
        GoogleFonts.plusJakartaSansTextTheme(base).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return bodyTheme.copyWith(
      displaySmall: headingTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineMedium: headingTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineSmall: headingTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: headingTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: headingTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleSmall: headingTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      bodyLarge: bodyTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: bodyTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        height: 1.45,
      ),
      bodySmall: bodyTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: headingTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
    );
  }
}
