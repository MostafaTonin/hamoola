import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../merchant/presentation/widgets/merchant_bottom_nav_bar.dart';

/// Screen representing the Client's "حسابي" (My Account) Screen.
/// Faithfully reproduces Image 1 from the user prompt:
/// - Top App Bar: "< حسابي"
/// - Centered Profile Card:
///   - Centered circular avatar with camera edit badge
///   - User Name: "مصطفى يحيى صالح طنين"
///   - Verified Badge: "موثق" with green checkmark
///   - 2 Info Columns: "رقم الهاتف" (+967 777 123 456) & "رقم الحساب" (783707104) with copy actions
///   - Action Button: "تعديل بيانات الحساب" with edit pencil
/// - 3 Horizontal Activity Summary Cards:
///   - Right: "حمولة مسجلة" (12, Orange Box Icon)
///   - Center: "طلبات نشطة" (9, Blue Truck Icon)
///   - Left: "رحلة مكتملة" (24, Green Checkmark Icon)
/// - Section: "بيانات الحساب" (تعديل بيانات الحساب, تحديث بيانات الهوية, بيانات التواصل, العنوان والموقع)
/// - Section: "عمليات حمولة" (طلباتي, حمولاتي, محفظتي)
/// - Accordion: "إدارة المفضلة والاقتراحات" (إدارة المفضلة)
/// - Accordion: "الخصوصية والأمان" (تغيير رمز التأكيد, تغيير كلمة المرور, استخدام البصمة لتسجيل الدخول, استخدام البصمة لتأكيد الدفع, الشروط والأحكام, سياسة الخصوصية)
/// - Accordion: "الدعم والمساعدة" (خدمة العملاء, مواقع التواصل, الرقم المجاني, نقاط الخدمة)
/// - Single Card: "إعدادات إضافية"
/// - Accordion: "تخصيص التطبيق" (مظهر التطبيق, لغة التطبيق)
/// - Single Card: "مشاركة تطبيق حمولة"
/// - Logout Card: "تسجيل الخروج" in red
/// - Bottom Navigation Bar (5 tabs with "حسابي" active in red)
class ClientAccountScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final VoidCallback? onOrders;
  final VoidCallback? onCargos;
  final VoidCallback? onMap;
  final VoidCallback? onWallet;
  final VoidCallback? onIdentityUpdate;
  final VoidCallback? onSettings;
  final VoidCallback? onSupport;
  final VoidCallback? onTerms;
  final VoidCallback? onLogout;
  final VoidCallback? onFab;

  const ClientAccountScreen({
    super.key,
    this.onBack,
    this.onHome,
    this.onOrders,
    this.onCargos,
    this.onMap,
    this.onWallet,
    this.onIdentityUpdate,
    this.onSettings,
    this.onSupport,
    this.onTerms,
    this.onLogout,
    this.onFab,
  });

  @override
  State<ClientAccountScreen> createState() => _ClientAccountScreenState();
}

class _ClientAccountScreenState extends State<ClientAccountScreen> {
  // Accordion expansion states
  bool _isFavoritesExpanded = false;
  bool _isSecurityExpanded = true;
  bool _isSupportExpanded = true;
  bool _isCustomizationExpanded = false;

  // Toggle switch states
  bool _useBiometricsLogin = true;
  bool _useBiometricsPayment = false;

