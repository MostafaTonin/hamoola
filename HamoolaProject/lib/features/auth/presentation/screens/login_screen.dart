import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/auth_simulation_store.dart';
import '../../domain/models/auth_user.dart';
import '../widgets/demo_accounts_sheet.dart';

/// Screen 09 in Prototype: "تسجيل الدخول" (Login Screen).
/// Directly matches the user screenshot:
/// - Brand Header with "حمولة HAMULA" and circular truck badge
/// - Title "مرحباً بعودتك" & subtitle "قم بتسجيل الدخول للمتابعة"
/// - 4 Role Selector Cards: عميل, سائق, تاجر, مكتب نقل
/// - Phone field with +967 YE country selector and phone icon
/// - Password field with lock icon and visibility toggle
/// - "نسيت كلمة المرور؟" prompt
/// - Biometric fingerprint login card
/// - Primary "تسجيل الدخول" button
/// - "دخول بدون نت" offline checkbox + "ليس لديك حساب؟ إنشاء حساب"
/// - Bottom quick shortcuts: الرقم المجاني, نقاط الخدمة, خدمة العملاء
class LoginScreen extends StatefulWidget {
  final VoidCallback? onRegister;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onBiometricLogin;
  final void Function(String role, String phone, String password, bool isOffline)?
      onSubmitLogin;
  final VoidCallback? onTollFree;
  final VoidCallback? onServicePoints;
  final VoidCallback? onCustomerSupport;

