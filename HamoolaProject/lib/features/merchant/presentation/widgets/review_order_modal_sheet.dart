import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/buttons/hamula_button.dart';
import '../../domain/models/transport_order_draft.dart';

/// Bottom sheet dialog for reviewing transport order before publishing
class ReviewOrderModalSheet extends StatelessWidget {
  final TransportOrderDraft order;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ReviewOrderModalSheet({
    super.key,
    required this.order,
    required this.onConfirm,
    required this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required TransportOrderDraft order,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReviewOrderModalSheet(
        order: order,
        onConfirm: () {
          Navigator.of(ctx).pop();
          onConfirm();
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  String _getTargetName() {
    switch (order.target) {
      case PublishTarget.allDrivers:
        return AppStrings.targetAllDrivers;
      case PublishTarget.specificDriver:
        return order.selectedDriver?.name ?? AppStrings.targetSpecificDriver;
      case PublishTarget.allOffices:
        return AppStrings.targetAllOffices;
      case PublishTarget.specificOffice:
        return order.selectedOffice?.name ?? AppStrings.targetSpecificOffice;
    }
  }

  String _getFlexibilityText() {
    switch (order.flexibility) {
      case ScheduleFlexibility.exact:
        return AppStrings.flexExact;
      case ScheduleFlexibility.plusMinus6Hours:
        return AppStrings.flexPlusMinus6;
      case ScheduleFlexibility.plusMinus12Hours:
        return AppStrings.flexPlusMinus12;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyDark : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Text(
              AppStrings.reviewOrderTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              ),
            ),
            const SizedBox(height: 18),

            // Summary Details Container
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x661E293B)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryLine(
                    label: AppStrings.reviewRouteLabel,
                    value: '${order.originCity} ← ${order.destCity}',
                    isDark: isDark,
                  ),
                  if (order.originAddressDetail.isNotEmpty) ...[
                    const Divider(height: 16),
                    _buildSummaryLine(
                      label: 'موقع التحميل:',
                      value: order.originAddressDetail,
                      isDark: isDark,
                    ),
                  ],
                  if (order.destAddressDetail.isNotEmpty) ...[
                    const Divider(height: 16),
                    _buildSummaryLine(
                      label: 'موقع التفريغ:',
                      value: order.destAddressDetail,
                      isDark: isDark,
                    ),
                  ],
                  const Divider(height: 16),
                  _buildSummaryLine(
                    label: AppStrings.reviewCargoLabel,
                    value: '${order.cargo.name} · ${order.cargo.weight}',
                    isDark: isDark,
                  ),
                  const Divider(height: 16),
                  _buildSummaryLine(
                    label: AppStrings.reviewVehicleLabel,
                    value: order.vehicleType,
                    isDark: isDark,
                  ),
                  const Divider(height: 16),
                  _buildSummaryLine(
                    label: AppStrings.reviewScheduleLabel,
                    value:
                        '${order.loadingDate} · ${order.loadingTime} (${_getFlexibilityText()})',
                    isDark: isDark,
                  ),
                  const Divider(height: 16),
                  _buildSummaryLine(
                    label: AppStrings.reviewBudgetLabel,
                    value:
                        '${order.minBudget} – ${order.maxBudget} ${AppStrings.yemeniRialUnit}${order.isBudgetNegotiable ? ' (${AppStrings.budgetNegotiable})' : ''}',
                    isDark: isDark,
                  ),
                  const Divider(height: 16),
                  _buildSummaryLine(
                    label: AppStrings.reviewPublishToLabel,
                    value: _getTargetName(),
                    isDark: isDark,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            HamulaButton(
              label: AppStrings.confirmPublishBtn,
              onPressed: onConfirm,
              variant: HamulaButtonVariant.primary,
              size: HamulaButtonSize.lg,
              icon: const Icon(Icons.send_rounded, size: 18),
            ),
            const SizedBox(height: 10),
            HamulaButton(
              label: AppStrings.cancelBtn,
              onPressed: onCancel,
              variant: HamulaButtonVariant.outlined,
              size: HamulaButtonSize.md,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine({
    required String label,
    required String value,
    required bool isDark,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isHighlight
                  ? AppColors.primaryGold
                  : (isDark ? AppColors.textWhite : AppColors.textMainLight),
            ),
          ),
        ),
      ],
    );
  }
}
