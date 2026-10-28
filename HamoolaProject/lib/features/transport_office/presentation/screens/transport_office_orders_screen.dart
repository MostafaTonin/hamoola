import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../driver/domain/models/driver_simulation_store.dart';
import '../../../driver/presentation/widgets/driver_submit_bid_sheet.dart';
import '../../../merchant/domain/models/merchant_simulation_store.dart';
import '../../../merchant/presentation/widgets/merchant_order_details_dialog.dart';
import '../../domain/models/transport_office_orders_data.dart';

/// Transport Office Orders Screen («طلباتي»):
/// - Dual Primary Tabs: «كمقدم خدمة» (truck icon) vs «كطالب خدمة» (document icon).
/// - 6 horizontal scrollable filter chips for each tab.
/// - Live search by order ID, cargo title, or cities.
/// - Card design strictly matching reference image with distinct provider/requester fields.
/// - Integrated actions: عرض التفاصيل, تقديم عرض, التواصل مع السائق, تتبع الرحلة 📍.
/// - Unified 5-item bottom navigation bar with active «طلباتي» (red) and rotating (+) FAB.
class TransportOfficeOrdersScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final String? initialTab;
  final ValueChanged<String>? onOrderDetails;

  const TransportOfficeOrdersScreen({
    super.key,
    this.onBack,
    this.initialTab,
    this.onOrderDetails,
  });

  @override
  State<TransportOfficeOrdersScreen> createState() =>
      _TransportOfficeOrdersScreenState();
}

