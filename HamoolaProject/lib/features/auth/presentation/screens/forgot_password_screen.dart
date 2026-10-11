import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/buttons/hamula_button.dart';

/// Screen 19 in Prototype: "استعادة كلمة المرور" (Forgot Password).
/// Faithfully reproduces `#screenForgotPassword` with 3-stage flow:
/// Stage 1: Phone input -> Stage 2: 6-digit OTP verification -> Stage 3: New password.
class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback? onBackToLogin;

  const ForgotPasswordScreen({
    super.key,
    this.onBackToLogin,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 1; // 1 = Phone, 2 = OTP, 3 = New Password, 4 = Success

  // Form Controllers
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isNewPassObscured = true;
  bool _isConfirmPassObscured = true;

  // Countdown timer for OTP resend
  int _secondsRemaining = 59;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _secondsRemaining = 59;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _submitPhone() {
    final phone = _phoneController.text.trim();
    if (phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.phoneInvalidError)),
      );
      return;
    }
    setState(() {
      _currentStep = 2;
    });
    _startCountdown();
  }

  void _submitOtp() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رمز التحقق المكون من 6 أرقام')),
      );
      return;
    }
    setState(() {
      _currentStep = 3;
    });
  }

  void _submitNewPassword() {
    final pass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.passwordMinLengthError)),
      );
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.passwordMismatchError)),
      );
      return;
    }
    setState(() {
      _currentStep = 4; // Success
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18.0),
          onPressed: () {
            if (_currentStep == 2) {
              setState(() => _currentStep = 1);
            } else if (_currentStep == 3) {
              setState(() => _currentStep = 2);
            } else {
              widget.onBackToLogin?.call();
            }
          },
          tooltip: AppStrings.back,
        ),
        title: Text(
          'استعادة كلمة المرور',
          style: GoogleFonts.cairo(
            fontSize: 18.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.compactMax),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space2xl,
                vertical: AppDimensions.spaceLg,
              ),
              child: switch (_currentStep) {
                1 => _buildStep1Phone(isDark),
                2 => _buildStep2Otp(isDark),
                3 => _buildStep3NewPassword(isDark),
                _ => _buildStep4Success(isDark),
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1: Phone Input
  // ---------------------------------------------------------------------------
  Widget _buildStep1Phone(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepBadge(Icons.lock_reset_rounded, isDark),
        const SizedBox(height: 18.0),
        Text(
          'استعادة كلمة المرور',
          style: GoogleFonts.cairo(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6.0),
        Text(
          'أدخل رقم هاتفك المسجل لاستلام رمز التحقق لتعيين كلمة مرور جديدة',
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32.0),
        // Phone input
        Text(
          AppStrings.phoneNumber,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          textDirection: TextDirection.ltr,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.phoneHint,
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              margin: const EdgeInsetsDirectional.only(end: 8.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLightInput,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇾🇪', style: TextStyle(fontSize: 18.0)),
                  const SizedBox(width: 6.0),
                  Text(
                    AppStrings.yemenCountryCode,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textWhite : AppColors.navyDark,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28.0),
        HamulaButton(
          label: 'إرسال رمز التحقق',
          onPressed: _submitPhone,
          variant: HamulaButtonVariant.primary,
          size: HamulaButtonSize.lg,
        ),
        const SizedBox(height: 16.0),
        Center(
          child: TextButton(
            onPressed: widget.onBackToLogin,
            child: Text(
              'العودة لتسجيل الدخول',
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.goldDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: 6-Digit OTP Verification
  // ---------------------------------------------------------------------------
  Widget _buildStep2Otp(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepBadge(Icons.security_rounded, isDark),
        const SizedBox(height: 18.0),
        Text(
          'التحقق من رقم الهاتف',
          style: GoogleFonts.cairo(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6.0),
        Text(
          'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى هاتفك',
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4.0),
        Text(
          '+967 ${_phoneController.text}',
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGold,
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28.0),
        // 6 Digits Row
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _buildOtpDigitBox(i, isDark)),
          ),
        ),
        const SizedBox(height: 20.0),
        // Resend Timer Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16.0, color: AppColors.primaryGold),
                const SizedBox(width: 4.0),
                Text(
                  '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _secondsRemaining == 0 ? _startCountdown : null,
              child: Text(
                'إعادة إرسال الرمز',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _secondsRemaining == 0 ? AppColors.goldDark : AppColors.textSubtle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        HamulaButton(
          label: 'تحقق ومتابعة',
          onPressed: _submitOtp,
          variant: HamulaButtonVariant.primary,
          size: HamulaButtonSize.lg,
        ),
        const SizedBox(height: 12.0),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: Text(
              'تعديل رقم الهاتف',
              style: GoogleFonts.cairo(
                fontSize: 13.0,
                color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpDigitBox(int index, bool isDark) {
    return SizedBox(
      width: 46.0,
      height: 52.0,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: GoogleFonts.ibmPlexSansArabic(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textWhite : AppColors.textMainLight,
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLightInput,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: const BorderSide(color: AppColors.primaryGold, width: 2.0),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3: New Password
  // ---------------------------------------------------------------------------
  Widget _buildStep3NewPassword(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepBadge(Icons.lock_outline_rounded, isDark),
        const SizedBox(height: 18.0),
        Text(
          'تعيين كلمة المرور الجديدة',
          style: GoogleFonts.cairo(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6.0),
        Text(
          'أنشئ كلمة مرور قوية لتأمين حسابك في المنصة',
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28.0),
        Text(
          'كلمة المرور الجديدة',
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        TextFormField(
          controller: _newPasswordController,
          obscureText: _isNewPassObscured,
          style: GoogleFonts.cairo(
            fontSize: 14.5,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل كلمة المرور الجديدة (6 أحرف فأكثر)',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20.0),
            suffixIcon: IconButton(
              icon: Icon(
                _isNewPassObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20.0,
                color: AppColors.textSubtle,
              ),
              onPressed: () => setState(() => _isNewPassObscured = !_isNewPassObscured),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        Text(
          AppStrings.confirmPassword,
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _isConfirmPassObscured,
          style: GoogleFonts.cairo(
            fontSize: 14.5,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.confirmPasswordHint,
            prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20.0),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPassObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20.0,
                color: AppColors.textSubtle,
              ),
              onPressed: () =>
                  setState(() => _isConfirmPassObscured = !_isConfirmPassObscured),
            ),
          ),
        ),
        const SizedBox(height: 28.0),
        HamulaButton(
          label: 'حفظ وتحديث كلمة المرور',
          onPressed: _submitNewPassword,
          variant: HamulaButtonVariant.primary,
          size: HamulaButtonSize.lg,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 4: Success State
  // ---------------------------------------------------------------------------
  Widget _buildStep4Success(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24.0),
        Center(
          child: Container(
            width: 84.0,
            height: 84.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.successBg,
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 58.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          'تم تحديث كلمة المرور بنجاح!',
          style: GoogleFonts.cairo(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Text(
          'يمكنك الآن تسجيل الدخول إلى حسابك باستخدام كلمة المرور الجديدة.',
          style: GoogleFonts.cairo(
            fontSize: 14.0,
            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36.0),
        HamulaButton(
          label: 'تسجيل الدخول الآن',
          onPressed: widget.onBackToLogin,
          variant: HamulaButtonVariant.primary,
          size: HamulaButtonSize.lg,
        ),
      ],
    );
  }

  Widget _buildStepBadge(IconData icon, bool isDark) {
    return Center(
      child: Container(
        width: 72.0,
        height: 72.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.goldBrandGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.30),
              blurRadius: 16.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 34.0,
            color: AppColors.navyDark,
          ),
        ),
      ),
    );
  }
}
