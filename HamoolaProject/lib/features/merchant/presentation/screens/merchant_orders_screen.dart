import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/merchant_order.dart';
import '../../domain/models/merchant_simulation_store.dart';
import '../widgets/merchant_bottom_nav_bar.dart';
import '../widgets/merchant_order_card.dart';
import '../widgets/merchant_order_details_dialog.dart';

/// Screen representing "طلباتي" (Merchant Transport Orders Screen)
/// Strictly separated from "حمولاتي" (Merchant Cargos Screen):
/// - Manages freight transport orders, their lifecycle stages, bids, and assigned drivers
/// - Status filter tabs: الكل, المسودات, بانتظار سائق, بانتظار مكتب, مسند لسائق, قيد النقل, مكتمل
/// - Links directly to order details / live trip tracking / bids review
/// - Primary FAB: "إنشاء طلب نقل جديد"
class MerchantOrdersScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onCreateOrder;
  final ValueChanged<String>? onOrderDetails;
  final ValueChanged<String>? onReviewOffers;
  final VoidCallback? onHome;
  final VoidCallback? onMap;
  final VoidCallback? onWallet;
  final VoidCallback? onAccount;

  const MerchantOrdersScreen({
    super.key,
    this.onBack,
    this.onCreateOrder,
    this.onOrderDetails,
    this.onReviewOffers,
    this.onHome,
    this.onMap,
    this.onWallet,
    this.onAccount,
  });

  @override
  State<MerchantOrdersScreen> createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends State<MerchantOrdersScreen> {
  MerchantNavTab _currentTab = MerchantNavTab.orders;
  String _selectedStatusFilter = 'all';

  final List<Map<String, String>> _statusTabs = [
    {'key': 'all', 'label': 'الكل'},
    {'key': 'draft', 'label': 'المسودات'},
    {'key': 'pending', 'label': 'بانتظار سائق'},
    {'key': 'assigned', 'label': 'مسند لسائق'},
    {'key': 'inTransit', 'label': 'قيد النقل'},
    {'key': 'completed', 'label': 'مكتمل'},
    {'key': 'pendingOffice', 'label': 'بانتظار مكتب'},
  ];

  List<MerchantOrder> _getFilteredOrders(List<MerchantOrder> all) {
    if (_selectedStatusFilter == 'all') return all;
    return all.where((o) {
      switch (_selectedStatusFilter) {
        case 'draft':
          return o.status == MerchantOrderStatus.draft;
        case 'pending':
          return o.status == MerchantOrderStatus.pendingDriver;
        case 'pendingOffice':
          return o.status == MerchantOrderStatus.pendingOffice;
        case 'assigned':
          return o.status == MerchantOrderStatus.assignedDriver;
        case 'inTransit':
          return o.status == MerchantOrderStatus.inTransit;
        case 'completed':
          return o.status == MerchantOrderStatus.completed;
        default:
          return true;
      }
    }).toList();
  }

  void _showOrderDetails(MerchantOrder order) {
    MerchantOrderDetailsDialog.show(
      context,
      order,
      onReviewOffers: (id) => widget.onReviewOffers?.call(id),
      onLiveTracking: (id) => widget.onOrderDetails?.call(id),
    );
  }

  void _handleTabSelected(MerchantNavTab tab) {
    setState(() => _currentTab = tab);
    if (tab == MerchantNavTab.home) {
      widget.onHome?.call();
    } else if (tab == MerchantNavTab.map) {
      widget.onMap?.call();
    } else if (tab == MerchantNavTab.wallet) {
      widget.onWallet?.call();
    } else if (tab == MerchantNavTab.account) {
      widget.onAccount?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = MerchantSimulationStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final filteredOrders = _getFilteredOrders(store.orders);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor:
                isDark ? AppColors.navyDark : AppColors.backgroundLight,
            body: SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.compactMax,
                  ),
                  child: Column(
                    children: [
                      // 1. Header
                      _buildHeader(isDark),

                      // 2. Status Filter Tabs Bar
                      _buildStatusTabs(isDark),

                      // 3. Orders List
                      Expanded(
                        child: filteredOrders.isEmpty
                            ? _buildEmptyState(isDark)
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spaceMd,
                                  vertical: AppDimensions.spaceSm,
                                ),
                                itemCount: filteredOrders.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12.0),
                                itemBuilder: (context, index) {
                                  final order = filteredOrders[index];
                                  return MerchantOrderCard(
                                    order: order,
                                    onTap: () => _showOrderDetails(order),
                                    onReviewOffers: () =>
                                        widget.onReviewOffers?.call(order.id),
                                    onOrderDetails: () =>
                                        _showOrderDetails(order),
                                  );
                                },
                              ),
                      ),

                      // 4. Bottom Nav Bar
                      MerchantBottomNavBar(
                        currentTab: _currentTab,
                        onTabSelected: _handleTabSelected,
                        onFabPressed: widget.onCreateOrder ?? () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    final totalCount = MerchantSimulationStore.instance.orders.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              onPressed: widget.onBack,
              tooltip: AppStrings.back,
            ),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 20,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'طلباتي',
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textWhite
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  '$totalCount طلبات نقل مسجلة',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSubtle
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action CTA: Create Order
          ElevatedButton.icon(
            onPressed: widget.onCreateOrder,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              'طلب جديد',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _statusTabs.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = _statusTabs[index];
          final isSelected = _selectedStatusFilter == tab['key'];

          return ChoiceChip(
            label: Text(tab['label']!),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedStatusFilter = tab['key']!);
              }
            },
            selectedColor: const Color(0xFF0F172A),
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            labelStyle: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textWhite : const Color(0xFF334155)),
            ),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0)),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 34,
                color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات نقل مطابقة',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'يمكنك إنشاء طلب نقل جديد وربطه بإحدى حمولاتك المسجلة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: widget.onCreateOrder,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'إنشاء طلب نقل جديد',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
