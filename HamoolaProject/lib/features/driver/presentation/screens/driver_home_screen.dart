import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/driver_bid_modal_sheet.dart';
import '../../domain/models/cargo_bid_opportunity.dart';

/// Main Dashboard and Cargo Marketplace for Truck Drivers & Transporters.
class DriverHomeScreen extends StatefulWidget {
  final VoidCallback? onNotifications;
  final VoidCallback? onSwitchToMerchant;
  final VoidCallback? onWallet;
  final VoidCallback? onSupport;
  final VoidCallback? onLogout;
  final ValueChanged<String>? onTripDetails;
  final VoidCallback? onVerifyLicense;

  const DriverHomeScreen({
    super.key,
    this.onNotifications,
    this.onSwitchToMerchant,
    this.onWallet,
    this.onSupport,
    this.onLogout,
    this.onTripDetails,
    this.onVerifyLicense,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isOnline = true;
  String _activeFilter = 'الكل';
  int _currentBottomNavIndex = 0;
  List<CargoBidOpportunity> _opportunities = List.of(CargoBidOpportunity.demoOpportunities);

  // Active driver metrics
  final int _todayEarnings = 85000;
  final int _activeBidsCount = 3;
  final double _driverRating = 4.95;
  final int _completedTripsCount = 142;

  final DriverActiveTrip _activeTrip = DriverActiveTrip.demoActiveTrip;

  List<CargoBidOpportunity> get _filteredOpportunities {
    switch (_activeFilter) {
      case 'مطابق لشاحنتي':
        return _opportunities
            .where((c) => c.requiredTruckType.contains('براد'))
            .toList();
      case 'تحميل فوري':
        return _opportunities.where((c) => c.isUrgent).toList();
      case 'الأعلى ميزانية':
        final list = List<CargoBidOpportunity>.from(_opportunities);
        list.sort((a, b) => b.targetBudgetYmr.compareTo(a.targetBudgetYmr));
        return list;
      case 'مسافات قصيرة':
        return _opportunities.where((c) => c.distanceKm <= 200).toList();
      default:
        return _opportunities;
    }
  }

  void _openBidModal(CargoBidOpportunity cargo) {
    DriverBidModalSheet.show(
      context,
      cargo: cargo,
      onBidSubmitted: (price) {
        setState(() {
          // Increment bid count locally
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
            );
          }
        });
      },
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundLight,
      drawer: _buildDriverDrawer(),
      appBar: _buildDriverAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 600));
          setState(() {
            _opportunities = List.of(CargoBidOpportunity.demoOpportunities);
          });
        },
        color: AppColors.goldDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Online / Offline Status Bar
              _buildAvailabilityStatusBar(),

              // Quick Metric Summary Cards
              _buildDriverMetrics(),

              // Ongoing Active Trip (if any)
              _buildActiveTripCard(),

              // Marketplace Section Header & Filter Chips
              _buildMarketplaceHeader(),

              // Cargo Cards Feed
              _buildCargoFeed(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildDriverAppBar() {
    return AppBar(
      backgroundColor: AppColors.navyDark,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        tooltip: 'القائمة الرئيسية',
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.goldLight,
            child: const Icon(Icons.person, color: AppColors.navyDark, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'كابتن عبد الله الصبري',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'براد مرسيدس 32 طن • 14/5820 ص',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded, color: Colors.white),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: widget.onNotifications,
          tooltip: 'التنبيهات',
        ),
      ],
    );
  }

  Widget _buildAvailabilityStatusBar() {
    return Container(
      color: AppColors.navyDark,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _isOnline
              ? AppColors.successBg.withValues(alpha: 0.15)
              : AppColors.navyMedium,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isOnline
                ? AppColors.success.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _isOnline ? AppColors.success : AppColors.textSubtle,
                shape: BoxShape.circle,
                boxShadow: _isOnline
                    ? [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isOnline
                    ? 'متصل • متاح لاستقبال طلبات النقل والمزايدة'
                    : 'غير متصل • لن تتلقى تنبيهات بحمولات جديدة',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isOnline ? AppColors.successBg : AppColors.textSubtle,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _isOnline,
                activeThumbColor: AppColors.success,
                activeTrackColor: AppColors.success.withValues(alpha: 0.4),
                inactiveThumbColor: AppColors.textSubtle,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                onChanged: (val) => setState(() => _isOnline = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverMetrics() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: 'أرباح اليوم',
              value: '${_formatCurrency(_todayEarnings)} ر.ي',
              icon: Icons.payments_rounded,
              color: AppColors.goldDark,
              bgColor: AppColors.goldLight,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMetricCard(
              title: 'عروضي النشطة',
              value: '$_activeBidsCount معلقة',
              icon: Icons.gavel_rounded,
              color: AppColors.infoText,
              bgColor: AppColors.infoBg,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildMetricCard(
              title: 'التقييم العام',
              value: '$_driverRating ★',
              subtitle: '($_completedTripsCount رحلة)',
              icon: Icons.star_rounded,
              color: AppColors.successDark,
              bgColor: AppColors.successBg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMutedLight,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSubtle,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveTripCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyDark.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'رحلة جارية الآن',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _activeTrip.tripId,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    '${_formatCurrency(_activeTrip.payoutYmr)} ر.ي',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _activeTrip.cargoTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primaryGold, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${_activeTrip.originCity} ➔ ${_activeTrip.destinationCity} (${_activeTrip.currentCheckpoint})',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _activeTrip.progressRatio,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'وصول تقديري: ${_activeTrip.estimatedArrival}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    if (widget.onTripDetails != null) {
                      widget.onTripDetails!(_activeTrip.tripId);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'تحديث الحالة',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceHeader() {
    final filterOptions = ['الكل', 'مطابق لشاحنتي', 'تحميل فوري', 'الأعلى ميزانية', 'مسافات قصيرة'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_rounded, color: AppColors.navyDark, size: 20),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'سوق الحمولات المتاحة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_filteredOpportunities.length} طلبات',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.map((opt) {
                final isSelected = _activeFilter == opt;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.navyDark : AppColors.textMutedLight,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.goldLight,
                    backgroundColor: AppColors.surfaceLight,
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryGold : AppColors.borderLight,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _activeFilter = opt);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCargoFeed() {
    final list = _filteredOpportunities;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSubtle),
            const SizedBox(height: 12),
            const Text(
              'لا توجد حمولات مطابقة للتصفية الحالية',
              style: TextStyle(color: AppColors.textMutedLight, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _activeFilter = 'الكل'),
              child: const Text('عرض جميع الحمولات'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cargo = list[index];
        return _buildCargoCard(cargo);
      },
    );
  }

  Widget _buildCargoCard(CargoBidOpportunity cargo) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cargo.isUrgent ? AppColors.goldBorder : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Urgency tag + Cargo ID + Merchant
          Row(
            children: [
              if (cargo.isUrgent) ...[
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flash_on_rounded, color: AppColors.error, size: 12),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            cargo.urgencyLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.errorText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                cargo.id,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyDark,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.goldDark, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    '${cargo.merchantRating}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title & Merchant name
          Text(
            cargo.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.navyDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            cargo.merchantName,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMutedLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Route Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.alt_route_rounded, color: AppColors.primaryGold, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${cargo.originCity} ➔ ${cargo.destinationCity}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${cargo.distanceKm} كم • ${cargo.durationHours} س',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMutedLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Specifications Tags (Weight, Truck Type, Refrigeration)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildSpecTag(
                icon: Icons.scale_rounded,
                label: '${cargo.weightTons} طن',
              ),
              _buildSpecTag(
                icon: Icons.local_shipping_outlined,
                label: cargo.requiredTruckType,
              ),
              if (cargo.temperatureSpec != null)
                _buildSpecTag(
                  icon: Icons.ac_unit_rounded,
                  label: cargo.temperatureSpec!,
                  color: AppColors.info,
                  bgColor: AppColors.infoBg,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Budget & Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ميزانية التاجر',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                    Text(
                      '${_formatCurrency(cargo.targetBudgetYmr)} ر.ي',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${cargo.offersCount} عروض منافسة',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSubtle,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _openBidModal(cargo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.gavel_rounded, size: 14, color: AppColors.primaryGold),
                label: const Text(
                  'تقديم عرض سعر',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTag({
    required IconData icon,
    required String label,
    Color color = AppColors.navyDark,
    Color bgColor = AppColors.backgroundLight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverDrawer() {
    return Drawer(
      backgroundColor: AppColors.surfaceLight,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navyDark, AppColors.navyMedium],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.goldLight,
                  child: const Icon(Icons.person, color: AppColors.navyDark, size: 30),
                ),
                const SizedBox(height: 8),
                const Text(
                  'كابتن عبد الله الصبري',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'كابتن موثق',
                        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'رقم الشاحنة: 14/5820 ص',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_rounded, color: AppColors.navyDark),
            title: const Text('سوق الحمولات والطلبات'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.navyDark),
            title: const Text('محفظتي وأرباح النقل'),
            onTap: () {
              Navigator.pop(context);
              if (widget.onWallet != null) widget.onWallet!();
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_rounded, color: AppColors.navyDark),
            title: const Text('مركز الإشعارات'),
            onTap: () {
              Navigator.pop(context);
              if (widget.onNotifications != null) widget.onNotifications!();
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_rounded, color: AppColors.goldDark),
            title: const Text('توثيق بيانات السائق والمركبة'),
            subtitle: const Text('تحديث بيانات الرخصة والشاحنة'),
            onTap: () {
              Navigator.pop(context);
              if (widget.onVerifyLicense != null) widget.onVerifyLicense!();
            },
          ),
          const Divider(),
          // Switch to Merchant Mode
          ListTile(
            leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.goldDark),
            title: const Text(
              'التبديل إلى واجهة التاجر',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldDark),
            ),
            subtitle: const Text('إدارة شحناتك الخاصة كتاجر ومورد'),
            onTap: () {
              Navigator.pop(context);
              if (widget.onSwitchToMerchant != null) widget.onSwitchToMerchant!();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.headset_mic_rounded, color: AppColors.navyDark),
            title: const Text('خدمة العملاء والدعم اللوجستي'),
            onTap: () {
              Navigator.pop(context);
              if (widget.onSupport != null) widget.onSupport!();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              if (widget.onLogout != null) widget.onLogout!();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.goldDark,
      unselectedItemColor: AppColors.textMutedLight,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      onTap: (index) {
        setState(() => _currentBottomNavIndex = index);
        if (index == 1) {
          // Bids
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الانتقال لقائمة العروض التي قدمتها للشاحنات'),
              duration: Duration(seconds: 1),
            ),
          );
        } else if (index == 2) {
          // Trip tracking
          if (widget.onTripDetails != null) {
            widget.onTripDetails!(_activeTrip.tripId);
          }
        } else if (index == 3) {
          // Wallet
          if (widget.onWallet != null) widget.onWallet!();
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_rounded),
          label: 'سوق الحمولات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gavel_rounded),
          label: 'عروضي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.navigation_rounded),
          label: 'رحلتي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_rounded),
          label: 'محفظتي',
        ),
      ],
    );
  }
}
