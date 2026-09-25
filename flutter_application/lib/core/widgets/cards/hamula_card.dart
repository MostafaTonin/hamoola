import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// Base reusable card matching the Hamoola design system specifications.
class HamulaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final List<BoxShadow>? customShadow;
  final bool hasBorder;

  const HamulaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.spaceMd),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppDimensions.radiusMd,
    this.customShadow,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedBg = backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    final resolvedBorderColor = borderColor ??
        (isDark ? AppColors.borderDark : AppColors.borderLight);

    final border = hasBorder
        ? Border.all(color: resolvedBorderColor, width: 1.0)
        : null;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: hasBorder
          ? BorderSide(color: resolvedBorderColor, width: 1.0)
          : BorderSide.none,
    );

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: customShadow ?? (isDark ? null : AppDimensions.cardShadow),
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      );

      return Container(
        margin: margin,
        decoration: BoxDecoration(
          color: resolvedBg,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: customShadow ?? (isDark ? null : AppDimensions.cardShadow),
        ),
        child: cardContent,
      );
    }

    if (margin != EdgeInsets.zero) {
      return Padding(
        padding: margin,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
