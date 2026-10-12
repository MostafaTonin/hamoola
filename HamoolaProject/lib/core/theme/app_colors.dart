import 'package:flutter/material.dart';

/// Hamoola Design System Color Tokens
/// Direct 1-to-1 extraction from CSS design tokens and prototype specifications.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // 1. Primary Gold / Amber Palette (ألوان الهوية والعنبر اللوجستي)
  // ---------------------------------------------------------------------------
  static const Color primaryGold = Color(0xFFF59E0B);
  static const Color goldDark = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFEF3C7);
  static const Color goldLighter = Color(0xFFFFFBEB);
  static const Color goldBorder = Color(0xFFFDE68A);
  static const Color goldText = Color(0xFF92400E);

  // ---------------------------------------------------------------------------
  // 2. Navy & Slate Palette (الأساس الكحلي والليلي)
  // ---------------------------------------------------------------------------
  static const Color navyDark = Color(0xFF0F172A);
  static const Color navyMedium = Color(0xFF1E293B);
  static const Color navyLight = Color(0xFF1E3A5F);
  static const Color navyCorporate = Color(0xFF163A5F);

  // ---------------------------------------------------------------------------
  // 3. Neutral & Surface Palette (الخلفيات والأسطح والنصوص)
  // ---------------------------------------------------------------------------
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMainLight = Color(0xFF0F172A);
  static const Color textMutedLight = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFF94A3B8);

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderLightInput = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0x3394A3B8); // rgba(148, 163, 184, 0.20)

  // ---------------------------------------------------------------------------
  // 4. Semantic / Status Colors (حالات العمليات والشارات)
  // ---------------------------------------------------------------------------
  // Success (مكتمل / متاح / موثق)
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFBBF7D0);
  static const Color successText = Color(0xFF065F46);

  // Warning / Pending (معلق / قيد المراجعة)
  static const Color warning = Color(0xFFD97706);
  static const Color warningAccent = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFF92400E);

  // Error / Danger / SOS (طوارئ / مرفوض / ملغي)
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorText = Color(0xFF991B1B);

  // Info (معلومات / تتبع / إرشادات)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFFEFF6FF);
  static const Color infoText = Color(0xFF1D4ED8);

  // ---------------------------------------------------------------------------
  // 5. Gradients (تدرجات الشعار والواجهات)
  // ---------------------------------------------------------------------------
  static const LinearGradient goldBrandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient navyHeroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );
}
