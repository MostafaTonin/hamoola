import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../domain/models/merchant_profile.dart';
import '../widgets/merchant_bottom_nav_bar.dart';

/// Screen representing Merchant Account Hub matching Image 2:
/// - Top App Bar: "< حسابي"
/// - Main Profile Identity Card:
///   - Corporate Logo Avatar on Right with Camera Edit Button
///   - Enterprise Name: "مؤسسة النور للتجارة العامة"
///   - Contact Subtitle: "صاحب الحساب: محمد أحمد"
///   - Badges: "موثق" & "حساب تجاري"
///   - 3 Columns with dividers: "رقم الهاتف" (+967 777 123 456), "رقم الحساب" (783707104), "رقم السجل التجاري" (1234567890) with copy actions
///   - Full Width Button: "تعديل بيانات المؤسسة" with edit pencil
/// - 3 Dynamic Activity Summary Cards:
///   - Right: "رحلة مكتملة" (42, Orange Box Icon)
///   - Center: "طلبات نشطة" (18, Blue Document Icon)
///   - Left: "حمولة مسجلة" (56, Green Truck Icon)
/// - Organized Sections matching Image 2:
///   1. بيانات المؤسسة (تعديل بيانات المؤسسة, بيانات السجل التجاري, بيانات التواصل, العنوان والموقع)
///   2. عمليات حمولة (طلباتي, حمولاتي, محفظتي, إدارة عروض الأسعار)
///   3. إدارة المفضلة والاقتراحات (إدارة المفضلة)
///   4. الخصوصية والأمان (تغيير رمز التأكيد, تغيير كلمة المرور, استخدام البصمة لتسجيل الدخول, استخدام البصمة لتأكيد الدفع, الشروط والأحكام, سياسة الخصوصية)
///   5. الدعم والمساعدة (خدمة العملاء, مواقع التواصل, الرقم المجاني, نقاط الخدمة)
///   6. إعدادات إضافية
///   7. تخصيص التطبيق (مظهر التطبيق, لغة التطبيق)
///   8. مشاركة تطبيق حمولة
///   9. تسجيل الخروج (Red Tinted Card)
/// - Bottom Navigation Bar with Account Tab active
class MerchantAccountScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final VoidCallback? onOrders;
  final VoidCallback? onCargos;
  final VoidCallback? onMap;
  final VoidCallback? onWallet;
  final VoidCallback? onVerification;
  final VoidCallback? onSettings;
  final VoidCallback? onSupport;
  final VoidCallback? onTerms;
  final VoidCallback? onLogout;
  final VoidCallback? onFab;

  final String? userName;
  final String? organizationName;
  final String? phoneNumber;
  final int? completedTrips;
  final double? rating;
  final int? commitmentPercent;
  final double? walletBalance;
  final AccountVerificationStatus? verificationStatus;

  const MerchantAccountScreen({
    super.key,
    this.onBack,
    this.onHome,
    this.onOrders,
    this.onCargos,
    this.onMap,
    this.onWallet,
    this.onVerification,
    this.onSettings,
    this.onSupport,
    this.onTerms,
    this.onLogout,
    this.onFab,
    this.userName,
    this.organizationName,
    this.phoneNumber,
    this.completedTrips,
    this.rating,
    this.commitmentPercent,
    this.walletBalance,
    this.verificationStatus,
  });

  @override
  State<MerchantAccountScreen> createState() => _MerchantAccountScreenState();
}

class _MerchantAccountScreenState extends State<MerchantAccountScreen> {
  final MerchantProfile _profile = MerchantProfile.instance;

  // Accordion toggle states matching Image 2
  bool _isEnterpriseExpanded = true;
  bool _isOperationsExpanded = true;
  bool _isFavoritesExpanded = false;
  bool _isSecurityExpanded = true;
  bool _isSupportExpanded = true;
  bool _isCustomizationExpanded = false;

  // Switches matching Image 2
  bool _useBiometricsLogin = true;
  bool _useBiometricsPayment = false;

