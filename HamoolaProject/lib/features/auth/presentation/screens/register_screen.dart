import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/auth_simulation_store.dart';
import '../../domain/models/auth_user.dart';

/// Available business and user roles in the Hamula Platform
enum HamulaUserRole { client, driver, merchant, office }

extension HamulaUserRoleX on HamulaUserRole {
  String get label {
    switch (this) {
      case HamulaUserRole.client:
        return AppStrings.roleClient;
      case HamulaUserRole.driver:
        return AppStrings.roleDriver;
      case HamulaUserRole.merchant:
        return AppStrings.roleMerchant;
      case HamulaUserRole.office:
        return AppStrings.roleOffice;
    }
  }

  IconData get icon {
    switch (this) {
      case HamulaUserRole.client:
        return Icons.person_outline_rounded;
      case HamulaUserRole.driver:
        return Icons.local_shipping_outlined;
      case HamulaUserRole.merchant:
        return Icons.storefront_outlined;
      case HamulaUserRole.office:
        return Icons.apartment_outlined;
    }
  }

  AuthUserRole toAuthUserRole() {
    switch (this) {
      case HamulaUserRole.client:
        return AuthUserRole.client;
      case HamulaUserRole.driver:
        return AuthUserRole.driver;
      case HamulaUserRole.merchant:
        return AuthUserRole.merchant;
      case HamulaUserRole.office:
        return AuthUserRole.office;
    }
  }
}

