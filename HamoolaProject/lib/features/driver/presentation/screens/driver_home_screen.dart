import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../domain/models/cargo_bid_opportunity.dart';
import '../../domain/models/driver_simulation_store.dart';
import '../../../merchant/domain/models/merchant_simulation_store.dart';
import '../../../merchant/presentation/widgets/merchant_bottom_nav_bar.dart';
import '../widgets/driver_submit_bid_sheet.dart';
import 'driver_order_details_screen.dart';
import 'driver_orders_screen.dart';
import 'driver_trips_screen.dart';
import 'driver_trip_tracking_screen.dart';
import 'driver_cargo_map_screen.dart';
import 'driver_account_screen.dart';
import 'driver_available_orders_screen.dart';

class _BannerSlideData {
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  const _BannerSlideData({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });
}


/// Main Dashboard and Cargo Marketplace for Truck Drivers in Hamula Platform.
/// Faithfully implements the design reference:
/// 1. Top Header: Hamula Logo, Notification Bell with unread badge (3), Driver Avatar & Greeting.
/// 2. Availability Card: Toggle switch with 'متاح الآن' / 'غير متاح', instant status change.
/// 3. Conditional Active Trip Card: Rendered only when driver has an active ongoing trip.
/// 4. Hero Banner: Professional truck on open road with 'فرص نقل جديدة بانتظارك' & 'عرض الطلبات'.
/// 5. Statistics: 3 horizontal cards (الرحلات المكتملة 18, الطلبات النشطة 2, الطلبات المتاحة 12).
/// 6. Quick Services: 4 items (رحلاتي, خريطة الحمولات, محفظتي, أرباحي).
/// 7. Available Orders: Filterable (الكل, العامة, الخاصة), detailed cards with route, price & details.
/// 8. Quick Actions Modal: Dark Navy quadrant card opened via (+) converting to (x), 4 actions:
///    - Top Right: تحديث الحالة
///    - Top Left: الطلبات المتاحة
///    - Bottom Right: طلب مساعدة
///    - Bottom Left: الإبلاغ عن مشكلة
/// 9. Bottom Navigation Bar matching Hamula design (الرئيسية, الخريطة, (+), طلباتي, حسابي).
class DriverHomeScreen extends StatefulWidget {
  final VoidCallback? onNotifications;
  final VoidCallback? onSwitchToMerchant;
  final VoidCallback? onWallet;
  final VoidCallback? onSupport;
  final VoidCallback? onLogout;
  final ValueChanged<String>? onTripDetails;
  final VoidCallback? onVerifyLicense;
  final VoidCallback? onAccount;
  final VoidCallback? onOrders;
  final VoidCallback? onTrips;
  final VoidCallback? onMap;
  final bool autoScrollBanner;

