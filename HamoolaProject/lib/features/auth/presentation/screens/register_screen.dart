import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/buttons/hamula_button.dart';

/// Available business roles in the Hamoola Platform
enum HamulaUserRole { merchant, driver, office }

/// Screen 10 in Prototype: "إنشاء حساب جديد" (Register Screen).
/// Faithfully reproduces `#screenRegister` with multi-role selection
/// (Merchant, Driver, Transport Office), full Yemeni validation, and terms agreement.
class RegisterScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onLogin;
  final VoidCallback? onTerms;
  final void Function(
    HamulaUserRole role,
    String fullName,
    String phone,
    String password,
  )?
  onSubmitRegister;

  const RegisterScreen({
    super.key,
    this.onBack,
    this.onLogin,
    this.onTerms,
    this.onSubmitRegister,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  HamulaUserRole _selectedRole = HamulaUserRole.merchant;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _agreeToTerms = false;
  bool _termsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() {
      _termsError = !_agreeToTerms;
    });

    if ((_formKey.currentState?.validate() ?? false) && _agreeToTerms) {
      widget.onSubmitRegister?.call(
        _selectedRole,
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
      );
    }
  }

  Widget _buildTermsAgreementRow(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.0,
              height: 20.0,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (val) {
                  setState(() {
                    _agreeToTerms = val ?? false;
                    if (_agreeToTerms) _termsError = false;
                  });
                },
                activeColor: AppColors.primaryGold,
                checkColor: AppColors.navyDark,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              AppStrings.agreeToTerms,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: InkWell(
                onTap: widget.onTerms,
                child: Text(
                  AppStrings.termsAndConditions,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldDark,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_termsError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 28.0),
            child: Text(
              AppStrings.termsRequiredError,
              style: GoogleFonts.cairo(fontSize: 11.5, color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return HamulaButton(
      label: AppStrings.registerSubmit,
      onPressed: _handleRegister,
      variant: HamulaButtonVariant.primary,
      size: HamulaButtonSize.lg,
    );
  }

  Widget _buildLoginPrompt(bool isDark) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          AppStrings.haveAccountPrompt,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 6.0),
        InkWell(
          onTap: widget.onLogin,
          child: Text(
            AppStrings.login,
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: AppColors.goldDark,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
        : const [Color(0xFFFFFFFF), Color(0xFFF8FAFC)];
    final titleColor = isDark ? AppColors.textWhite : const Color(0xFF0F172A);
    final descColor = isDark ? AppColors.textSubtle : const Color(0xFF64748B);

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space2xl,
                  vertical: AppDimensions.spaceMd,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopNavigation(isDark),
                      const SizedBox(height: 12.0),
                      _buildHeader(titleColor, descColor),
                      const SizedBox(height: 20.0),
                      _buildRoleSelector(isDark),
                      const SizedBox(height: 20.0),
                      _buildFullNameField(isDark),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _buildPhoneField(isDark),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _buildPasswordField(isDark),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _buildConfirmPasswordField(isDark),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _buildTermsAgreementRow(isDark),
                      const SizedBox(height: AppDimensions.spaceLg),
                      _buildSubmitButton(),
                      const SizedBox(height: AppDimensions.spaceLg),
                      _buildLoginPrompt(isDark),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation(bool isDark) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: IconButton(
        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18.0),
        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
        onPressed: widget.onBack,
        tooltip: AppStrings.back,
      ),
    );
  }

  Widget _buildHeader(Color titleColor, Color descColor) {
    return Column(
      children: [
        Text(
          AppStrings.register,
          style: GoogleFonts.cairo(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4.0),
        Text(
          AppStrings.registerWelcome,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: descColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectRole,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            // Role 1: Merchant
            Expanded(
              child: _buildRoleCard(
                role: HamulaUserRole.merchant,
                label: AppStrings.roleMerchant,
                icon: Icons.storefront_rounded,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8.0),
            // Role 2: Driver
            Expanded(
              child: _buildRoleCard(
                role: HamulaUserRole.driver,
                label: AppStrings.roleDriver,
                icon: Icons.local_shipping_rounded,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8.0),
            // Role 3: Transport Office
            Expanded(
              child: _buildRoleCard(
                role: HamulaUserRole.office,
                label: AppStrings.roleOffice,
                icon: Icons.apartment_rounded,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required HamulaUserRole role,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                    : const Color(0xFFFEF3C7))
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.20),
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 3.0),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24.0,
              color: isSelected ? AppColors.primaryGold : AppColors.textSubtle,
            ),
            const SizedBox(height: 6.0),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.textWhite : const Color(0xFF92400E))
                    : (isDark ? AppColors.textSubtle : AppColors.textMainLight),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.fullName,
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.cairo(
            fontSize: 14.5,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.nameRequiredError;
            }
            return null;
          },
          decoration: const InputDecoration(
            hintText: AppStrings.fullNameHint,
            prefixIcon: Icon(Icons.person_outline_rounded, size: 20.0),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.phoneNumber,
          style: GoogleFonts.cairo(
            fontSize: 13.0,
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.phoneRequiredError;
            }
            if (value.trim().length < 9) {
              return AppStrings.phoneInvalidError;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: AppStrings.phoneHint,
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              margin: const EdgeInsetsDirectional.only(end: 8.0),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLightInput,
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
      ],
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.password,
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXs),
        TextFormField(
          controller: _passwordController,
          obscureText: _isPasswordObscured,
          style: GoogleFonts.cairo(
            fontSize: 14.5,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.passwordRequiredError;
            }
            if (value.length < 6) {
              return AppStrings.passwordMinLengthError;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: AppStrings.passwordHint,
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20.0),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20.0,
                color: AppColors.textSubtle,
              ),
              onPressed: () {
                setState(() => _isPasswordObscured = !_isPasswordObscured);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          obscureText: _isConfirmPasswordObscured,
          style: GoogleFonts.cairo(
            fontSize: 14.5,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.passwordRequiredError;
            }
            if (value != _passwordController.text) {
              return AppStrings.passwordMismatchError;
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: AppStrings.confirmPasswordHint,
            prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20.0),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20.0,
                color: AppColors.textSubtle,
              ),
              onPressed: () {
                setState(
                  () =>
                      _isConfirmPasswordObscured = !_isConfirmPasswordObscured,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
