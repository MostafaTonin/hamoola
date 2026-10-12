import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/buttons/hamula_button.dart';

/// Modal sheet showing successful publication of transport order
class OrderPublishedModalSheet extends StatelessWidget {
  final String orderId;
  final String routeSummary;
  final VoidCallback onReturnHome;
  final VoidCallback onViewOffers;

  const OrderPublishedModalSheet({
    super.key,
    required this.orderId,
    required this.routeSummary,
    required this.onReturnHome,
    required this.onViewOffers,
  });

  static Future<void> show(
    BuildContext context, {
    required String orderId,
    required String routeSummary,
    required VoidCallback onReturnHome,
    required VoidCallback onViewOffers,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderPublishedModalSheet(
        orderId: orderId,
        routeSummary: routeSummary,
        onReturnHome: () {
          Navigator.of(ctx).pop();
          onReturnHome();
        },
        onViewOffers: () {
          Navigator.of(ctx).pop();
          onViewOffers();
        },
      ),
    );
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
            const SizedBox(height: 20),

            // Success Badge Icon
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              AppStrings.orderPublishedSuccessTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              ),
            ),
            const SizedBox(height: 8),

            // Order Code & Route Info
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x661E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${AppStrings.orderNumberTag} $orderId',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•  $routeSummary',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Primary Action: View Offers
            HamulaButton(
              label: AppStrings.viewOffersBtn,
              onPressed: onViewOffers,
              variant: HamulaButtonVariant.primary,
              size: HamulaButtonSize.lg,
              icon: const Icon(Icons.local_offer_outlined, size: 18),
            ),
            const SizedBox(height: 10),

            // Secondary Action: Return Home
            HamulaButton(
              label: AppStrings.returnHomeBtn,
              onPressed: onReturnHome,
              variant: HamulaButtonVariant.outlined,
              size: HamulaButtonSize.md,
            ),
          ],
        ),
      ),
    );
  }
}
