import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// The official Splash Screen of the Hamoola platform.
/// Directly mirrors the HTML/CSS/JS prototype with faithful visual tokens,
/// subtle entrance animation, pulsing wave loading dots, and lifecycle-safe navigation.
class SplashScreen extends StatefulWidget {
  final Duration duration;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navigationTimer;

  // Entrance animation controller for center brand content (600ms)
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  // Continuous looping controller for the 3 loading dots (1400ms)
  late final AnimationController _dotsController;

  @override
  void initState() {
    super.initState();

    _setupAnimations();
    _startNavigationTimer();
  }

  void _setupAnimations() {
    // 600ms entrance matching CSS `@keyframes splashEntrance`
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final curvedEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Cubic(0.16, 1.0, 0.3, 1.0),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedEntrance);
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(curvedEntrance);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(curvedEntrance);

    _entranceController.forward();

    // 1400ms loop matching CSS `@keyframes dotPulseWave`
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(widget.duration, _onTimerComplete);
  }

  void _onTimerComplete() {
    if (!mounted) return;
    context.go(AppRoutes.onboarding1);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background gradient:
    // Light: linear-gradient(180deg, #FFFFFF 0%, #F1F5F9 100%)
    // Dark:  linear-gradient(180deg, #0F172A 0%, #1E293B 100%)
    final gradientColors = isDark
        ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
        : const [Color(0xFFFFFFFF), Color(0xFFF1F5F9)];

    final titleColor = isDark ? AppColors.textWhite : const Color(0xFF0F172A);
    final taglineColor = isDark ? AppColors.textSubtle : const Color(0xFF64748B);
    final versionColor = isDark ? const Color(0xFF64748B) : AppColors.textSubtle;
    final titleShadowColor = isDark
        ? const Color.fromRGBO(0, 0, 0, 0.45)
        : const Color.fromRGBO(15, 23, 42, 0.08);

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
                  vertical: AppDimensions.space2xl,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox.shrink(),

                    // Central Brand Section
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Glowing Badge with Truck SVG
                              _buildLogoBadge(),
                              const SizedBox(height: AppDimensions.spaceXl),

                              // Brand Title
                              Text(
                                'حمولة',
                                style: GoogleFonts.cairo(
                                  fontSize: 38.0,
                                  fontWeight: FontWeight.w900,
                                  color: titleColor,
                                  letterSpacing: 0.5,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color: titleShadowColor,
                                      blurRadius: 16.0,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.spaceXs),

                              // Tagline
                              Text(
                                'منصتك الذكية لربط الشحنات والشاحنات',
                                style: GoogleFonts.cairo(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: taglineColor,
                                  height: 1.5,
                                  letterSpacing: 0.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer with Animated Wave Dots & Version
                    _buildFooter(versionColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoBadge() {
    return Container(
      width: 120.0,
      height: 120.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // Logo glow layer matching `.logo-glow-layer`
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            blurRadius: 30.0,
            spreadRadius: 6.0,
          ),
        ],
      ),
      child: SvgPicture.asset(
        'assets/icons/hamula_truck_logo.svg',
        width: 120.0,
        height: 120.0,
      ),
    );
  }

  Widget _buildFooter(Color versionColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3 Loading Dots with sequential pulsing wave
        AnimatedBuilder(
          animation: _dotsController,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(0),
                const SizedBox(width: AppDimensions.spaceSm),
                _buildDot(1),
                const SizedBox(width: AppDimensions.spaceSm),
                _buildDot(2),
              ],
            );
          },
        ),
        const SizedBox(height: AppDimensions.spaceMd),

        // App Version
        Text(
          'الإصدار 1.0.0',
          style: GoogleFonts.cairo(
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            color: versionColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    // Phase shift each dot by ~0.20 to match 0.22s delay
    final progress = (_dotsController.value - (index * 0.20)) % 1.0;

    // Peak at 0.5 cycle
    final normalized = (progress < 0.5)
        ? (progress / 0.5)
        : (1.0 - (progress - 0.5) / 0.5);

    final scale = 0.85 + (0.45 * normalized);
    final isPulsing = normalized > 0.4;

    final dotColor = isPulsing
        ? AppColors.primaryGold
        : const Color.fromRGBO(148, 163, 184, 0.35);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 7.5,
        height: 7.5,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
          boxShadow: isPulsing
              ? [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.55),
                    blurRadius: 8.0,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
