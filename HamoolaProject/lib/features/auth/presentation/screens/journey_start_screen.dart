import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/buttons/hamula_button.dart';

/// Screen 08 in Prototype: "ابدأ رحلتك مع حمولة" (Journey Start / Auth Gateway).
/// Faithfully reproduces `#screenJourneyStart` from the web prototype,
/// serving as the seamless bridge between Onboarding and Authentication.
class JourneyStartScreen extends StatefulWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;
  final VoidCallback? onSkip;

  const JourneyStartScreen({
    super.key,
    this.onLogin,
    this.onRegister,
    this.onSkip,
  });

  @override
  State<JourneyStartScreen> createState() => _JourneyStartScreenState();
}

class _JourneyStartScreenState extends State<JourneyStartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0.0, end: -6.0).animate(
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
    final gradientColors = isDark
        ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
        : const [Color(0xFFFFFFFF), Color(0xFFF8FAFC)];
    final skipColor = isDark ? AppColors.textSubtle : const Color(0xFF64748B);
    final titleColor = isDark ? AppColors.textWhite : const Color(0xFF0F172A);
    final descColor = isDark ? AppColors.textSubtle : const Color(0xFF475569);

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
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.compactMax),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space2xl,
                  vertical: AppDimensions.spaceLg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopBar(skipColor),
                    _buildBody(titleColor, descColor, isDark),
                    _buildFooter(),
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
          onTap: widget.onSkip ?? widget.onLogin,
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

  Widget _buildBody(Color titleColor, Color descColor, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeroVisual(isDark),
        const SizedBox(height: 24.0),
        Text(
          AppStrings.journeyStartTitle,
          style: GoogleFonts.cairo(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: titleColor,
            height: 1.35,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320.0),
          child: Text(
            AppStrings.journeyStartDesc,
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

  Widget _buildHeroVisual(bool isDark) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0.0, _floatAnimation.value),
        child: child,
      ),
      child: Container(
        width: 290.0,
        height: 190.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF1E293B), Color(0xFF0F172A)]
                : const [Color(0xFF163A5F), Color(0xFF0F172A)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.18 : 0.14),
              blurRadius: 28.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Abstract highway grid / glow background
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                ),
              ),
            ),
            // Custom Painted Modern Heavy Truck
            CustomPaint(
              size: const Size(220.0, 130.0),
              painter: _FleetHeroPainter(),
            ),
            // Floating Badge Chip: "انطلاق ووصول موثوق"
            Positioned(
              bottom: 12.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.0,
                      height: 7.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 7.0),
                    Text(
                      AppStrings.journeyStartBadge,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
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

  Widget _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Action 1: Login
        HamulaButton(
          label: AppStrings.login,
          onPressed: widget.onLogin,
          variant: HamulaButtonVariant.primary,
          size: HamulaButtonSize.lg,
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        // Action 2: Register
        HamulaButton(
          label: AppStrings.createAccount,
          onPressed: widget.onRegister,
          variant: HamulaButtonVariant.outlined,
          size: HamulaButtonSize.lg,
        ),
      ],
    );
  }
}

/// Custom painter for the modern heavy transport fleet hero visual
class _FleetHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final wheelPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final rimPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final linePaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final speedLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Road lines
    canvas.drawLine(
      Offset(15.0, size.height - 20.0),
      Offset(size.width - 15.0, size.height - 20.0),
      linePaint,
    );

    // Speed lines behind truck
    canvas.drawLine(
      Offset(18.0, size.height - 48.0),
      Offset(38.0, size.height - 48.0),
      speedLinePaint,
    );
    canvas.drawLine(
      Offset(24.0, size.height - 62.0),
      Offset(48.0, size.height - 62.0),
      speedLinePaint,
    );

    // Trailer / Container Box (Gold body)
    final trailerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(50.0, 32.0, 95.0, 68.0),
      const Radius.circular(6.0),
    );
    canvas.drawRRect(trailerRect, goldPaint);

    // Container vertical ribs
    final ribPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 2.0;
    for (double x = 68.0; x <= 135.0; x += 16.0) {
      canvas.drawLine(Offset(x, 34.0), Offset(x, 98.0), ribPaint);
    }

    // Cab / Tractor (Dark body with aerodynamic front)
    final cabPath = Path()
      ..moveTo(148.0, 98.0)
      ..lineTo(148.0, 48.0)
      ..lineTo(178.0, 48.0)
      ..quadraticBezierTo(192.0, 52.0, 196.0, 72.0)
      ..lineTo(200.0, 98.0)
      ..close();
    canvas.drawPath(cabPath, darkPaint);

    // Windshield
    final windshieldPath = Path()
      ..moveTo(164.0, 52.0)
      ..lineTo(176.0, 52.0)
      ..quadraticBezierTo(188.0, 56.0, 190.0, 70.0)
      ..lineTo(164.0, 70.0)
      ..close();
    canvas.drawPath(windshieldPath, windowPaint);

    // Headlight (Glowing amber)
    final lightPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(194.0, 84.0, 6.0, 8.0),
        const Radius.circular(2.0),
      ),
      lightPaint,
    );

    // Wheels
    const wheelRadius = 13.0;
    final wheelPositions = [
      Offset(72.0, size.height - 20.0),
      Offset(102.0, size.height - 20.0),
      Offset(172.0, size.height - 20.0),
    ];

    for (final pos in wheelPositions) {
      canvas.drawCircle(pos, wheelRadius, wheelPaint);
      canvas.drawCircle(pos, wheelRadius * 0.55, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
