import 'package:flutter/material.dart';

/// Hamoola Responsive Breakpoints
abstract final class AppBreakpoints {
  static const double compactMax = 600.0;
  static const double mediumMax = 1024.0;
  static const double maxContentWidth = 1200.0;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactMax;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compactMax && width <= mediumMax;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width > mediumMax;
}
