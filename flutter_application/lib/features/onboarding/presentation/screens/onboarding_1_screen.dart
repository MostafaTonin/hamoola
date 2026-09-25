import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Onboarding Screen 1: "سهولة نقل الحمولة"
/// Direct Flutter implementation matching the HTML/CSS prototype:
/// - Screen ID: `#screenOnboarding1`
/// - Top Bar: "تخطي" skip button
/// - Body: Subtle floating truck illustration + Title (Cairo 700, 24px) + Description (Cairo 400, 14.5px)
/// - Footer: 3-dot indicator (Dot 1 active gold pill 26x8) + "التالي" CTA button (height 52px, radius 14px)
class Onboarding1Screen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const Onboarding1Screen({
    super.key,
    this.onNext,
    this.onSkip,
  });

  @override
  State<Onboarding1Screen> createState() => _Onboarding1ScreenState();
}

class _Onboarding1ScreenState extends State<Onboarding1Screen>
    with SingleTickerProviderStateMixin {
  // Truck hover floating animation (matches CSS @keyframes truckHoverEffect 4s ease-in-out)
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: -5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background gradient:
    // Light: linear-gradient(180deg, #FFFFFF 0%, #F8FAFC 100%)
    // Dark:  linear-gradient(180deg, #0F172A 0%, #1E293B 100%)
    final gradientColors = isDark
        ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
        : const [Color(0xFFFFFFFF), Color(0xFFF8FAFC)];

    final skipColor = isDark ? AppColors.textSubtle : const Color(0xFF64748B);
    final titleColor = isDark ? AppColors.textWhite : const Color(0xFF0F172A);
    final descColor = isDark ? AppColors.textSubtle : const Color(0xFF475569);
    final inactiveDotColor = isDark
        ? const Color.fromRGBO(148, 163, 184, 0.28)
        : const Color.fromRGBO(148, 163, 184, 0.40);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space2xl,
                  vertical: AppDimensions.spaceLg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar: "تخطي" Skip Button (Right-aligned in RTL)
                    _buildTopBar(skipColor),

                    // Central Body: Illustration, Title, and Description
                    _buildBody(titleColor, descColor),

                    // Footer: 3-dot indicator + "التالي" Next Button
                    _buildFooter(inactiveDotColor),
                  ],
                ),
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
          onTap: widget.onSkip,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMd,
              vertical: AppDimensions.spaceXs,
            ),
            child: Text(
              AppStrings.skip,
              style: GoogleFonts.cairo(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                color: skipColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Color titleColor, Color descColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Truck Illustration with Ambient Glow & Floating Animation
        _buildIllustration(),
        const SizedBox(height: 22.0),

        // Main Title (Cairo 700, 24px)
        Text(
          AppStrings.onboarding1Title,
          style: GoogleFonts.cairo(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: titleColor,
            height: 1.35,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spaceMd),

        // Short Description (Cairo 400, 14.5px)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 310.0),
          child: Text(
            AppStrings.onboarding1Desc,
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: descColor,
              height: 1.65,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Circular halo behind the truck (.illustration-halo)
        Container(
          width: 160.0,
          height: 160.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFF59E0B).withValues(alpha: 0.16),
                const Color(0xFFF59E0B).withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.70],
            ),
          ),
        ),

        // Floating SVG Truck Illustration
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0.0, _floatAnimation.value),
              child: child,
            );
          },
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 280.0,
              maxHeight: 200.0,
            ),
            child: SvgPicture.asset(
              'assets/icons/onboarding_truck_1.svg',
              width: 280.0,
              height: 200.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Color inactiveDotColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3-dot Onboarding indicator (Dot 1 active gold pill)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dot 1 (Active)
            Container(
              width: 26.0,
              height: 8.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                gradient: AppColors.goldBrandGradient,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.50),
                    blurRadius: 10.0,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSm),

            // Dot 2 (Inactive)
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: inactiveDotColor,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSm),

            // Dot 3 (Inactive)
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: inactiveDotColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space2xl),

        // "التالي" Primary Next Button (.btn-primary-next)
        Container(
          width: double.infinity,
          height: 52.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            gradient: AppColors.goldBrandGradient,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                blurRadius: 22.0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14.0),
            child: InkWell(
              onTap: widget.onNext,
              borderRadius: BorderRadius.circular(14.0),
              child: Center(
                child: Text(
                  AppStrings.next,
                  style: GoogleFonts.cairo(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSm),
      ],
    );
  }
}
