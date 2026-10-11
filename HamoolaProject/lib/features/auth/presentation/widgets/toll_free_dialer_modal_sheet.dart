import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/communication_launcher.dart';

/// Toll-Free Phone Dialer Modal Sheet.
/// Matches prototype `#phoneDialerModal` with contact avatar,
/// formatted number display, and instant call simulation.
class TollFreeDialerModalSheet extends StatelessWidget {
  final String phoneNumber;
  final String targetName;

  const TollFreeDialerModalSheet({
    super.key,
    this.phoneNumber = AppStrings.companyTollFreeNumber,
    this.targetName = 'حمولة — الرقم المجاني',
  });

  static Future<void> show(
    BuildContext context, {
    String phoneNumber = AppStrings.companyTollFreeNumber,
    String targetName = 'حمولة — الرقم المجاني',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TollFreeDialerModalSheet(
        phoneNumber: phoneNumber,
        targetName: targetName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space2xl,
        vertical: AppDimensions.spaceLg,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20.0,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle pill
            Container(
              width: 44.0,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLg),

            // Dialer avatar icon
            Container(
              width: 76.0,
              height: 76.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.successBg,
                border: Border.all(color: AppColors.success, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.25),
                    blurRadius: 16.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.phone_in_talk_rounded,
                  size: 38.0,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 18.0),

            // Target Name
            Text(
              targetName,
              style: GoogleFonts.cairo(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6.0),

            // Phone Number Display
            Text(
              phoneNumber,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGold,
                letterSpacing: 1.5,
              ),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),

            // Free Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: AppColors.successBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.5,
                    height: 6.5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'مكالمة مجانية على مدار 24 ساعة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28.0),

            // Actions: Call button
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightLg,
              child: ElevatedButton.icon(
                onPressed: () {
                  final navContext = context;
                  Navigator.of(navContext).pop();
                  CommunicationLauncher.makePhoneCall(
                    navContext,
                    phoneNumber: phoneNumber,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderSm,
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.call_rounded, size: 22.0),
                label: Text(
                  'اتصال الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSm),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightMd,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                ),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6.0),
          ],
        ),
      ),
    );
  }
}
