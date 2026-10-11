import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/merchant_order.dart';

class MerchantAttentionCard extends StatelessWidget {
  final MerchantAttentionItem item;
  final VoidCallback? onAction;

  const MerchantAttentionCard({
    super.key,
    required this.item,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final indicatorColor =
        item.isOffers ? AppColors.primaryGold : const Color(0xFF3B82F6);

    final iconBg = item.isOffers
        ? const Color(0x2EF59E0B)
        : const Color(0x2E3B82F6);

    final iconColor =
        item.isOffers ? AppColors.primaryGold : const Color(0xFF60A5FA);

    final actionBg = item.isOffers
        ? const Color(0x26F59E0B)
        : const Color(0x263B82F6);

    final actionBorder = item.isOffers
        ? AppColors.primaryGold.withValues(alpha: 0.35)
        : const Color(0x593B82F6);

    final actionTextColor =
        item.isOffers ? AppColors.primaryGold : const Color(0xFF93C5FD);

    final cardBg = isDark
        ? const Color(0xB81E293B)
        : Colors.white;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(13.0),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Side colored accent indicator
              Container(
                width: 4.0,
                color: indicatorColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28.0,
                            height: 28.0,
                            margin: const EdgeInsets.only(top: 2.0),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              item.isOffers
                                  ? Icons.local_offer_outlined
                                  : Icons.credit_card_outlined,
                              size: 16.0,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.textMainLight,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 3.0),
                                Text(
                                  item.description,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFFCBD5E1)
                                        : AppColors.textMutedLight,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.only(top: 6.0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : AppColors.borderLight,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.timeAgo,
                              style: GoogleFonts.cairo(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSubtle
                                    : AppColors.textMutedLight,
                              ),
                            ),
                            InkWell(
                              onTap: onAction,
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: actionBg,
                                  border: Border.all(color: actionBorder),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.actionText,
                                      style: GoogleFonts.cairo(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: actionTextColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                    Icon(
                                      Icons.arrow_back_ios_rounded,
                                      size: 10.0,
                                      color: actionTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
