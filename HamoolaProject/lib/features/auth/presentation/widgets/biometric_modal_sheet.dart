import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Interactive Biometric Authentication Modal Sheet.
/// Matches prototype `#biometricModal` with glowing sensor, haptic animation,
/// simulation of success, and automatic transition.
class BiometricModalSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const BiometricModalSheet({
    super.key,
    required this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BiometricModalSheet(onSuccess: onSuccess),
    );
  }

  @override
  State<BiometricModalSheet> createState() => _BiometricModalSheetState();
}

class _BiometricModalSheetState extends State<BiometricModalSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  Timer? _autoVerifyTimer;
  Timer? _popTimer;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-verify simulation after 1.5 seconds (or user can tap immediately)
    _autoVerifyTimer = Timer(const Duration(milliseconds: 1500), _verifyBiometrics);
  }

  void _verifyBiometrics() {
    if (_isVerified || !mounted) return;
    setState(() => _isVerified = true);
    _pulseController.stop();

    _popTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSuccess();
    });
  }

  @override
  void dispose() {
    _autoVerifyTimer?.cancel();
    _popTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
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

            // Modal Header
            Text(
              _isVerified ? 'تم التحقق بنجاح!' : 'المصادقة بالبصمة',
              style: GoogleFonts.cairo(
                fontSize: 19.0,
                fontWeight: FontWeight.w700,
                color: _isVerified
                    ? AppColors.success
                    : (isDark ? AppColors.textWhite : AppColors.textMainLight),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6.0),
            Text(
              _isVerified
                  ? 'جاري تسجيل الدخول إلى حسابك...'
                  : 'المس مستشعر البصمة للمتابعة وتسجيل الدخول',
              style: GoogleFonts.cairo(
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28.0),

            // Animated Sensor Target
            GestureDetector(
              onTap: _verifyBiometrics,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _isVerified ? 1.0 : _pulseAnimation.value,
                  child: child,
                ),
                child: Container(
                  width: 96.0,
                  height: 96.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isVerified
                        ? AppColors.successBg
                        : const Color(0xFFFEF3C7),
                    border: Border.all(
                      color: _isVerified ? AppColors.success : AppColors.primaryGold,
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isVerified ? AppColors.success : AppColors.primaryGold)
                            .withValues(alpha: 0.35),
                        blurRadius: 18.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isVerified
                          ? Icons.check_circle_rounded
                          : Icons.fingerprint_rounded,
                      size: 52.0,
                      color: _isVerified ? AppColors.success : AppColors.primaryGold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),

            // Cancel action button
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightMd,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderSm,
                  ),
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
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
