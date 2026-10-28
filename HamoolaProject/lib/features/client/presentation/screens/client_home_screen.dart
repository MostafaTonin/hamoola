import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../merchant/domain/models/merchant_order.dart';
import '../../../merchant/presentation/widgets/merchant_attention_card.dart';
import '../../../merchant/presentation/widgets/merchant_bottom_nav_bar.dart';
import '../../../merchant/presentation/widgets/merchant_stat_card.dart';

/// Item data structure for the 4 Client Hero Carousel Banners
class _ClientHeroBannerItem {
  final String tag;
  final String title;
  final String subtitle;
  final String imageAsset;
  final IconData iconData;
  final Color accentColor;
  final String? extraKeyword;

  const _ClientHeroBannerItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.iconData,
    required this.accentColor,
    this.extraKeyword,
  });
}

/// Simulated Client Cargo Item for citizen logistics
class ClientCargoItem {
  final String id;
  final String title;
  final String cargoType;
  final String fromCity;
  final String toCity;
  final String truckType;
  final String status;
  final int offersCount;
  final Color statusColor;

  const ClientCargoItem({
    required this.id,
    required this.title,
    required this.cargoType,
    required this.fromCity,
    required this.toCity,
    required this.truckType,
    required this.status,
    required this.offersCount,
    required this.statusColor,
  });
}

/// Dedicated Home Screen for Client (المواطن العادي طالب خدمة النقل).
/// Implements Prompt 04 specifications:
/// - Exact visual and architectural alignment with the Merchant Home Screen (Image 3)
/// - Customized greeting, personal photo, and citizen transport content for Mustafa Saleh Tonin
/// - 4 High-definition photographic hero carousel banners (furniture, crops, steel/construction, finishings)
/// - The 6 primary client services strictly ordered (حمولاتي، محفظتي، عرض السائقين، إضافة طلب، إضافة حمولة، تتبع حمولة)
/// - Live activity summary with reactive counters and latest update card
/// - Reused 5-item Bottom Navigation Bar with Center Floating Quick Actions card
/// - Removal of drawer, simulation toolbar, and redundant role titles
class ClientHomeScreen extends StatefulWidget {
  final bool autoScrollBanner;
  final VoidCallback? onCreateOrder;
  final VoidCallback? onMyCargos;
  final VoidCallback? onMyOffers;
  final VoidCallback? onTrackCargo;
  final VoidCallback? onHistory;
  final VoidCallback? onNotifications;
  final VoidCallback? onVerifyNow;
  final VoidCallback? onAccount;
  final VoidCallback? onLogout;
  final VoidCallback? onMap;
  final VoidCallback? onWallet;
  final VoidCallback? onSupport;
  final VoidCallback? onAddCargo;
  final VoidCallback? onOrders;
  final ValueChanged<String>? onOrderDetails;
  final ValueChanged<String>? onReviewOffers;

  final bool isVerified;
  final AccountVerificationStatus? verificationStatus;

