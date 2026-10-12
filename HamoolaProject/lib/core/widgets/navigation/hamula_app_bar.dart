import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_typography.dart';

/// Reusable application bar conforming to Hamoola's clean navigation headers.
class HamulaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final bool hasBottomBorder;

  const HamulaAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.hasBottomBorder = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 62.0 : 54.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final resolvedBg = backgroundColor ??
        (isDark ? AppColors.navyDark : AppColors.surfaceLight);

    final resolvedBorderColor = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: resolvedBg,
        border: hasBottomBorder
            ? Border(bottom: BorderSide(color: resolvedBorderColor, width: 1.0))
            : null,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: elevation,
        scrolledUnderElevation: 0,
        centerTitle: centerTitle,
        leading: _buildLeading(context, isDark),
        title: _buildTitle(isDark),
        actions: actions != null
            ? [
                ...actions!,
                const SizedBox(width: AppDimensions.spaceSm),
              ]
            : null,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, bool isDark) {
    if (leading != null) {
      return leading;
    }

    final canPop = ModalRoute.of(context)?.canPop ?? false;
    if (!showBackButton || !canPop) {
      return null;
    }

    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 18.0,
        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
      ),
      tooltip: 'رجوع',
      onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
    );
  }

  Widget _buildTitle(bool isDark) {
    if (titleWidget != null) {
      return titleWidget!;
    }

    final textColor = isDark ? AppColors.textWhite : AppColors.textMainLight;

    if (subtitle == null) {
      return Text(
        title ?? '',
        style: AppTypography.pageTitle.copyWith(
          color: textColor,
          fontSize: 17.0,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title ?? '',
          style: AppTypography.pageTitle.copyWith(
            color: textColor,
            fontSize: 16.0,
          ),
        ),
        Text(
          subtitle!,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }
}
