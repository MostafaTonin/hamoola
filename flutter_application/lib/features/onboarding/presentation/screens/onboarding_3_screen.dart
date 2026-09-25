import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Onboarding Screen 3: "ابدأ رحلتك مع حمولة"
/// Direct Flutter port of prototype screen #screenOnboarding3.
class Onboarding3Screen extends StatefulWidget {
  final VoidCallback? onStartNow;
  final VoidCallback? onSkip;
  const Onboarding3Screen({super.key, this.onStartNow, this.onSkip});
  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen>
    with SingleTickerProviderStateMixin {
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
                    _buildBody(titleColor, descColor),
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
        _buildIllustration(),
        const SizedBox(height: 22.0),
        Text(
          AppStrings.onboarding3Title,
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
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 310.0),
          child: Text(
            AppStrings.onboarding3Desc,
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
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) => Transform.translate(
            offset: Offset(0.0, _floatAnimation.value),
            child: child,
          ),
          child: SizedBox(
            width: 280.0,
            height: 200.0,
            child: CustomPaint(painter: _JourneyTruckPainter()),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Color inactiveDotColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dot 1 (Inactive)
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(shape: BoxShape.circle, color: inactiveDotColor),
            ),
            const SizedBox(width: AppDimensions.spaceSm),
            // Dot 2 (Inactive)
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(shape: BoxShape.circle, color: inactiveDotColor),
            ),
            const SizedBox(width: AppDimensions.spaceSm),
            // Dot 3 (Active — gold pill 26x8)
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
          ],
        ),
        const SizedBox(height: AppDimensions.space2xl),
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
              onTap: widget.onStartNow,
              borderRadius: BorderRadius.circular(14.0),
              child: Center(
                child: Text(
                  AppStrings.startNow,
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

/// CustomPainter for Onboarding 3: Journey / Launch Truck Illustration
class _JourneyTruckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.475;

    // Radial halo
    canvas.drawCircle(
      Offset(cx, cy),
      78,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.22),
            const Color(0xFFF59E0B).withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 78)),
    );

    // Road line (wider 3.5px)
    canvas.drawLine(
      const Offset(20, 162),
      const Offset(260, 162),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x1AF59E0B), Color(0xD9F59E0B), Color(0x1AF59E0B)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(const Rect.fromLTWH(20, 162, 240, 3))
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    final dp = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(50, 171), const Offset(90, 171), dp);
    canvas.drawLine(const Offset(115, 171), const Offset(175, 171), dp);
    canvas.drawLine(const Offset(200, 171), const Offset(240, 171), dp);

    // GPS dashed route
    _drawDashed(
      canvas,
      Path()..moveTo(50, 115)..cubicTo(80, 85, 125, 65, 192, 48),
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.8)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
      dl: 6,
      gl: 4,
    );

    // Cargo box
    final br = RRect.fromLTRBR(52, 70, 160, 144, const Radius.circular(6));
    canvas.drawRRect(br, Paint()..color = const Color(0xFF1E293B));
    canvas.drawRRect(br, Paint()..color = const Color(0xFF334155)..strokeWidth = 2..style = PaintingStyle.stroke);
    final divPaint = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(78, 70), const Offset(78, 144), divPaint);
    canvas.drawLine(const Offset(108, 70), const Offset(108, 144), divPaint);
    canvas.drawLine(const Offset(134, 70), const Offset(134, 144), divPaint);

    // Gold launch band with arrows
    canvas.drawRect(const Rect.fromLTWH(52, 98, 108, 15), Paint()..color = const Color(0xF2F59E0B));
    final ap = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    // Arrow 1
    canvas.drawLine(const Offset(96, 105.5), const Offset(108, 105.5), ap);
    canvas.drawLine(const Offset(108, 105.5), const Offset(103, 101.5), ap);
    canvas.drawLine(const Offset(108, 105.5), const Offset(103, 109.5), ap);
    // Arrow 2
    canvas.drawLine(const Offset(120, 105.5), const Offset(132, 105.5), ap);
    canvas.drawLine(const Offset(132, 105.5), const Offset(127, 101.5), ap);
    canvas.drawLine(const Offset(132, 105.5), const Offset(127, 109.5), ap);

    // Truck cabin
    final cab = Path()
      ..moveTo(160, 68)
      ..lineTo(194, 68)
      ..cubicTo(204.5, 68, 213.3, 75.8, 215.2, 86.1)
      ..lineTo(222, 124)
      ..cubicTo(223, 129.5, 218.8, 134.5, 213.2, 134.5)
      ..lineTo(160, 134.5)
      ..close();
    canvas.drawPath(cab, Paint()..color = const Color(0xFF0F172A));
    canvas.drawPath(cab, Paint()..color = const Color(0xFF334155)..strokeWidth = 2..style = PaintingStyle.stroke);

    // Windshield
    final ws = Path()
      ..moveTo(168, 75)
      ..lineTo(192, 75)
      ..cubicTo(198.5, 75, 204, 79.8, 205.2, 86.2)
      ..lineTo(210.2, 112)
      ..lineTo(168, 112)
      ..close();
    canvas.drawPath(
      ws,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        ).createShader(const Rect.fromLTWH(168, 75, 42, 37)),
    );
    canvas.drawLine(
      const Offset(182, 78),
      const Offset(174, 108),
      Paint()..color = Colors.white.withValues(alpha: 0.6)..strokeWidth = 2.0..strokeCap = StrokeCap.round,
    );

    // Headlight + beam
    canvas.drawPath(
      Path()..moveTo(218, 120)..lineTo(224, 120)..lineTo(224, 128)..lineTo(217, 128)..close(),
      Paint()..color = const Color(0xFFF59E0B),
    );
    canvas.drawPath(
      Path()..moveTo(225, 124)..lineTo(265, 115)..lineTo(265, 133)..close(),
      Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.45),
    );

    // Truck base
    canvas.drawRRect(RRect.fromLTRBR(52, 142, 222, 150, const Radius.circular(2)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(RRect.fromLTRBR(160, 132, 220, 144, const Radius.circular(3)), Paint()..color = const Color(0xFF1E293B));

    // Wheels (r=16 for this truck)
    for (final wc in [194.0, 124.0, 80.0]) {
      _drawWheel16(canvas, Offset(wc, 154));
    }

    // Destination pin
    final pinPath = Path()
      ..moveTo(195, 42)
      ..cubicTo(187, 27, 181, 18, 181, 10)
      ..cubicTo(181, 1, 188, -6, 195, -6)
      ..cubicTo(202, -6, 209, 1, 209, 10)
      ..cubicTo(209, 18, 203, 27, 195, 42)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(pinPath, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawCircle(const Offset(195, 10), 6, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(const Offset(195, 10), 2.5, Paint()..color = Colors.white);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(195, 44), width: 20, height: 7),
      Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.3),
    );
  }

  void _drawWheel16(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 16, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(c, 16, Paint()..color = const Color(0xFF334155)..strokeWidth = 2..style = PaintingStyle.stroke);
    canvas.drawCircle(c, 10, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(c, 5, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawCircle(c, 2, Paint()..color = Colors.white);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint, {double dl = 6, double gl = 4}) {
    for (final m in path.computeMetrics()) {
      double d = 0;
      bool draw = true;
      while (d < m.length) {
        final sl = draw ? dl : gl;
        if (draw) canvas.drawPath(m.extractPath(d, d + sl), paint);
        d += sl;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