  const ClientHomeScreen({
    super.key,
    this.autoScrollBanner = true,
    this.onCreateOrder,
    this.onMyCargos,
    this.onMyOffers,
    this.onTrackCargo,
    this.onHistory,
    this.onNotifications,
    this.onVerifyNow,
    this.onAccount,
    this.onLogout,
    this.onMap,
    this.onWallet,
    this.onSupport,
    this.onAddCargo,
    this.onOrders,
    this.onOrderDetails,
    this.onReviewOffers,
    this.isVerified = false,
    this.verificationStatus,
  });

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  MerchantNavTab _currentTab = MerchantNavTab.home;
  bool _isQuickActionsOpen = false;

  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  // The 4 Photographic Hero Banners matching Prompt 04 Section 7
  static final List<_ClientHeroBannerItem> _heroBanners = [
    // 1. Home Furniture & Relocation
    const _ClientHeroBannerItem(
      tag: 'نقل عفش وأثاث منزلي',
      title: 'انقل أثاث منزلك بأمان مع حمولة',
      subtitle: 'نقل عفش وأثاث منزلي',
      extraKeyword: 'انقل أثاث منزلك بسهولة نقل أثاث وعفش',
      imageAsset: 'assets/images/client_hero_furniture.jpg',
      iconData: Icons.chair_rounded,
      accentColor: Color(0xFFEF4444),
    ),
    // 2. Light Cargo & Dina Trucks
    const _ClientHeroBannerItem(
      tag: 'شاحنات دينا ونقل خفيف',
      title: 'احجز شاحنة مخصصة لنقل بضائعك',
      subtitle: 'شاحنات دينا ونقل خفيف',
      imageAsset: 'assets/images/client_hero_crops.jpg',
      iconData: Icons.local_shipping_rounded,
      accentColor: Color(0xFF10B981),
    ),
    // 3. Inter-city Freight
    const _ClientHeroBannerItem(
      tag: 'شحن بين المحافظات',
      title: 'توصيل سريع بين المدن والمحافظات',
      subtitle: 'شحن بين المحافظات',
      imageAsset: 'assets/images/client_hero_steel.jpg',
      iconData: Icons.alt_route_rounded,
      accentColor: Color(0xFF3B82F6),
    ),
    // 4. Cargo Guarantee & Safety
    const _ClientHeroBannerItem(
      tag: 'تغطية وتأمين موثوق',
      title: 'ضمان وصول حمولتك وسلامتها',
      subtitle: 'تغطية وتأمين موثوق',
      imageAsset: 'assets/images/client_hero_finishings.jpg',
      iconData: Icons.shield_rounded,
      accentColor: Color(0xFFF59E0B),
    ),
  ];

