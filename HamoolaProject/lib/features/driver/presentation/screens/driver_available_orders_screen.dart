import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cargo_bid_opportunity.dart';
import '../../domain/models/driver_simulation_store.dart';
import '../widgets/driver_submit_bid_sheet.dart';

/// Screen representing the full marketplace of available cargo orders for the driver.
/// Opens when clicking "عرض الكل" in the Available Orders section of Driver Dashboard.
class DriverAvailableOrdersScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final String initialFilter;

  const DriverAvailableOrdersScreen({
    super.key,
    this.onBack,
    this.initialFilter = 'الكل',
  });

  @override
  State<DriverAvailableOrdersScreen> createState() => _DriverAvailableOrdersScreenState();
}

class _DriverAvailableOrdersScreenState extends State<DriverAvailableOrdersScreen> {
  late String _activeFilter;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'الكل',
    'العامة',
    'الخاصة',
    'مطابق لشاحنتي',
    'تحميل فوري',
  ];

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialFilter;
    DriverSimulationStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    DriverSimulationStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  List<CargoBidOpportunity> get _filteredOpportunities {
    final list = DriverSimulationStore.instance.opportunities;
    List<CargoBidOpportunity> filtered;

    switch (_activeFilter) {
      case 'العامة':
        filtered = list.where((c) => !c.isPrivate).toList();
        break;
      case 'الخاصة':
        filtered = list.where((c) => c.isPrivate).toList();
        break;
      case 'مطابق لشاحنتي':
        filtered = list
            .where((c) => c.requiredTruckType.contains('براد') || c.requiredTruckType.contains('ثقيل'))
            .toList();
        break;
      case 'تحميل فوري':
        filtered = list.where((c) => c.isUrgent).toList();
        break;
      default:
        filtered = list;
    }

    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((c) =>
              c.title.contains(query) ||
              c.originCity.contains(query) ||
              c.destinationCity.contains(query) ||
              c.merchantName.contains(query))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = _filteredOpportunities;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.navyDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              size: 20,
            ),
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          title: Text(
            'سوق الحمولات المتاحة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Search Input
            Container(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن نوع البضاعة، المدينة، التاجر...',
                    hintStyle: GoogleFonts.cairo(fontSize: 12.5, color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            // Filter Chips Bar
            Container(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _activeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          filter,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        showCheckmark: false,
                        onSelected: (val) {
                          if (val) setState(() => _activeFilter = filter);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Full List of Orders
            Expanded(
              child: orders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد حمولات مطابقة للمرشح الحالي',
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (ctx, index) => _buildFullOrderCard(orders[index], isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullOrderCard(CargoBidOpportunity order, bool isDark) {
    return InkWell(
      onTap: () => context.push(AppRoutes.driverOrderDetails, extra: order),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: order.isUrgent ? const Color(0xFFEA580C) : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: order.isPrivate ? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.isPrivate ? 'طلب خاص' : 'طلب عام',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: order.isPrivate ? const Color(0xFF92400E) : const Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                    if (order.isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.urgencyLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${order.targetBudgetYmr} ريال',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.title,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${order.originCity} ← ${order.destinationCity} (${order.distanceKm} كم)',
                  style: GoogleFonts.cairo(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'الناقلة: ${order.requiredTruckType} • ${order.weightTons} طن',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(fontSize: 11.5, color: const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'التاجر: ${order.merchantName}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(fontSize: 11.5, color: const Color(0xFF64748B)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (order.isPrivate) {
                    context.push(AppRoutes.driverOrderDetails, extra: order);
                  } else {
                    DriverSubmitBidSheet.show(
                      context,
                      cargo: order,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  order.isPrivate ? 'عرض التفاصيل' : 'تقديم عرض سعر',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