  AuthUser get _currentUser {
    final store = AuthSimulationStore.instance;
    final current = store.currentUser;
    if (current != null && current.role == AuthUserRole.client) {
      return current;
    }
    return store.getDemoUserByRole(AuthUserRole.client) ?? store.users.first;
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ $label: $text', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoDialog(String title, String content, IconData icon) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          content: Text(
            content,
            style: GoogleFonts.cairo(fontSize: 13, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إغلاق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditProfileDialog() {
    final user = _currentUser;
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تعديل بيانات الحساب',
                style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  final newName = nameCtrl.text.trim();
                  if (newName.isNotEmpty) {
                    final updated = user.copyWith(name: newName);
                    AuthSimulationStore.instance.registerUser(updated);
                    setState(() {});
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث بيانات الحساب بنجاح', style: GoogleFonts.cairo()),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('حفظ التعديلات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.navyDark : const Color(0xFFF8FAFC),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppBreakpoints.compactMax),
              child: Column(
                children: [
                  // 1. Top App Bar: "< حسابي"
                  _buildHeader(isDark),

                  // 2. Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceMd,
                        vertical: AppDimensions.spaceSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Profile Card (Image 1)
                          _buildProfileCard(isDark),
                          const SizedBox(height: 14),

                          // 3 Horizontal Activity Summary Cards (Image 1)
                          _buildActivitySummaryRow(isDark),
                          const SizedBox(height: 18),

                          // Section: "بيانات الحساب" (Image 1)
                          _buildSectionHeader('بيانات الحساب', isDark),
                          const SizedBox(height: 8),
                          _buildCardGroup(
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.person_outline_rounded,
                                title: 'تعديل بيانات الحساب',
                                isDark: isDark,
                                onTap: _openEditProfileDialog,
                              ),
                              _buildMenuItem(
                                icon: Icons.badge_outlined,
                                title: 'تحديث بيانات الهوية',
                                isDark: isDark,
                                onTap: widget.onIdentityUpdate ??
                                    () {
                                      _showInfoDialog(
                                        'بيانات الهوية',
                                        'رقم الهوية: TEST-YE-100245\nجهة الإصدار: الأحوال المدنية — صنعاء\nحالة التوثيق: موثق معتمد',
                                        Icons.badge_outlined,
                                      );
                                    },
                              ),
                              _buildMenuItem(
                                icon: Icons.phone_outlined,
                                title: 'بيانات التواصل',
                                isDark: isDark,
                                onTap: () => _showInfoDialog(
                                  'بيانات التواصل',
                                  'الهاتف المسجل: +967 777 123 456\nالاسم: ${_currentUser.name}',
                                  Icons.phone_outlined,
                                ),
                              ),
                              _buildMenuItem(
                                icon: Icons.location_on_outlined,
                                title: 'العنوان والموقع',
                                isDark: isDark,
                                onTap: () => _showInfoDialog(
                                  'العنوان والموقع',
                                  'المدينة: صنعاء\nالمنطقة: شارع الستين',
                                  Icons.location_on_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Section: "عمليات حمولة" (Image 1)
                          _buildSectionHeader('عمليات حمولة', isDark),
                          const SizedBox(height: 8),
                          _buildCardGroup(
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.receipt_long_outlined,
                                title: 'طلباتي',
                                isDark: isDark,
                                onTap: widget.onOrders,
                              ),
                              _buildMenuItem(
                                icon: Icons.inventory_2_outlined,
                                title: 'حمولاتي',
                                isDark: isDark,
                                onTap: widget.onCargos,
                              ),
                              _buildMenuItem(
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'محفظتي',
                                isDark: isDark,
                                onTap: widget.onWallet,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Accordion Section: "إدارة المفضلة والاقتراحات" (Image 1)
                          _buildAccordionSection(
                            title: 'إدارة المفضلة والاقتراحات',
                            icon: Icons.favorite_rounded,
                            iconColor: const Color(0xFFEF4444),
                            isExpanded: _isFavoritesExpanded,
                            onToggle: () => setState(() => _isFavoritesExpanded = !_isFavoritesExpanded),
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.star_rounded,
                                iconColor: const Color(0xFFEF4444),
                                title: 'إدارة المفضلة',
                                isDark: isDark,
                                onTap: () => _showInfoDialog(
                                  'المفضلة',
                                  'قائمة السائقين والمكاتب المفضلة لديك فارغة حالياً.',
                                  Icons.star_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Accordion Section: "الخصوصية والأمان" (Image 1)
                          _buildAccordionSection(
                            title: 'الخصوصية والأمان',
                            icon: Icons.shield_rounded,
                            iconColor: const Color(0xFF2563EB),
                            isExpanded: _isSecurityExpanded,
                            onToggle: () => setState(() => _isSecurityExpanded = !_isSecurityExpanded),
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.lock_outline_rounded,
                                title: 'تغيير رمز التأكيد',
                                isDark: isDark,
                                onTap: () => _showInfoDialog(
                                  'رمز التأكيد',
                                  'يمكنك إعادة تعيين رمز التأكيد PIN لحسابك.',
                                  Icons.lock_outline_rounded,
                                ),
                              ),
                              _buildMenuItem(
                                icon: Icons.vpn_key_outlined,
                                title: 'تغيير كلمة المرور',
                                isDark: isDark,
                                onTap: () => _showInfoDialog(
                                  'كلمة المرور',
                                  'لتغيير كلمة المرور، يرجى إدخال كلمة المرور الحالية والجديدة.',
                                  Icons.vpn_key_outlined,
                                ),
                              ),
                              _buildSwitchMenuItem(
                                title: 'استخدام البصمة لتسجيل الدخول',
                                value: _useBiometricsLogin,
                                onChanged: (val) => setState(() => _useBiometricsLogin = val),
                                isDark: isDark,
                              ),
                              _buildSwitchMenuItem(
                                title: 'استخدام البصمة لتأكيد الدفع',
                                value: _useBiometricsPayment,
                                onChanged: (val) => setState(() => _useBiometricsPayment = val),
                                isDark: isDark,
                              ),
                              _buildMenuItem(
                                icon: Icons.description_outlined,
                                title: 'الشروط والأحكام',
                                isDark: isDark,
                                onTap: widget.onTerms,
                              ),
                              _buildMenuItem(
                                icon: Icons.verified_user_outlined,
                                title: 'سياسة الخصوصية',
                                isDark: isDark,
                                onTap: widget.onTerms,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Accordion Section: "الدعم والمساعدة" (Image 1)
                          _buildAccordionSection(
                            title: 'الدعم والمساعدة',
                            icon: Icons.headset_mic_rounded,
                            iconColor: const Color(0xFF2563EB),
                            isExpanded: _isSupportExpanded,
                            onToggle: () => setState(() => _isSupportExpanded = !_isSupportExpanded),
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.chat_bubble_outline_rounded,
                                title: 'خدمة العملاء',
                                isDark: isDark,
                                onTap: widget.onSupport,
                              ),
                              _buildMenuItem(
                                icon: Icons.share_outlined,
                                title: 'مواقع التواصل',
                                isDark: isDark,
                                onTap: widget.onSupport,
                              ),
                              _buildMenuItem(
                                icon: Icons.phone_in_talk_outlined,
                                title: 'الرقم المجاني',
                                isDark: isDark,
                                onTap: () => _copyToClipboard('8000000', 'الرقم المجاني'),
                              ),
                              _buildMenuItem(
                                icon: Icons.location_on_outlined,
                                title: 'نقاط الخدمة',
                                isDark: isDark,
                                onTap: () => _showInfoDialog(
                                  'نقاط الخدمة',
                                  'تنتشر نقاط خدمة حمولة في صنعاء، عدن، تعز، الحديدة، وحضرموت.',
                                  Icons.location_on_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Single Card: "إعدادات إضافية" (Image 1)
                          _buildCardGroup(
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.settings_outlined,
                                title: 'إعدادات إضافية',
                                isDark: isDark,
                                onTap: widget.onSettings,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Accordion Section: "تخصيص التطبيق" (Image 1)
                          _buildAccordionSection(
                            title: 'تخصيص التطبيق',
                            icon: Icons.palette_outlined,
                            iconColor: const Color(0xFF8B5CF6),
                            isExpanded: _isCustomizationExpanded,
                            onToggle: () => setState(() => _isCustomizationExpanded = !_isCustomizationExpanded),
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.wb_sunny_outlined,
                                iconColor: const Color(0xFFF59E0B),
                                title: 'مظهر التطبيق',
                                isDark: isDark,
                                onTap: () => _showInfoDialog(
                                  'مظهر التطبيق',
                                  'الوضع الحالي: تلقائي حسب النظام.',
                                  Icons.wb_sunny_outlined,
                                ),
                              ),
                              _buildMenuItem(
                                icon: Icons.language_rounded,
                                iconColor: const Color(0xFF2563EB),
                                title: 'لغة التطبيق',
                                isDark: isDark,
                                onTap: () => _showInfoDialog(
                                  'لغة التطبيق',
                                  'اللغة الحالية: العربية (اليمن).',
                                  Icons.language_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Single Card: "مشاركة تطبيق حمولة" (Image 1)
                          _buildCardGroup(
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.share_rounded,
                                title: 'مشاركة تطبيق حمولة',
                                isDark: isDark,
                                onTap: () => _copyToClipboard('https://hamula.app/download', 'رابط التطبيق'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Logout Button (Image 1)
                          _buildLogoutButton(isDark),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // 3. Bottom Navigation Bar with "حسابي" active (Image 1)
                  MerchantBottomNavBar(
                    currentTab: MerchantNavTab.account,
                    onTabSelected: (tab) {
                      if (tab == MerchantNavTab.home) {
                        widget.onHome?.call();
                      } else if (tab == MerchantNavTab.orders) {
                        widget.onOrders?.call();
                      } else if (tab == MerchantNavTab.map) {
                        widget.onMap?.call();
                      } else if (tab == MerchantNavTab.wallet) {
                        widget.onWallet?.call();
                      }
                    },
                    onFabPressed: widget.onFab ?? () {},
                    showMapTab: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            onPressed: widget.onBack ?? () => Navigator.maybePop(context),
            tooltip: AppStrings.back,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'حسابي',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance back button
        ],
      ),
    );
  }

  /// Profile Card exactly matching Image 1:
  /// - Centered Circular Avatar with Camera Badge
  /// - Name: "مصطفى يحيى صالح طنين"
  /// - Pill Badge: "موثق" with green checkmark
  /// - Two Columns: "رقم الهاتف" (+967 777 123 456) & "رقم الحساب" (783707104) with copy buttons
  /// - Full width button: "تعديل بيانات الحساب" with edit pencil
  Widget _buildProfileCard(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Centered Avatar with Camera Badge
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE0F2FE),
                    border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/avatar_personal_preview.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF0284C7),
                        size: 50,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: InkWell(
                    onTap: _openEditProfileDialog,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Centered Name: "مصطفى يحيى صالح طنين"
          Text(
            'مصطفى يحيى صالح طنين',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),

          // 3. Centered Badge: "موثق"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 4),
                Text(
                  'موثق',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Two Columns with vertical divider: "رقم الحساب" & "رقم الهاتف"
          Row(
            children: [
              // Column 1: رقم الحساب (Right in RTL)
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _copyToClipboard('783707104', 'رقم الحساب'),
                          child: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'رقم الحساب',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '783707104',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                height: 32,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
              ),

              // Column 2: رقم الهاتف (Left in RTL)
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _copyToClipboard('+967 777 123 456', 'رقم الهاتف'),
                          child: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'رقم الهاتف',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+967 777 123 456',
                      textDirection: TextDirection.ltr,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5. Button: "تعديل بيانات الحساب" with edit pencil
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _openEditProfileDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF2563EB),
                elevation: 0,
                side: BorderSide(
                  color: isDark ? const Color(0xFF2563EB) : const Color(0xFFBFDBFE),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تعديل بيانات الحساب',
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3 Activity Summary Cards exactly matching Image 1:
  /// - Right: Orange Box Icon, 12, "حمولة مسجلة"
  /// - Center: Blue Truck Icon, 9, "طلبات نشطة"
  /// - Left: Green Checkmark Icon, 24, "رحلة مكتملة"
  Widget _buildActivitySummaryRow(bool isDark) {
    return Row(
      children: [
        // Left in RTL: رحلة مكتملة (24, Green)
        Expanded(
          child: _buildKpiCard(
            title: 'رحلة مكتملة',
            value: '24',
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF16A34A),
            bgColor: isDark ? const Color(0xFF132A24) : const Color(0xFFF0FDF4),
            borderColor: isDark ? const Color(0xFF065F46) : const Color(0xFFDCFCE7),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),

        // Center: طلبات نشطة (9, Blue)
        Expanded(
          child: _buildKpiCard(
            title: 'طلبات نشطة',
            value: '9',
            icon: Icons.local_shipping_rounded,
            iconColor: const Color(0xFF2563EB),
            bgColor: isDark ? const Color(0xFF132238) : const Color(0xFFEFF6FF),
            borderColor: isDark ? const Color(0xFF1E40AF) : const Color(0xFFDBEAFE),
            onTap: widget.onOrders,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),

        // Right in RTL: حمولة مسجلة (12, Orange)
        Expanded(
          child: _buildKpiCard(
            title: 'حمولة مسجلة',
            value: '12',
            icon: Icons.all_inbox_rounded,
            iconColor: const Color(0xFFEA580C),
            bgColor: isDark ? const Color(0xFF2B1D14) : const Color(0xFFFFF7ED),
            borderColor: isDark ? const Color(0xFF9A3412) : const Color(0xFFFFEDD5),
            onTap: widget.onCargos,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildCardGroup({required List<Widget> children, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
            ),
            ...children,
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (iconColor ?? const Color(0xFF2563EB)).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchMenuItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.fingerprint_rounded,
            size: 20,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return InkWell(
      onTap: widget.onLogout,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3B151E) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF881337) : const Color(0xFFFEE2E2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFEF4444),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFEF4444),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