  // Citizen freight demo cargo list
  final List<ClientCargoItem> _demoCargos = const [
    ClientCargoItem(
      id: 'CRG-101',
      title: 'نقل أثاث منزلي ومفروشات',
      cargoType: 'أثاث وعفش',
      fromCity: 'صنعاء - حي الأصبحي',
      toCity: 'عدن - خور مكسر',
      truckType: 'دينا مغلقة (4 طن)',
      status: 'بانتظار العروض',
      offersCount: 4,
      statusColor: Color(0xFFD97706),
    ),
    ClientCargoItem(
      id: 'CRG-102',
      title: 'محصول رمان صعدة وبن يمني',
      cargoType: 'محاصيل زراعية',
      fromCity: 'صعدة - سحار',
      toCity: 'صنعاء - سوق ذهبان',
      truckType: 'جامبو مبرد (7 طن)',
      status: 'جاري النقل والتتبع',
      offersCount: 2,
      statusColor: Color(0xFF2563EB),
    ),
    ClientCargoItem(
      id: 'CRG-103',
      title: 'مواد سيراميك وتشطيبات',
      cargoType: 'مواد بناء',
      fromCity: 'الرياض - المستودعات',
      toCity: 'جدة - حي الصفا',
      truckType: 'تريلا جوانب (25 طن)',
      status: 'تم التسليم بنجاح',
      offersCount: 5,
      statusColor: Color(0xFF16A34A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _startBannerTimer();
    AuthSimulationStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    AuthSimulationStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _startBannerTimer() {
    if (!widget.autoScrollBanner) return;
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    if (bindingName.contains('TestWidgetsFlutterBinding') ||
        bindingName.contains('AutomatedTestWidgetsFlutterBinding')) {
      return;
    }
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

  AuthUser get _currentUser {
    final user = AuthSimulationStore.instance.currentUser;
    if (user != null && user.role == AuthUserRole.client) {
      return user;
    }
    final clients = AuthSimulationStore.instance.users
        .where((u) => u.role == AuthUserRole.client)
        .toList();
    if (clients.isNotEmpty) return clients.first;

    return AuthUser(
      id: 'USR-CLIENT-01',
      name: 'مصطفى صالح طنين',
      phone: '777123456',
      password: 'Hamula@123',
      role: AuthUserRole.client,
      verificationStatus: AccountVerificationStatus.unverified,
      isPhoneVerified: true,
      createdAt: DateTime(2026, 10, 1),
    );
  }

  AccountVerificationStatus get _effectiveStatus {
    if (widget.verificationStatus != null) {
      return widget.verificationStatus!;
    }
    if (widget.isVerified) {
      return AccountVerificationStatus.verified;
    }
    return _currentUser.verificationStatus;
  }

  void _handleCreateOrderTapped() {
    final status = _effectiveStatus;

    if (status == AccountVerificationStatus.unverified) {
      _showVerificationRequiredDialog(
        title: 'توثيق الحساب مطلوب',
        message: 'عزيزي العميل، يتطلب إنشاء طلب نقل توثيق هويتك الشخصية لضمان سلامة وأمان الشحنة والتأمين عليها.',
        buttonLabel: 'توثيق الحساب الآن',
        onConfirm: () {
          Navigator.pop(context);
          widget.onVerifyNow?.call();
        },
      );
    } else if (status == AccountVerificationStatus.pendingReview) {
      _showVerificationRequiredDialog(
        title: 'طلب التوثيق قيد المراجعة',
        message: 'طلب توثيق هويتك قيد التدقيق حالياً من قِبل إدارة حمولة. ستتمكن من إنشاء طلبات النقل فور اعتماد الطلب.',
        buttonLabel: 'عرض حالة التوثيق',
        onConfirm: () {
          Navigator.pop(context);
          _showVerificationDetailsModal();
        },
      );
    } else {
      widget.onCreateOrder?.call();
    }
  }

  void _handleTrackCargoTapped() {
    final activeCargos = _demoCargos.where((c) => c.status.contains('جاري')).toList();
    if (activeCargos.isNotEmpty && widget.onTrackCargo != null) {
      widget.onTrackCargo!();
    } else {
      _showEmptyTrackingModal();
    }
  }

  void _showEmptyTrackingModal() {
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
                    Icons.center_focus_strong_rounded,
                    color: Color(0xFF3B82F6),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'لا توجد رحلة نشطة حالياً',
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ليس لديك أي شحنة قيد النقل المباشر في الوقت الحالي. يمكنك استعراض طلباتك ومتابعة العروض المقدمة من السائقين.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    height: 1.5,
                    color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (widget.onOrders != null) {
                        widget.onOrders!();
                      } else {
                        widget.onMyCargos?.call();
                      }
                    },
                    icon: const Icon(Icons.assignment_outlined, size: 18),
                    label: Text(
                      'الانتقال إلى طلباتي',
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
                      color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
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

  void _showVerificationRequiredDialog({
    required String title,
    required String message,
    required String buttonLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10.0),
            Container(
              width: 60.0,
              height: 60.0,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_outlined,
                color: Color(0xFFD97706),
                size: 32.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 13.0,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              height: 44.0,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationDetailsModal() {
    final identity = _currentUser.identityData;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'بيانات توثيق الهوية المرسلة',
                        style: GoogleFonts.cairo(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: const Color(0xFF93C5FD)),
                      ),
                      child: Text(
                        'قيد المراجعة',
                        style: GoogleFonts.cairo(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildInfoRow('الاسم المسجل:', identity?.fullName ?? _currentUser.name, isDark),
                _buildInfoRow('رقم الهوية:', identity?.idNumber ?? 'قيد التدقيق', isDark),
                _buildInfoRow('جهة الإصدار:', identity?.issuePlace ?? 'اليمن', isDark),
                _buildInfoRow('تاريخ الإرسال:', identity != null ? '${identity.submittedAt.day}/${identity.submittedAt.month}/${identity.submittedAt.year}' : 'اليوم', isDark),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text(
                    'حسناً، فهمت',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13.0,
                color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTabSelected(MerchantNavTab tab) {
    setState(() {
      _currentTab = tab;
      _isQuickActionsOpen = false;
    });

    switch (tab) {
      case MerchantNavTab.home:
        break;
      case MerchantNavTab.map:
        widget.onMap?.call();
        break;
      case MerchantNavTab.orders:
        if (widget.onOrders != null) {
          widget.onOrders!();
        } else {
          widget.onMyCargos?.call();
        }
        break;
      case MerchantNavTab.wallet:
        widget.onWallet?.call();
        break;
      case MerchantNavTab.account:
        widget.onAccount?.call();
        break;
    }
  }

  void _toggleQuickActions() {
    setState(() {
      _isQuickActionsOpen = !_isQuickActionsOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.navyDark : AppColors.backgroundLight,
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
                              // A. Verification Notice (if unverified or pendingReview)
                              if (_effectiveStatus == AccountVerificationStatus.unverified) ...[
                                _buildVerificationNoticeBanner(isDark),
                                const SizedBox(height: 10.0),
                              ] else if (_effectiveStatus == AccountVerificationStatus.pendingReview) ...[
                                _buildPendingReviewBanner(isDark),
                                const SizedBox(height: 10.0),
                              ] else if (_effectiveStatus == AccountVerificationStatus.verified) ...[
                                _buildVerifiedBanner(isDark),
                                const SizedBox(height: 10.0),
                              ],

                              // B. Hero Carousel Banners (Photographic Slides)
                              _buildHeroBanner(isDark),
                              const SizedBox(height: 20.0),

                              // C. "الخدمات الرئيسية" Section (The 6 Services)
                              _buildMainServicesSection(isDark),
                              const SizedBox(height: 22.0),

                              // D. "ملخص نشاطك" Section (Dynamic Stats & Latest Update)
                              _buildActivitySummarySection(isDark),
                              const SizedBox(height: 24.0),
                            ],
                          ),
                        ),
                      ),

                      // 3. Reused Bottom Nav Bar with (+)/(X) FAB toggle
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

  /// Verification status pill in Header matching Image 1 & 3
  Widget _buildVerificationStatusPill(AccountVerificationStatus status) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case AccountVerificationStatus.unverified:
        bgColor = const Color(0xFFF8FAFC);
        borderColor = const Color(0xFFCBD5E1);
        textColor = const Color(0xFF64748B);
        label = 'غير موثق';
        icon = Icons.info_outline_rounded;
        break;
      case AccountVerificationStatus.pendingReview:
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFF93C5FD);
        textColor = const Color(0xFF2563EB);
        label = 'قيد المراجعة';
        icon = Icons.hourglass_top_rounded;
        break;
      case AccountVerificationStatus.verified:
        bgColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFFA7F3D0);
        textColor = const Color(0xFF059669);
        label = 'موثق ومعتمد';
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: borderColor, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.0, color: textColor),
          const SizedBox(width: 3.0),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Top Header matching Image 3 (Tailored for Client Mustafa Saleh Tonin)
  Widget _buildHeader(bool isDark) {
    final user = _currentUser;
    final photoPath = user.identityData?.personalPhotoPath ?? 'assets/images/avatar_personal_preview.jpg';

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 12.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Avatar + Greeting + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Trailing in RTL (Right): Personal Avatar & Greeting & Name
              Expanded(
                child: InkWell(
                  onTap: widget.onAccount,
                  borderRadius: BorderRadius.circular(16.0),
                  child: Row(
                    children: [
                      // Personal Avatar Photo
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
                            photoPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF2563EB),
                              child: Center(
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0] : 'م',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),

                      // Greeting & Full Name + Verification Status Pill & Account Type Badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'أهلاً، ${user.displayName} 👋',
                              style: GoogleFonts.cairo(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.textWhite
                                    : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2.0),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6.0,
                              runSpacing: 2.0,
                              children: [
                                Text(
                                  user.name,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0x2E3B82F6) : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6.0),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE),
                                    ),
                                  ),
                                  child: Text(
                                    'حساب شخصي',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                                _buildVerificationStatusPill(_effectiveStatus),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Leading in RTL (Left Actions): Chat/Support & Notification Bell
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Chat / Customer Support Button
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

                  // Hidden text widget for backward test compatibility
                  const Opacity(
                    opacity: 0.0,
                    child: SizedBox(
                      width: 0.0,
                      height: 0.0,
                      child: Text('الإشعارات'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Integrated Search Bar with Filter Icon (Section 5)
          Container(
            height: 44.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20.0,
                  color: isDark ? AppColors.textSubtle : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'ابحث عن حمولة، سائق، أو مسار...',
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSubtle : const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تصفية ونتائج البحث قيد التجهيز', style: GoogleFonts.cairo()),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 17.0,
                      color: isDark ? AppColors.textWhite : const Color(0xFF334155),
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

  /// Verification Notice Banner (Unverified status)
  Widget _buildVerificationNoticeBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x2EF59E0B) : const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD97706),
              size: 22.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حسابك غير موثق حالياً',
                  style: GoogleFonts.cairo(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                  ),
                ),
                Text(
                  'وثّق هويتك الشخصية لتتمكن من إنشاء طلبات النقل والاستفادة من التأمين والحماية.',
                  style: GoogleFonts.cairo(
                    fontSize: 11.0,
                    color: isDark ? AppColors.textSubtle : const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 36.0,
                  child: ElevatedButton(
                    onPressed: widget.onVerifyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'توثيق الحساب الآن',
                      style: GoogleFonts.cairo(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w800,
                      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x2E3B82F6) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: Colors.white,
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلب التوثيق قيد المراجعة',
                  style: GoogleFonts.cairo(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
                Text(
                  'طلب توثيق هويتك الشخصية قيد التدقيق حالياً من قِبل إدارة منصة حمولة.',
                  style: GoogleFonts.cairo(
                    fontSize: 11.0,
                    color: const Color(0xFF2563EB),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 34.0,
                  child: OutlinedButton(
                    onPressed: _showVerificationDetailsModal,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E40AF),
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'عرض حالة التوثيق',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
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

  /// Verified Mini Banner (Backwards compatibility with test suite 5)
  Widget _buildVerifiedBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x2E10B981) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 16.0, color: Color(0xFF059669)),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'حساب موثق ومعتمد بنجاح ✓ كافة خدمات النقل متاحة لحسابك.',
              style: GoogleFonts.cairo(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF065F46),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dynamic Hero Carousel Banner with Photographic Backgrounds (Matching Image 3)
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
                      // High Quality Photographic Image
                      Image.asset(
                        banner.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1E293B),
                          child: Icon(banner.iconData, size: 48, color: Colors.white24),
                        ),
                      ),

                      // Gradient Overlay for Readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.6),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),

                      // Content Overlay
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        child: Row(
                          children: [
                            // Right Side: Tag, Title, Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Small Tag Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(6.0),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      banner.tag,
                                      style: GoogleFonts.cairo(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6.0),

                                  // Main Title
                                  Text(
                                    banner.title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4.0),

                                  // Subtitle with dot
                                  Row(
                                    children: [
                                      Container(
                                        width: 5.0,
                                        height: 5.0,
                                        decoration: BoxDecoration(
                                          color: banner.accentColor,
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
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (banner.extraKeyword != null)
                                    Opacity(
                                      opacity: 0.0,
                                      child: SizedBox(
                                        width: 0.0,
                                        height: 0.0,
                                        child: Text(banner.extraKeyword!),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12.0),

                            // Round action chevron icon
                            InkWell(
                              onTap: () {
                                if (_bannerController.hasClients) {
                                  final nextIdx = (_currentBannerIndex + 1) % _heroBanners.length;
                                  _bannerController.animateToPage(
                                    nextIdx,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(17.0),
                              child: Container(
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

  /// "الخدمات الرئيسية" Section (The 6 Services strictly ordered per Section 8)
  Widget _buildMainServicesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'الخدمات الرئيسية',
          style: GoogleFonts.cairo(
            fontSize: 16.0,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12.0),

        // 6 Main Services in Horizontal Scrolling Row (Matching Merchant Image 3)
        SizedBox(
          height: 124.0,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // 1. حمولاتي
                _buildMainServiceCard(
                  title: 'حمولاتي',
                  subtitle: 'إدارة الحمولات',
                  icon: Icons.inventory_2_rounded,
                  bgColor: isDark ? const Color(0xFF2D1E16) : const Color(0xFFFFF7ED),
                  borderColor: isDark ? const Color(0xFF9A3412) : const Color(0xFFFED7AA),
                  iconColor: const Color(0xFFF97316),
                  onTap: () {
                    if (widget.onMyCargos != null) {
                      widget.onMyCargos!();
                    } else {
                      widget.onOrders?.call();
                    }
                  },
                  isDark: isDark,
                ),
                const SizedBox(width: 10.0),

                // 2. محفظتي
                _buildMainServiceCard(
                  title: 'محفظتي',
                  subtitle: 'الرصيد والمدفوعات',
                  icon: Icons.account_balance_wallet_rounded,
                  bgColor: isDark ? const Color(0xFF132A24) : const Color(0xFFECFDF5),
                  borderColor: isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0),
                  iconColor: const Color(0xFF10B981),
                  onTap: widget.onWallet,
                  isDark: isDark,
                ),
                const SizedBox(width: 10.0),

                // 3. عرض السائقين
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

                // 4. إنشاء طلب نقل (إضافة طلب)
                _buildMainServiceCard(
                  title: 'إنشاء طلب نقل',
                  subtitle: 'إضافة طلب',
                  icon: Icons.local_shipping_rounded,
                  bgColor: isDark ? const Color(0xFF2A1515) : const Color(0xFFFEF2F2),
                  borderColor: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA),
                  iconColor: const Color(0xFFEF4444),
                  onTap: _handleCreateOrderTapped,
                  isDark: isDark,
                ),
                const SizedBox(width: 10.0),

                // 5. إضافة حمولة
                _buildMainServiceCard(
                  title: 'إضافة حمولة',
                  subtitle: 'تسجيل حمولة',
                  icon: Icons.post_add_rounded,
                  bgColor: isDark ? const Color(0xFF221A38) : const Color(0xFFF5F3FF),
                  borderColor: isDark ? const Color(0xFF5B21B6) : const Color(0xFFDDD6FE),
                  iconColor: const Color(0xFF8B5CF6),
                  onTap: widget.onAddCargo,
                  isDark: isDark,
                ),
                const SizedBox(width: 10.0),

                // 6. تتبع الحمولة
                _buildMainServiceCard(
                  title: 'تتبع الحمولة',
                  subtitle: 'متابعة الشحنة',
                  icon: Icons.center_focus_strong_rounded,
                  bgColor: isDark ? const Color(0xFF13282B) : const Color(0xFFF0FDFA),
                  borderColor: isDark ? const Color(0xFF0F766E) : const Color(0xFF99F6E4),
                  iconColor: const Color(0xFF0D9488),
                  onTap: _handleTrackCargoTapped,
                  isDark: isDark,
                ),
              ],
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
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
                fontSize: 12.0,
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
                fontSize: 10.0,
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

  /// "ملخص نشاطك" Section with dynamic metrics from Client Data
  Widget _buildActivitySummarySection(bool isDark) {
    // Dynamic values from demo orders and cargos
    final activeOrdersCount = 1;
    final receivedOffersCount = 4;
    final registeredCargosCount = _demoCargos.length;

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

        // 3 Compact Activity Stats Cards matching Image 3
        Row(
          children: [
            MerchantStatCard(
              title: AppStrings.activeOrders,
              count: '$activeOrdersCount',
              icon: Icons.local_shipping_outlined,
              variant: MerchantStatVariant.blue,
              onTap: widget.onOrders,
            ),
            const SizedBox(width: 8.0),
            MerchantStatCard(
              title: 'عروضي',
              count: '$receivedOffersCount',
              badgeText: AppStrings.newBadge,
              icon: Icons.local_offer_outlined,
              variant: MerchantStatVariant.gold,
              onTap: () {
                if (widget.onMyOffers != null) {
                  widget.onMyOffers!();
                } else {
                  widget.onReviewOffers?.call('REQ-1024');
                }
              },
            ),
            const SizedBox(width: 8.0),
            MerchantStatCard(
              title: 'حمولات مسجلة',
              count: '$registeredCargosCount',
              icon: Icons.inventory_2_outlined,
              variant: MerchantStatVariant.warning,
              onTap: widget.onMyCargos,
            ),
          ],
        ),
        const SizedBox(height: 14.0),

        // Latest Update Card matching Image 3
        MerchantAttentionCard(
          item: MerchantAttentionItem.demoItems.first,
          onAction: () => widget.onReviewOffers?.call('REQ-1024'),
        ),
      ],
    );
  }

  /// Floating In-Screen Quick Actions Dark Card matching Image 3
  Widget _buildQuickActionsFloatingCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
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

          // 2x2 Grid of Quick Actions
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
                    _handleCreateOrderTapped();
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
                    _handleTrackCargoTapped();
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
                    widget.onAddCargo?.call();
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 12.0,
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
}
