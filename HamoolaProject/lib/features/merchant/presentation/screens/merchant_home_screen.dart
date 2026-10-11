import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/merchant_order.dart';
import '../widgets/merchant_attention_card.dart';
import '../widgets/merchant_bottom_nav_bar.dart';
import '../widgets/merchant_drawer.dart';
import '../widgets/merchant_order_card.dart';
import '../widgets/merchant_stat_card.dart';

/// Redesigned Merchant Home Screen directly matching the UI screenshot:
/// - Top Greeting Header with Notification Bell
/// - Hero Banner: "هل لديك شحنة جديدة؟" with illustration & pagination dots
/// - "الخدمات السريعة" section with primary CTA "إنشاء طلب نقل" and 4 square action cards (حمولاتي, عروضي, التتبع, السجل)
/// - "ملخص نشاطك" activity summary section
/// - Verified vs. Unverified access control with interactive restriction prompt
/// - Bottom Nav Bar with (الرئيسية, طلباتي, +, الخريطة, حسابي)
class MerchantHomeScreen extends StatefulWidget {
  final VoidCallback? onCreateOrder;
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

  const MerchantHomeScreen({
    super.key,
    this.onCreateOrder,
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
  });

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MerchantNavTab _currentTab = MerchantNavTab.home;
  late bool _isVerified;

