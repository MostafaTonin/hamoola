import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_typography.dart';

/// Button visual variants matching the Hamoola prototype
enum HamulaButtonVariant {
  primary,
  outlined,
  ghost,
}

/// Button size variants
enum HamulaButtonSize {
  sm,
  md,
  lg,
}

/// A production-grade, highly reusable button adhering to Hamoola's design tokens.
class HamulaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final HamulaButtonVariant variant;
  final HamulaButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customBackgroundColor;
  final Color? customForegroundColor;

  const HamulaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = HamulaButtonVariant.primary,
    this.size = HamulaButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.customBackgroundColor,
    this.customForegroundColor,
  });

  bool get _isEnabled => onPressed != null && !isLoading;

  double get _height {
    return switch (size) {
      HamulaButtonSize.sm => AppDimensions.buttonHeightSm,
      HamulaButtonSize.md => AppDimensions.buttonHeightMd,
      HamulaButtonSize.lg => AppDimensions.buttonHeightLg,
    };
  }

  double get _fontSize {
    return switch (size) {
      HamulaButtonSize.sm => 11.5,
      HamulaButtonSize.md => 13.0,
      HamulaButtonSize.lg => 14.5,
    };
  }

  EdgeInsetsGeometry get _padding {
    return switch (size) {
      HamulaButtonSize.sm => const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd),
      HamulaButtonSize.md => const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLg),
      HamulaButtonSize.lg => const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXl),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = _buildContent();

    final buttonStyle = switch (variant) {
      HamulaButtonVariant.primary => _buildPrimaryStyle(isDark),
      HamulaButtonVariant.outlined => _buildOutlinedStyle(isDark),
      HamulaButtonVariant.ghost => _buildGhostStyle(isDark),
    };

    Widget button = switch (variant) {
      HamulaButtonVariant.primary => ElevatedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: buttonStyle,
          child: content,
        ),
      HamulaButtonVariant.outlined => OutlinedButton(
          onPressed: _isEnabled ? onPressed : null,
          style: buttonStyle,
          child: content,
        ),
      HamulaButtonVariant.ghost => TextButton(
          onPressed: _isEnabled ? onPressed : null,
          style: buttonStyle,
          child: content,
        ),
    };

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, height: _height, child: button);
    } else {
      button = SizedBox(height: _height, child: button);
    }

    return button;
  }

  Widget _buildContent() {
    if (isLoading) {
      final spinnerColor = switch (variant) {
        HamulaButtonVariant.primary => AppColors.navyDark,
        HamulaButtonVariant.outlined => customForegroundColor ?? AppColors.goldDark,
        HamulaButtonVariant.ghost => customForegroundColor ?? AppColors.goldDark,
      };

      return SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        ),
      );
    }

    final textWidget = Text(
      label,
      style: AppTypography.buttonText.copyWith(
        fontSize: _fontSize,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (icon == null) {
      return textWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon!,
        const SizedBox(width: AppDimensions.spaceXs),
        Flexible(child: textWidget),
      ],
    );
  }

  ButtonStyle _buildPrimaryStyle(bool isDark) {
    final defaultBg = customBackgroundColor ?? AppColors.primaryGold;
    final defaultFg = customForegroundColor ?? AppColors.navyDark;

    return ElevatedButton.styleFrom(
      backgroundColor: defaultBg,
      foregroundColor: defaultFg,
      disabledBackgroundColor: isDark ? AppColors.surfaceDark : AppColors.borderLight,
      disabledForegroundColor: AppColors.textSubtle,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderSm),
      padding: _padding,
    );
  }

  ButtonStyle _buildOutlinedStyle(bool isDark) {
    final defaultFg = customForegroundColor ?? AppColors.goldDark;
    final borderColor = isDark ? AppColors.goldBorder : AppColors.goldBorder;

    return OutlinedButton.styleFrom(
      foregroundColor: defaultFg,
      disabledForegroundColor: AppColors.textSubtle,
      side: BorderSide(
        color: _isEnabled ? borderColor : (isDark ? AppColors.borderDark : AppColors.borderLight),
        width: 1.2,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderSm),
      padding: _padding,
    );
  }

  ButtonStyle _buildGhostStyle(bool isDark) {
    final defaultFg = customForegroundColor ?? (isDark ? AppColors.primaryGold : AppColors.goldDark);

    return TextButton.styleFrom(
      foregroundColor: defaultFg,
      disabledForegroundColor: AppColors.textSubtle,
      shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderSm),
      padding: _padding,
    );
  }
}
