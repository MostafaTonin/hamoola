import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Hamoola Design System Typography Tokens
/// Unified typography scale based on Cairo (UI/Headers) and IBM Plex Sans Arabic (Metrics/Data)
abstract final class AppTypography {
  // ---------------------------------------------------------------------------
  // 1. Font Families
  // ---------------------------------------------------------------------------
  static String get primaryFontFamily => GoogleFonts.cairo().fontFamily ?? 'Cairo';
  static String get dataFontFamily =>
      GoogleFonts.ibmPlexSansArabic().fontFamily ?? 'IBM Plex Sans Arabic';

  // ---------------------------------------------------------------------------
  // 2. Text Styles (Light Theme Defaults)
  // ---------------------------------------------------------------------------

  /// العناوين الرئيسية للشاشات (19px, Bold 700)
  static TextStyle get pageTitle => GoogleFonts.cairo(
        fontSize: 19.0,
        fontWeight: FontWeight.w700,
        color: AppColors.textMainLight,
        height: 1.35,
      );

  /// عناوين الأقسام الرئيسية (15.5px, SemiBold 600)
  static TextStyle get sectionTitle => GoogleFonts.cairo(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textMainLight,
        height: 1.35,
      );

  /// عناوين الكروت والبطاقات (13.5px, SemiBold 600)
  static TextStyle get cardTitle => GoogleFonts.cairo(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textMainLight,
        height: 1.35,
      );

  /// النصوص الأساسية والبيانات (12.5px, Medium 500)
  static TextStyle get bodyMedium => GoogleFonts.cairo(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textMainLight,
        height: 1.45,
      );

  /// النصوص الأساسية (12.5px, Regular 400)
  static TextStyle get bodyRegular => GoogleFonts.cairo(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textMainLight,
        height: 1.45,
      );

  /// النصوص الوصفية والتصنيفات (11px, Regular 400)
  static TextStyle get secondary => GoogleFonts.cairo(
        fontSize: 11.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textMutedLight,
        height: 1.4,
      );

  /// التواريخ والملاحظات الدقيقة (10px, Regular 400)
  static TextStyle get caption => GoogleFonts.cairo(
        fontSize: 10.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textSubtle,
        height: 1.3,
      );

  /// نصوص الأزرار الرئيسية (13px, SemiBold 600)
  static TextStyle get buttonText => GoogleFonts.cairo(
        fontSize: 13.0,
        fontWeight: FontWeight.w600,
        color: AppColors.navyDark,
        height: 1.2,
      );

  /// الشارات وحالات الطلب (9.5px, SemiBold 600)
  static TextStyle get badgeText => GoogleFonts.cairo(
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  // ---------------------------------------------------------------------------
  // 3. Metrics / Data Styles (IBM Plex Sans Arabic)
  // ---------------------------------------------------------------------------

  /// أرقام العدادات والإحصائيات الكبيرة (22px, Bold 700)
  static TextStyle get metricLarge => GoogleFonts.ibmPlexSansArabic(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        color: AppColors.textMainLight,
      );

  /// أرقام الأوزان والحمولات والأسعار (14px, SemiBold 600)
  static TextStyle get metricMedium => GoogleFonts.ibmPlexSansArabic(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textMainLight,
      );

  // ---------------------------------------------------------------------------
  // 4. Material TextTheme Bridge
  // ---------------------------------------------------------------------------
  static TextTheme createTextTheme(Color textColor, Color mutedColor) {
    return TextTheme(
      headlineSmall: pageTitle.copyWith(color: textColor),
      titleMedium: sectionTitle.copyWith(color: textColor),
      titleSmall: cardTitle.copyWith(color: textColor),
      bodyMedium: bodyMedium.copyWith(color: textColor),
      bodySmall: secondary.copyWith(color: mutedColor),
      labelLarge: buttonText,
      labelSmall: caption.copyWith(color: mutedColor),
    );
  }
}