/// Screen 10 in Prototype: "إنشاء حساب جديد" (Register Screen).
/// Faithfully reproduces Hamula registration with brand identity:
/// - Brand Header with "حمولة HAMULA" and circular truck badge
/// - Title "إنشاء حساب جديد" & subtitle "انضم إلى مجتمع حمولة للنقل"
/// - 4 Role Selector Cards: عميل, سائق, تاجر, مكتب نقل
/// - Full Name input field with person icon
/// - Phone input field with country code (+967 / +966)
/// - Password input with visibility toggle
/// - Confirm password with match validation & visibility toggle
/// - Terms and conditions checkbox
/// - Duplicate phone validation against local simulation store
/// - Transitions to OtpVerifyScreen without prematurely verifying KYC status
class RegisterScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onLogin;
  final VoidCallback? onTerms;
  final void Function(
    HamulaUserRole role,
    String fullName,
    String phone,
    String password,
  )? onSubmitRegister;

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

  HamulaUserRole _selectedRole = HamulaUserRole.client;
  String _countryCode = '+967';
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _agreeToTerms = false;
  bool _termsError = false;
  bool _isLoading = false;
  String? _errorMessage;

  final List<HamulaUserRole> _roles = [
    HamulaUserRole.client,
    HamulaUserRole.driver,
    HamulaUserRole.merchant,
    HamulaUserRole.office,
  ];

  @override
  void initState() {
    super.initState();
    _applyRoleDemoDefaults(_selectedRole, force: true);
  }

  void _applyRoleDemoDefaults(HamulaUserRole role, {bool force = false}) {
    _countryCode = '+967';
    _agreeToTerms = false;
    _termsError = false;
    _errorMessage = null;
    switch (role) {
      case HamulaUserRole.client:
        _nameController.text = 'مصطفى صالح طنين';
        _phoneController.text = '777123456';
        _passwordController.text = 'Hamula@123';
        _confirmPasswordController.text = 'Hamula@123';
        break;
      case HamulaUserRole.merchant:
        _nameController.text = 'محمد أحمد';
        _phoneController.text = '771234567';
        _passwordController.text = 'Hamula@123';
        _confirmPasswordController.text = 'Hamula@123';
        break;
      case HamulaUserRole.driver:
        _nameController.text = 'أحمد صالح السالمي';
        _phoneController.text = '772345678';
        _passwordController.text = 'Hamula@123';
        _confirmPasswordController.text = 'Hamula@123';
        break;
      case HamulaUserRole.office:
        _nameController.text = 'صالح مسعد العمري';
        _phoneController.text = '774567890';
        _passwordController.text = 'Hamula@123';
        _confirmPasswordController.text = 'Hamula@123';
        break;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_isLoading) return;
    setState(() {
      _termsError = !_agreeToTerms;
      _errorMessage = null;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || !_agreeToTerms) {
      return;
    }

    final phone = _phoneController.text.trim();
    setState(() => _isLoading = true);

    // Register user into simulation store (unverified by default; handles edit deduplication)
    final registerResult = AuthSimulationStore.instance.register(
      role: _selectedRole.toAuthUserRole(),
      fullName: _nameController.text.trim(),
      phone: phone,
      password: _passwordController.text,
      countryCode: _countryCode,
    );

    setState(() => _isLoading = false);

    if (!registerResult.isSuccess) {
      setState(() {
        _errorMessage = registerResult.errorMessage ?? 'فشل إنشاء الحساب.';
      });
      return;
    }

    widget.onSubmitRegister?.call(
      _selectedRole,
      _nameController.text.trim(),
      phone,
      _passwordController.text,
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر الدولة',
                style: GoogleFonts.cairo(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12.0),
              ListTile(
                leading: const Text('🇾🇪', style: TextStyle(fontSize: 22.0)),
                title: Text(
                  'اليمن (+967)',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
                trailing: _countryCode == '+967'
                    ? const Icon(Icons.check, color: Color(0xFFE67E22))
                    : null,
                onTap: () {
                  setState(() => _countryCode = '+967');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇸🇦', style: TextStyle(fontSize: 22.0)),
                title: Text(
                  'السعودية (+966)',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
                trailing: _countryCode == '+966'
                    ? const Icon(Icons.check, color: Color(0xFFE67E22))
                    : null,
                onTap: () {
                  setState(() => _countryCode = '+966');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
    final titleColor = isDark ? AppColors.textWhite : const Color(0xFF0F172A);
    final descColor = isDark ? AppColors.textSubtle : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.compactMax),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: AppDimensions.spaceMd,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Back button
                    _buildTopNavigation(isDark),
                    const SizedBox(height: 6.0),

                    // 2. Brand Header (Logo + Title + Welcome subtitle)
                    _buildHeader(titleColor, descColor),
                    const SizedBox(height: 22.0),

                    // 3. 4 Role Selector Cards (عميل, سائق, تاجر, مكتب نقل)
                    _buildRoleSelector(isDark),
                    const SizedBox(height: 20.0),

                    // 4. Full Name Input Field
                    _buildFullNameField(isDark),
                    const SizedBox(height: 16.0),

                    // 5. Phone Input Field (+967 / +966)
                    _buildPhoneField(isDark),
                    const SizedBox(height: 16.0),

                    // 6. Password Input Field
                    _buildPasswordField(isDark),
                    const SizedBox(height: 16.0),

                    // 7. Confirm Password Input Field
                    _buildConfirmPasswordField(isDark),
                    const SizedBox(height: 14.0),

                    // 8. Terms & Conditions Agreement
                    _buildTermsAgreementRow(isDark),
                    const SizedBox(height: 16.0),

                    // 9. Inline Error Banner (if any)
                    if (_errorMessage != null) ...[
                      _buildInlineErrorMessage(),
                      const SizedBox(height: 12.0),
                    ],

                    // 10. Primary Submit Button
                    _buildSubmitButton(),
                    const SizedBox(height: 16.0),

                    // 11. Login Prompt ("لديك حساب بالفعل؟ تسجيل الدخول")
                    _buildLoginPrompt(isDark),
                    const SizedBox(height: 16.0),
                  ],
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
        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20.0),
        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
        onPressed: widget.onBack,
        tooltip: AppStrings.back,
      ),
    );
  }

  Widget _buildHeader(Color titleColor, Color descColor) {
    return Column(
      children: [
        // App Brand Logo matching LoginScreen
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'حمولة',
                  style: GoogleFonts.cairo(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    height: 1.1,
                  ),
                ),
                Text(
                  'HAMULA',
                  style: GoogleFonts.cairo(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE67E22),
                    letterSpacing: 2.0,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10.0),
            Container(
              width: 48.0,
              height: 48.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 26.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Text(
          AppStrings.register,
          style: GoogleFonts.cairo(
            fontSize: 22.0,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4.0),
        Text(
          AppStrings.registerWelcome,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
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
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10.0),
        Row(
          children: _roles.map((role) {
            final isSelected = _selectedRole == role;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedRole = role;
                      _applyRoleDemoDefaults(role, force: true);
                    });
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFFBEB)
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE67E22)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFE2E8F0)),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          role.icon,
                          size: 22.0,
                          color: isSelected
                              ? const Color(0xFFE67E22)
                              : (isDark
                                  ? AppColors.textSubtle
                                  : const Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          role.label,
                          style: GoogleFonts.cairo(
                            fontSize: 12.0,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFFE67E22)
                                : (isDark
                                    ? AppColors.textSubtle
                                    : const Color(0xFF64748B)),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFullNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.fullName,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: TextFormField(
            controller: _nameController,
            style: GoogleFonts.cairo(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: AppStrings.fullNameHint,
              hintStyle: GoogleFonts.cairo(
                fontSize: 13.5,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF94A3B8),
                size: 20.0,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 14.0,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.nameRequiredError;
              }
              return null;
            },
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
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              // Interactive country indicator
              InkWell(
                onTap: _showCountryPicker,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12.0),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                        size: 18.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _countryCode,
                        style: GoogleFonts.cairo(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE67E22),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _countryCode == '+967' ? 'YE' : 'SA',
                        style: GoogleFonts.cairo(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Phone text input
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  style: GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'أدخل رقم الهاتف',
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 13.5,
                      color: const Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF94A3B8),
                      size: 20.0,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 14.0,
                    ),
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
                ),
              ),
            ],
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
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _isPasswordObscured,
            style: GoogleFonts.cairo(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: AppStrings.passwordHint,
              hintStyle: GoogleFonts.cairo(
                fontSize: 13.5,
                color: const Color(0xFF94A3B8),
              ),
              suffixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF94A3B8),
                size: 20.0,
              ),
              prefixIcon: IconButton(
                icon: Icon(
                  _isPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 20.0,
                ),
                onPressed: () =>
                    setState(() => _isPasswordObscured = !_isPasswordObscured),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 14.0,
              ),
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
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: TextFormField(
            controller: _confirmPasswordController,
            obscureText: _isConfirmPasswordObscured,
            style: GoogleFonts.cairo(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: AppStrings.confirmPasswordHint,
              hintStyle: GoogleFonts.cairo(
                fontSize: 13.5,
                color: const Color(0xFF94A3B8),
              ),
              suffixIcon: const Icon(
                Icons.lock_reset_rounded,
                color: Color(0xFF94A3B8),
                size: 20.0,
              ),
              prefixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 20.0,
                ),
                onPressed: () => setState(
                  () => _isConfirmPasswordObscured = !_isConfirmPasswordObscured,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 14.0,
              ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAgreementRow(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 22.0,
              height: 22.0,
              child: Checkbox(
                value: _agreeToTerms,
                onChanged: (val) {
                  setState(() {
                    _agreeToTerms = val ?? false;
                    if (_agreeToTerms) _termsError = false;
                  });
                },
                activeColor: const Color(0xFFE67E22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
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
                    color: const Color(0xFFE67E22),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_termsError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 30.0),
            child: Text(
              AppStrings.termsRequiredError,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInlineErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFF87171)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 18.0,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF991B1B),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50.0,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE67E22),
          foregroundColor: Colors.white,
          elevation: 2.0,
          shadowColor: const Color(0x55E67E22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                AppStrings.registerSubmit,
                style: GoogleFonts.cairo(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginPrompt(bool isDark) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟ ',
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 4.0),
        InkWell(
          onTap: widget.onLogin,
          child: Text(
            'تسجيل الدخول',
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE67E22),
            ),
          ),
        ),
      ],
    );
  }
}
