import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Screen 04 in Prototype: "ابدأ رحلتك مع حمولة" (Final Onboarding Screen).
/// Faithfully reproduces the screenshot provided:
/// - Top "تخطي" (Skip) action
/// - Hero card with realistic truck on highway photo (`hamula_journey_start.jpg`)
/// - Bottom overlay badge on photo: "انطلاق ووصول موثوق 🟠"
/// - Title: "ابدأ رحلتك مع حمولة"
/// - Subtitle: "أنشئ حسابك وابدأ في نقل حمولاتك بسهولة."
/// - Stepper indicator with active amber pill and 5 inactive circular dots
/// - Primary bottom CTA button: "ابدأ الآن"
class Onboarding3Screen extends StatelessWidget {
  final VoidCallback? onStartNow;
  final VoidCallback? onSkip;

  const Onboarding3Screen({
    super.key,
    this.onStartNow,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
    final skipColor = isDark ? AppColors.textSubtle : const Color(0xFF64748B);
    final titleColor = isDark ? AppColors.textWhite : const Color(0xFF0F172A);
    final descColor = isDark ? AppColors.textSubtle : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.compactMax),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space2xl,
                vertical: AppDimensions.spaceMd,
              ),
              child: Column(
                children: [
                  // 1. Top Bar with "تخطي"
                  _buildTopBar(skipColor),

                  const Spacer(flex: 1),

                  // 2. Center Content (Hero Photo Card + Titles)
                  _buildHeroCard(isDark),
                  const SizedBox(height: 24.0),
                  _buildTitles(titleColor, descColor),

                  const Spacer(flex: 2),

                  // 3. Pagination Dots + "ابدأ الآن" Button
                  _buildFooter(),
                  const SizedBox(height: 12.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(Color skipColor) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: InkWell(
          onTap: onSkip,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMd,
              vertical: AppDimensions.spaceXs,
            ),
            child: Text(
              AppStrings.skip,
              style: GoogleFonts.cairo(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: skipColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(bool isDark) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 220.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 18.0,
            offset: const Offset(0.0, 8.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.0),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Truck on Highway image matching the user screenshot
            Image.asset(
              'assets/images/hamula_journey_start.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1E293B),
                  child: const Center(
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.primaryGold,
                      size: 64.0,
                    ),
                  ),
                );
              },
            ),

            // Subtle gradient overlay for badge contrast
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),

            // Badge overlay: "انطلاق ووصول موثوق 🟠"
            Positioned(
              bottom: 14.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xCC0F172A), // Dark glassmorphic backdrop
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: const Color(0x40F59E0B),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'انطلاق ووصول موثوق',
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGold,
                            blurRadius: 4.0,
                            spreadRadius: 1.0,
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
    );
  }

  Widget _buildTitles(Color titleColor, Color descColor) {
    return Column(
      children: [
        Text(
          'ابدأ رحلتك مع حمولة',
          style: GoogleFonts.cairo(
            fontSize: 24.0,
            fontWeight: FontWeight.w800,
            color: titleColor,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'أنشئ حسابك وابدأ في نقل حمولاتك بسهولة.',
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: descColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Stepper Dots: Active elongated amber pill + 5 circular dots matching screenshot
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active elongated amber pill
            Container(
              width: 28.0,
              height: 8.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            const SizedBox(width: 6.0),
            // 5 inactive dots
            for (int i = 0; i < 5; i++) ...[
              Container(
                width: 7.0,
                height: 7.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFCBD5E1),
                ),
              ),
              if (i < 4) const SizedBox(width: 6.0),
            ],
          ],
        ),
        const SizedBox(height: 24.0),

        // Primary Button: "ابدأ الآن" in vibrant orange/amber
        SizedBox(
          width: double.infinity,
          height: 52.0,
          child: ElevatedButton(
            onPressed: onStartNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE67E22), // Matching the screenshot vibrant amber/orange
              foregroundColor: Colors.white,
              elevation: 2.0,
              shadowColor: const Color(0x55E67E22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
            child: Text(
              'ابدأ الآن',
              style: GoogleFonts.cairo(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