  const LoginScreen({
    super.key,
    this.onRegister,
    this.onForgotPassword,
    this.onBiometricLogin,
    this.onSubmitLogin,
    this.onTollFree,
    this.onServicePoints,
    this.onCustomerSupport,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'عميل';
  String _countryCode = '+967';
  bool _isPasswordObscured = true;
  bool _isOfflineLogin = false;
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _roles = [
    {'id': 'عميل', 'label': 'عميل', 'icon': Icons.person_outline_rounded},
    {'id': 'سائق', 'label': 'سائق', 'icon': Icons.local_shipping_outlined},
    {'id': 'تاجر', 'label': 'تاجر', 'icon': Icons.storefront_outlined},
    {'id': 'مكتب نقل', 'label': 'مكتب نقل', 'icon': Icons.apartment_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _applyRoleDemoDefaults('عميل', force: true);
  }

  void _applyRoleDemoDefaults(String role, {bool force = false}) {
    _selectedRole = role;
    _countryCode = '+967';
    _errorMessage = null;
    if (role == 'عميل') {
      _phoneController.text = '777123456';
      _passwordController.text = 'Hamula@123';
    } else if (role == 'تاجر') {
      _phoneController.text = '771234567';
      _passwordController.text = 'Hamula@123';
    } else if (role == 'سائق') {
      _phoneController.text = '772345678';
      _passwordController.text = 'Hamula@123';
    } else if (role == 'مكتب نقل') {
      _phoneController.text = '774567890';
      _passwordController.text = 'Hamula@123';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_isLoading) return;
    setState(() => _errorMessage = null);

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final authResult = AuthSimulationStore.instance.login(
          role: _selectedRole,
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          isOffline: _isOfflineLogin,
        );

        if (!authResult.isSuccess) {
          setState(() {
            _errorMessage = authResult.errorMessage;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authResult.errorMessage ?? 'فشل تسجيل الدخول.',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }

        final resolvedRole = authResult.user?.role.label ?? _selectedRole;
        widget.onSubmitLogin?.call(
          resolvedRole,
          _phoneController.text.trim(),
          _passwordController.text,
          _isOfflineLogin,
        );
      });
    }
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
                    const SizedBox(height: 12.0),

                    // 1. Logo & Greeting Header
                    _buildLogoHeader(titleColor, descColor),
                    const SizedBox(height: 12.0),

                    // Quick Demo Accounts Pill
                    _buildDemoAccountsQuickButton(isDark),
                    const SizedBox(height: 18.0),

                    // 2. 4 Role Selector Cards
                    _buildRoleSelector(isDark),
                    const SizedBox(height: 22.0),

                    // 3. Phone Input Field (+967 YE)
                    _buildPhoneField(isDark),
                    const SizedBox(height: 16.0),

                    // 4. Password Input Field
                    _buildPasswordField(isDark),
                    const SizedBox(height: 10.0),

                    // 5. "نسيت كلمة المرور؟"
                    _buildForgotPasswordRow(),
                    const SizedBox(height: 16.0),

                    // 6. Biometric Fingerprint Button
                    _buildBiometricButton(isDark),
                    const SizedBox(height: 16.0),

                    // Inline Error Message Banner
                    if (_errorMessage != null) ...[
                      _buildInlineErrorMessage(),
                      const SizedBox(height: 12.0),
                    ],

                    // 7. Primary Login Button
                    _buildSubmitButton(),
                    const SizedBox(height: 16.0),

                    // 8. Offline Checkbox & Register Link
                    _buildSubActionsRow(isDark),
                    const SizedBox(height: 28.0),

                    // 9. Bottom Quick Service Buttons
                    _buildBottomShortcuts(isDark),
                    const SizedBox(height: 12.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader(Color titleColor, Color descColor) {
    return Column(
      children: [
        // App Brand Logo matching screenshot
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
        const SizedBox(height: 18.0),
        Text(
          'مرحباً بعودتك',
          style: GoogleFonts.cairo(
            fontSize: 22.0,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4.0),
        Text(
          'قم بتسجيل الدخول للمتابعة',
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

  Widget _buildDemoAccountsQuickButton(bool isDark) {
    return Center(
      child: InkWell(
        onTap: () {
          DemoAccountsSheet.show(
            context,
            onSelectAccount: (account) {
              setState(() {
                _selectedRole = account.role.label;
                _phoneController.text = account.phone;
                _passwordController.text = account.password;
                _errorMessage = null;
              });
            },
          );
        },
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.flash_on_rounded,
                size: 16.0,
                color: Color(0xFFE67E22),
              ),
              const SizedBox(width: 6.0),
              Flexible(
                child: Text(
                  'حسابات تجريبية',
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE67E22),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildRoleSelector(bool isDark) {
    return Row(
      children: _roles.map((role) {
        final isSelected = _selectedRole == role['id'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _applyRoleDemoDefaults(role['id'] as String, force: true);
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
                        : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0)),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      role['icon'] as IconData,
                      size: 22.0,
                      color: isSelected
                          ? const Color(0xFFE67E22)
                          : (isDark ? AppColors.textSubtle : const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      role['label'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 12.0,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFFE67E22)
                            : (isDark ? AppColors.textSubtle : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الهاتف',
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
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              // +967 YE Country code dropdown indicator
              InkWell(
                onTap: _showCountryPicker,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(12.0)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18.0),
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    if (val.trim().length != 9) {
                      return 'يرجى إدخال رقم هاتف يمني صحيح (9 أرقام)';
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
          'كلمة المرور',
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
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
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
              hintText: 'أدخل كلمة المرور',
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
                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordRow() {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: InkWell(
        onTap: widget.onForgotPassword,
        child: Text(
          'نسيت كلمة المرور؟',
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE67E22),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton(bool isDark) {
    return InkWell(
      onTap: widget.onBiometricLogin,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                color: Color(0xFFE67E22),
                size: 22.0,
              ),
            ),
            const SizedBox(width: 10.0),
            Flexible(
              child: Text(
                'تسجيل الدخول بالبصمة',
                style: GoogleFonts.cairo(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50.0,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
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
                'تسجيل الدخول',
                style: GoogleFonts.cairo(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSubActionsRow(bool isDark) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6.0,
      runSpacing: 6.0,
      children: [
        // Register prompt: "ليس لديك حساب؟ إنشاء حساب"
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ليس لديك حساب؟ ',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              ),
            ),
            InkWell(
              onTap: widget.onRegister,
              child: Text(
                'إنشاء حساب',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE67E22),
                ),
              ),
            ),
          ],
        ),

        // Offline login checkbox: "دخول بدون نت"
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'دخول بدون نت',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 4.0),
            SizedBox(
              width: 22.0,
              height: 22.0,
              child: Checkbox(
                value: _isOfflineLogin,
                activeColor: const Color(0xFFE67E22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                onChanged: (val) => setState(() => _isOfflineLogin = val ?? false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomShortcuts(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildShortcutItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'خدمة العملاء',
            onTap: widget.onCustomerSupport,
            isDark: isDark,
          ),
        ),
        Expanded(
          child: _buildShortcutItem(
            icon: Icons.location_on_outlined,
            label: 'نقاط الخدمة',
            onTap: widget.onServicePoints,
            isDark: isDark,
          ),
        ),
        Expanded(
          child: _buildShortcutItem(
            icon: Icons.phone_outlined,
            label: 'الرقم المجاني',
            onTap: widget.onTollFree,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutItem({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            Container(
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF64748B),
                size: 20.0,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
