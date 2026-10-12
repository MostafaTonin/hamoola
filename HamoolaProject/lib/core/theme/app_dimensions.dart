import 'package:flutter/material.dart';

/// Hamoola Design System Spacing, Radius, and Shadow Metrics
abstract final class AppDimensions {
  // ---------------------------------------------------------------------------
  // 1. Spacing Scale (سلم المسافات الموحد)
  // ---------------------------------------------------------------------------
  static const double space2xs = 3.0;
  static const double spaceXs = 6.0;
  static const double spaceSm = 9.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 20.0;
  static const double space2xl = 24.0;
  static const double space3xl = 32.0;

  // ---------------------------------------------------------------------------
  // 2. Border Radii (أنصاف الأقطار المعتمدة)
  // ---------------------------------------------------------------------------
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 28.0;
  static const double radiusFull = 9999.0;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius border2xl = BorderRadius.all(Radius.circular(radius2xl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(radiusFull));

  // ---------------------------------------------------------------------------
  // 3. Component Dimensions (أبعاد المكونات القياسية)
  // ---------------------------------------------------------------------------
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 50.0;

  static const double inputFieldHeight = 48.0;
  static const double iconSizeSm = 14.0;
  static const double iconSizeMd = 18.0;
  static const double iconSizeLg = 22.0;
  static const double iconSizeHero = 26.0;

  static const double iconBoxSm = 28.0;
  static const double iconBoxMd = 34.0;
  static const double iconBoxLg = 38.0;

  // ---------------------------------------------------------------------------
  // 4. Shadows (الظلال القياسية المستخرجة من النموذج)
  // ---------------------------------------------------------------------------
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.04),
      blurRadius: 3.0,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.08),
      blurRadius: 12.0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      blurRadius: 25.0,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 6.0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.12),
      blurRadius: 36.0,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.04),
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ];
}
