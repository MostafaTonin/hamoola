import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

/// Hamoola Theme Provider (Light and Dark Themes)
/// Conforms directly to the visual rules in CSS prototype.
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // 1. Light Theme (الثيم الفاتح - الافتراضي)
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    final textTheme = AppTypography.createTextTheme(
      AppColors.textMainLight,
      AppColors.textMutedLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.primaryFontFamily,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primaryGold,
      dividerColor: AppColors.borderLight,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGold,
        onPrimary: AppColors.navyDark,
        secondary: AppColors.navyCorporate,
        onSecondary: AppColors.textWhite,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textMainLight,
        error: AppColors.error,
        onError: AppColors.textWhite,
      ),

      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textMainLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.pageTitle,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderMd,
          side: BorderSide(color: AppColors.borderLight),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.navyDark,
          elevation: 0,
          minimumSize: const Size(64.0, AppDimensions.buttonHeightMd),
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderSm),
          textStyle: AppTypography.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLg),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.goldDark,
          side: const BorderSide(color: AppColors.goldBorder, width: 1.2),
          minimumSize: const Size(64.0, AppDimensions.buttonHeightMd),
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderSm),
          textStyle: AppTypography.buttonText.copyWith(color: AppColors.goldDark),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLg),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceSm,
        ),
        hintStyle: AppTypography.secondary.copyWith(color: AppColors.textSubtle),
        labelStyle: AppTypography.bodyRegular.copyWith(color: AppColors.textMutedLight),
        border: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSm,
          borderSide: BorderSide(color: AppColors.borderLightInput),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSm,
          borderSide: BorderSide(color: AppColors.borderLightInput),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSm,
          borderSide: BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSm,
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.textSubtle,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Dark Theme (الثيم الداكن)
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    final textTheme = AppTypography.createTextTheme(
      AppColors.textWhite,
      AppColors.textSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.primaryFontFamily,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primaryGold,
      dividerColor: AppColors.borderDark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGold,
        onPrimary: AppColors.navyDark,
        secondary: AppColors.goldLight,
        onSecondary: AppColors.navyDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textWhite,
        error: AppColors.error,
        onError: AppColors.textWhite,
      ),

      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navyDark,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.pageTitle.copyWith(color: AppColors.textWhite),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderMd,
          side: BorderSide(color: AppColors.borderDark),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.navyDark,
          elevation: 0,
          minimumSize: const Size(64.0, AppDimensions.buttonHeightMd),
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderSm),
          textStyle: AppTypography.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLg),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceSm,
        ),
        hintStyle: AppTypography.secondary.copyWith(color: AppColors.textSubtle),
        labelStyle: AppTypography.bodyRegular.copyWith(color: AppColors.textSubtle),
        border: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSm,
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSm,
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.borderSm,
          borderSide: BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryGold,
        unselectedItemColor: AppColors.textSubtle,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
