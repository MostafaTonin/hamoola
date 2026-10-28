import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../domain/models/merchant_order.dart';
import '../../domain/models/merchant_profile.dart';
import '../widgets/merchant_attention_card.dart';
import '../widgets/merchant_bottom_nav_bar.dart';
import '../widgets/merchant_drawer.dart';
import '../widgets/merchant_order_card.dart';
import '../widgets/merchant_stat_card.dart';

/// Redesigned Merchant Home Screen matching Image 3:
/// - Top Greeting Header with Notification Bell & Chat Support icons, merchant profile avatar & name
/// - Dynamic Freight Hero Banner Carousel with 4 auto-rotating slides and pagination dots
/// - "الخدمات الرئيسية" Section with pastel cards (إنشاء طلب نقل, عرض السائقين, حمولاتي, طلباتي)
/// - "ملخص نشاطك" Activity Summary Section
/// - Floating In-Screen Quick Actions Dark Card toggled by center (+) button turning to (X)
/// - RTL Bottom Navigation Bar with (الرئيسية, الخريطة, (+)/(X), طلباتي, حسابي)
class MerchantHomeScreen extends StatefulWidget {
  final VoidCallback? onCreateOrder;
  final VoidCallback? onOrders;
  final VoidCallback? onCargos;
  final VoidCallback? onMap;
  final VoidCallback? onWallet;
  final VoidCallback? onAccount;
  final VoidCallback? onNotifications;
  final VoidCallback? onServicePoints;
  final VoidCallback? onSupport;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;
  final VoidCallback? onVerifyNow;
  final VoidCallback? onSwitchToDriver;
  final ValueChanged<String>? onOrderDetails;
  final ValueChanged<String>? onReviewOffers;

  final bool isVerified;
  final AccountVerificationStatus? verificationStatus;

  const MerchantHomeScreen({
    super.key,
    this.onCreateOrder,
    this.onOrders,
    this.onCargos,
    this.onMap,
    this.onWallet,
    this.onAccount,
    this.onNotifications,
    this.onServicePoints,
    this.onSupport,
    this.onSettings,
    this.onLogout,
    this.onVerifyNow,
    this.onSwitchToDriver,
    this.onOrderDetails,
    this.onReviewOffers,
    this.isVerified = true,
    this.verificationStatus,
  });

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MerchantNavTab _currentTab = MerchantNavTab.home;
  bool _isQuickActionsOpen = false;

  final List<MerchantOrder> _orders = MerchantOrder.demoOrders;
  final List<MerchantAttentionItem> _attentionItems =
      MerchantAttentionItem.demoItems;

  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  AuthUser get _currentMerchantUser {
    final store = AuthSimulationStore.instance;
    final current = store.currentUser;
    if (current != null && current.role == AuthUserRole.merchant) {
      return current;
    }
    return store.users.firstWhere(
      (u) => u.role == AuthUserRole.merchant,
      orElse: () => AuthUser(
        id: 'USR-MERCHANT-01',
        name: MerchantProfile.instance.contactName,
        phone: MerchantProfile.instance.phoneNumber,
        password: 'password123',
        createdAt: DateTime(2025, 1, 1),
        role: AuthUserRole.merchant,
        verificationStatus: widget.verificationStatus ??
            (widget.isVerified
                ? AccountVerificationStatus.verified
                : AccountVerificationStatus.unverified),
      ),
    );
  }

  AccountVerificationStatus get _effectiveStatus {
    if (widget.verificationStatus != null) {
      return widget.verificationStatus!;
    }
    if (!widget.isVerified) {
      return AccountVerificationStatus.unverified;
    }
    return _currentMerchantUser.verificationStatus;
  }

  String get _effectiveOwnerName {
    final current = AuthSimulationStore.instance.currentUser;
    if (current != null && current.role == AuthUserRole.merchant && current.name.isNotEmpty) {
      return current.name;
    }
    return MerchantProfile.instance.contactName;
  }