  AuthUser get _currentMerchantUser {
    final store = AuthSimulationStore.instance;
    final current = store.currentUser;
    if (current != null && current.role == AuthUserRole.merchant) {
      return current;
    }
    return store.getDemoUserByRole(AuthUserRole.merchant) ?? store.users.first;
  }

  AccountVerificationStatus get effectiveVerificationStatus {
    if (widget.verificationStatus != null) return widget.verificationStatus!;
    return _currentMerchantUser.verificationStatus;
  }

  @override
  void initState() {
    super.initState();
    _profile.addListener(_onProfileChanged);
    AuthSimulationStore.instance.addListener(_onProfileChanged);
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _profile.removeListener(_onProfileChanged);
    AuthSimulationStore.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  String get effectiveCompanyName {
    if (widget.organizationName != null) return widget.organizationName!;
    final current = AuthSimulationStore.instance.currentUser;
    if (current != null && current.role == AuthUserRole.merchant) {
      final ent = current.merchantData?.enterpriseName;
      if (ent != null && ent.trim().isNotEmpty) return ent.trim();
    }
    return 'مؤسسة النور للتجارة العامة';
  }

  String get effectiveContactName {
    if (widget.userName != null) return widget.userName!;
    final current = AuthSimulationStore.instance.currentUser;
    if (current != null && current.role == AuthUserRole.merchant && current.name.isNotEmpty) {
      return current.name;
    }
    return 'محمد أحمد';
  }

  String get effectivePhone {
    if (widget.phoneNumber != null) return widget.phoneNumber!;
    return '+967 777 123 456';
  }

  String get effectiveCrNumber {
    final current = AuthSimulationStore.instance.currentUser;
    if (current != null && current.merchantData?.crNumber != null) {
      return current.merchantData!.crNumber;
    }
    return '1234567890';
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
    final companyCtrl = TextEditingController(text: effectiveCompanyName);
    final ownerCtrl = TextEditingController(text: effectiveContactName);

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
                'تعديل بيانات المؤسسة',
                style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: companyCtrl,
                decoration: InputDecoration(
                  labelText: 'اسم المؤسسة / المنشأة',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.domain_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ownerCtrl,
                decoration: InputDecoration(
                  labelText: 'صاحب الحساب / المفوض',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  final newCompany = companyCtrl.text.trim();
                  final newOwner = ownerCtrl.text.trim();
                  if (newCompany.isNotEmpty) {
                    _profile.updateCompanyDetails(companyName: newCompany, contactName: newOwner);
                    final user = _currentMerchantUser;
                    final updatedMerchantData = user.merchantData?.copyWith(enterpriseName: newCompany);
                    final updatedUser = user.copyWith(
                      name: newOwner.isNotEmpty ? newOwner : user.name,
                      merchantData: updatedMerchantData,
                    );
                    AuthSimulationStore.instance.registerUser(updatedUser);
                    setState(() {});
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث بيانات المؤسسة بنجاح', style: GoogleFonts.cairo()),
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
                  // 1. Header: "< حسابي"
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
                          // Profile Identity Card (Image 2)
                          _buildProfileCard(isDark),
                          const SizedBox(height: 14),

                          // Activity Summary Indicators (3 Cards - Image 2)
                          _buildActivitySummaryRow(isDark),
                          const SizedBox(height: 18),

                          // Section: "بيانات المؤسسة" (Image 2)
                          _buildAccordionSection(
                            title: 'بيانات المؤسسة',
                            icon: Icons.description_outlined,
                            iconColor: const Color(0xFF2563EB),
                            isExpanded: _isEnterpriseExpanded,
                            onToggle: () => setState(() => _isEnterpriseExpanded = !_isEnterpriseExpanded),
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.person_outline_rounded,
                                title: 'تعديل بيانات المؤسسة',
                                isDark: isDark,
                                onTap: _openEditProfileDialog,
                              ),
                              _buildMenuItem(
                                icon: Icons.badge_outlined,
                                title: 'بيانات السجل التجاري',
                                subtitle: 'معلومات المؤسسة',
                                isDark: isDark,
                                onTap: () {
                                  final mData = _currentMerchantUser.merchantData;
                                  final crNum = mData?.crNumber ?? effectiveCrNumber;
                                  final bType = mData?.businessType ?? 'تجارة جملة وتجزئة';
                                  final issuer = mData?.crIssuer ?? 'وزارة الصناعة والتجارة - مكتب الأمانة';
                                  _showInfoDialog(
                                    'معلومات المؤسسة',
                                    'الاسم التجاري: $effectiveCompanyName\nرقم السجل: $crNum\nنوع النشاط: $bType\nجهة الإصدار: $issuer\nالحالة: ساري المفعول',
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
                                  'الهاتف المسجل: $effectivePhone\nالمفوض التجاري: $effectiveContactName\nالبريد: info@alnoor-trade.ye',
                                  Icons.phone_outlined,
                                ),
                              ),
                              _buildMenuItem(
                                icon: Icons.location_on_outlined,
                                title: 'العنوان والموقع',
                                isDark: isDark,
                                onTap: () => _showInfoDialog(
                                  'العنوان والموقع',
                                  'المقر الرئيسي: صنعاء - شارع الستين الجنوبي - عمارة الأمل',
                                  Icons.location_on_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Section: "عمليات حمولة" (Image 2)
                          _buildAccordionSection(
                            title: 'عمليات حمولة',
                            icon: Icons.local_shipping_outlined,
                            iconColor: const Color(0xFFEA580C),
                            isExpanded: _isOperationsExpanded,
                            onToggle: () => setState(() => _isOperationsExpanded = !_isOperationsExpanded),
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
                              _buildMenuItem(
                                icon: Icons.local_offer_outlined,
                                title: 'إدارة عروض الأسعار',
                                isDark: isDark,
                                onTap: () => _showInfoDialog(
                                  'إدارة عروض الأسعار',
                                  'يمكنك استعراض ومقارنة وقبول عروض الأسعار المقدمة من السائقين ومكاتب النقل.',
                                  Icons.local_offer_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Accordion Section: "إدارة المفضلة والاقتراحات" (Image 2)
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
                                  'قائمة السائقين ومكاتب النقل المفضلة لديك فارغة حالياً.',
                                  Icons.star_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Accordion Section: "الخصوصية والأمان" (Image 2)
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
                                  'يمكنك تغيير رمز تأكيد المعاملات المالية لحساب المنشأة.',
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

                          // Accordion Section: "الدعم والمساعدة" (Image 2)
                          _buildAccordionSection(
                            title: 'الدعم والمساعدة',
                            icon: Icons.headset_mic_rounded,
                            iconColor: const Color(0xFF8B5CF6),
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

                          // Single Card: "إعدادات إضافية" (Image 2)
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

                          // Accordion Section: "تخصيص التطبيق" (Image 2)
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

                          // Single Card: "مشاركة تطبيق حمولة" (Image 2)
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

                          // Logout Button (Image 2)
                          _buildLogoutButton(isDark),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // 3. Bottom Navigation Bar with "حسابي" active (Image 2)
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

  /// Profile Identity Card matching Image 2:
  /// - Avatar with company logo on the right (in RTL) + camera badge
  /// - Title: "مؤسسة النور للتجارة العامة"
  /// - Subtitle: "صاحب الحساب: محمد أحمد"
  /// - Badges: "موثق" (green) + "حساب تجاري" (blue)
  /// - 3 Columns with dividers:
  ///   - Right: "رقم الهاتف" (+967 777 123 456)
  ///   - Center: "رقم الحساب" (783707104)
  ///   - Left: "رقم السجل التجاري" (1234567890)
  /// - Full width button: "تعديل بيانات المؤسسة" with edit pencil
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
          // Top Row: Avatar on Right (in RTL), Details on Left
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Camera Overlay
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFCA5A5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/merchant_company_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFFEE2E2),
                          child: const Icon(Icons.apartment_rounded, color: Color(0xFFDC2626), size: 36),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _openEditProfileDialog,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Enterprise Name, Subtitle, Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      effectiveCompanyName,
                      style: GoogleFonts.cairo(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'صاحب الحساب: $effectiveContactName',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Badges Row: "موثق" + "حساب تجاري"
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // موثق / قيد المراجعة
                        if (effectiveVerificationStatus == AccountVerificationStatus.pendingReview)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFCD34D)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFFD97706)),
                                const SizedBox(width: 4),
                                Text(
                                  'قيد المراجعة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF16A34A)),
                                const SizedBox(width: 4),
                                Text(
                                  'موثق',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 6),

                        // حساب تجاري
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.storefront_outlined, size: 12, color: Color(0xFF2563EB)),
                              const SizedBox(width: 4),
                              Text(
                                'حساب تجاري',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),

          // 3 Columns with Vertical Dividers matching Image 2:
          // Right: رقم السجل التجاري (1234567890)
          // Center: رقم الحساب (783707104)
          // Left: رقم الهاتف (+967 777 123 456)
          Row(
            children: [
              // Right in RTL: رقم السجل التجاري
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _copyToClipboard(effectiveCrNumber, 'رقم السجل التجاري'),
                          child: const Icon(Icons.copy_rounded, size: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'رقم السجل التجاري',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      effectiveCrNumber,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                height: 28,
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),

              // Center in RTL: رقم الحساب
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _copyToClipboard('783707104', 'رقم الحساب'),
                          child: const Icon(Icons.copy_rounded, size: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'رقم الحساب',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '783707104',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                height: 28,
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),

              // Left in RTL: رقم الهاتف
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _copyToClipboard(effectivePhone, 'رقم الهاتف'),
                          child: const Icon(Icons.copy_rounded, size: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            'رقم الهاتف',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      effectivePhone,
                      textDirection: TextDirection.ltr,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12,
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

          // Full width button: "تعديل بيانات المؤسسة"
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
                    'تعديل بيانات المؤسسة',
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

  /// 3 Activity Summary Cards exactly matching Image 2:
  /// - Left in RTL: "حمولة مسجلة" (56, Green Truck Icon)
  /// - Center in RTL: "طلبات نشطة" (18, Blue Document Icon)
  /// - Right in RTL: "رحلة مكتملة" (42, Orange Box Icon)
  Widget _buildActivitySummaryRow(bool isDark) {
    return Row(
      children: [
        // Left in RTL: حمولة مسجلة (56, Green)
        Expanded(
          child: _buildKpiCard(
            title: 'حمولة مسجلة',
            value: '56',
            icon: Icons.local_shipping_rounded,
            iconColor: const Color(0xFF16A34A),
            bgColor: isDark ? const Color(0xFF132A24) : const Color(0xFFF0FDF4),
            borderColor: isDark ? const Color(0xFF065F46) : const Color(0xFFDCFCE7),
            onTap: widget.onCargos,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),

        // Center in RTL: طلبات نشطة (18, Blue)
        Expanded(
          child: _buildKpiCard(
            title: 'طلبات نشطة',
            value: '18',
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF2563EB),
            bgColor: isDark ? const Color(0xFF132238) : const Color(0xFFEFF6FF),
            borderColor: isDark ? const Color(0xFF1E40AF) : const Color(0xFFDBEAFE),
            onTap: widget.onOrders,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),

        // Right in RTL: رحلة مكتملة (42, Orange)
        Expanded(
          child: _buildKpiCard(
            title: 'رحلة مكتملة',
            value: '42',
            icon: Icons.all_inbox_rounded,
            iconColor: const Color(0xFFEA580C),
            bgColor: isDark ? const Color(0xFF2B1D14) : const Color(0xFFFFF7ED),
            borderColor: isDark ? const Color(0xFF9A3412) : const Color(0xFFFFEDD5),
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
    String? subtitle,
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
                child: subtitle != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            subtitle,
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      )
                    : Text(
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
