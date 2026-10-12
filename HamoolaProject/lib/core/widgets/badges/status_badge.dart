import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_typography.dart';

/// Semantic status categories for logistics operations
enum StatusBadgeType {
  success,
  warning,
  danger,
  info,
  neutral,
}

/// Reusable status badge component for cargos, driver verifications, and system states.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final Widget? icon;
  final bool isPill;
  final VoidCallback? onTap;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusBadgeType.neutral,
    this.icon,
    this.isPill = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = _resolveColors();

    final badgeRadius = isPill
        ? BorderRadius.circular(AppDimensions.radiusFull)
        : BorderRadius.circular(6.0);

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSm,
        vertical: 3.5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: badgeRadius,
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4.0),
          ],
          Text(
            label,
            style: AppTypography.badgeText.copyWith(
              color: fg,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      badge = InkWell(
        onTap: onTap,
        borderRadius: badgeRadius,
        child: badge,
      );
    }

    return badge;
  }

  (Color bg, Color fg, Color border) _resolveColors() {
    return switch (type) {
      StatusBadgeType.success => (
          AppColors.successBg,
          AppColors.successText,
          AppColors.successBorder,
        ),
      StatusBadgeType.warning => (
          AppColors.warningBg,
          AppColors.warningText,
          AppColors.goldBorder,
        ),
      StatusBadgeType.danger => (
          AppColors.errorBg,
          AppColors.errorText,
          const Color(0xFFFECACA),
        ),
      StatusBadgeType.info => (
          AppColors.infoBg,
          AppColors.infoText,
          const Color(0xFFBFDBFE),
        ),
      StatusBadgeType.neutral => (
          const Color(0xFFF1F5F9),
          const Color(0xFF475569),
          AppColors.borderLight,
        ),
    };
  }
}