  final List<MerchantOrder> _orders = MerchantOrder.demoOrders;
  final List<MerchantAttentionItem> _attentionItems =
      MerchantAttentionItem.demoItems;

  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _isVerified = widget.isVerified;
    _bannerController = PageController();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (_bannerController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % _heroBanners.length;
        _bannerController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _handleTabSelected(MerchantNavTab tab) {
    setState(() => _currentTab = tab);
    if (tab == MerchantNavTab.orders) {
      widget.onCargos?.call();
    } else if (tab == MerchantNavTab.map) {
      widget.onMap?.call();
    } else if (tab == MerchantNavTab.wallet) {
      widget.onWallet?.call();
    } else if (tab == MerchantNavTab.account) {
      widget.onAccount?.call();
    }
  }

  void _handleCreateOrderAction() {
    if (_isVerified) {
      widget.onCreateOrder?.call();
    } else {
      _showVerificationRequiredModal(actionName: AppStrings.createTransportOrderBtn);
    }
  }

  void _handleOffersAction() {
    if (_isVerified) {
      widget.onReviewOffers?.call('REQ-1024');
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor:
            isDark ? AppColors.navyDark : AppColors.backgroundLight,
        drawer: MerchantDrawer(
          merchantName: AppStrings.merchantDefaultName,
          companyName: AppStrings.merchantDefaultCompany,
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
              child: Column(
                children: [
                  // 1. Top Header Matching Screenshot
                  _buildHeader(isDark),

                  // 2. Scrollable Body Content
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
                          // A. Verification Warning Banner (if unverified)
                          if (!_isVerified) ...[
                            _buildVerificationNoticeBanner(isDark),
                            const SizedBox(height: 10.0),
                          ],

                          // B. Hero Banner ("هل لديك شحنة جديدة؟")
                          _buildHeroBanner(isDark),
                          const SizedBox(height: 16.0),

                          // C. "الخدمات السريعة" Section
                          _buildQuickServicesSection(isDark),
                          const SizedBox(height: 20.0),

                          // D. "ملخص نشاطك" Section
                          _buildActivitySummarySection(isDark),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),

                  // 3. Merchant Bottom Nav Bar (Matches Screenshot)
                  MerchantBottomNavBar(
                    currentTab: _currentTab,
                    onTabSelected: _handleTabSelected,
                    onFabPressed: _showQuickServicesModal,
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

  /// Top Header exactly matching the screenshot
  Widget _buildHeader(bool isDark) {
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
          // Right: Greeting & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
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
                    ),
                  ],
                ),
                const SizedBox(height: 1.0),
                Text(
                  AppStrings.readyToTransportSubtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSubtle
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Left Actions: Simulation Verification Toggle + Notification Bell
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtle interactive verification simulation switch
              InkWell(
                onTap: () {
                  setState(() => _isVerified = !_isVerified);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isVerified
                            ? 'تم تفعيل وضع التاجر المعتمد والموثق'
                            : 'تم تفعيل وضع التاجر غير الموثق (تجربة القيود)',
                        style: GoogleFonts.cairo(),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: _isVerified
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isVerified
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.warning.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    _isVerified ? 'موثق ✓' : 'غير موثق 🔒',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _isVerified ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ),

              // Notification Bell Card
              InkWell(
                onTap: widget.onNotifications,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 22.0,
                        color: isDark
                            ? AppColors.textWhite
                            : const Color(0xFF1E293B),
                      ),
                      Positioned(
                        top: 9.0,
                        right: 10.0,
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

  /// Banner shown when merchant account is not verified
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
            onPressed: () => _showVerificationRequiredModal(
              actionName: 'توثيق الحساب التجاري',
            ),
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
    );
  }

  static final List<_HeroBannerItem> _heroBanners = [
    // 1. Blue: هل لديك شحنة جديدة؟ (Matches Screenshot 3)
    _HeroBannerItem(
      tag: AppStrings.newCargoBadge,
      title: AppStrings.doYouHaveNewCargoTitle,
      subtitle: AppStrings.createOrderHeroDesc,
      lightBg: const Color(0xFFEFF6FF),
      lightBorder: const Color(0xFFBFDBFE),
      tagBg: const Color(0xFFDBEAFE),
      tagColor: const Color(0xFF1D4ED8),
      iconCircleBg: const Color(0xFFDBEAFE),
      iconColor: const Color(0xFF2563EB),
      iconWidget: Center(
        child: Container(
          width: 38.0,
          height: 26.0,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 4.0),
              width: 8.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
        ),
      ),
    ),
    // 2. Amber: شحن مباشر وسريع (Matches Screenshot 1)
    _HeroBannerItem(
      tag: 'شحن مباشر وسريع',
      title: 'انقل حمولتك بسهولة',
      subtitle: 'اطلب شاحنة مناسبة لحمولتك في دقائق',
      lightBg: const Color(0xFFFFFBEB),
      lightBorder: const Color(0xFFFDE68A),
      tagBg: const Color(0xFFFEF3C7),
      tagColor: const Color(0xFFB45309),
      iconCircleBg: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFD97706),
      iconWidget: const Center(
        child: Icon(
          Icons.local_shipping_rounded,
          color: Color(0xFFD97706),
          size: 30.0,
        ),
      ),
    ),
    // 3. Green: أسطول الناقلين (Matches Screenshot 2)
    _HeroBannerItem(
      tag: 'أسطول الناقلين',
      title: 'ابحث عن السائق المناسب',
      subtitle: 'استعرض السائقين المتاحين بالقرب منك',
      lightBg: const Color(0xFFECFDF5),
      lightBorder: const Color(0xFFA7F3D0),
      tagBg: const Color(0xFFD1FAE5),
      tagColor: const Color(0xFF047857),
      iconCircleBg: const Color(0xFFD1FAE5),
      iconColor: const Color(0xFF059669),
      iconWidget: const Center(
        child: Icon(
          Icons.map_rounded,
          color: Color(0xFF059669),
          size: 30.0,
        ),
      ),
    ),
    // 4. Purple: متابعة حية (Matches Screenshot 4)
    _HeroBannerItem(
      tag: 'متابعة حية',
      title: 'تابع رحلتك خطوة بخطوة',
      subtitle: 'اعرف حالة طلب النقل وموقع الشاحنة',
      lightBg: const Color(0xFFF5F3FF),
      lightBorder: const Color(0xFFDDD6FE),
      tagBg: const Color(0xFFEDE9FE),
      tagColor: const Color(0xFF6D28D9),
      iconCircleBg: const Color(0xFFEDE9FE),
      iconColor: const Color(0xFF7C3AED),
      iconWidget: const Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          color: Color(0xFF7C3AED),
          size: 28.0,
        ),
      ),
    ),
  ];

  /// Dynamic Hero Carousel Banner with auto-rotation & 4 indicator dots
  Widget _buildHeroBanner(bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 112.0,
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
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : banner.lightBg,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : banner.lightBorder,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10.0,
                      offset: const Offset(0, 3.0),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Illustration Circle on the left
                    Container(
                      width: 56.0,
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: banner.iconCircleBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: banner.iconWidget,
                    ),
                    const SizedBox(width: 14.0),

                    // Right: Tag + Title + Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tag Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0x333B82F6)
                                  : banner.tagBg,
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              banner.tag,
                              style: GoogleFonts.cairo(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFF93C5FD)
                                    : banner.tagColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),

                          // Title
                          Text(
                            banner.title,
                            style: GoogleFonts.cairo(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? AppColors.textWhite
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1.0),

                          // Subtitle
                          Text(
                            banner.subtitle,
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textSubtle
                                  : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10.0),

        // Carousel Pagination Dots (4 dots with active amber pill)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_heroBanners.length, (index) {
            final isActive = _currentBannerIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: isActive ? 20.0 : 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryGold
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(3.0),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Quick Services Bottom Sheet matching Screenshot 5 (2x2 square options, no subtext)
  void _showQuickServicesModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 44.0,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Header Row: Title & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'خدمات سريعة',
                        style: GoogleFonts.cairo(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          width: 34.0,
                          height: 34.0,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18.0,
                            color: isDark ? AppColors.textWhite : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),

                  // 2x2 Grid of Square Options organized with borders & lines
                  Row(
                    children: [
                      // Card 1: طلب نقل (Truck Icon)
                      Expanded(
                        child: _buildQuickOptionSquareCard(
                          title: 'طلب نقل',
                          icon: Icons.local_shipping_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          iconBgColor: const Color(0x2EF59E0B),
                          onTap: () {
                            Navigator.pop(ctx);
                            _handleCreateOrderAction();
                          },
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      // Card 2: تتبع الرحلة (Tracking Icon)
                      Expanded(
                        child: _buildQuickOptionSquareCard(
                          title: 'تتبع الرحلة',
                          icon: Icons.center_focus_strong_rounded,
                          iconColor: const Color(0xFF60A5FA),
                          iconBgColor: const Color(0x2E3B82F6),
                          onTap: () {
                            Navigator.pop(ctx);
                            widget.onReviewOffers?.call('REQ-1024');
                          },
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      // Card 3: إضافة حمولة (Cargo Box)
                      Expanded(
                        child: _buildQuickOptionSquareCard(
                          title: 'إضافة حمولة',
                          icon: Icons.inventory_2_rounded,
                          iconColor: const Color(0xFF34D399),
                          iconBgColor: const Color(0x2E10B981),
                          onTap: () {
                            Navigator.pop(ctx);
                            widget.onCargos?.call();
                          },
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      // Card 4: خريطة السائقين (Map Icon)
                      Expanded(
                        child: _buildQuickOptionSquareCard(
                          title: 'خريطة السائقين',
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFF2DD4BF),
                          iconBgColor: const Color(0x2E14B8A6),
                          onTap: () {
                            Navigator.pop(ctx);
                            widget.onMap?.call();
                          },
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Clean square option card without cluttered subtext, matching screenshot
  Widget _buildQuickOptionSquareCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Premium dark navy matching Image 5
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 8.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Clean Bold Title (No subtext as requested)
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              // Square Icon Badge
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "الخدمات السريعة" Section with Primary CTA and 4 Square Action Cards
  Widget _buildQuickServicesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          AppStrings.quickServicesSection,
          style: GoogleFonts.cairo(
            fontSize: 15.0,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10.0),

        // Primary Action CTA: "إنشاء طلب نقل" (Matches Screenshot)
        InkWell(
          onTap: _handleCreateOrderAction,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x2EF59E0B)
                  : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: const Color(0xFFFDE68A),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.12),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3.0),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Right: Label
                Row(
                  children: [
                    Text(
                      AppStrings.createTransportOrderBtn,
                      style: GoogleFonts.cairo(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                    if (!_isVerified) ...[
                      const SizedBox(width: 6.0),
                      const Icon(Icons.lock_outline_rounded,
                          size: 16.0, color: Color(0xFFB45309)),
                    ],
                  ],
                ),

                // Left: Golden Square + Button
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12.0),

        // 4 Square Quick Actions Row (حمولاتي, عروضي, التتبع, السجل)
        Row(
          children: [
            // 1. حمولاتي
            Expanded(
              child: _buildSquareActionCard(
                label: AppStrings.myCargosQuick,
                icon: Icons.inventory_2_outlined,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                isDark: isDark,
                onTap: widget.onCargos,
              ),
            ),
            const SizedBox(width: 10.0),

            // 2. عروضي
            Expanded(
              child: _buildSquareActionCard(
                label: AppStrings.myOffersQuick,
                icon: Icons.local_offer_outlined,
                iconBg: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFEA580C),
                isDark: isDark,
                onTap: _handleOffersAction,
                isLocked: !_isVerified,
              ),
            ),
            const SizedBox(width: 10.0),

            // 3. التتبع
            Expanded(
              child: _buildSquareActionCard(
                label: AppStrings.trackingQuick,
                icon: Icons.explore_outlined,
                iconBg: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF059669),
                isDark: isDark,
                onTap: widget.onMap,
              ),
            ),
            const SizedBox(width: 10.0),

            // 4. السجل
            Expanded(
              child: _buildSquareActionCard(
                label: AppStrings.historyQuick,
                icon: Icons.access_time_rounded,
                iconBg: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF64748B),
                isDark: isDark,
                onTap: widget.onCargos,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Individual Square Action Card (حمولاتي, عروضي, التتبع, السجل)
  Widget _buildSquareActionCard({
    required String label,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool isDark,
    VoidCallback? onTap,
    bool isLocked = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8.0,
              offset: const Offset(0, 2.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Square Box
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : iconBg,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 22.0,
                    color: isDark ? AppColors.textWhite : iconColor,
                  ),
                  if (isLocked)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),

            // Label
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.0,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textWhite
                    : const Color(0xFF1E293B),
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// "ملخص نشاطك" Section with clean, concise stats and attention items
  Widget _buildActivitySummarySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          AppStrings.activitySummarySection,
          style: GoogleFonts.cairo(
            fontSize: 15.0,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10.0),

        // 3 Compact Activity Stats Cards
        Row(
          children: [
            MerchantStatCard(
              title: AppStrings.activeOrders,
              count: '2',
              icon: Icons.local_shipping_outlined,
              variant: MerchantStatVariant.blue,
              onTap: widget.onCargos,
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
              title: AppStrings.pendingAction,
              count: '1',
              icon: Icons.hourglass_top_outlined,
              variant: MerchantStatVariant.warning,
              onTap: widget.onCargos,
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // Needs Attention Item
        if (_attentionItems.isNotEmpty)
          MerchantAttentionCard(
            item: _attentionItems.first,
            onAction: () =>
                widget.onReviewOffers?.call(_attentionItems.first.orderId),
          ),
        const SizedBox(height: 12.0),

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

/// Data Model representing each slide of the Merchant Hero Carousel Banner
class _HeroBannerItem {
  final String tag;
  final String title;
  final String subtitle;
  final Color lightBg;
  final Color lightBorder;
  final Color tagBg;
  final Color tagColor;
  final Color iconCircleBg;
  final Color iconColor;
  final Widget iconWidget;

  const _HeroBannerItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.lightBg,
    required this.lightBorder,
    required this.tagBg,
    required this.tagColor,
    required this.iconCircleBg,
    required this.iconColor,
    required this.iconWidget,
  });
}