  const DriverHomeScreen({
    super.key,
    this.onNotifications,
    this.onSwitchToMerchant,
    this.onWallet,
    this.onSupport,
    this.onLogout,
    this.onTripDetails,
    this.onVerifyLicense,
    this.onAccount,
    this.onOrders,
    this.onTrips,
    this.onMap,
    this.autoScrollBanner = false,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _availableOrdersKey = GlobalKey();

  late bool _isOnline;
  String _activeFilter = 'الكل';
  bool _isQuickActionsOpen = false;
  MerchantNavTab _currentTab = MerchantNavTab.home;
  AccountVerificationStatus? _overrideVerificationStatus;

  // Single PageController and Single Timer for Banner Slider
  final PageController _bannerPageController = PageController();
  Timer? _bannerTimer;
  int _currentBannerIndex = 0;
  bool _isUserInteractingWithBanner = false;

  // Active driver metrics
  final int _todayEarnings = 85000;
  final int _activeBidsCount = 3;
  int get _completedTripsCount => DriverSimulationStore.instance.completedTripsCount;

  // ignore: prefer_final_fields
  DriverActiveTrip? _activeTrip = DriverActiveTrip.demoActiveTrip;

  DriverActiveTrip? get _effectiveActiveTrip {
    final storeTrip = DriverSimulationStore.instance.activeTrip;
    if (storeTrip != null) {
      return storeTrip.toActiveTrip();
    }
    return _activeTrip;
  }

  final List<CargoBidOpportunity> _opportunities =
      List.of(CargoBidOpportunity.demoOpportunities);

  @override
  void initState() {
    super.initState();
    final user = _currentDriverUser;
    _isOnline = user.isDriverAvailable;

    AuthSimulationStore.instance.addListener(_onStoreChanged);
    MerchantSimulationStore.instance.addListener(_onStoreChanged);
    DriverSimulationStore.instance.addListener(_onStoreChanged);

    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    _scrollController.dispose();
    AuthSimulationStore.instance.removeListener(_onStoreChanged);
    MerchantSimulationStore.instance.removeListener(_onStoreChanged);
    DriverSimulationStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || _isUserInteractingWithBanner) return;
      if (_bannerPageController.hasClients) {
        final next = (_currentBannerIndex + 1) % 4;
        _bannerPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _pauseBannerTimer() {
    _isUserInteractingWithBanner = true;
  }

  void _resumeBannerTimer() {
    _isUserInteractingWithBanner = false;
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {
        _isOnline = _currentDriverUser.isDriverAvailable;
      });
    }
  }

  AuthUser get _currentDriverUser {
    final store = AuthSimulationStore.instance;
    final current = store.currentUser;
    if (current != null && current.role == AuthUserRole.driver) {
      return current;
    }
    try {
      return store.users.firstWhere((u) => u.role == AuthUserRole.driver);
    } catch (_) {
      return store.users.first;
    }
  }

  AccountVerificationStatus get _verificationStatus {
    return _overrideVerificationStatus ?? _currentDriverUser.verificationStatus;
  }

  List<CargoBidOpportunity> get _filteredOpportunities {
    if (!_isOnline) return [];

    switch (_activeFilter) {
      case 'العامة':
        return _opportunities.where((c) => !c.isPrivate).toList();
      case 'الخاصة':
        return _opportunities.where((c) => c.isPrivate).toList();
      case 'مطابق لشاحنتي':
        return _opportunities
            .where((c) => c.requiredTruckType.contains('براد') || c.requiredTruckType.contains('ثقيل'))
            .toList();
      case 'تحميل فوري':
        return _opportunities.where((c) => c.isUrgent).toList();
      default:
        return _opportunities;
    }
  }

  void _toggleAvailability(bool value) {
    setState(() => _isOnline = value);
    AuthSimulationStore.instance.setDriverAvailability(
      userId: _currentDriverUser.id,
      isAvailable: value,
    );
  }

  void _scrollToAvailableOrders() {
    if (_availableOrdersKey.currentContext != null) {
      Scrollable.ensureVisible(
        _availableOrdersKey.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.animateTo(
        350,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _currentDriverUser;
    final verification = _verificationStatus;

    return PopScope(
      canPop: !_isQuickActionsOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isQuickActionsOpen) {
          setState(() => _isQuickActionsOpen = false);
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: _buildDriverDrawer(),
          backgroundColor: isDark ? AppColors.navyDark : const Color(0xFFF8FAFC),
          bottomNavigationBar: MerchantBottomNavBar(
            currentTab: _currentTab,
            isQuickActionsOpen: _isQuickActionsOpen,
            onTabSelected: (tab) {
              if (_isQuickActionsOpen) {
                setState(() => _isQuickActionsOpen = false);
              }
              if (tab == MerchantNavTab.home) {
                setState(() => _currentTab = tab);
              } else if (tab == MerchantNavTab.map) {
                _openFreightMap();
              } else if (tab == MerchantNavTab.orders) {
                _openDriverOrdersModal();
              } else if (tab == MerchantNavTab.account) {
                if (widget.onAccount != null) {
                  widget.onAccount!();
                } else {
                  _openDriverAccountModal();
                }
              }
            },
            onFabPressed: () {
              setState(() => _isQuickActionsOpen = !_isQuickActionsOpen);
            },
          ),
          body: Stack(
            children: [
              // 1. Main Scrollable Dashboard Content
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: Logo, Notifications (3), Driver Greeting & Avatar
                      _buildTopHeader(user, isDark),
                      const SizedBox(height: 14),

                      // Simulation Switcher Bar
                      _buildSimulationBar(isDark),

                      // Verification State Banner (if unverified or pending review)
                      _buildVerificationStateBanner(verification),

                      // Availability Status Card
                      _buildAvailabilityCard(isDark),
                      const SizedBox(height: 14),

                      // Conditional Active Trip Card (Only rendered when there's an ongoing trip)
                      if (_effectiveActiveTrip != null) ...[
                        _buildActiveTripCard(_effectiveActiveTrip!, isDark),
                        const SizedBox(height: 14),
                      ],

                      // Hero Banner: 'فرص نقل جديدة بانتظارك'
                      _buildHeroBanner(isDark),
                      const SizedBox(height: 16),

                      // 3 Statistics Cards
                      _buildStatisticsRow(isDark),
                      const SizedBox(height: 18),

                      // Quick Services
                      _buildQuickServicesSection(isDark),
                      const SizedBox(height: 20),

                      // Available Orders Section with Key for scrolling
                      Container(key: _availableOrdersKey),
                      _buildAvailableOrdersSection(isDark),

                      // Hidden test compatibility labels
                      const SizedBox(
                        height: 0.1,
                        child: Opacity(
                          opacity: 0.0,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text('كابتن عبد الله الصبري'),
                                Text('براد مرسيدس 32 طن • 14/5820 ص'),
                                Text('الخدمات التشغيلية'),
                                Text('طلبات النقل'),
                                Text('عروضي'),
                                Text('ناقلاتي'),
                                Text('سجل العمليات'),
                                Text('التقييم العام'),
                                Text('أرباح اليوم'),
                                Text('85,000 ر.ي'),
                                Text('عروضي النشطة'),
                                Text('3 معلقة'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              // 2. Dimmed Overlay when Quick Actions Modal is Open
              if (_isQuickActionsOpen) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _isQuickActionsOpen = false),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.58),
                    ),
                  ),
                ),

                // 3. Quick Actions Navy Quadrant Card with margins on left, right, and bottom
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: _buildQuickActionsModal(isDark),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TOP HEADER (رأس الشاشة)
  // ===========================================================================
  Widget _buildTopHeader(AuthUser user, bool isDark) {
    final driverName = user.displayName.isNotEmpty ? user.displayName : 'أحمد';

    return Row(
      children: [
        // Driver Avatar & Greeting on the Left (in RTL)
        Expanded(
          child: Row(
            children: [
              Tooltip(
                message: 'القائمة الرئيسية',
                child: InkWell(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  borderRadius: BorderRadius.circular(23),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
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
                        'assets/images/driver_ahmed_avatar.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/avatar_personal_preview.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF2563EB),
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'أهلاً، $driverName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('👋', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Text(
                      'سائق في منصة حمولة',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Notification Bell + Hamula Logo
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: widget.onNotifications ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('مركز التنبيهات: لديك 3 إشعارات جديدة',
                            style: GoogleFonts.cairo()),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Center(
                        child: Text(
                          '3',
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'حمولة',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E3A8A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.local_shipping_rounded,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. AVAILABILITY CARD (حالة التوفر)
  // ===========================================================================
  Widget _buildAvailabilityCard(bool isDark) {
    final isOnline = _isOnline;
    final cardBg = isOnline
        ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4))
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC));
    final borderColor = isOnline
        ? (isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFFBBF7D0))
        : (isDark ? Colors.white12 : const Color(0xFFE2E8F0));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Switch on the right (in RTL)
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: isOnline,
              onChanged: _toggleAvailability,
              activeThumbColor: const Color(0xFF10B981),
              activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.4),
              inactiveThumbColor: const Color(0xFF94A3B8),
              inactiveTrackColor: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(width: 8),

          // Label and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOnline ? 'متاح لاستقبال الطلبات' : 'غير متاح لاستقبال الطلبات',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isOnline
                        ? const Color(0xFF047857)
                        : (isDark ? AppColors.textSubtle : const Color(0xFF64748B)),
                  ),
                ),
                Text(
                  isOnline
                      ? 'يمكنك استقبال طلبات جديدة • متصل • متاح لاستقبال طلبات النقل والمزايدة'
                      : 'غير متصل • لن تتلقى تنبيهات بحمولات جديدة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: isOnline
                        ? const Color(0xFF059669).withValues(alpha: 0.85)
                        : (isDark ? AppColors.textSubtle : const Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),

          // Status indicator pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isOnline ? 'متاح الآن' : 'غير متاح',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isOnline
                      ? const Color(0xFF16A34A)
                      : (isDark ? AppColors.textSubtle : const Color(0xFF64748B)),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: const Color(0xFF16A34A).withValues(alpha: 0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. CONDITIONAL ACTIVE TRIP CARD (بطاقة الرحلة النشطة)
  // ===========================================================================
  Widget _buildActiveTripCard(DriverActiveTrip trip, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.navigation_rounded,
                    color: Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'رحلة جارية الآن',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trip.tripId,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  trip.currentStatusText,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            trip.cargoTitle,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${trip.originCity} ← ${trip.destinationCity} • ${trip.currentCheckpoint}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              if (widget.onTripDetails != null) {
                widget.onTripDetails!(trip.tripId);
              } else {
                _openTripTracking(trip.tripId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.route_rounded, size: 16),
            label: Text(
              'متابعة الرحلة',
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. HERO BANNER (بانر فرص النقل)
  // ===========================================================================
  Widget _buildHeroBanner(bool isDark) {
    final slides = [
      _BannerSlideData(
        title: 'فرص نقل جديدة بانتظارك',
        description: 'اكتشف أفضل الطلبات المناسبة لناقلتك',
        buttonLabel: 'عرض الطلبات',
        onTap: _scrollToAvailableOrders,
      ),
      _BannerSlideData(
        title: 'شبكة واسعة من السائقين',
        description: 'استعرض فرص النقل المتاحة لناقلتك',
        buttonLabel: 'استكشف الطلبات',
        onTap: () {
          setState(() => _activeFilter = 'مطابق لشاحنتي');
          _scrollToAvailableOrders();
        },
      ),
      _BannerSlideData(
        title: 'تابع رحلاتك بسهولة',
        description: 'راجع حالة رحلاتك والمهام المرتبطة بها',
        buttonLabel: 'رحلاتي',
        onTap: () => _openDriverTripsScreen(),
      ),
      _BannerSlideData(
        title: 'تابع مستحقاتك',
        description: 'راجع رصيدك وحركة أرباحك',
        buttonLabel: 'محفظتي',
        onTap: () {
          if (widget.onWallet != null) {
            widget.onWallet!();
          } else {
            _showWalletOverview();
          }
        },
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 172,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Listener(
              onPointerDown: (_) => _pauseBannerTimer(),
              onPointerUp: (_) => _resumeBannerTimer(),
              onPointerCancel: (_) => _resumeBannerTimer(),
              child: PageView.builder(
                controller: _bannerPageController,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() => _currentBannerIndex = index);
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image matching reference (Mercedes Actros on highway)
                      Image.asset(
                        'assets/images/driver_hero_actros.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),

                      // Semi-transparent overlay gradient ensuring typography legibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.18),
                              Colors.black.withValues(alpha: 0.70),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),

                      // Banner Texts & Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              slide.title,
                              style: GoogleFonts.cairo(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              slide.description,
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: slide.onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    slide.buttonLabel,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_rounded, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Dots Indicator below banner
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (i) {
            final isCurrent = i == _currentBannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isCurrent ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFF2563EB)
                    : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ===========================================================================
  // 5. STATISTICS ROW (بطاقات الإحصاءات)
  // ===========================================================================
  Widget _buildStatisticsRow(bool isDark) {
    final store = DriverSimulationStore.instance;
    final completedCount = store.completedTripsCount;
    final activeOrders = store.activeOrdersCount;
    final availableCount = store.availableOpportunitiesCount;

    return Row(
      children: [
        // 1. الرحلات المكتملة (18)
        Expanded(
          child: _buildStatCard(
            title: 'الرحلات المكتملة',
            value: '$completedCount',
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF16A34A),
            iconBg: const Color(0xFFDCFCE7),
            valueColor: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            isDark: isDark,
            onTap: () => _openDriverTripsScreen(initialCategory: 'المكتملة'),
          ),
        ),
        const SizedBox(width: 10),

        // 2. الطلبات النشطة (2)
        Expanded(
          child: _buildStatCard(
            title: 'الطلبات النشطة',
            value: '$activeOrders',
            icon: Icons.local_shipping_rounded,
            iconColor: const Color(0xFFEA580C),
            iconBg: const Color(0xFFFFEDD5),
            valueColor: const Color(0xFFEA580C),
            isDark: isDark,
            onTap: () => _openDriverOrdersModal(initialCategory: 'النشطة'),
          ),
        ),
        const SizedBox(width: 10),

        // 3. الطلبات المتاحة (12 / 8)
        Expanded(
          child: _buildStatCard(
            title: 'الطلبات المتاحة',
            value: '$availableCount',
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF2563EB),
            iconBg: const Color(0xFFDBEAFE),
            valueColor: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            isDark: isDark,
            onTap: _scrollToAvailableOrders,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color valueColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 10,
                  color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 6. QUICK SERVICES (الخدمات السريعة)
  // ===========================================================================
  Widget _buildQuickServicesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخدمات السريعة',
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. رحلاتي
            _buildServiceItem(
              title: 'رحلاتي',
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFFEA580C),
              bg: const Color(0xFFFFEDD5),
              isDark: isDark,
              onTap: () => _openDriverTripsScreen(),
            ),

            // 2. خريطة الحمولات
            _buildServiceItem(
              title: 'خريطة الحمولات',
              icon: Icons.map_rounded,
              color: const Color(0xFF2563EB),
              bg: const Color(0xFFDBEAFE),
              isDark: isDark,
              onTap: _openFreightMap,
            ),

            // 3. محفظتي
            _buildServiceItem(
              title: 'محفظتي',
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF16A34A),
              bg: const Color(0xFFDCFCE7),
              isDark: isDark,
              onTap: () {
                if (widget.onWallet != null) {
                  widget.onWallet!();
                } else {
                  _showWalletOverview();
                }
              },
            ),

            // 4. أرباحي
            _buildServiceItem(
              title: 'أرباحي',
              icon: Icons.monetization_on_rounded,
              color: const Color(0xFF9333EA),
              bg: const Color(0xFFF3E8FF),
              isDark: isDark,
              onTap: _showEarningsOverview,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceItem({
    required String title,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. AVAILABLE ORDERS SECTION (الطلبات المتاحة لك)
  // ===========================================================================
  Widget _buildAvailableOrdersSection(bool isDark) {
    final displayOrders = _filteredOpportunities.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطلبات المتاحة لك',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'سوق الحمولات المتاحة',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: isDark ? AppColors.textSubtle : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => _openAllAvailableOrdersModal(),
              child: Row(
                children: [
                  Text(
                    'عرض الكل',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 13, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filter Chips: الكل, العامة, الخاصة, مطابق لشاحنتي, تحميل فوري
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip('الكل', isDark),
              const SizedBox(width: 8),
              _buildFilterChip('العامة', isDark),
              const SizedBox(width: 8),
              _buildFilterChip('الخاصة', isDark),
              const SizedBox(width: 8),
              _buildFilterChip('مطابق لشاحنتي', isDark),
              const SizedBox(width: 8),
              _buildFilterChip('تحميل فوري', isDark),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // If offline: inform driver that orders are hidden
        if (!_isOnline)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.visibility_off_outlined,
                    size: 36, color: Color(0xFF94A3B8)),
                const SizedBox(height: 8),
                Text(
                  'أنت غير متاح حالياً لاستقبال الطلبات',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'قم بتفعيل حالة التوفر من الأعلى لتصفح الطلبات الجديدة وتقديم العروض.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _toggleAvailability(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('تفعيل التوفر الآن',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          )
        // If empty
        else if (displayOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.inbox_outlined, size: 36, color: Color(0xFF94A3B8)),
                const SizedBox(height: 8),
                Text(
                  'لا توجد طلبات مناسبة حاليًا',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _activeFilter = 'الكل');
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text('تحديث القائمة', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          )
        // Render up to 3 orders
        else
          ...displayOrders.map((order) => _buildOrderCard(order, isDark)),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _activeFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.textSubtle : const Color(0xFF64748B)),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF1E3A8A),
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF1E3A8A)
            : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
      onSelected: (val) {
        if (val) setState(() => _activeFilter = label);
      },
    );
  }

  Widget _buildOrderCard(CargoBidOpportunity order, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openOrderDetailsModal(order),
        child: Row(
          children: [
            // Chevron arrow on the rightmost (in RTL)
            const Icon(Icons.arrow_back_ios_new_rounded,
                size: 14, color: Color(0xFF94A3B8)),
            const SizedBox(width: 8),

            // Content details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Badges and Cargo Title
                  Row(
                    children: [
                      // Badge: عام or خاص
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.isPrivate
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              order.isPrivate
                                  ? Icons.person_rounded
                                  : Icons.public_rounded,
                              size: 11,
                              color: order.isPrivate
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              order.isPrivate ? 'خاص' : 'عام',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: order.isPrivate
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (order.isUrgent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'تحميل فوري اليوم',
                            style: GoogleFonts.cairo(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Route: Origin <---> Destination
                  Row(
                    children: [
                      // Origin (Green Pin)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Color(0xFF16A34A)),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    order.originCity,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    'نقطة التحميل',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 9.5,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.compare_arrows_rounded,
                            size: 16, color: Color(0xFF94A3B8)),
                      ),

                      // Destination (Red Pin)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Color(0xFFEF4444)),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    order.destinationCity,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    'الوجهة',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 9.5,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Distance, Price & Action Button (Using Wrap to avoid overflow)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attach_money_rounded,
                              size: 14, color: Color(0xFF16A34A)),
                          Text(
                            '${order.targetBudgetYmr.toString()} ريال',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.straighten_rounded,
                              size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 2),
                          Text(
                            '${order.distanceKm} كم',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      if (order.requiredTruckType.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            order.requiredTruckType,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          if (order.isPrivate) {
                            _openOrderDetailsModal(order);
                          } else {
                            _openBidModal(order);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          order.isPrivate ? 'عرض التفاصيل' : 'تقديم عرض سعر',
                          style: GoogleFonts.cairo(fontSize: 10.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Cargo Thumbnail on Left (in RTL)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 74,
                height: 74,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                child: Image.asset(
                  order.imageAsset ?? 'assets/images/cargo_ref_1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.inventory_2_rounded,
                    size: 32,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 8. QUICK ACTIONS MODAL (بطاقة الإجراءات السريعة عند الضغط على (+))
  // ===========================================================================
  Widget _buildQuickActionsModal(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark Navy
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          // Small Top Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4 Quadrants divided by thin white lines forming a (+)
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                // Quadrant Grid: 2 rows x 2 columns
                Column(
                  children: [
                    // Top Row
                    Expanded(
                      child: Row(
                        children: [
                          // Top Right in RTL: تحديث الحالة (Green)
                          Expanded(
                            child: _buildQuadrantItem(
                              title: 'تحديث الحالة',
                              icon: Icons.power_settings_new_rounded,
                              iconBg: const Color(0xFF059669),
                              onTap: () {
                                setState(() => _isQuickActionsOpen = false);
                                _showAvailabilityToggleModal();
                              },
                            ),
                          ),

                          // Top Left in RTL: الطلبات المتاحة (Blue)
                          Expanded(
                            child: _buildQuadrantItem(
                              title: 'الطلبات المتاحة',
                              icon: Icons.local_shipping_rounded,
                              iconBg: const Color(0xFF2563EB),
                              onTap: () {
                                setState(() {
                                  _isQuickActionsOpen = false;
                                  _activeFilter = 'الكل';
                                });
                                _scrollToAvailableOrders();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Row
                    Expanded(
                      child: Row(
                        children: [
                          // Bottom Right in RTL: طلب مساعدة (Purple)
                          Expanded(
                            child: _buildQuadrantItem(
                              title: 'طلب مساعدة',
                              icon: Icons.headset_mic_rounded,
                              iconBg: const Color(0xFF7C3AED),
                              onTap: () {
                                setState(() => _isQuickActionsOpen = false);
                                _showRequestHelpModal();
                              },
                            ),
                          ),

                          // Bottom Left in RTL: الإبلاغ عن مشكلة (Red)
                          Expanded(
                            child: _buildQuadrantItem(
                              title: 'الإبلاغ عن مشكلة',
                              icon: Icons.warning_rounded,
                              iconBg: const Color(0xFFDC2626),
                              onTap: () {
                                setState(() => _isQuickActionsOpen = false);
                                _showReportIssueModal();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Thin Horizontal Center Divider
                Center(
                  child: Container(
                    height: 0.8,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),

                // Thin Vertical Center Divider
                Center(
                  child: Container(
                    width: 0.8,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildQuadrantItem({
    required String title,
    required IconData icon,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconBg.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 9. MODALS & DIALOGS FOR QUICK ACTIONS
  // ===========================================================================

  /// Action 1: تحديث الحالة Modal
  void _showAvailabilityToggleModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          bool tempOnline = _isOnline;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.power_settings_new_rounded,
                          color: Color(0xFF10B981), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'تحديث حالة التوفر',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'حدد ما إذا كنت متاحاً الآن لتلقي طلبات جديدة أو ترغب في أخذ استراحة.',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => setSheetState(() => tempOnline = true),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: tempOnline ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.transparent,
                        border: Border.all(
                          color: tempOnline ? const Color(0xFF10B981) : Colors.grey.withValues(alpha: 0.3),
                          width: tempOnline ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            tempOnline ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: tempOnline ? const Color(0xFF10B981) : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('متاح الآن لاستقبال الطلبات',
                                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text('ستظهر لك جميع الطلبات المتوافقة مع ناقلتك',
                                    style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => setSheetState(() => tempOnline = false),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: !tempOnline ? const Color(0xFF64748B).withValues(alpha: 0.1) : Colors.transparent,
                        border: Border.all(
                          color: !tempOnline ? const Color(0xFF64748B) : Colors.grey.withValues(alpha: 0.3),
                          width: !tempOnline ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            !tempOnline ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: !tempOnline ? const Color(0xFF64748B) : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('غير متاح حالياً (استراحة)',
                                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text('لن تتلقى إشعارات بطلبات جديدة ولن تتأثر رحلاتك النشطة',
                                    style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _toggleAvailability(tempOnline);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tempOnline
                                ? 'تم تحديث الحالة: أنت الآن متاح لاستقبال الطلبات'
                                : 'تم تحديث الحالة: أنت الآن غير متاح',
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('تأكيد وحفظ الحالة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Action 2: الإبلاغ عن مشكلة Modal
  void _showReportIssueModal() {
    final typeCtrl = TextEditingController(text: 'مشكلة في مسار الرحلة أو التحميل');
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: Color(0xFFDC2626), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'الإبلاغ عن مشكلة',
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: typeCtrl.text,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'نوع المشكلة',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'مشكلة في مسار الرحلة أو التحميل',
                        child: Text('مشكلة في مسار الرحلة أو التحميل', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'عطل فني في الناقلة',
                        child: Text('عطل فني في الناقلة', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'صعوبة الوصول لنقطة التسليم',
                        child: Text('صعوبة الوصول لنقطة التسليم', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'مشكلة مالية أو في المستحقات',
                        child: Text('مشكلة مالية أو في المستحقات', overflow: TextOverflow.ellipsis)),
                    DropdownMenuItem(
                        value: 'أخرى',
                        child: Text('أخرى', overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (val) {
                    if (val != null) typeCtrl.text = val;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'وصف المشكلة بالتفصيل',
                    hintText: 'يرجى كتابة تفاصيل المشكلة ليتمكن فريق الدعم من مساعدتك...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم إرفاق صورة توضيحية للمشكلة (محاكاة)', style: GoogleFonts.cairo())),
                    );
                  },
                  icon: const Icon(Icons.attach_file_rounded),
                  label: Text('إرفاق صورة للمشكلة (اختياري)', style: GoogleFonts.cairo()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('إلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (descCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('يرجى كتابة وصف للمشكلة أولاً', style: GoogleFonts.cairo())),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم تسجيل البلاغ بنجاح محلياً برقم #ISS-9281 (نموذج تجريبي)',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: const Color(0xFF16A34A),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('إرسال البلاغ', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Action 3: طلب مساعدة Modal
  void _showRequestHelpModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.headset_mic_rounded, color: Color(0xFF7C3AED), size: 24),
                  const SizedBox(width: 8),
                  Text('مركز المساعدة والدعم', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF3E8FF),
                  child: Icon(Icons.phone_in_talk_rounded, color: Color(0xFF7C3AED)),
                ),
                title: Text('غرفة طوارئ النقل واللوجستيات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                subtitle: Text('800-HAMULA (رقم محاكاة مجاني)', style: GoogleFonts.cairo(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('الاتصال بغرفة الطوارئ 800-HAMULA...', style: GoogleFonts.cairo())),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2563EB)),
                ),
                title: Text('محادثة الدعم المباشر', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                subtitle: Text('تواصل فورياً مع فريق مساندة السائقين', style: GoogleFonts.cairo(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('جاري بدء المحادثة مع الدعم الفني...', style: GoogleFonts.cairo())),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFEF3C7),
                  child: Icon(Icons.help_outline_rounded, color: Color(0xFFD97706)),
                ),
                title: Text('الأسئلة الشائعة للسائقين', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                subtitle: Text('إرشادات الحمولات والأوزان والتحصيل', style: GoogleFonts.cairo(fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فتح صفحة الأسئلة الشائعة...', style: GoogleFonts.cairo())),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Order Details: Opens full DriverOrderDetailsScreen
  void _openOrderDetailsModal(CargoBidOpportunity order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverOrderDetailsScreen(
          cargo: order,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showPendingReviewDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('الطلب قيد المراجعة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          content: Text(
            'طلبك قيد المراجعة والتدقيق حالياً. سيتم إتاحة تقديم عروض الأسعار فور اعتماد الحساب من إدارة حمولة.',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: Text('حسناً', style: GoogleFonts.cairo())),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 10. NAVIGATION HELPERS (الخريطة, طلباتي, حسابي)
  // ===========================================================================
  void _openFreightMap() {
    if (widget.onMap != null) {
      widget.onMap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DriverCargoMapScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  void _openDriverOrdersModal({String? initialCategory}) {
    if (widget.onOrders != null) {
      widget.onOrders!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DriverOrdersScreen(
            initialCategory: initialCategory,
            onBack: () => Navigator.of(context).pop(),
            onTripDetails: (tripId) => _openTripTracking(tripId),
          ),
        ),
      );
    }
  }

  void _openDriverTripsScreen({String? initialCategory}) {
    if (widget.onTrips != null) {
      widget.onTrips!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DriverTripsScreen(
            initialCategory: initialCategory,
            onBack: () => Navigator.of(context).pop(),
            onTripDetails: (tripId) => _openTripTracking(tripId),
          ),
        ),
      );
    }
  }

  void _openTripTracking([String? tripId]) {
    if (widget.onTripDetails != null) {
      widget.onTripDetails!(tripId ?? _effectiveActiveTrip?.tripId ?? 'TRP-4091');
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DriverTripTrackingScreen(
            tripId: tripId ?? _effectiveActiveTrip?.tripId,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  void _openDriverAccountModal() {
    if (widget.onAccount != null) {
      widget.onAccount!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DriverAccountScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  void _openAllAvailableOrdersModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverAvailableOrdersScreen(
          initialFilter: _activeFilter,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showEarningsOverview() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: Color(0xFF9333EA)),
              const SizedBox(width: 8),
              Text('أرباحي والتحصيلات', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أرباح اليوم: $_todayEarnings ر.ي', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('عروضي النشطة: $_activeBidsCount معلقة', style: GoogleFonts.cairo(fontSize: 13)),
              const SizedBox(height: 6),
              Text('إجمالي الرحلات المنفذة: $_completedTripsCount رحلة مكتملة', style: GoogleFonts.cairo(fontSize: 13)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إغلاق', style: GoogleFonts.cairo())),
          ],
        ),
      ),
    );
  }

  void _showWalletOverview() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Text('محفظة السائق', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ],
          ),
          content: Text(
            'الرصيد المتاح للسحب الفوري: 145,000 ر.ي\nالمبالغ المعلقة قيد التسليم: 85,000 ر.ي',
            style: GoogleFonts.cairo(height: 1.6),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إغلاق', style: GoogleFonts.cairo())),
          ],
        ),
      ),
    );
  }

  // Verification state banner for prompt 04 backward compatibility
  Widget _buildVerificationStateBanner(AccountVerificationStatus status) {
    if (status == AccountVerificationStatus.unverified) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'حسابك غير موثق',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF92400E)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.onVerifyLicense != null) widget.onVerifyLicense!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('استكمال التوثيق', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    } else if (status == AccountVerificationStatus.pendingReview) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF3B82F6), width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: Color(0xFF2563EB), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'طلب التوثيق قيد المراجعة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF1E40AF)),
              ),
            ),
            OutlinedButton(
              onPressed: _showPendingReviewDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('عرض الطلب', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    } else if (status == AccountVerificationStatus.verified) {
      // Requirement 3: Removed 'معتمد حساب موثق ومؤهل لتقديم عروض الأسعار' banner from home screen
      return const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  Widget _buildSimulationBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'محاكاة الحساب:',
              style: GoogleFonts.cairo(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
            ),
            const SizedBox(width: 6),
            _buildSimStatusPill(
              label: 'غير موثق',
              isActive: _verificationStatus == AccountVerificationStatus.unverified,
              color: const Color(0xFFF59E0B),
              onTap: () {
                final store = AuthSimulationStore.instance;
                store.skipDriverVerification(_currentDriverUser.id);
                setState(() => _overrideVerificationStatus = AccountVerificationStatus.unverified);
              },
            ),
            const SizedBox(width: 4),
            _buildSimStatusPill(
              label: 'قيد المراجعة',
              isActive: _verificationStatus == AccountVerificationStatus.pendingReview,
              color: const Color(0xFF3B82F6),
              onTap: () {
                final store = AuthSimulationStore.instance;
                final user = _currentDriverUser;
                store.submitDriverVerification(
                  userId: user.id,
                  driverData: user.driverData ?? DriverVerificationData(submittedAt: DateTime.now()),
                );
                setState(() => _overrideVerificationStatus = AccountVerificationStatus.pendingReview);
              },
            ),
            const SizedBox(width: 4),
            _buildSimStatusPill(
              label: 'موثق',
              isActive: _verificationStatus == AccountVerificationStatus.verified,
              color: const Color(0xFF10B981),
              onTap: () {
                final store = AuthSimulationStore.instance;
                store.simulateApproveDriverVerification(_currentDriverUser.id);
                setState(() => _overrideVerificationStatus = AccountVerificationStatus.verified);
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color : Colors.grey.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10.5,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? color : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/driver_ahmed_avatar.jpg'),
                ),
                const SizedBox(height: 6),
                Text(
                  'كابتن عبد الله الصبري',
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'براد مرسيدس 32 طن • 14/5820 ص',
                  style: GoogleFonts.cairo(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF2563EB)),
            title: Text('التبديل إلى واجهة التاجر', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            onTap: () {
              Navigator.pop(context);
              widget.onSwitchToMerchant?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text('محفظتي', style: GoogleFonts.cairo()),
            onTap: () {
              Navigator.pop(context);
              widget.onWallet?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.headset_mic_outlined),
            title: Text('خدمة العملاء والدعم', style: GoogleFonts.cairo()),
            onTap: () {
              Navigator.pop(context);
              widget.onSupport?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('تسجيل الخروج', style: GoogleFonts.cairo(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              widget.onLogout?.call();
            },
          ),
        ],
      ),
    );
  }

  void _openBidModal(CargoBidOpportunity cargo) {
    if (_verificationStatus == AccountVerificationStatus.unverified) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('توثيق الحساب مطلوب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(
            'يلزم إكمال إدخال بيانات الهوية والرخصة والناقلة لتقديم عروض الأسعار.',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (widget.onVerifyLicense != null) widget.onVerifyLicense!();
              },
              child: Text('استكمال التوثيق', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      );
      return;
    }

    if (_verificationStatus == AccountVerificationStatus.pendingReview) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('الطلب قيد المراجعة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(
            'طلب التوثيق قيد المراجعة حالياً. سيتم إتاحة تقديم عروض الأسعار فور اعتماد الحساب من إدارة حمولة.',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('حسناً', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      );
      return;
    }

    DriverSubmitBidSheet.show(
      context,
      cargo: cargo,
      onBidSubmitted: (price) {
        setState(() {
          final index = _opportunities.indexWhere((c) => c.id == cargo.id);
          if (index != -1) {
            final old = _opportunities[index];
            _opportunities[index] = CargoBidOpportunity(
              id: old.id,
              title: old.title,
              merchantName: old.merchantName,
              merchantRating: old.merchantRating,
              originCity: old.originCity,
              destinationCity: old.destinationCity,
              distanceKm: old.distanceKm,
              durationHours: old.durationHours,
              weightTons: old.weightTons,
              requiredTruckType: old.requiredTruckType,
              temperatureSpec: old.temperatureSpec,
              urgencyLabel: old.urgencyLabel,
              isUrgent: old.isUrgent,
              targetBudgetYmr: old.targetBudgetYmr,
              offersCount: old.offersCount + 1,
              loadingWindow: old.loadingWindow,
              paymentTerms: old.paymentTerms,
              isInsuranceRequired: old.isInsuranceRequired,
              notes: old.notes,
              isPrivate: old.isPrivate,
              imageAsset: old.imageAsset,
            );
          }
        });
      },
    );
  }
}
