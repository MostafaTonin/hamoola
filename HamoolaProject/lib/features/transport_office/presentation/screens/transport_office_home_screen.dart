import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../driver/domain/models/cargo_bid_opportunity.dart';
import '../../../driver/domain/models/driver_simulation_store.dart';
import '../../../merchant/domain/models/merchant_simulation_store.dart';

/// Transport Office Home Screen (Section 1 to 12 in User Specification):
/// - Exact visual fidelity matching the reference image.
/// - Top header with office greeting, short office name, smart assistant and notification bell.
/// - 4-banner hero slider rotating automatically every 3 seconds with single timer.
/// - 3 stats cards in one horizontal row: الطلبات المتاحة, الطلبات النشطة, الرحلات المكتملة.
/// - 4 quick services in one row: رحلاتي, السائقون, محفظتي, أرباحي.
/// - "الطلبات المتاحة لك" section with real-time filters (الكل, العامة, الخاصة) and rich cards.
/// - Dedicated 5-item bottom navigation bar with central red (+) FAB without text.
/// - Dark navy 2x2 grid quick actions sheet for (+): تحديث الحالة, رحلاتي الجارية, طلب مساعدة, الإبلاغ عن مشكلة.
class TransportOfficeHomeScreen extends StatefulWidget {
  final VoidCallback? onVerifyNow;
  final VoidCallback? onAccount;
  final VoidCallback? onNotifications;
  final VoidCallback? onLogout;
  final ValueChanged<String>? onOrderDetails;
  final AccountVerificationStatus? initialVerificationStatus;

  const TransportOfficeHomeScreen({
    super.key,
    this.onVerifyNow,
    this.onAccount,
    this.onNotifications,
    this.onLogout,
    this.onOrderDetails,
    this.initialVerificationStatus,
  });

  @override
  State<TransportOfficeHomeScreen> createState() => _TransportOfficeHomeScreenState();
}

