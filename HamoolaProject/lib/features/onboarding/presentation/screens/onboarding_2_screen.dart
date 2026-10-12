import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Onboarding Screen 2: "نقل آمن وموثوق"
/// Direct Flutter port of prototype screen #screenOnboarding2.
class Onboarding2Screen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  const Onboarding2Screen({super.key, this.onNext, this.onSkip});
  @override
  State<Onboarding2Screen> createState() => _Onboarding2ScreenState();
}

class _Onboarding2ScreenState extends State<Onboarding2Screen>
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
          AppStrings.onboarding2Title,
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
            AppStrings.onboarding2Desc,
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
            child: CustomPaint(painter: _ShieldTruckPainter()),
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
            // Dot 2 (Active — gold pill 26x8)
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
            // Dot 3 (Inactive)
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(shape: BoxShape.circle, color: inactiveDotColor),
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

/// CustomPainter for Onboarding 2: Shield + Secured Truck Illustration
class _ShieldTruckPainter extends CustomPainter {
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

    // Road line
    canvas.drawLine(
      const Offset(25, 162),
      const Offset(255, 162),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x1AF59E0B), Color(0xCCF59E0B), Color(0x1AF59E0B)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(const Rect.fromLTWH(25, 162, 230, 3))
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final dp = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(60, 171), const Offset(95, 171), dp);
    canvas.drawLine(const Offset(120, 171), const Offset(170, 171), dp);
    canvas.drawLine(const Offset(195, 171), const Offset(230, 171), dp);

    // Shield outer fill
    final shieldPath = Path()
      ..moveTo(140, 22)
      ..cubicTo(185, 22, 215, 36, 218, 52)
      ..cubicTo(218, 112, 175, 146, 140, 164)
      ..cubicTo(105, 146, 62, 112, 62, 52)
      ..cubicTo(65, 36, 95, 22, 140, 22)
      ..close();
    canvas.drawPath(
      shieldPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF21E293B), Color(0xD90F172A), Color(0xF21E293B)],
          stops: [0.0, 0.7, 1.0],
        ).createShader(const Rect.fromLTWH(62, 22, 156, 142)),
    );
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // Shield inner dashed ring
    final innerPath = Path()
      ..moveTo(140, 30)
      ..cubicTo(176, 30, 202, 42, 205, 56)
      ..cubicTo(205, 106, 168, 136, 140, 152)
      ..cubicTo(112, 136, 75, 106, 75, 56)
      ..cubicTo(78, 42, 104, 30, 140, 30)
      ..close();
    _drawDashed(
      canvas,
      innerPath,
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Grid lines
    final gp = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(90, 60)..quadraticBezierTo(140, 45, 190, 60), gp);
    canvas.drawPath(Path()..moveTo(98, 80)..quadraticBezierTo(140, 68, 182, 80), gp);

    // Cargo box
    final br = RRect.fromLTRBR(68, 76, 162, 144, const Radius.circular(6));
    canvas.drawRRect(br, Paint()..color = const Color(0xFF1E293B));
    canvas.drawRRect(br, Paint()..color = const Color(0xFF334155)..strokeWidth = 2..style = PaintingStyle.stroke);
    final divPaint = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(92, 76), const Offset(92, 144), divPaint);
    canvas.drawLine(const Offset(124, 76), const Offset(124, 144), divPaint);

    // Lock band
    canvas.drawRect(const Rect.fromLTWH(68, 100, 94, 15), Paint()..color = const Color(0xF2F59E0B));
    canvas.drawCircle(const Offset(115, 107.5), 5, Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(
      RRect.fromLTRBR(112.5, 105.5, 117.5, 109.5, const Radius.circular(1)),
      Paint()..color = Colors.white,
    );
    canvas.drawPath(
      Path()
        ..moveTo(113.5, 105.5)
        ..lineTo(113.5, 104.2)
        ..cubicTo(113.5, 103.5, 114.2, 103, 115, 103)
        ..cubicTo(115.8, 103, 116.5, 103.5, 116.5, 104.2)
        ..lineTo(116.5, 105.5),
      Paint()..color = Colors.white..strokeWidth = 1.0..style = PaintingStyle.stroke,
    );

    // Cabin
    final cab = Path()
      ..moveTo(162, 76)
      ..lineTo(188, 76)
      ..cubicTo(197.5, 76, 205.5, 83, 207.2, 92.5)
      ..lineTo(213, 124)
      ..cubicTo(214, 129.5, 209.8, 134.5, 204.2, 134.5)
      ..lineTo(162, 134.5)
      ..close();
    canvas.drawPath(cab, Paint()..color = const Color(0xFF0F172A));
    canvas.drawPath(cab, Paint()..color = const Color(0xFF334155)..strokeWidth = 2..style = PaintingStyle.stroke);

    // Windshield
    final ws = Path()
      ..moveTo(168, 82)
      ..lineTo(188, 82)
      ..cubicTo(193.5, 82, 198, 86, 199.2, 91.5)
      ..lineTo(203.2, 114)
      ..lineTo(168, 114)
      ..close();
    canvas.drawPath(
      ws,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        ).createShader(const Rect.fromLTWH(168, 82, 35, 32)),
    );
    canvas.drawLine(
      const Offset(178, 84),
      const Offset(171, 110),
      Paint()..color = Colors.white.withValues(alpha: 0.6)..strokeWidth = 1.8..strokeCap = StrokeCap.round,
    );

    // Headlight
    canvas.drawPath(
      Path()..moveTo(209, 120)..lineTo(215, 120)..lineTo(215, 128)..lineTo(208, 128)..close(),
      Paint()..color = const Color(0xFFF59E0B),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(222, 124), width: 14, height: 8),
      Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.35),
    );

    // Truck base
    canvas.drawRRect(RRect.fromLTRBR(68, 142, 214, 150, const Radius.circular(2)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(RRect.fromLTRBR(162, 132, 210, 144, const Radius.circular(3)), Paint()..color = const Color(0xFF1E293B));

    // Wheels
    for (final cx in [190.0, 132.0, 92.0]) {
      _drawWheel(canvas, Offset(cx, 154));
    }

    // Verified badge
    const bc = Offset(140, 48);
    canvas.drawCircle(bc, 18, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(bc, 18, Paint()..color = const Color(0xFFF59E0B)..strokeWidth = 2.5..style = PaintingStyle.stroke);
    canvas.drawCircle(bc, 13, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawPath(
      Path()..moveTo(135, 48.5)..lineTo(138.5, 52)..lineTo(145, 45),
      Paint()..color = const Color(0xFF0F172A)..strokeWidth = 2.8..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke,
    );
  }

  void _drawWheel(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 15, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(c, 15, Paint()..color = const Color(0xFF334155)..strokeWidth = 2..style = PaintingStyle.stroke);
    canvas.drawCircle(c, 9, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(c, 4.5, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawCircle(c, 2, Paint()..color = Colors.white);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint, {double dl = 5, double gl = 4}) {
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