class _TransportOfficeOrdersScreenState extends State<TransportOfficeOrdersScreen>
    with SingleTickerProviderStateMixin {
  // Primary Tab: Provider vs Requester
  late TransportOfficeOrderRole _activeRole;

  // Filter chips
  OfficeProviderFilter _providerFilter = OfficeProviderFilter.all;
  OfficeRequesterFilter _requesterFilter = OfficeRequesterFilter.all;

  // Search
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  // Order lists
  late List<OfficeProviderOrder> _providerOrders;
  late List<OfficeRequesterOrder> _requesterOrders;

  // (+) FAB animation controller for rotating + to ×
  late final AnimationController _fabAnimController;
  bool _isFabSheetOpen = false;

  // Availability state
  bool _isAvailableForOrders = true;

  @override
  void initState() {
    super.initState();
    _activeRole = widget.initialTab == 'requester'
        ? TransportOfficeOrderRole.requester
        : TransportOfficeOrderRole.provider;

    _isAvailableForOrders = AppPreferences.instance.isOfficeAvailable;

    _providerOrders = List.from(OfficeProviderOrder.demoOrders);
    _requesterOrders = List.from(OfficeRequesterOrder.demoOrders);

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    DriverSimulationStore.instance.addListener(_onStoreChanged);
    MerchantSimulationStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fabAnimController.dispose();
    DriverSimulationStore.instance.removeListener(_onStoreChanged);
    MerchantSimulationStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  // ===========================================================================
  // Filtered Lists Logic
  // ===========================================================================
  List<OfficeProviderOrder> get _filteredProviderOrders {
    final driverStore = DriverSimulationStore.instance;

    // Build synchronized list
    final List<OfficeProviderOrder> list = [];

    for (final base in _providerOrders) {
      // Check if driver simulation store has a bid on this cargo
      final hasBid = driverStore.hasBidOnCargo(base.id);
      final bidItem = driverStore.getBidForCargo(base.id);

      OfficeProviderOrder order = base;
      if (hasBid && bidItem != null) {
        order = order.copyWith(
          category: OfficeProviderFilter.myBids,
          bidAmount: bidItem.bidAmount,
          bidStatus: bidItem.status,
        );
      }
      list.add(order);
    }

    // Filter by selected chip
    List<OfficeProviderOrder> results = list;
    if (_providerFilter != OfficeProviderFilter.all) {
      results = results.where((o) => o.category == _providerFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      results = results.where((o) {
        return o.id.toLowerCase().contains(_searchQuery) ||
            o.title.toLowerCase().contains(_searchQuery) ||
            o.originCity.toLowerCase().contains(_searchQuery) ||
            o.destinationCity.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return results;
  }

  List<OfficeRequesterOrder> get _filteredRequesterOrders {
    List<OfficeRequesterOrder> results = _requesterOrders;

    // Filter by selected chip
    if (_requesterFilter != OfficeRequesterFilter.all) {
      results = results.where((o) => o.status == _requesterFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      results = results.where((o) {
        return o.id.toLowerCase().contains(_searchQuery) ||
            o.title.toLowerCase().contains(_searchQuery) ||
            o.originCity.toLowerCase().contains(_searchQuery) ||
            o.destinationCity.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return results;
  }

  // ===========================================================================
  // Actions
  // ===========================================================================
  void _openDetailsForProviderOrder(OfficeProviderOrder order) {
    if (widget.onOrderDetails != null) {
      widget.onOrderDetails!(order.id);
      return;
    }
    // Navigate using existing DriverOrderDetails route
    context.push(
      AppRoutes.driverOrderDetails,
      extra: order.toCargoOpportunity(),
    );
  }

  void _openDetailsForRequesterOrder(OfficeRequesterOrder order) {
    if (widget.onOrderDetails != null) {
      widget.onOrderDetails!(order.id);
      return;
    }
    // Open existing MerchantOrderDetailsDialog
    MerchantOrderDetailsDialog.show(
      context,
      order.toMerchantOrder(),
      onLiveTracking: (id) => context.push(AppRoutes.merchantTripTracking, extra: id),
    );
  }

  Future<void> _handleProviderSubmitBid(OfficeProviderOrder order) async {
    final cargo = order.toCargoOpportunity();
    final result = await DriverSubmitBidSheet.show(
      context,
      cargo: cargo,
      onBidSubmitted: (amount) {
        // Update local list state
        setState(() {
          final index = _providerOrders.indexWhere((o) => o.id == order.id);
          if (index != -1) {
            _providerOrders[index] = _providerOrders[index].copyWith(
              category: OfficeProviderFilter.myBids,
              bidAmount: amount,
              bidStatus: 'pending',
            );
          }
        });
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF16A34A),
          content: Text(
            'تم تقديم عرض السعر بنجاح وانتقل إلى قائمة «عروضي» ✓',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      );
    }
  }

  void _showDriverContactSheet(OfficeRequesterOrder order) {
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
                  CircleAvatar(
                    radius: 24.0,
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: const Icon(Icons.person_rounded, color: Color(0xFF1D4ED8), size: 28.0),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.driverName ?? 'السائق المسند للرحلة',
                          style: GoogleFonts.cairo(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          order.driverPhone ?? '+967 771 889 900',
                          style: GoogleFonts.cairo(
                            fontSize: 13.0,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      'سائق معتمد',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'جاري الاتصال بالسائق: ${order.driverPhone ?? "+967 771 889 900"}...',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.call_rounded, size: 20.0),
                label: Text('اتصال هاتفي مباشر', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
              const SizedBox(height: 10.0),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'جاري فتح المحادثة الفورية مع السائق...',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_outlined, size: 20.0),
                label: Text('محادثة فورية عبر حمولة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1D4ED8),
                  side: const BorderSide(color: Color(0xFF1D4ED8)),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Build Main Tree
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
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
              // Layer 1: Page Content
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomBarHeight),
                    child: Column(
                      children: [
                        // 1. Screen Header
                        _buildScreenHeader(),

                        // 2. The Two Main Role Tabs
                        _buildDualRoleTabs(),

                        const SizedBox(height: 10.0),

                        // 3. Horizontal Filter Chips
                        _buildFilterChipsRow(),

                        // 4. Pill Search Bar
                        _buildSearchBar(),

                        // 5. Scrollable Orders List
                        Expanded(
                          child: RefreshIndicator(
                            color: const Color(0xFF1D4ED8),
                            onRefresh: () async {
                              await Future.delayed(const Duration(milliseconds: 400));
                              if (mounted) setState(() {});
                            },
                            child: _buildOrdersList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Layer 2: Dim Backdrop Scrim for (+) Sheet
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

              // Layer 4: Bottom Navigation Bar with centered (+) FAB (ALWAYS VISIBLE)
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
  // Section 2: Screen Header
  // ===========================================================================
  Widget _buildScreenHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (< chevron)
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
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.0,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          // Title & Subtitle centered
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'طلباتي',
                      style: GoogleFonts.cairo(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'إدارة طلبات مكتب النقل',
                      style: GoogleFonts.cairo(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search glass button
          InkWell(
            onTap: () {
              _searchFocusNode.requestFocus();
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
                  Icons.search_rounded,
                  size: 22.0,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section 3: Dual Role Tabs («كمقدم خدمة» vs «كطالب خدمة»)
  // ===========================================================================
  Widget _buildDualRoleTabs() {
    final isProvider = _activeRole == TransportOfficeOrderRole.provider;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
      child: Row(
        children: [
          // Tab 1: «كمقدم خدمة»
          Expanded(
            child: _buildRoleTabButton(
              title: 'كمقدم خدمة',
              subtitle: 'طلبات وعروض النقل',
              icon: Icons.local_shipping_rounded,
              isActive: isProvider,
              onTap: () {
                if (!isProvider) {
                  setState(() {
                    _activeRole = TransportOfficeOrderRole.provider;
                    _providerFilter = OfficeProviderFilter.all;
                  });
                }
              },
            ),
          ),

          const SizedBox(width: 12.0),

          // Tab 2: «كطالب خدمة»
          Expanded(
            child: _buildRoleTabButton(
              title: 'كطالب خدمة',
              subtitle: 'طلباتي للبحث عن سائق',
              icon: Icons.description_rounded,
              isActive: !isProvider,
              onTap: () {
                if (isProvider) {
                  setState(() {
                    _activeRole = TransportOfficeOrderRole.requester;
                    _requesterFilter = OfficeRequesterFilter.all;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTabButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF1D4ED8).withValues(alpha: 0.32),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF475569),
              size: 26.0,
            ),
            const SizedBox(height: 6.0),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2.0),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Section 4: Horizontal Filter Chips
  // ===========================================================================
  Widget _buildFilterChipsRow() {
    final isProvider = _activeRole == TransportOfficeOrderRole.provider;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: isProvider
            ? OfficeProviderFilter.values.map((filter) {
                final isSelected = _providerFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildFilterChip(
                    label: filter.label,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _providerFilter = filter);
                    },
                  ),
                );
              }).toList()
            : OfficeRequesterFilter.values.map((filter) {
                final isSelected = _requesterFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildFilterChip(
                    label: filter.label,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _requesterFilter = filter);
                    },
                  ),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Section 5: Pill Search Bar
  // ===========================================================================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 10.0),
      child: Container(
        height: 44.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: GoogleFonts.cairo(fontSize: 13.0, color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: 'ابحث برقم الطلب أو نوع الحمولة...',
            hintStyle: GoogleFonts.cairo(fontSize: 12.5, color: const Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search_rounded, size: 20.0, color: Color(0xFF94A3B8)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18.0, color: Color(0xFF64748B)),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Section 6: Orders List & Empty States
  // ===========================================================================
  Widget _buildOrdersList() {
    final isProvider = _activeRole == TransportOfficeOrderRole.provider;

    if (isProvider) {
      final list = _filteredProviderOrders;
      if (list.isEmpty) {
        return _buildEmptyState(
          title: _searchQuery.isNotEmpty
              ? 'لا توجد نتائج مطابقة لبحثك'
              : 'لا توجد طلبات في هذا الفلتر',
          subtitle: _searchQuery.isNotEmpty
              ? 'جرّب البحث باسم مدينة أو رقم طلب آخر.'
              : 'ستظهر هنا طلبات النقل التي يمكنك تقديم عروض أسعار عليها.',
          icon: Icons.inventory_2_outlined,
          canClearSearch: _searchQuery.isNotEmpty,
        );
      }

      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12.0),
        itemBuilder: (ctx, idx) => _buildProviderOrderCard(list[idx]),
      );
    } else {
      final list = _filteredRequesterOrders;
      if (list.isEmpty) {
        return _buildEmptyState(
          title: _searchQuery.isNotEmpty
              ? 'لا توجد نتائج مطابقة لبحثك'
              : 'لا توجد طلبات في هذا الفلتر',
          subtitle: _searchQuery.isNotEmpty
              ? 'جرّب البحث باسم مدينة أو نوع حمولة آخر.'
              : 'يمكنك إنشاء طلب نقل جديد بالضغط على زر (+) في الأسفل.',
          icon: Icons.assignment_outlined,
          canClearSearch: _searchQuery.isNotEmpty,
        );
      }

      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12.0),
        itemBuilder: (ctx, idx) => _buildRequesterOrderCard(list[idx]),
      );
    }
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required IconData icon,
    bool canClearSearch = false,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.0,
              height: 72.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: const Color(0xFF94A3B8), size: 36.0),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6.0),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (canClearSearch) ...[
              const SizedBox(height: 16.0),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  side: const BorderSide(color: Color(0xFF1D4ED8)),
                ),
                child: Text(
                  'مسح البحث والعودة',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Section 7: Order Cards — Provider Role («كمقدم خدمة»)
  // ===========================================================================
  Widget _buildProviderOrderCard(OfficeProviderOrder order) {
    final isGeneral = !order.isPrivate;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetailsForProviderOrder(order),
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top section: Image on left, details on right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cargo thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        order.imageAsset,
                        width: 74.0,
                        height: 74.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 74.0,
                          height: 74.0,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Color(0xFF94A3B8),
                            size: 30.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),

                    // Order Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Line 1: Badge + Title + Chevron
                          Row(
                            children: [
                              // Badge (طلب عام / طلب خاص)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: isGeneral ? const Color(0xFFE0F2FE) : const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  isGeneral ? 'طلب عام' : 'طلب خاص',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: isGeneral ? const Color(0xFF0284C7) : const Color(0xFF9333EA),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),

                              // Title + chevron
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        order.title,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13.5,
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
                          const SizedBox(height: 2.0),

                          // Line 2: Order ID
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              'رقم الطلب: ${order.id}',
                              style: GoogleFonts.cairo(
                                fontSize: 11.0,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6.0),

                          // Line 3: Route (صنعاء 📍 ← 📍 تعز) with FittedBox
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Destination
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on_rounded, size: 13.0, color: Color(0xFFEF4444)),
                                        const SizedBox(width: 2.0),
                                        Text(
                                          order.destinationCity,
                                          style: GoogleFonts.cairo(fontSize: 12.0, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'وجهة التفريغ',
                                      style: GoogleFonts.cairo(fontSize: 10.0, color: const Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Icon(Icons.arrow_back_rounded, size: 16.0, color: Color(0xFF94A3B8)),
                                ),

                                // Origin
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          order.originCity,
                                          style: GoogleFonts.cairo(fontSize: 12.0, fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(width: 2.0),
                                        const Icon(Icons.location_on_rounded, size: 13.0, color: Color(0xFF16A34A)),
                                      ],
                                    ),
                                    Text(
                                      'نقطة التحميل',
                                      style: GoogleFonts.cairo(fontSize: 10.0, color: const Color(0xFF94A3B8)),
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

                const SizedBox(height: 10.0),

                // Middle Stats Row: Distance, Weight, Price with FittedBox
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Distance
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_road_rounded, size: 13.5, color: Color(0xFF64748B)),
                            const SizedBox(width: 4.0),
                            Text(
                              '${order.distanceKm} كم',
                              style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                            ),
                          ],
                        ),

                        const SizedBox(width: 18.0),

                        // Weight
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.scale_rounded, size: 13.5, color: Color(0xFF64748B)),
                            const SizedBox(width: 4.0),
                            Text(
                              '${order.weightTons.toStringAsFixed(0)} طن',
                              style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                            ),
                          ],
                        ),

                        const SizedBox(width: 18.0),

                        // Price in green
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.payments_outlined, size: 14.0, color: Color(0xFF16A34A)),
                            const SizedBox(width: 4.0),
                            Text(
                              '${order.priceYmr} ريال',
                              style: GoogleFonts.cairo(fontSize: 12.0, fontWeight: FontWeight.w800, color: const Color(0xFF16A34A)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),

                // Bottom Action Buttons
                _buildProviderCardActions(order),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCardActions(OfficeProviderOrder order) {
    if (order.category == OfficeProviderFilter.myBids) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _openDetailsForProviderOrder(order),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                side: const BorderSide(color: Color(0xFF1D4ED8)),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              child: Text(
                'عرض التفاصيل',
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Center(
                child: Text(
                  'تم تقديم عرض (${order.bidAmount ?? order.priceYmr} ريال)',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D4ED8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (order.category == OfficeProviderFilter.inProgress ||
        order.category == OfficeProviderFilter.assigned) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _openDetailsForProviderOrder(order),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                side: const BorderSide(color: Color(0xFF1D4ED8)),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              child: Text(
                'عرض التفاصيل',
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.driverTrips, extra: 'النشطة'),
              icon: const Icon(Icons.location_on_rounded, size: 16.0, color: Color(0xFF1D4ED8)),
              label: Text(
                'تتبع الرحلة',
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                side: const BorderSide(color: Color(0xFF1D4ED8)),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ),
        ],
      );
    }

    if (order.category == OfficeProviderFilter.completed) {
      return OutlinedButton(
        onPressed: () => _openDetailsForProviderOrder(order),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          side: const BorderSide(color: Color(0xFF1D4ED8)),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        child: Text(
          'عرض التفاصيل',
          style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
        ),
      );
    }

    // Default for available orders matching screenshot:
    // Outline "عرض التفاصيل" on left, solid blue "تقديم عرض" on right
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _openDetailsForProviderOrder(order),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              side: const BorderSide(color: Color(0xFF1D4ED8)),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
            child: Text(
              'عرض التفاصيل',
              style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _handleProviderSubmitBid(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
            ),
            child: Text(
              'تقديم عرض',
              style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Section 8: Order Cards — Requester Role («كطالب خدمة»)
  // ===========================================================================
  Widget _buildRequesterOrderCard(OfficeRequesterOrder order) {
    Color badgeBg;
    Color badgeFg;
    switch (order.status) {
      case OfficeRequesterFilter.waitingDriver:
        badgeBg = const Color(0xFFFEF3C7);
        badgeFg = const Color(0xFFD97706);
        break;
      case OfficeRequesterFilter.assignedDriver:
        badgeBg = const Color(0xFFDBEAFE);
        badgeFg = const Color(0xFF2563EB);
        break;
      case OfficeRequesterFilter.inProgress:
        badgeBg = const Color(0xFFDCFCE7);
        badgeFg = const Color(0xFF16A34A);
        break;
      case OfficeRequesterFilter.completed:
        badgeBg = const Color(0xFFF1F5F9);
        badgeFg = const Color(0xFF64748B);
        break;
      case OfficeRequesterFilter.cancelled:
        badgeBg = const Color(0xFFFEE2E2);
        badgeFg = const Color(0xFFDC2626);
        break;
      case OfficeRequesterFilter.all:
        badgeBg = const Color(0xFFF1F5F9);
        badgeFg = const Color(0xFF64748B);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetailsForRequesterOrder(order),
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top section: Image on left, details on right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cargo thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        order.imageAsset,
                        width: 74.0,
                        height: 74.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 74.0,
                          height: 74.0,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Color(0xFF94A3B8),
                            size: 30.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),

                    // Order Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Line 1: Badge + Title + Chevron
                          Row(
                            children: [
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  order.status.label,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: badgeFg,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),

                              // Title + chevron
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        order.title,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13.5,
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
                          const SizedBox(height: 2.0),

                          // Line 2: Order ID
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              'رقم الطلب: ${order.id}',
                              style: GoogleFonts.cairo(
                                fontSize: 11.0,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6.0),

                          // Line 3: Route (صنعاء 📍 ← 📍 تعز) with FittedBox
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Destination
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on_rounded, size: 13.0, color: Color(0xFFEF4444)),
                                        const SizedBox(width: 2.0),
                                        Text(
                                          order.destinationCity,
                                          style: GoogleFonts.cairo(fontSize: 12.0, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'وجهة التفريغ',
                                      style: GoogleFonts.cairo(fontSize: 10.0, color: const Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Icon(Icons.arrow_back_rounded, size: 16.0, color: Color(0xFF94A3B8)),
                                ),

                                // Origin
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          order.originCity,
                                          style: GoogleFonts.cairo(fontSize: 12.0, fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(width: 2.0),
                                        const Icon(Icons.location_on_rounded, size: 13.0, color: Color(0xFF16A34A)),
                                      ],
                                    ),
                                    Text(
                                      'نقطة التحميل',
                                      style: GoogleFonts.cairo(fontSize: 10.0, color: const Color(0xFF94A3B8)),
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

                const SizedBox(height: 10.0),

                // Middle Stats Row: Date, Weight, Date with FittedBox
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Road / Date icon
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_road_rounded, size: 13.5, color: Color(0xFF64748B)),
                            const SizedBox(width: 4.0),
                            Text(
                              order.dateStr,
                              style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16.0),

                        // Weight
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.scale_rounded, size: 13.5, color: Color(0xFF64748B)),
                            const SizedBox(width: 4.0),
                            Text(
                              '${order.weightTons.toStringAsFixed(0)} طن',
                              style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16.0),

                        // Calendar
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 13.5, color: Color(0xFF64748B)),
                            const SizedBox(width: 4.0),
                            Text(
                              order.dateStr,
                              style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),

                // Bottom Action Buttons
                _buildRequesterCardActions(order),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequesterCardActions(OfficeRequesterOrder order) {
    // Card 1: "بانتظار سائق" -> Single outline "عرض التفاصيل"
    if (order.status == OfficeRequesterFilter.waitingDriver) {
      return OutlinedButton(
        onPressed: () => _openDetailsForRequesterOrder(order),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          side: const BorderSide(color: Color(0xFF1D4ED8)),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        child: Text(
          'عرض التفاصيل',
          style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
        ),
      );
    }

    // Card 2: "تم إسناد سائق" -> "التواصل مع السائق" outline on left, solid blue "عرض التفاصيل" on right
    if (order.status == OfficeRequesterFilter.assignedDriver) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showDriverContactSheet(order),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                side: const BorderSide(color: Color(0xFF1D4ED8)),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              child: Text(
                'التواصل مع السائق',
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _openDetailsForRequesterOrder(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              child: Text(
                'عرض التفاصيل',
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      );
    }

    // Card 3: "قيد التنفيذ" -> "تتبع الرحلة 📍" on left, "عرض التفاصيل" on right
    if (order.status == OfficeRequesterFilter.inProgress) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.merchantTripTracking, extra: order.id),
              icon: const Icon(Icons.location_on_rounded, size: 16.0, color: Color(0xFF1D4ED8)),
              label: Text(
                'تتبع الرحلة',
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                side: const BorderSide(color: Color(0xFF1D4ED8)),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _openDetailsForRequesterOrder(order),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                side: const BorderSide(color: Color(0xFF1D4ED8)),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              child: Text(
                'عرض التفاصيل',
                style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
              ),
            ),
          ),
        ],
      );
    }

    // Card 4: "مكتملة" / "ملغاة" -> Single outline "عرض التفاصيل"
    return OutlinedButton(
      onPressed: () => _openDetailsForRequesterOrder(order),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        side: const BorderSide(color: Color(0xFF1D4ED8)),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
      ),
      child: Text(
        'عرض التفاصيل',
        style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF1D4ED8)),
      ),
    );
  }

  // ===========================================================================
  // Section 9: Bottom Navigation Bar with Rotating (+) FAB
  // ===========================================================================
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
              // 1. الرئيسية
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                isActive: false,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.transportOfficeHome);
                  }
                },
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

              // 4. طلباتي (ACTIVE - Red #DC2626)
              _buildNavItem(
                icon: Icons.assignment_rounded,
                label: 'طلباتي',
                isActive: true,
                onTap: () {},
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
  // Quick Actions Sheet & Dialogs
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
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
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
                            context.push(AppRoutes.transportOfficeTrips);
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 1.0,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  Row(
                    children: [
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
                    const SizedBox(height: 18.0),
                    _buildStatusOptionTile(
                      title: 'متاح لاستقبال الطلبات',
                      subtitle: 'استقبال الطلبات الخاصة الموجهة للمكتب، مع إمكانية التقديم على الطلبات العامة.',
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF16A34A),
                      isSelected: tempStatus == true,
                      onTap: () => setModalState(() => tempStatus = true),
                    ),
                    const SizedBox(height: 10.0),
                    _buildStatusOptionTile(
                      title: 'غير متاح حالياً',
                      subtitle: 'عدم توجيه طلبات خاصة جديدة، دون التأثير على الطلبات والرحلات الحالية والطلبات العامة.',
                      icon: Icons.pause_circle_outline_rounded,
                      iconColor: const Color(0xFFEA580C),
                      isSelected: tempStatus == false,
                      onTap: () => setModalState(() => tempStatus = false),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dlgCtx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            child: Text(
                              'إلغاء',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await AppPreferences.instance.setOfficeAvailable(tempStatus);
                              if (mounted) {
                                setState(() => _isAvailableForOrders = tempStatus);
                              }
                              if (dlgCtx.mounted) Navigator.pop(dlgCtx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            ),
                            child: Text('حفظ الحالة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
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
      child: Container(
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
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  Text('موضوع الطلب *', style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      hintText: 'مثال: استفسار بخصوص تسوية الرحلة',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى إدخال موضوع الطلب' : null,
                  ),
                  const SizedBox(height: 12.0),
                  Text('تفاصيل المساعدة المطلوبة *', style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    controller: detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اكتب تفاصيل طلبك...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى كتابة تفاصيل الطلب' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: Text('إلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dlgCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تسجيل طلب المساعدة بنجاح ✓', style: GoogleFonts.cairo()),
                    ),
                  );
                }
              },
              child: Text('إرسال الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportIssueDialog() {
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dlgCtx) => Directionality(
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
                  Text('وصف المشكلة *', style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6.0),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'صف المشكلة بوضوح...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى كتابة وصف المشكلة' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: Text('إلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dlgCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم رفع البلاغ بنجاح ✓', style: GoogleFonts.cairo()),
                    ),
                  );
                }
              },
              child: Text('إرسال البلاغ', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