class _TransportOfficeHomeScreenState extends State<TransportOfficeHomeScreen>
    with SingleTickerProviderStateMixin {
  AccountVerificationStatus? _statusOverride;
  // Slider state
  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;

  // Filter state for Available Orders
  String _selectedOrderFilter = 'الكل'; // 'الكل', 'العامة', 'الخاصة'

  // Office Availability state (persisted)
  bool _isAvailableForOrders = true;

  // (+) FAB animation controller for rotating + to ×
  late final AnimationController _fabAnimController;
  bool _isFabSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _statusOverride = widget.initialVerificationStatus;
    _isAvailableForOrders = AppPreferences.instance.isOfficeAvailable;
    _bannerController = PageController();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _startBannerAutoScroll();

    // Listen to changes in simulation stores
    DriverSimulationStore.instance.addListener(_onStoreChanged);
    MerchantSimulationStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _fabAnimController.dispose();
    DriverSimulationStore.instance.removeListener(_onStoreChanged);
    MerchantSimulationStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _startBannerAutoScroll() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      final next = (_currentBannerIndex + 1) % 4;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  AuthUser get _officeUser {
    final store = AuthSimulationStore.instance;
    final current = store.currentUser;
    if (current != null && current.role == AuthUserRole.office) {
      if (_statusOverride != null) {
        return current.copyWith(verificationStatus: _statusOverride);
      }
      return current;
    }
    return store.getDemoUserByRole(AuthUserRole.office) ??
        AuthUser(
          id: 'USR-OFFICE-01',
          name: 'صالح مسعد العمري',
          phone: '774567890',
          password: 'password123',
          role: AuthUserRole.office,
          verificationStatus: _statusOverride ?? widget.initialVerificationStatus ?? AccountVerificationStatus.verified,
          createdAt: DateTime(2026, 7, 10),
          officeData: OfficeEnterpriseData(
            officeName: 'مكتب النقل السالمي',
            activityType: 'نقل ثقيل وبضائع بين المحافظات',
            crNumber: 'CR-7729104',
            crIssuer: 'وزارة الصناعة والتجارة - مكتب النقل',
            crIssueDate: '2021-06-15',
            crExpiryDate: '2027-06-14',
            address: 'صنعاء - شارع تعز - جولة 45',
            businessDescription: 'خدمات شحن ونقل بضائع وتأجير شاحنات وقاطرات لجميع المحافظات',
            fleetCount: 18,
          ),
        );
  }

  String get _officeDisplayName {
    final name = _officeUser.officeData?.officeName;
    if (name != null &&
        name.isNotEmpty &&
        name != 'مكتب الأمانة لنقل البضائع والمهمات') {
      return name;
    }
    return 'مكتب النقل السالمي';
  }

  // Banners data matching Section 4
  final List<Map<String, dynamic>> _banners = const [
    {
      'title': 'فرص نقل جديدة بانتظارك',
      'subtitle': 'اكتشف أفضل الطلبات المناسبة لمكتبك',
      'button': 'عرض الطلبات',
      'image': 'assets/images/driver_hero_actros.jpg',
      'action': 'available_orders',
    },
    {
      'title': 'تابع رحلات مكتبك بسهولة',
      'subtitle': 'تابع حالة الرحلات والمهام المرتبطة بها',
      'button': 'عرض الرحلات',
      'image': 'assets/images/hamula_intercity_cargo.jpg',
      'action': 'trips',
    },
    {
      'title': 'شبكة من السائقين الموثوقين',
      'subtitle': 'أدر السائقين الذين تزكيهم من خلال حمولة',
      'button': 'السائقون',
      'image': 'assets/images/hamula_port_cargo.jpg',
      'action': 'drivers',
    },
    {
      'title': 'تحتاج إلى سائق لنقل حمولة؟',
      'subtitle': 'أنشئ طلب نقل وابحث عن السائق المناسب',
      'button': 'إنشاء طلب',
      'image': 'assets/images/merchant_hero_truck_banner.jpg',
      'action': 'create_order',
    },
  ];

  void _handleBannerAction(String action) {
    switch (action) {
      case 'available_orders':
        context.push(AppRoutes.driverAvailableOrders, extra: 'الكل');
        break;
      case 'trips':
        context.push(AppRoutes.driverTrips, extra: 'النشطة');
        break;
      case 'drivers':
        context.push(AppRoutes.merchantSelectDriver);
        break;
      case 'create_order':
        context.push(AppRoutes.merchantCreateOrder);
        break;
    }
  }

  // Filtered available orders
  List<CargoBidOpportunity> get _filteredOrders {
    final all = DriverSimulationStore.instance.opportunities
        .where((o) => !o.isExpiredOrClosed)
        .toList();

    if (_selectedOrderFilter == 'العامة') {
      return all.where((o) => !o.isPrivate).toList();
    } else if (_selectedOrderFilter == 'الخاصة') {
      // Show private orders directed to office (only if office is available)
      if (!_isAvailableForOrders) {
        return [];
      }
      return all.where((o) => o.isPrivate).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final driverStore = DriverSimulationStore.instance;

    // Dynamic stats values
    final availableCount = driverStore.availableOpportunitiesCount > 0
        ? driverStore.availableOpportunitiesCount
        : 9;
    final activeCount = driverStore.activeOrdersCount > 0
        ? driverStore.activeOrdersCount
        : 4;
    final completedCount = driverStore.completedTripsCount > 0
        ? driverStore.completedTripsCount
        : 18;

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomBarHeight = 58.0 + bottomInset;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: PopScope(
          canPop: !_isFabSheetOpen,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _isFabSheetOpen) {
              _closeQuickActions();
            }
          },
          child: Stack(
            children: [
              // Layer 1: Scrollable Page Content + Bottom padding for nav bar
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomBarHeight),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Section 3: Header
                          _buildHeader(),

                          const SizedBox(height: 12.0),

                          // Section 4: Main Slider (4 Banners)
                          _buildHeroSlider(),

                          const SizedBox(height: 16.0),

                          // Section 5: Three Stats Cards in one row
                          _buildStatsRow(
                            availableCount: availableCount,
                            activeCount: activeCount,
                            completedCount: completedCount,
                          ),

                          const SizedBox(height: 20.0),

                          // Section 6: Quick Services ("الخدمات السريعة")
                          _buildQuickServicesSection(),

                          const SizedBox(height: 20.0),

                          // Section 7: Available Orders Section ("الطلبات المتاحة لك")
                          _buildAvailableOrdersSection(),

                          const SizedBox(height: 40.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Layer 2: Dim Backdrop Scrim (when card is open)
              if (_isFabSheetOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => _closeQuickActions(),
                    behavior: HitTestBehavior.opaque,
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _fabAnimController,
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.52),
                      ),
                    ),
                  ),
                ),

              // Layer 3: Floating 4-Action Card (detached with margins from sides and bottom)
              if (_isFabSheetOpen)
                Positioned(
                  left: 16.0,
                  right: 16.0,
                  bottom: bottomBarHeight + 14.0,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _fabAnimController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _fabAnimController,
                        curve: Curves.easeOut,
                      ),
                      child: _buildFloatingQuickActionsCard(),
                    ),
                  ),
                ),

              // Layer 4: Bottom Navigation Bar with centered (+) FAB (ALWAYS VISIBLE on top of backdrop!)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomNavigationBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Section 3: Top Header
  // ===========================================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Office Icon in light-blue rounded container
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF3FE),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Center(
              child: Icon(
                Icons.apartment_rounded,
                color: Color(0xFF1D4ED8),
                size: 26.0,
              ),
            ),
          ),
          const SizedBox(width: 10.0),

          // Greeting & Office Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    children: [
                      Text(
                        'أهلًا بك في حمولة',
                        style: GoogleFonts.cairo(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Text('👋', style: TextStyle(fontSize: 14.0)),
                    ],
                  ),
                ),
                Text(
                  _officeDisplayName,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Smart Assistant button (Robot icon only, no text)
          InkWell(
            onTap: _showSmartAssistantDialog,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: Color(0xFF2563EB),
                  size: 22.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),

          // Notification Bell button with unread indicator badge
          InkWell(
            onTap: widget.onNotifications ?? () => context.push(AppRoutes.notifications),
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF0F172A),
                    size: 22.0,
                  ),
                  Positioned(
                    top: 10.0,
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
    );
  }

  // ===========================================================================
  // Section 4: Main Slider (4 Banners with 3s Auto-Scroll)
  // ===========================================================================
  Widget _buildHeroSlider() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 172.0,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (idx) {
              setState(() => _currentBannerIndex = idx);
            },
            itemBuilder: (ctx, idx) {
              final banner = _banners[idx];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Truck image background
                      Image.asset(
                        banner['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1E293B),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            size: 48.0,
                            color: Colors.white24,
                          ),
                        ),
                      ),

                      // Gradient overlay for legibility (dark on right in RTL)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                        ),
                      ),

                      // Overlay texts & Action button
                      Positioned(
                        right: 16.0,
                        top: 14.0,
                        bottom: 14.0,
                        left: 80.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner['title'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3.0),
                            Text(
                              banner['subtitle'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () => _handleBannerAction(banner['action'] as String),
                              borderRadius: BorderRadius.circular(20.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 6.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E60E2),
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1E60E2).withValues(alpha: 0.4),
                                      blurRadius: 8.0,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      banner['button'] as String,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6.0),
                                    const Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                      size: 15.0,
                                    ),
                                  ],
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

        // Indicator dots (4 dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (idx) {
            final isActive = idx == _currentBannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              width: isActive ? 18.0 : 7.0,
              height: 7.0,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4.0),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ===========================================================================
  // Section 5: Three Stats Cards in One Row (Right to Left)
  // ===========================================================================
  Widget _buildStatsRow({
    required int availableCount,
    required int activeCount,
    required int completedCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // 1. الطلبات المتاحة (Rightmost in RTL)
          Expanded(
            child: _buildSingleStatCard(
              title: 'الطلبات المتاحة',
              number: '$availableCount',
              numberColor: const Color(0xFF0F172A),
              icon: Icons.description_rounded,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              buttonBgColor: const Color(0xFFEFF6FF),
              buttonTextColor: const Color(0xFF2563EB),
              onTap: () => context.push(AppRoutes.driverAvailableOrders, extra: 'الكل'),
            ),
          ),
          const SizedBox(width: 10.0),

          // 2. الطلبات النشطة (Center)
          Expanded(
            child: _buildSingleStatCard(
              title: 'الطلبات النشطة',
              number: '$activeCount',
              numberColor: const Color(0xFFEA580C),
              icon: Icons.local_shipping_rounded,
              iconBgColor: const Color(0xFFFFF7ED),
              iconColor: const Color(0xFFEA580C),
              buttonBgColor: const Color(0xFFFFF7ED),
              buttonTextColor: const Color(0xFFEA580C),
              onTap: () => context.push(AppRoutes.driverOrders, extra: 'عروضي النشطة'),
            ),
          ),
          const SizedBox(width: 10.0),

          // 3. الرحلات المكتملة (Leftmost in RTL)
          Expanded(
            child: _buildSingleStatCard(
              title: 'الرحلات المكتملة',
              number: '$completedCount',
              numberColor: const Color(0xFF0F172A),
              icon: Icons.check_circle_rounded,
              iconBgColor: const Color(0xFFF0FDF4),
              iconColor: const Color(0xFF16A34A),
              buttonBgColor: const Color(0xFFF0FDF4),
              buttonTextColor: const Color(0xFF16A34A),
              onTap: () => context.push(AppRoutes.driverTrips, extra: 'المكتملة'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleStatCard({
    required String title,
    required String number,
    required Color numberColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required Color buttonBgColor,
    required Color buttonTextColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon on top
          Container(
            padding: const EdgeInsets.all(7.5),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: iconColor, size: 21.0),
          ),
          const SizedBox(height: 7.0),

          // Title
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2.0),

          // Large Stat Number
          Text(
            number,
            style: GoogleFonts.cairo(
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
              color: numberColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8.0),

          // Action button "عرض الكل ←"
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.5),
              decoration: BoxDecoration(
                color: buttonBgColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'عرض الكل',
                      style: GoogleFonts.cairo(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w800,
                        color: buttonTextColor,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.arrow_back_rounded,
                      color: buttonTextColor,
                      size: 12.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section 6: Quick Services ("الخدمات السريعة")
  // ===========================================================================
  Widget _buildQuickServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخدمات السريعة',
            style: GoogleFonts.cairo(
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              // 1. رحلاتي (Right)
              Expanded(
                child: _buildQuickServiceItem(
                  title: 'رحلاتي',
                  icon: Icons.local_shipping_rounded,
                  iconColor: const Color(0xFFE8590C),
                  boxBgColor: const Color(0xFFFFF2E8),
                  onTap: () => context.push(AppRoutes.transportOfficeTrips),
                ),
              ),
              const SizedBox(width: 12.0),

              // 2. السائقون
              Expanded(
                child: _buildQuickServiceItem(
                  title: 'السائقون',
                  icon: Icons.group_rounded,
                  iconColor: const Color(0xFF2271EB),
                  boxBgColor: const Color(0xFFEDF5FF),
                  onTap: () => context.push(AppRoutes.transportOfficeDrivers),
                ),
              ),
              const SizedBox(width: 12.0),

              // 3. محفظتي
              Expanded(
                child: _buildQuickServiceItem(
                  title: 'محفظتي',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFF12B76A),
                  boxBgColor: const Color(0xFFE9FBF0),
                  onTap: () => context.push(AppRoutes.merchantWallet),
                ),
              ),
              const SizedBox(width: 12.0),

              // 4. أرباحي (Left)
              Expanded(
                child: _buildQuickServiceItem(
                  title: 'أرباحي',
                  icon: Icons.insert_chart_rounded,
                  iconColor: const Color(0xFF9044EB),
                  boxBgColor: const Color(0xFFF3EBFF),
                  onTap: _showEarningsSummarySheet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServiceItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color boxBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 64.0,
            decoration: BoxDecoration(
              color: boxBgColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 30.0),
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section 7: Available Orders Section ("الطلبات المتاحة لك")
  // ===========================================================================
  Widget _buildAvailableOrdersSection() {
    final filtered = _filteredOrders;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الطلبات المتاحة لك',
                      style: GoogleFonts.cairo(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'تصفح أحدث الطلبات المناسبة لمكتبك',
                      style: GoogleFonts.cairo(
                        fontSize: 12.0,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => context.push(
                  AppRoutes.driverAvailableOrders,
                  extra: _selectedOrderFilter,
                ),
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF2563EB),
                        size: 15.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'عرض الكل',
                        style: GoogleFonts.cairo(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // Filter Chips (الكل, العامة, الخاصة)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('الكل'),
                const SizedBox(width: 8.0),
                _buildFilterChip('العامة'),
                const SizedBox(width: 8.0),
                _buildFilterChip('الخاصة'),
              ],
            ),
          ),

          const SizedBox(height: 14.0),

          // Orders List
          if (filtered.isEmpty)
            _buildEmptyOrdersState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10.0),
              itemBuilder: (ctx, idx) {
                final order = filtered[idx];
                return _buildOrderCard(order);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedOrderFilter == label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedOrderFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(CargoBidOpportunity order) {
    final isGeneral = !order.isPrivate;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onOrderDetails != null) {
              widget.onOrderDetails!(order.id);
            } else {
              context.push(AppRoutes.driverOrderDetails, extra: order);
            }
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cargo thumbnail image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    order.imageAsset ?? 'assets/images/cargo_ref_1.jpg',
                    width: 76.0,
                    height: 76.0,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 76.0,
                      height: 76.0,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF94A3B8),
                        size: 32.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),

                // Order details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Row: Title + Chevron + Badge (طلب عام / طلب خاص)
                      // Top Row: Title + Chevron + Badge (طلب عام / طلب خاص)
                      Row(
                        children: [
                          // Badge: طلب عام / طلب خاص
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: isGeneral
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFFAF5FF),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              isGeneral ? 'طلب عام' : 'طلب خاص',
                              style: GoogleFonts.cairo(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w800,
                                color: isGeneral
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFF7E22CE),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),

                          // Title and chevron expand to available space
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    order.title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                        ],
                      ),
                      const SizedBox(height: 6.0),

                      // Middle Row: Route (Origin 📍 ↔ 📍 Destination) with Flexible to prevent overflow
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14.0,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 2.0),
                          Flexible(
                            child: Text(
                              order.originCity,
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              Icons.swap_horiz_rounded,
                              size: 15.0,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const Icon(
                            Icons.location_on_rounded,
                            size: 14.0,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 2.0),
                          Flexible(
                            child: Text(
                              order.destinationCity,
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),

                      // Bottom Row: 3 Badges (Price in Rial, Weight, Distance) with FittedBox to prevent overflow
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Price
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.payments_outlined,
                                  size: 13.5,
                                  color: Color(0xFF16A34A),
                                ),
                                const SizedBox(width: 3.0),
                                Text(
                                  '${order.targetBudgetYmr} ريال',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10.0),

                            // Weight
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.fitness_center_rounded,
                                  size: 12.5,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 2.5),
                                Text(
                                  '${order.weightTons.toInt()} طن',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10.0),

                            // Distance
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.alt_route_rounded,
                                  size: 12.5,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 2.5),
                                Text(
                                  '${order.distanceKm} كم',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 32.0,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            !_isAvailableForOrders && _selectedOrderFilter == 'الخاصة'
                ? 'حالة استقبال الطلبات غير متاحة حالياً'
                : 'لا توجد طلبات متطابقة مع الفلتر الحالي',
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.0),
          Text(
            !_isAvailableForOrders && _selectedOrderFilter == 'الخاصة'
                ? 'قم بتفعيل حالة المكتب إلى «متاح» من زر (+) لتلقي الطلبات الخاصة.'
                : 'جرّب تغيير خيار الفلتر لعرض المزيد من فرص النقل.',
            style: GoogleFonts.cairo(
              fontSize: 12.0,
              color: const Color(0xFF94A3B8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12.0),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedOrderFilter = 'الكل';
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 16.0),
            label: Text(
              'عرض جميع الطلبات',
              style: GoogleFonts.cairo(fontSize: 12.0, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section 8: Bottom Navigation Bar with Center Floating (+) FAB
  // ===========================================================================
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. الرئيسية (Active - Red)
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                isActive: true,
                onTap: () {},
              ),

              // 2. الخريطة
              _buildNavItem(
                icon: Icons.location_on_outlined,
                label: 'الخريطة',
                isActive: false,
                onTap: () => context.push(AppRoutes.driverCargoMap),
              ),

              // 3. Middle Floating (+) Button (NO TEXT UNDER IT!)
              SizedBox(
                width: 56.0,
                child: Center(child: _buildCenterFab()),
              ),

              // 4. طلباتي
              _buildNavItem(
                icon: Icons.assignment_outlined,
                label: 'طلباتي',
                isActive: false,
                onTap: () => context.push(AppRoutes.transportOfficeOrders),
              ),

              // 5. حسابي
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                label: 'حسابي',
                isActive: false,
                onTap: widget.onAccount ?? () => context.push(AppRoutes.transportOfficeAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFFDC2626) : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24.0),
              const SizedBox(height: 2.0),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11.0,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFab() {
    return GestureDetector(
      onTap: _toggleQuickActionsSheet,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: const Offset(0, -6.0), // Elevated slightly above the bottom bar
        child: Container(
          width: 54.0,
          height: 54.0,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: _isFabSheetOpen ? 0.55 : 0.4),
                blurRadius: _isFabSheetOpen ? 14.0 : 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 0.125).animate(
                CurvedAnimation(
                  parent: _fabAnimController,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Section 9: (+) Quick Actions Floating Card (Dark Navy 2x2 Grid)
  // ===========================================================================
  void _toggleQuickActionsSheet() {
    if (_isFabSheetOpen) {
      _closeQuickActions();
    } else {
      _openQuickActions();
    }
  }

  void _openQuickActions() {
    setState(() => _isFabSheetOpen = true);
    _fabAnimController.forward(from: 0.0);
  }

  void _closeQuickActions({bool immediate = false}) {
    if (!_isFabSheetOpen) return;
    if (immediate) {
      _fabAnimController.reset();
      setState(() => _isFabSheetOpen = false);
    } else {
      _fabAnimController.reverse().then((_) {
        if (mounted) {
          setState(() => _isFabSheetOpen = false);
        }
      });
    }
  }

  Widget _buildFloatingQuickActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark navy #0F172A
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24.0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 4.0),
              width: 38.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),

            // 2x2 Grid with horizontal and vertical thin lines
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: تحديث الحالة & رحلاتي الجارية
                  Row(
                    children: [
                      // 1. تحديث الحالة
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.sync_alt_rounded,
                          label: 'تحديث الحالة',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            _showStatusUpdateDialog();
                          },
                        ),
                      ),

                      // Vertical divider
                      Container(
                        height: 80.0,
                        width: 1.0,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),

                      // 2. رحلاتي الجارية
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.local_shipping_rounded,
                          label: 'رحلاتي الجارية',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            context.push(AppRoutes.transportOfficeTrips);
                          },
                        ),
                      ),
                    ],
                  ),

                  // Horizontal divider
                  Container(
                    width: double.infinity,
                    height: 1.0,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),

                  // Row 2: طلب مساعدة & الإبلاغ عن مشكلة
                  Row(
                    children: [
                      // 3. طلب مساعدة
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.headset_mic_rounded,
                          label: 'طلب مساعدة',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            _showSupportRequestDialog();
                          },
                        ),
                      ),

                      // Vertical divider
                      Container(
                        height: 80.0,
                        width: 1.0,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),

                      // 4. الإبلاغ عن مشكلة
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.report_problem_rounded,
                          label: 'الإبلاغ عن مشكلة',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            _showReportIssueDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionGridTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28.0,
            ),
            const SizedBox(height: 10.0),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Action 1: Status Update Dialog ("متاح" / "غير متاح")
  // ===========================================================================
  void _showStatusUpdateDialog() {
    bool tempStatus = _isAvailableForOrders;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dlgCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: const EdgeInsets.all(22.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    Row(
                      children: [
                        const Icon(Icons.sync_alt_rounded, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8.0),
                        Text(
                          'تحديث حالة استقبال الطلبات',
                          style: GoogleFonts.cairo(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'تحدد هذه الحالة جاهزية مكتبك لتلقي الطلبات الخاصة الموجهة مباشرة.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 18.0),

                    // Option 1: متاح
                    _buildStatusOptionTile(
                      title: 'متاح لاستقبال الطلبات',
                      subtitle: 'استقبال الطلبات الخاصة الموجهة للمكتب، مع إمكانية التقديم على الطلبات العامة.',
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF16A34A),
                      isSelected: tempStatus == true,
                      onTap: () {
                        setModalState(() => tempStatus = true);
                      },
                    ),

                    const SizedBox(height: 10.0),

                    // Option 2: غير متاح
                    _buildStatusOptionTile(
                      title: 'غير متاح حالياً',
                      subtitle: 'عدم توجيه طلبات خاصة جديدة، دون التأثير على الطلبات والرحلات الحالية والطلبات العامة.',
                      icon: Icons.pause_circle_outline_rounded,
                      iconColor: const Color(0xFFEA580C),
                      isSelected: tempStatus == false,
                      onTap: () {
                        setModalState(() => tempStatus = false);
                      },
                    ),

                    const SizedBox(height: 20.0),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dlgCtx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            child: Text(
                              'إلغاء',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await AppPreferences.instance.setOfficeAvailable(tempStatus);
                              if (mounted) {
                                setState(() {
                                  _isAvailableForOrders = tempStatus;
                                });
                              }
                              if (dlgCtx.mounted) Navigator.pop(dlgCtx);
                              _showStatusSnackBar(tempStatus);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Text(
                              'حفظ الحالة',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showStatusSnackBar(bool status) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: status ? const Color(0xFF16A34A) : const Color(0xFF475569),
        content: Text(
          status
              ? 'تم تحديث الحالة: المكتب متاح لاستقبال الطلبات ✓'
              : 'تم تحديث الحالة: المكتب غير متاح لتلقي طلبات خاصة جديدة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Action 3: Support Request Dialog (Section 9)
  // ===========================================================================
  void _showSupportRequestDialog() {
    final subjectController = TextEditingController();
    final detailsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dlgCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Row(
            children: [
              const Icon(Icons.headset_mic_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 8.0),
              Text(
                'طلب مساعدة والدعم الفني',
                style: GoogleFonts.cairo(fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'موضوع الطلب *',
                    style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    controller: subjectController,
                    style: GoogleFonts.cairo(fontSize: 13.0),
                    decoration: InputDecoration(
                      hintText: 'مثال: استفسار بخصوص تسوية الرحلة',
                      hintStyle: GoogleFonts.cairo(fontSize: 12.0, color: const Color(0xFF94A3B8)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'يرجى إدخال موضوع الطلب' : null,
                  ),
                  const SizedBox(height: 14.0),
                  Text(
                    'تفاصيل المساعدة المطلوبة *',
                    style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    controller: detailsController,
                    maxLines: 4,
                    style: GoogleFonts.cairo(fontSize: 13.0),
                    decoration: InputDecoration(
                      hintText: 'اكتب تفاصيل طلبك بدقة لمساعدتك في أسرع وقت...',
                      hintStyle: GoogleFonts.cairo(fontSize: 12.0, color: const Color(0xFF94A3B8)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      contentPadding: const EdgeInsets.all(12.0),
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'يرجى كتابة تفاصيل الطلب' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dlgCtx);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF16A34A),
                      content: Text(
                        'تم تسجيل طلب المساعدة بنجاح (رقم التذكرة: SUP-${DateTime.now().millisecondsSinceEpoch % 10000}) ✓',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('إرسال الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Action 4: Report Issue Dialog (Section 9)
  // ===========================================================================
  void _showReportIssueDialog() {
    final descController = TextEditingController();
    String issueType = 'تأخير في التحميل أو التستيف';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              title: Row(
                children: [
                  const Icon(Icons.report_problem_rounded, color: Color(0xFFEA580C)),
                  const SizedBox(width: 8.0),
                  Text(
                    'الإبلاغ عن مشكلة لوجستية',
                    style: GoogleFonts.cairo(fontSize: 16.5, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نوع المشكلة *',
                        style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6.0),
                      DropdownButtonFormField<String>(
                        initialValue: issueType,
                        items: const [
                          DropdownMenuItem(
                            value: 'تأخير في التحميل أو التستيف',
                            child: Text('تأخير في التحميل أو التستيف'),
                          ),
                          DropdownMenuItem(
                            value: 'اختلاف مواصفات أو وزن الشحنة',
                            child: Text('اختلاف مواصفات أو وزن الشحنة'),
                          ),
                          DropdownMenuItem(
                            value: 'تعذر التواصل مع السائق أو التاجر',
                            child: Text('تعذر التواصل مع السائق أو التاجر'),
                          ),
                          DropdownMenuItem(
                            value: 'مشكلة مالية أو في الرصيد',
                            child: Text('مشكلة مالية أو في الرصيد'),
                          ),
                          DropdownMenuItem(
                            value: 'أخرى',
                            child: Text('مشكلة أخرى'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setDlgState(() => issueType = val);
                        },
                        style: GoogleFonts.cairo(fontSize: 12.5, color: const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      Text(
                        'وصف المشكلة *',
                        style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6.0),
                      TextFormField(
                        controller: descController,
                        maxLines: 4,
                        style: GoogleFonts.cairo(fontSize: 13.0),
                        decoration: InputDecoration(
                          hintText: 'صف المشكلة بوضوح، مع ذكر رقم الرحلة أو الطلب إن وجد...',
                          hintStyle: GoogleFonts.cairo(fontSize: 12.0, color: const Color(0xFF94A3B8)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          contentPadding: const EdgeInsets.all(12.0),
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty) ? 'يرجى كتابة وصف المشكلة' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgCtx),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.pop(dlgCtx);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFFEA580C),
                          content: Text(
                            'تم رفع البلاغ بنجاح وسيتابع فريق الطوارئ معك فوراً ✓',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: Text('إرسال البلاغ', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // Dialogs: Smart Assistant & Earnings Summary
  // ===========================================================================
  void _showSmartAssistantDialog() {
    showDialog(
      context: context,
      builder: (dlgCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Row(
            children: [
              const Icon(Icons.smart_toy_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 8.0),
              Text(
                'المساعد الذكي لمكتب النقل',
                style: GoogleFonts.cairo(fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك! يمكنني مساعدتك في:',
                style: GoogleFonts.cairo(fontSize: 13.0, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8.0),
              Text('• حساب تسعيرة النقل التقديرية بالطن والكيلومتر.', style: GoogleFonts.cairo(fontSize: 12.0)),
              Text('• مراجعة أفضل الطلبات المطابقة لمسارات مكتبك.', style: GoogleFonts.cairo(fontSize: 12.0)),
              Text('• تتبع مسار الرحلات النشطة وتحذيرات الطرق.', style: GoogleFonts.cairo(fontSize: 12.0)),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dlgCtx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('حسناً', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEarningsSummarySheet() {
    final store = MerchantSimulationStore.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(22.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Icon(Icons.insert_chart_rounded, color: Color(0xFF9044EB)),
                  const SizedBox(width: 8.0),
                  Text(
                    'ملخص أرباح مكتب النقل',
                    style: GoogleFonts.cairo(fontSize: 17.0, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EBFF),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صافي الأرباح المحققة',
                          style: GoogleFonts.cairo(fontSize: 12.0, color: const Color(0xFF6B21A8)),
                        ),
                        Text(
                          '${store.walletBalance.toStringAsFixed(0)} ريال',
                          style: GoogleFonts.cairo(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF581C87),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.trending_up_rounded, color: Color(0xFF9044EB), size: 36.0),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('مستحقات قيد التسوية:', style: GoogleFonts.cairo(fontSize: 13.0, color: const Color(0xFF64748B))),
                  Text('${store.pendingBalance.toStringAsFixed(0)} ريال', style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                ],
              ),
              const Divider(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إجمالي الرحلات المسلمة:', style: GoogleFonts.cairo(fontSize: 13.0, color: const Color(0xFF64748B))),
                  Text('18 رحلة بنجاح', style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.w800, color: const Color(0xFF16A34A))),
                ],
              ),
              const SizedBox(height: 18.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push(AppRoutes.merchantWallet);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9044EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Text('الانتقال للمحفظة والتسويات', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