  String get _effectiveEnterpriseName {
    final current = AuthSimulationStore.instance.currentUser;
    if (current != null && current.role == AuthUserRole.merchant) {
      final ent = current.merchantData?.enterpriseName;
      if (ent != null && ent.trim().isNotEmpty) return ent.trim();
    }
    return MerchantProfile.instance.companyName;
  }

  String _getEnterpriseDisplayName(String name) {
    if (name.contains('مؤسسة النور')) {
      return 'مؤسسة النور';
    }
    if (name.trim().isNotEmpty) {
      return name.split(' للتجارة').first.trim();
    }
    return 'مؤسسة النور';
  }

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _startBannerTimer();
    MerchantProfile.instance.addListener(_handleStoreChanged);
    AuthSimulationStore.instance.addListener(_handleStoreChanged);
  }

  void _handleStoreChanged() {
    if (mounted) setState(() {});
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_bannerController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % _heroBanners.length;
        _bannerController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    MerchantProfile.instance.removeListener(_handleStoreChanged);
    AuthSimulationStore.instance.removeListener(_handleStoreChanged);
    super.dispose();
  }

  void _handleTabSelected(MerchantNavTab tab) {
    if (_isQuickActionsOpen) {
      setState(() => _isQuickActionsOpen = false);
    }
    setState(() => _currentTab = tab);
    if (tab == MerchantNavTab.orders) {
      widget.onOrders?.call();
    } else if (tab == MerchantNavTab.map) {
      widget.onMap?.call();
    } else if (tab == MerchantNavTab.wallet) {
      widget.onWallet?.call();
    } else if (tab == MerchantNavTab.account) {
      widget.onAccount?.call();
    }
  }

  void _toggleQuickActions() {
    setState(() {
      _isQuickActionsOpen = !_isQuickActionsOpen;
    });
  }

  void _handleCreateOrderAction() {
    if (_effectiveStatus == AccountVerificationStatus.verified) {
      widget.onCreateOrder?.call();
    } else if (_effectiveStatus == AccountVerificationStatus.pendingReview) {
      _showPendingReviewModal(
          actionName: AppStrings.createTransportOrderBtn);
    } else {
      _showVerificationRequiredModal(
          actionName: AppStrings.createTransportOrderBtn);
    }
  }

  void _handleOffersAction() {
    if (_effectiveStatus == AccountVerificationStatus.verified) {
      widget.onReviewOffers?.call('REQ-1024');
    } else if (_effectiveStatus == AccountVerificationStatus.pendingReview) {
      _showPendingReviewModal(actionName: AppStrings.myOffersQuick);
    } else {
      _showVerificationRequiredModal(actionName: AppStrings.myOffersQuick);
    }
  }

  void _showVerificationRequiredModal({required String actionName}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Lock / Shield Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0x2EF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: AppColors.primaryGold,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppStrings.verificationRequiredTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'لتفعيل ميزة "$actionName" والتعامل المالي، يرجى إتمام توثيق حسابك.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onVerifyNow?.call();
                    },
                    icon: const Icon(Icons.verified_user_rounded, size: 18),
                    label: Text(
                      AppStrings.startVerificationBtn,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: const Color(0xFF0F172A),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    AppStrings.laterBtn,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPendingReviewModal({required String actionName}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0x2E3B82F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: Color(0xFF2563EB),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'طلب التوثيق قيد المراجعة',
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'طلب توثيق حساب المنشأة التجاري قيد التدقيق حالياً من قِبل إدارة حمولة. سيتم تفعيل ميزة "$actionName" فور اعتماد الطلب.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showMerchantReviewSheet();
                    },
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: Text(
                      'عرض تفاصيل الطلب',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'إغلاق',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMerchantReviewSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _currentMerchantUser;
    final data = user.merchantData;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'تفاصيل طلب توثيق المنشأة',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          'قيد المراجعة',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem('اسم المنشأة:', _effectiveEnterpriseName, Icons.domain_rounded),
                  _buildReviewItem('صاحب الحساب:', _effectiveOwnerName, Icons.person_outline_rounded),
                  _buildReviewItem('رقم السجل التجاري:', data?.crNumber ?? '10294812', Icons.badge_outlined),
                  _buildReviewItem('نوع النشاط:', data?.businessType ?? 'استيراد وتصدير وتجارة عامة', Icons.category_outlined),
                  _buildReviewItem('جهة إصدار السجل:', data?.crIssuer ?? 'وزارة الصناعة والتجارة', Icons.account_balance_outlined),
                  _buildReviewItem('العنوان والمقر:', data?.address ?? 'صنعاء - شارع الستين الجنوبي', Icons.location_on_outlined),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0x1A3B82F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'طلبك قيد التدقيق بواسطة الإدارة، ولا يتطلب إعادة الإرسال.',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: const Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        AuthSimulationStore.instance.simulateApproveMerchantVerification(_currentMerchantUser.id);
                        setState(() {});
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: Text(
                        'اعتماد التوثيق تجريبياً',
                        style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationToolbar(AccountVerificationStatus currentStatus) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.primaryGold, size: 14),
            const SizedBox(width: 6),
            Text(
              'محاكاة توثيق التاجر:',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 12),
            _buildSimStatusPill(
              label: 'غير موثق',
              isActive: currentStatus == AccountVerificationStatus.unverified,
              color: const Color(0xFFF59E0B),
              onTap: () {
                final store = AuthSimulationStore.instance;
                store.skipMerchantVerification(_currentMerchantUser.id);
                setState(() {});
              },
            ),
            const SizedBox(width: 6),
            _buildSimStatusPill(
              label: 'قيد المراجعة',
              isActive: currentStatus == AccountVerificationStatus.pendingReview,
              color: const Color(0xFF3B82F6),
              onTap: () {
                final store = AuthSimulationStore.instance;
                final user = _currentMerchantUser;
                store.submitMerchantVerification(
                  userId: user.id,
                  merchantData: user.merchantData ??
                      MerchantEnterpriseData(
                        enterpriseName: _effectiveEnterpriseName,
                        crNumber: '10294812',
                        businessType: 'استيراد وتصدير وتجارة عامة',
                        crIssuer: 'وزارة الصناعة والتجارة',
                        submittedAt: DateTime.now(),
                      ),
                );
                setState(() {});
              },
            ),
            const SizedBox(width: 6),
            _buildSimStatusPill(
              label: 'موثق',
              isActive: currentStatus == AccountVerificationStatus.verified,
              color: const Color(0xFF10B981),
              onTap: () {
                final store = AuthSimulationStore.instance;
                store.simulateApproveMerchantVerification(_currentMerchantUser.id);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimStatusPill({
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? color : Colors.white.withValues(alpha: 0.15),
            width: isActive ? 1.4 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? color : Colors.white70,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = MerchantProfile.instance;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor:
            isDark ? AppColors.navyDark : AppColors.backgroundLight,
        drawer: MerchantDrawer(
          merchantName: profile.contactName,
          companyName: profile.companyName,
          onProfile: widget.onAccount,
          onCargos: widget.onCargos,
          onMap: widget.onMap,
          onWallet: widget.onWallet,
          onServicePoints: widget.onServicePoints,
          onSupport: widget.onSupport,
          onSettings: widget.onSettings,
          onLogout: widget.onLogout,
          onSwitchToDriver: widget.onSwitchToDriver,
        ),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Stack(
                children: [
                  // Main Body Layout
                  Column(
                    children: [
                      // 1. Top Header Matching Image 3
                      _buildHeader(isDark, profile),

                      // 2. Prototype Simulation Toolbar
                      _buildSimulationToolbar(_effectiveStatus),

                      // 3. Scrollable Body Content
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
                              // A. Verification Notice (if unverified or pendingReview)
                              if (_effectiveStatus ==
                                  AccountVerificationStatus.unverified) ...[
                                _buildVerificationNoticeBanner(isDark),
                                const SizedBox(height: 10.0),
                              ] else if (_effectiveStatus ==
                                  AccountVerificationStatus.pendingReview) ...[
                                _buildPendingReviewBanner(isDark),
                                const SizedBox(height: 10.0),
                              ],

                              // B. Hero Carousel Banners
                              _buildHeroBanner(isDark),
                              const SizedBox(height: 20.0),

                              // C. "الخدمات الرئيسية" Section
                              _buildMainServicesSection(isDark),
                              const SizedBox(height: 22.0),

                              // D. "ملخص نشاطك" Section
                              _buildActivitySummarySection(isDark, profile),
                              const SizedBox(height: 24.0),
                            ],
                          ),
                        ),
                      ),

                      // 3. Bottom Nav Bar with (+)/(X) FAB toggle
                      MerchantBottomNavBar(
                        currentTab: _currentTab,
                        onTabSelected: _handleTabSelected,
                        onFabPressed: _toggleQuickActions,
                        showMapTab: true,
                        isQuickActionsOpen: _isQuickActionsOpen,
                      ),
                    ],
                  ),

                  // Backdrop Dim Barrier when Quick Actions Card is Open
                  if (_isQuickActionsOpen)
                    Positioned.fill(
                      bottom: 62.0,
                      child: GestureDetector(
                        onTap: () => setState(() => _isQuickActionsOpen = false),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                      ),
                    ),

                  // Floating In-Screen Quick Actions Dark Card (Image 3)
                  if (_isQuickActionsOpen)
                    Positioned(
                      left: 16.0,
                      right: 16.0,
                      bottom: 70.0,
                      child: _buildQuickActionsFloatingCard(isDark),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top Header matching Image 3
  Widget _buildHeader(bool isDark, MerchantProfile profile) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Trailing in RTL (Right): Avatar & Greeting & Company Name
          Expanded(
            child: Row(
              children: [
                // Enterprise Avatar Logo
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
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
                      profile.avatarPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.business_rounded,
                            color: Color(0xFFEF4444), size: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),

                // Greeting & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppStrings.goodMorningGreeting,
                            style: GoogleFonts.cairo(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? AppColors.textWhite
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '، ${_getEnterpriseDisplayName(_effectiveEnterpriseName)} 👋',
                              style: GoogleFonts.cairo(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textWhite
                                    : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _effectiveEnterpriseName,
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSubtle
                                    : const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_effectiveStatus ==
                              AccountVerificationStatus.verified) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 10,
                                    color: Color(0xFF059669),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'معتمد ✓',
                                    style: GoogleFonts.cairo(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Leading in RTL (Left Actions): Verification toggle, Chat, Notification Bell
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chat Support Icon Button with unread indicator
              InkWell(
                onTap: widget.onSupport,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20.0,
                        color: isDark
                            ? AppColors.textWhite
                            : const Color(0xFF1E293B),
                      ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),

              // Notification Bell Card
              InkWell(
                onTap: widget.onNotifications,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 21.0,
                        color: isDark
                            ? AppColors.textWhite
                            : const Color(0xFF1E293B),
                      ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Verification Notice Banner
  Widget _buildVerificationNoticeBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0x1AF59E0B),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7.0),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primaryGold,
              size: 18.0,
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.accountNotVerifiedBannerTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                  ),
                ),
                Text(
                  AppStrings.accountNotVerifiedBannerSubtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    color: isDark
                        ? AppColors.textSubtle
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.onVerifyNow != null) {
                widget.onVerifyNow!();
              } else {
                _showVerificationRequiredModal(
                  actionName: 'توثيق الحساب التجاري',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'استكمال التوثيق',
                  style: GoogleFonts.cairo(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Opacity(
                  opacity: 0.0,
                  child: Text(
                    AppStrings.verifyNowBtn,
                    style: GoogleFonts.cairo(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Pending Review Banner
  Widget _buildPendingReviewBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7.0),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: Colors.white,
              size: 18.0,
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب التوثيق قيد المراجعة',
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
                Text(
                  'بيانات المنشأة والسجل التجاري قيد التدقيق بواسطة إدارة المنصة',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          OutlinedButton(
            onPressed: _showMerchantReviewSheet,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E40AF),
              side: const BorderSide(color: Color(0xFF3B82F6)),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'عرض تفاصيل الطلب',
              style: GoogleFonts.cairo(
                fontSize: 11.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static final List<_HeroBannerItem> _heroBanners = [
    // 1. Hero Actros Freight Truck Banner matching Image 3
    _HeroBannerItem(
      tag: 'شحن مباشر وسريع',
      title: 'انقل حمولتك',
      highlightTitle: 'بكل سهولة',
      subtitle: 'مع شبكة واسعة من السائقين الموثوقين',
      imageAsset: 'assets/images/merchant_hero_truck_banner.jpg',
      iconData: Icons.local_shipping_rounded,
      accentColor: const Color(0xFFDC2626),
    ),
    // 2. Wide network of drivers
    _HeroBannerItem(
      tag: 'أسطول الناقلين',
      title: 'شبكة واسعة',
      highlightTitle: 'من السائقين',
      subtitle: 'استعرض مئات الشاحنات المتاحة لنقل حمولتك فوراً',
      imageAsset: 'assets/images/driver_hero_actros.jpg',
      iconData: Icons.map_rounded,
      accentColor: const Color(0xFF2563EB),
    ),
    // 3. Track transport & trip
    _HeroBannerItem(
      tag: 'متابعة حية',
      title: 'تابع طلب النقل',
      highlightTitle: 'والرحلة',
      subtitle: 'تتبع مباشر لحركة شحنتك وموقع السائق خطوة بخطوة',
      imageAsset: 'assets/images/hamula_intercity_cargo.jpg',
      iconData: Icons.navigation_rounded,
      accentColor: const Color(0xFF059669),
    ),
    // 4. Manage cargos & orders
    _HeroBannerItem(
      tag: 'إدارة متكاملة',
      title: 'إدارة حمولاتك',
      highlightTitle: 'وطلباتك',
      subtitle: 'سجل طرودك وتابع عروض الأسعار في مكان واحد',
      imageAsset: 'assets/images/hamula_port_cargo.jpg',
      iconData: Icons.all_inbox_rounded,
      accentColor: const Color(0xFFD97706),
    ),
  ];

  /// Dynamic Freight Hero Carousel Banner (Image 3)
  Widget _buildHeroBanner(bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 154.0,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _heroBanners.length,
            onPageChanged: (idx) {
              setState(() => _currentBannerIndex = idx);
            },
            itemBuilder: (context, index) {
              final banner = _heroBanners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 12.0,
                      offset: const Offset(0, 4.0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image
                      Image.asset(
                        banner.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1E293B),
                          child: const Icon(Icons.local_shipping_rounded,
                              size: 48, color: Colors.white24),
                        ),
                      ),

                      // Gradient Overlay for readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.55),
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),

                      // Text Content Overlay matching Image 3
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 14.0),
                        child: Row(
                          children: [
                            // Right Side: Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Title + Highlight in Red
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${banner.title} ',
                                          style: GoogleFonts.cairo(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                        TextSpan(
                                          text: banner.highlightTitle,
                                          style: GoogleFonts.cairo(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFFEF4444), // Crimson highlight
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),

                                  // Subtitle
                                  Row(
                                    children: [
                                      Container(
                                        width: 5.0,
                                        height: 5.0,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6.0),
                                      Expanded(
                                        child: Text(
                                          banner.subtitle,
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12.0),

                            // Round action chevron icon
                            Container(
                              width: 34.0,
                              height: 34.0,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 22.0,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10.0),

        // Carousel Pagination Dots (4 dots with active red pill matching Image 3)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_heroBanners.length, (index) {
            final isActive = _currentBannerIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              width: isActive ? 18.0 : 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFEF4444)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(3.0),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// "الخدمات الرئيسية" Section matching Image 3 (Clean pastel cards)
  Widget _buildMainServicesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'الخدمات الرئيسية',
          style: GoogleFonts.cairo(
            fontSize: 16.0,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12.0),

        // Horizontal Row / Scroll of 4 Main Services (Image 3)
        SizedBox(
          height: 124.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. إنشاء طلب نقل (Light mint/green card)
              _buildMainServiceCard(
                title: 'إنشاء طلب نقل',
                subtitle: 'طلب جديد',
                icon: Icons.local_shipping_rounded,
                bgColor: isDark ? const Color(0xFF132A24) : const Color(0xFFECFDF5),
                borderColor: isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0),
                iconColor: const Color(0xFF10B981),
                onTap: _handleCreateOrderAction,
                isDark: isDark,
              ),
              const SizedBox(width: 10.0),

              // 2. عرض السائقين (Light blue card)
              _buildMainServiceCard(
                title: 'عرض السائقين',
                subtitle: 'على الخريطة',
                icon: Icons.people_alt_rounded,
                bgColor: isDark ? const Color(0xFF132238) : const Color(0xFFEFF6FF),
                borderColor: isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE),
                iconColor: const Color(0xFF3B82F6),
                onTap: widget.onMap,
                isDark: isDark,
              ),
              const SizedBox(width: 10.0),

              // 3. حمولاتي (Light orange card)
              _buildMainServiceCard(
                title: 'حمولاتي',
                subtitle: 'إدارة الحمولات',
                icon: Icons.inventory_2_rounded,
                bgColor: isDark ? const Color(0xFF2D1E16) : const Color(0xFFFFF7ED),
                borderColor: isDark ? const Color(0xFF9A3412) : const Color(0xFFFED7AA),
                iconColor: const Color(0xFFF97316),
                onTap: widget.onCargos,
                isDark: isDark,
              ),
              const SizedBox(width: 10.0),

              // 4. طلباتي (Light purple card)
              _buildMainServiceCard(
                title: 'طلباتي',
                subtitle: 'متابعة الطلبات',
                icon: Icons.assignment_rounded,
                bgColor: isDark ? const Color(0xFF221A38) : const Color(0xFFF5F3FF),
                borderColor: isDark ? const Color(0xFF5B21B6) : const Color(0xFFDDD6FE),
                iconColor: const Color(0xFF8B5CF6),
                onTap: widget.onOrders,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.0),
      child: Container(
        width: 114.0,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centered icon container
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 24.0),
            ),
            const SizedBox(height: 8.0),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2.0),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
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

  /// Floating In-Screen Quick Actions Dark Card matching Image 3
  Widget _buildQuickActionsFloatingCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Navy dark background
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtle drag handle (Image 3)
          Container(
            width: 40.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 12.0),

          // 2x2 Grid of the 4 Approved Actions (Image 3)
          Row(
            children: [
              // 1. طلب نقل (Orange Truck)
              Expanded(
                child: _buildDarkQuickActionItem(
                  title: 'طلب نقل',
                  subtitle: 'إنشاء طلب سريع',
                  icon: Icons.local_shipping_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  iconBg: const Color(0x2EF59E0B),
                  onTap: () {
                    setState(() => _isQuickActionsOpen = false);
                    _handleCreateOrderAction();
                  },
                ),
              ),
              const SizedBox(width: 8.0),

              // 2. تتبع الحمولة (Blue Tracker)
              Expanded(
                child: _buildDarkQuickActionItem(
                  title: 'تتبع الحمولة',
                  subtitle: 'متابعة حالة النقل',
                  icon: Icons.center_focus_strong_rounded,
                  iconColor: const Color(0xFF60A5FA),
                  iconBg: const Color(0x2E3B82F6),
                  onTap: () {
                    setState(() => _isQuickActionsOpen = false);
                    widget.onReviewOffers?.call('REQ-1024');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              // 3. إضافة حمولة (Red/Pink Cargo Box)
              Expanded(
                child: _buildDarkQuickActionItem(
                  title: 'إضافة حمولة',
                  subtitle: 'تسجيل حمولة جديدة',
                  icon: Icons.inventory_2_rounded,
                  iconColor: const Color(0xFFEF4444),
                  iconBg: const Color(0x2EEF4444),
                  onTap: () {
                    setState(() => _isQuickActionsOpen = false);
                    widget.onCargos?.call();
                  },
                ),
              ),
              const SizedBox(width: 8.0),

              // 4. إضافة رصيد (Green Wallet)
              Expanded(
                child: _buildDarkQuickActionItem(
                  title: 'إضافة رصيد',
                  subtitle: 'شحن رصيد محفظتك',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFF10B981),
                  iconBg: const Color(0x2E10B981),
                  onTap: () {
                    setState(() => _isQuickActionsOpen = false);
                    widget.onWallet?.call();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDarkQuickActionItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // 1. Icon container on the right (start in RTL)
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 20.0),
                ),
              ),
              const SizedBox(width: 8.0),

              // 2. Text column in the middle (Flexible/Expanded to prevent ANY overflow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4.0),

              // 3. Chevron on the left (end in RTL)
              const Icon(
                Icons.chevron_left_rounded,
                size: 18.0,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "ملخص نشاطك" Section with dynamic metrics from profile
  Widget _buildActivitySummarySection(bool isDark, MerchantProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          AppStrings.activitySummarySection,
          style: GoogleFonts.cairo(
            fontSize: 16.0,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12.0),

        // 3 Compact Activity Stats Cards
        Row(
          children: [
            MerchantStatCard(
              title: AppStrings.activeOrders,
              count: '${profile.activeOrdersCount}',
              icon: Icons.local_shipping_outlined,
              variant: MerchantStatVariant.blue,
              onTap: widget.onOrders,
            ),
            const SizedBox(width: 8.0),
            MerchantStatCard(
              title: AppStrings.newOffers,
              count: '5',
              badgeText: AppStrings.newBadge,
              icon: Icons.local_offer_outlined,
              variant: MerchantStatVariant.gold,
              onTap: _handleOffersAction,
            ),
            const SizedBox(width: 8.0),
            MerchantStatCard(
              title: 'حمولات مسجلة',
              count: '${profile.registeredCargosCount}',
              icon: Icons.inventory_2_outlined,
              variant: MerchantStatVariant.warning,
              onTap: widget.onCargos,
            ),
          ],
        ),
        const SizedBox(height: 14.0),

        // Needs Attention Item
        if (_attentionItems.isNotEmpty)
          MerchantAttentionCard(
            item: _attentionItems.first,
            onAction: () =>
                widget.onReviewOffers?.call(_attentionItems.first.orderId),
          ),
        const SizedBox(height: 14.0),

        // Recent Order Card
        if (_orders.isNotEmpty)
          MerchantOrderCard(
            order: _orders.first,
            onDetails: () => widget.onOrderDetails?.call(_orders.first.id),
          ),
      ],
    );
  }
}

class _HeroBannerItem {
  final String tag;
  final String title;
  final String highlightTitle;
  final String subtitle;
  final String imageAsset;
  final IconData iconData;
  final Color accentColor;

  const _HeroBannerItem({
    required this.tag,
    required this.title,
    required this.highlightTitle,
    required this.subtitle,
    required this.imageAsset,
    required this.iconData,
    required this.accentColor,
  });
}
