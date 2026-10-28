import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/merchant_order.dart';

class MerchantOrderCard extends StatelessWidget {
  final MerchantOrder order;
  final VoidCallback? onDetails;
  final VoidCallback? onTap;
  final VoidCallback? onReviewOffers;
  final VoidCallback? onOrderDetails;

  const MerchantOrderCard({
    super.key,
    required this.order,
    this.onDetails,
    this.onTap,
    this.onReviewOffers,
    this.onOrderDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark
        ? const Color(0xC01E293B)
        : Colors.white;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight;

    Color badgeBg;
    Color badgeBorder;
    Color badgeTextColor;

    switch (order.status) {
      case MerchantOrderStatus.draft:
        badgeBg = const Color(0x1F64748B);
        badgeBorder = const Color(0x4064748B);
        badgeTextColor = const Color(0xFF94A3B8);
        break;
      case MerchantOrderStatus.pendingDriver:
        badgeBg = const Color(0x2EF59E0B);
        badgeBorder = AppColors.primaryGold.withValues(alpha: 0.35);
        badgeTextColor = const Color(0xFFFBBF24);
        break;
      case MerchantOrderStatus.pendingOffice:
        badgeBg = const Color(0x2E8B5CF6);
        badgeBorder = const Color(0x598B5CF6);
        badgeTextColor = const Color(0xFFA78BFA);
        break;
      case MerchantOrderStatus.assignedDriver:
        badgeBg = const Color(0x2E3B82F6);
        badgeBorder = const Color(0x593B82F6);
        badgeTextColor = const Color(0xFF93C5FD);
        break;
      case MerchantOrderStatus.inTransit:
        badgeBg = const Color(0x2EF59E0B);
        badgeBorder = AppColors.primaryGold.withValues(alpha: 0.4);
        badgeTextColor = AppColors.primaryGold;
        break;
      case MerchantOrderStatus.completed:
        badgeBg = const Color(0x2E10B981);
        badgeBorder = const Color(0x5910B981);
        badgeTextColor = const Color(0xFF6EE7B7);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => (onTap ?? onOrderDetails ?? onDetails)?.call(),
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          // Order Header: ID, cargo type & status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                      color: const Color(0x2EF59E0B),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Icon(
                      order.iconData,
                      size: 16.0,
                      color: AppColors.primaryGold,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        order.cargoName,
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(7.0),
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  order.statusLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Route Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x800F172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(9.0),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                // Origin
                Row(
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success,
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      order.originCity,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFE2E8F0) : AppColors.textMainLight,
                      ),
                    ),
                  ],
                ),
                // Route Arrow Line
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 1.0,
                        width: 24.0,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.borderLightInput,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 13.0,
                          color: AppColors.primaryGold,
                        ),
                      ),
                      Container(
                        height: 1.0,
                        width: 24.0,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.borderLightInput,
                      ),
                    ],
                  ),
                ),
                // Destination
                Row(
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGold,
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      order.destinationCity,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFE2E8F0) : AppColors.textMainLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),

          // Meta Footer & Details Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (order.offersCount > 0)
                      Flexible(
                        child: Text(
                          '${order.offersCount} عروض جديدة',
                          style: GoogleFonts.cairo(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFBBF24),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else if (order.driverName != null)
                      Flexible(
                        child: Text(
                          '${AppStrings.driverPrefix}${order.driverName}',
                          style: GoogleFonts.cairo(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF93C5FD),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      '•',
                      style: GoogleFonts.cairo(
                        fontSize: 10.0,
                        color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                      ),
                    ),
                  ),
                  Text(
                    order.timeAgo,
                    style: GoogleFonts.cairo(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
                onTap: () {
                  if (order.offersCount > 0 && onReviewOffers != null) {
                    onReviewOffers?.call();
                  } else {
                    (onOrderDetails ?? onDetails ?? onTap)?.call();
                  }
                },
                borderRadius: BorderRadius.circular(7.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.borderLight,
                    ),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (order.offersCount > 0 && onReviewOffers != null)
                            ? 'مراجعة العروض'
                            : AppStrings.viewDetails,
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                        ),
                      ),
                      const SizedBox(width: 3.0),
                      Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 9.0,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}
