import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_typography.dart';

/// Standard, production-grade text input field adhering to Hamoola's design tokens.
class HamulaTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const HamulaTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inputBorder = OutlineInputBorder(
      borderRadius: AppDimensions.borderSm,
      borderSide: BorderSide(
        color: isDark ? AppColors.borderDark : AppColors.borderLightInput,
        width: 1.0,
      ),
    );

    final focusedBorder = const OutlineInputBorder(
      borderRadius: AppDimensions.borderSm,
      borderSide: BorderSide(
        color: AppColors.primaryGold,
        width: 1.5,
      ),
    );

    final errorBorder = const OutlineInputBorder(
      borderRadius: AppDimensions.borderSm,
      borderSide: BorderSide(
        color: AppColors.error,
        width: 1.5,
      ),
    );

    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: textDirection,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      style: AppTypography.bodyMedium.copyWith(
        color: enabled
            ? (isDark ? AppColors.textWhite : AppColors.textMainLight)
            : AppColors.textSubtle,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.secondary.copyWith(
          color: AppColors.textSubtle,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: AppTypography.caption.copyWith(
          color: AppColors.error,
        ),
        filled: true,
        fillColor: enabled
            ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
            : (isDark ? AppColors.navyDark : AppColors.backgroundLight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceSm,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
      ),
    );

    if (label == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: AppTypography.bodyRegular.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        field,
      ],
    );
  }
}
