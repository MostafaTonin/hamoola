import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../domain/models/transport_office_trips_store.dart';
import 'transport_office_trip_details_screen.dart';

/// Main Trips Screen for Transport Office: «رحلاتي»
class TransportOfficeTripsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final OfficeTripRole? initialRole;
  final OfficeTripFilter? initialFilter;

  const TransportOfficeTripsScreen({
    super.key,
    this.onBack,
    this.initialRole,
    this.initialFilter,
  });

  @override
  State<TransportOfficeTripsScreen> createState() => _TransportOfficeTripsScreenState();
}

class _TransportOfficeTripsScreenState extends State<TransportOfficeTripsScreen>
    with SingleTickerProviderStateMixin {
  final TransportOfficeTripsStore _store = TransportOfficeTripsStore.instance;

  late OfficeTripRole _selectedRole;
  late OfficeTripFilter _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Floating (+) FAB quick actions animation
  late AnimationController _fabAnimController;
  bool _isFabSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? OfficeTripRole.provider;
    _selectedFilter = widget.initialFilter ?? OfficeTripFilter.all;

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _searchController.addListener(() {
      setState(() {});
    });

    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  List<OfficeTrip> get _filteredTrips {
    return _store.getFilteredTrips(
      role: _selectedRole,
      filter: _selectedFilter,
      query: _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 1. Independent Sub-screen Header (Home header elements hidden)
                      _buildScreenHeader(),

                      // 2. Scrollable Body
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 110.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12.0),

                              // Two Main Role Tabs: «كمقدم خدمة» vs «كطالب خدمة»
                              _buildRoleTabs(),

                              const SizedBox(height: 12.0),

                              // Instant Search Field
                              _buildSearchField(),

                              const SizedBox(height: 12.0),

                              // Status Filter Chips (5 filters for «كمقدم خدمة»)
                              if (_selectedRole == OfficeTripRole.provider) ...[
                                _buildStatusFilters(),
                                const SizedBox(height: 14.0),
                              ] else ...[
                                const SizedBox(height: 6.0),
                              ],

                              // Trips List & Cards
                              _buildTripsList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Quick Actions Backdrop when (+) is open
                  if (_isFabSheetOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => _closeQuickActions(),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ),

                  // Floating 2x2 Quick Actions Card
                  if (_isFabSheetOpen)
                    Positioned(
                      left: 16.0,
                      right: 16.0,
                      bottom: 84.0,
                      child: _buildFloatingQuickActionsCard(),
                    ),

                  // Unified 5-Item Bottom Navigation Bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildUnifiedBottomNavBar(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Independent Screen Header
  // ===========================================================================
  Widget _buildScreenHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          InkWell(
            onTap: widget.onBack ?? () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.transportOfficeHome);
              }
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18.0,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          // Title & Icon Badge in Center
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'رحلاتي',
                      style: GoogleFonts.cairo(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        size: 16.0,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Symmetrical spacer
          const SizedBox(width: 40.0),
        ],
      ),
    );
  }

  // ===========================================================================
  // Two Main Role Tabs: «كمقدم خدمة» vs «كطالب خدمة»
  // ===========================================================================
  Widget _buildRoleTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 46.0,
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Row(
          children: [
            // Tab 1: كمقدم خدمة
            Expanded(
              child: _buildRoleTabItem(
                label: 'كمقدم خدمة',
                isSelected: _selectedRole == OfficeTripRole.provider,
                onTap: () {
                  setState(() {
                    _selectedRole = OfficeTripRole.provider;
                    _selectedFilter = OfficeTripFilter.all;
                  });
                },
              ),
            ),

            // Tab 2: كطالب خدمة
            Expanded(
              child: _buildRoleTabItem(
                label: 'كطالب خدمة',
                isSelected: _selectedRole == OfficeTripRole.seeker,
                onTap: () {
                  setState(() {
                    _selectedRole = OfficeTripRole.seeker;
                    _selectedFilter = OfficeTripFilter.all;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTabItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Search Field
  // ===========================================================================
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 46.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: 'البحث عن رحلة، عميل، سائق...',
            hintStyle: GoogleFonts.cairo(
              fontSize: 13.0,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF64748B),
              size: 20.0,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18.0,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11.0),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Status Filters (Horizontal Scrollable Chips)
  // ===========================================================================
  Widget _buildStatusFilters() {
    final counts = _store.getCounts(_selectedRole);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: OfficeTripFilter.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          final count = counts[filter] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _buildFilterChip(
              filter: filter,
              count: count,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterChip({
    required OfficeTripFilter filter,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color activeBg;
    Color activeText = Colors.white;

    switch (filter) {
      case OfficeTripFilter.all:
        activeBg = const Color(0xFF2563EB);
        break;
      case OfficeTripFilter.pendingStart:
        activeBg = const Color(0xFFD97706);
        break;
      case OfficeTripFilter.inProgress:
        activeBg = const Color(0xFF16A34A);
        break;
      case OfficeTripFilter.completed:
        activeBg = const Color(0xFF2563EB);
        break;
      case OfficeTripFilter.cancelled:
        activeBg = const Color(0xFFDC2626);
        break;
    }

    final Color bgColor = isSelected ? activeBg : Colors.white;
    final Color textColor = isSelected ? activeText : const Color(0xFF64748B);
    final Color borderColor = isSelected ? activeBg : const Color(0xFFE2E8F0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: 38.0,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: borderColor),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBg.withValues(alpha: 0.25),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filter.label,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 5.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.cairo(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Trips List & Cards
  // ===========================================================================
  Widget _buildTripsList() {
    final list = _filteredTrips;

    if (list.isEmpty) {
      final isSearching = _searchController.text.trim().isNotEmpty;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          children: [
            Container(
              width: 72.0,
              height: 72.0,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off_rounded : Icons.local_shipping_outlined,
                size: 36.0,
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              isSearching
                  ? 'لم يتم العثور على رحلات مطابقة'
                  : (_selectedRole == OfficeTripRole.provider
                      ? 'لا توجد رحلات في هذا الفلتر حالياً'
                      : 'لا توجد طلبات في هذا التبويب حالياً'),
              style: GoogleFonts.cairo(
                fontSize: 15.0,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6.0),
            Text(
              isSearching
                  ? 'جرّب البحث باسم عميل أو سائق أو رقم رحلة آخر.'
                  : 'ستظهر الرحلات الجديدة تلقائياً عند إسنادها لمكتبك.',
              style: GoogleFonts.cairo(
                fontSize: 12.0,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            if (isSearching) ...[
              const SizedBox(height: 12.0),
              TextButton(
                onPressed: () => _searchController.clear(),
                child: Text(
                  'مسح نص البحث',
                  style: GoogleFonts.cairo(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12.0),
        itemBuilder: (context, index) {
          final trip = list[index];
          return _buildTripCard(trip);
        },
      ),
    );
  }

  // ===========================================================================
  // Trip Card Implementation
  // ===========================================================================
  Widget _buildTripCard(OfficeTrip trip) {
    return InkWell(
      onTap: () => _openTripDetails(trip),
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Row: Status Badge on Start side, Trip ID on End side
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardStatusBadge(trip.status),
                Text(
                  '#${trip.id}',
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // 2. Prominent Route (Origin ← Destination)
            Row(
              children: [
                const Icon(
                  Icons.alt_route_rounded,
                  size: 18.0,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    trip.formattedRoute,
                    style: GoogleFonts.cairo(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6.0),

            // 3. Client Name with Business/Building Icon
            Row(
              children: [
                const Icon(
                  Icons.business_rounded,
                  size: 15.0,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  child: Text(
                    trip.clientName,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6.0),

            // 4. Date / Time & Overdue indicator
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 15.0,
                  color: trip.isOverdue
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text(
                    _formatCardDate(trip),
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: trip.isOverdue
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trip.isOverdue) ...[
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      'تجاوز الموعد',
                      style: GoogleFonts.cairo(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10.0),
            const Divider(height: 1.0, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10.0),

            // 5. Specs (Truck type, Payload) & Agreed Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Truck details
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 16.0,
                        color: Color(0xFF475569),
                      ),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          '${trip.truckType} • ${trip.weightTons.toInt()}طن',
                          style: GoogleFonts.cairo(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),

                // Price
                Text(
                  '${trip.agreedPriceSar} ر.س',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8.0),

            // 6. Assigned Driver row
            Row(
              children: [
                if (trip.driver != null) ...[
                  // Driver Avatar
                  Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        trip.driver!.avatarAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFEFF6FF),
                          child: Center(
                            child: Text(
                              trip.driver!.name.substring(0, 1),
                              style: GoogleFonts.cairo(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    trip.driver!.name,
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 16.0,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'لم يتم تعيين سائق',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12.0),

            // 7. Action Buttons according to state
            _buildCardActionButtons(trip),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStatusBadge(OfficeTripStatus status) {
    Color bg;
    Color border;
    Color text;

    switch (status) {
      case OfficeTripStatus.pendingStart:
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFDE68A);
        text = const Color(0xFFD97706);
        break;
      case OfficeTripStatus.inProgress:
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFF86EFAC);
        text = const Color(0xFF16A34A);
        break;
      case OfficeTripStatus.completed:
        bg = const Color(0xFFEFF6FF);
        border = const Color(0xFFBFDBFE);
        text = const Color(0xFF2563EB);
        break;
      case OfficeTripStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFFECACA);
        text = const Color(0xFFDC2626);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: border),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.cairo(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }

  Widget _buildCardActionButtons(OfficeTrip trip) {
    switch (trip.status) {
      case OfficeTripStatus.pendingStart:
        return Row(
          children: [
            // عرض التفاصيل
            Expanded(
              child: SizedBox(
                height: 38.0,
                child: OutlinedButton(
                  onPressed: () => _openTripDetails(trip),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'عرض التفاصيل',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // بدء الرحلة
            Expanded(
              child: SizedBox(
                height: 38.0,
                child: ElevatedButton(
                  onPressed: () => _confirmStartTrip(trip),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'بدء الرحلة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case OfficeTripStatus.inProgress:
        return Row(
          children: [
            // عرض التفاصيل
            Expanded(
              child: SizedBox(
                height: 38.0,
                child: OutlinedButton(
                  onPressed: () => _openTripDetails(trip),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'عرض التفاصيل',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // إنهاء الرحلة
            Expanded(
              child: SizedBox(
                height: 38.0,
                child: ElevatedButton(
                  onPressed: () => _confirmCompleteTrip(trip),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'إنهاء الرحلة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case OfficeTripStatus.completed:
      case OfficeTripStatus.cancelled:
        return SizedBox(
          width: double.infinity,
          height: 38.0,
          child: OutlinedButton(
            onPressed: () => _openTripDetails(trip),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF334155),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'عرض التفاصيل',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
    }
  }

  // ===========================================================================
  // Dialogs & Actions
  // ===========================================================================

  Future<void> _confirmStartTrip(OfficeTrip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(
            'بدء الرحلة #${trip.id}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في بدء الرحلة الآن وانطلاق الشاحنة من ${trip.originCity} إلى ${trip.destinationCity}؟',
            style: GoogleFonts.cairo(fontSize: 13.5, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('تراجع', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('تأكيد بدء الرحلة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final success = await _store.startTrip(trip.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم بدء الرحلة بنجاح ✓', style: GoogleFonts.cairo()),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    }
  }

  Future<void> _confirmCompleteTrip(OfficeTrip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(
            'إنهاء الرحلة #${trip.id}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'هل تم تسليم الشحنة في ${trip.destinationCity} وتوقيع سند الاستلام من قبل العميل؟',
            style: GoogleFonts.cairo(fontSize: 13.5, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('تراجع', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('تأكيد إنهاء الرحلة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final success = await _store.completeTrip(trip.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنهاء الرحلة وتأكيد التسليم بنجاح ✓', style: GoogleFonts.cairo()),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
    }
  }

  void _openTripDetails(OfficeTrip trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransportOfficeTripDetailsScreen(tripId: trip.id),
      ),
    );
  }

  String _formatCardDate(OfficeTrip trip) {
    DateTime dt;
    String prefix = '';

    switch (trip.status) {
      case OfficeTripStatus.pendingStart:
        dt = trip.scheduledDate;
        prefix = 'الموعد: ';
        break;
      case OfficeTripStatus.inProgress:
        dt = trip.actualStartTime ?? trip.scheduledDate;
        prefix = 'بدأت: ';
        break;
      case OfficeTripStatus.completed:
        dt = trip.actualEndTime ?? trip.scheduledDate;
        prefix = 'اكتملت: ';
        break;
      case OfficeTripStatus.cancelled:
        dt = trip.cancelledAt ?? trip.scheduledDate;
        prefix = 'أُلغيت: ';
        break;
    }

    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    final monthName = months[dt.month - 1];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'م' : 'ص';
    final minuteStr = dt.minute.toString().padLeft(2, '0');

    return '$prefix${dt.day} $monthName ${dt.year} • $hour:$minuteStr $period';
  }

  // ===========================================================================
  // Unified Bottom Navigation Bar
  // ===========================================================================
  Widget _buildUnifiedBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. الرئيسية
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                isActive: false,
                onTap: () => context.go(AppRoutes.transportOfficeHome),
              ),

              // 2. الخريطة
              _buildNavItem(
                icon: Icons.map_outlined,
                label: 'الخريطة',
                isActive: false,
                onTap: () => context.push(AppRoutes.driverCargoMap),
              ),

              // 3. Central (+) FAB
              _buildCenterFab(),

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
                onTap: () => context.push(AppRoutes.transportOfficeAccount),
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
        offset: const Offset(0, -6.0),
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
  // Quick Actions Sheet & Grid (2x2)
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
        color: const Color(0xFF0F172A),
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
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 4.0),
              width: 38.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.sync_alt_rounded,
                          label: 'تحديث الحالة',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            _showStatusNotification();
                          },
                        ),
                      ),
                      Container(
                        height: 80.0,
                        width: 1.0,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.local_shipping_rounded,
                          label: 'رحلاتي الجارية',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            setState(() {
                              _selectedRole = OfficeTripRole.provider;
                              _selectedFilter = OfficeTripFilter.inProgress;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 1.0,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionGridTile(
                          icon: Icons.support_agent_rounded,
                          label: 'طلب مساعدة',
                          onTap: () {
                            _closeQuickActions(immediate: true);
                            _showSupportDialog();
                          },
                        ),
                      ),
                      Container(
                        height: 80.0,
                        width: 1.0,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
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
            Icon(icon, color: Colors.white, size: 28.0),
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

  void _showStatusNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حالة المكتب: متاح لاستقبال الرحلات ✓', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text('مركز الدعم والمساعدة', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
          content: Text(
            'فريق الدعم الفني لحمولة متاح لمساعدتك على مدار الساعة.\nهاتف: 920000000\nواتساب: +966500000000',
            style: GoogleFonts.cairo(fontSize: 13.5, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('إغلاق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportIssueDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text('الإبلاغ عن مشكلة', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
          content: Text(
            'هل تواجه مشكلة في تتبع رحلة أو مستحقات؟ يرجى إرسال تفاصيل البلاغ وسيتم التواصل معك مباشرة.',
            style: GoogleFonts.cairo(fontSize: 13.5, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('إلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم استلام بلاغك وسيتواصل معك الدعم الفني', style: GoogleFonts.cairo()),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: Text('إرسال البلاغ', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
