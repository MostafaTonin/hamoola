import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

enum MerchantStatVariant {
  blue,
  gold,
  warning,
}

class MerchantStatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final MerchantStatVariant variant;
  final String? badgeText;
  final bool showDot;
  final VoidCallback? onTap;

  const MerchantStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.variant = MerchantStatVariant.gold,
    this.badgeText,
    this.showDot = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color iconBgColor;
    Color iconColor;
    Color numberColor = isDark ? AppColors.textWhite : AppColors.textMainLight;

    switch (variant) {
      case MerchantStatVariant.blue:
        iconBgColor = const Color(0x2E3B82F6);
        iconColor = const Color(0xFF60A5FA);
        break;
      case MerchantStatVariant.gold:
        iconBgColor = const Color(0x2EF59E0B);
        iconColor = AppColors.primaryGold;
        numberColor = AppColors.primaryGold;
        break;
      case MerchantStatVariant.warning:
        iconBgColor = const Color(0x33D97706);
        iconColor = AppColors.goldDark;
        numberColor = AppColors.goldDark;
        break;
    }

    final cardBg = isDark
        ? const Color(0xB21E293B)
        : Colors.white;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 26.0,
                      height: 26.0,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Icon(icon, size: 15.0, color: iconColor),
                    ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 1.0,
                        ),
                        decoration: BoxDecoration(
                          color: variant == MerchantStatVariant.blue
                              ? AppColors.successBg
                              : const Color(0x33F59E0B),
                          borderRadius: BorderRadius.circular(4.0),
                          border: variant == MerchantStatVariant.gold
                              ? Border.all(
                                  color: AppColors.primaryGold.withValues(alpha: 0.35),
                                )
                              : null,
                        ),
                        child: Text(
                          badgeText!,
                          style: GoogleFonts.cairo(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: variant == MerchantStatVariant.blue
                                ? AppColors.success
                                : AppColors.primaryGold,
                          ),
                        ),
                      )
                    else if (showDot)
                      Container(
                        width: 7.0,
                        height: 7.0,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGold,
                              blurRadius: 5.0,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                        color: numberColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textSubtle
                            : AppColors.textMutedLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
