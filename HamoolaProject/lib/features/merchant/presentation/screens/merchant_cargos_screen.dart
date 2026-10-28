import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/cargo_card_item.dart';
import '../../domain/models/merchant_simulation_store.dart';
import '../widgets/merchant_bottom_nav_bar.dart';
import '../widgets/merchant_cargo_card_widget.dart';
import '../widgets/merchant_cargo_details_dialog.dart';
import 'merchant_create_cargo_screen.dart';

enum CargoSortOption {
  newestFirst,
  oldestFirst,
  highestWeight,
}

/// Screen representing Merchant Cargos Management Hub (حمولاتي).
/// Features real-time reactive listing, status-based filters, dynamic counters,
/// sorting options, and direct modal details inspection via MerchantCargoDetailsDialog.
class MerchantCargosScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onAddCargo;
  final ValueChanged<CargoCardItem>? onCargoSelected;
  final ValueChanged<CargoCardItem>? onViewCargoDetails;
  final VoidCallback? onHome;
  final VoidCallback? onWallet;
  final VoidCallback? onAccount;

  const MerchantCargosScreen({
    super.key,
    this.onBack,
    this.onAddCargo,
    this.onCargoSelected,
    this.onViewCargoDetails,
    this.onHome,
    this.onWallet,
    this.onAccount,
  });

  @override
  State<MerchantCargosScreen> createState() => _MerchantCargosScreenState();
}

class _MerchantCargosScreenState extends State<MerchantCargosScreen> {
  MerchantNavTab _currentTab = MerchantNavTab.orders;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'الكل';
  CargoSortOption _selectedSort = CargoSortOption.newestFirst;

  static const List<String> _statusFilters = [
    'الكل',
    'متاحة للاستخدام',
    'مرتبطة بطلب نشط',
    'مكتملة الاستخدام',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelected(MerchantNavTab tab) {
    setState(() => _currentTab = tab);
    if (tab == MerchantNavTab.home) {
      widget.onHome?.call();
    } else if (tab == MerchantNavTab.wallet) {
      widget.onWallet?.call();
    } else if (tab == MerchantNavTab.account) {
      widget.onAccount?.call();
    }
  }

  void _openCargoDetails(CargoCardItem cargo) {
    if (widget.onViewCargoDetails != null) {
      widget.onViewCargoDetails!(cargo);
    } else {
      MerchantCargoDetailsDialog.show(
        context,
        cargo,
        onCargoUpdated: () => setState(() {}),
        onCargoDeleted: () => setState(() {}),
      );
    }
  }

  void _openAddCargoFlow() {
    if (widget.onAddCargo != null) {
      widget.onAddCargo!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MerchantCreateCargoScreen(
            onBack: () => Navigator.of(context).pop(),
            onSubmitCargo: (newCargo) {
              MerchantSimulationStore.instance.addCargo(newCargo);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تمت إضافة الحمولة "${newCargo.name}" بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ),
      );
    }
  }

  double _extractWeightNumber(String weightStr) {
    final clean = weightStr.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = MerchantSimulationStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final allCargos = store.cargos;
        final query = _searchController.text.trim().toLowerCase();

        // 1. Filter by Status & Search Query
        final filteredCargos = allCargos.where((c) {
          bool matchesStatus = true;
          if (_selectedStatusFilter == 'متاحة للاستخدام') {
            matchesStatus = c.status == 'متاحة للاستخدام' ||
                c.status == 'جاهزة للنقل' ||
                (!c.hasActiveOrder &&
                    c.status != 'مكتملة' &&
                    c.status != 'مكتملة الاستخدام');
          } else if (_selectedStatusFilter == 'مرتبطة بطلب نشط') {
            matchesStatus = c.status == 'مرتبطة بطلب نشط' ||
                c.hasActiveOrder ||
                c.status == 'قيد النقل';
          } else if (_selectedStatusFilter == 'مكتملة الاستخدام') {
            matchesStatus =
                c.status == 'مكتملة' || c.status == 'مكتملة الاستخدام';
          }

          final matchesQuery = query.isEmpty ||
              c.name.toLowerCase().contains(query) ||
              c.id.toLowerCase().contains(query) ||
              c.category.toLowerCase().contains(query) ||
              (c.subCategory?.toLowerCase().contains(query) ?? false);

          return matchesStatus && matchesQuery;
        }).toList();

        // 2. Sort Cargos
        switch (_selectedSort) {
          case CargoSortOption.newestFirst:
            // Keep default registered order (newest first in store)
            break;
          case CargoSortOption.oldestFirst:
            filteredCargos.sort((a, b) => b.id.compareTo(a.id));
            break;
          case CargoSortOption.highestWeight:
            filteredCargos.sort((a, b) => _extractWeightNumber(b.weight)
                .compareTo(_extractWeightNumber(a.weight)));
            break;
        }

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
                      // 1. Screen Header
                      _buildHeader(isDark),

                      // 2. Search Field
                      _buildSearchField(isDark),

                      // 3. Status Filter Chips
                      _buildFilterChips(isDark),

                      // 4. Subheader (Sort Option & Dynamic Registered Count)
                      _buildSortAndCounterBar(isDark, filteredCargos.length),

                      // 5. Scrollable Cargos List
                      Expanded(
                        child: filteredCargos.isEmpty
                            ? _buildEmptyState(isDark)
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spaceMd,
                                  vertical: AppDimensions.spaceSm,
                                ),
                                itemCount: filteredCargos.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12.0),
                                itemBuilder: (context, index) {
                                  final item = filteredCargos[index];
                                  return MerchantCargoCardWidget(
                                    cargo: item,
                                    onTap: () {
                                      if (widget.onCargoSelected != null) {
                                        widget.onCargoSelected?.call(item);
                                      } else {
                                        _openCargoDetails(item);
                                      }
                                    },
                                  );
                                },
                              ),
                      ),

                      // 6. Merchant Bottom Navigation Bar
                      MerchantBottomNavBar(
                        currentTab: _currentTab,
                        onTabSelected: _handleTabSelected,
                        onFabPressed: _openAddCargoFlow,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right (RTL): Back Button + Titles
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20.0),
                color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                onPressed: widget.onBack,
                tooltip: AppStrings.back,
              ),
              const SizedBox(width: 4.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.myCargos,
                    style: GoogleFonts.cairo(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                  ),
                  Text(
                    'إدارة الحمولات المسجلة لديك',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: isDark
                          ? AppColors.textSubtle
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Left (RTL): Add Cargo Button
          InkWell(
            onTap: _openAddCargoFlow,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: isDark
                      ? AppColors.primaryGold
                      : const Color(0xFF334155),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 17.0,
                    color: AppColors.primaryGold,
                  ),
                  const SizedBox(width: 5.0),
                  Text(
                    AppStrings.addCargo,
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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

  Widget _buildSearchField(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 6.0),
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Container(
        height: 42.0,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: TextField(
          key: const ValueKey('cargos_search_field'),
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
          decoration: InputDecoration(
            hintText: 'البحث في الحمولات...',
            hintStyle: GoogleFonts.cairo(
              fontSize: 12.0,
              color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20.0,
              color: AppColors.primaryGold,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16.0),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 9.0),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 8.0),
      child: SizedBox(
        height: 32.0,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _statusFilters.length,
          separatorBuilder: (context, index) => const SizedBox(width: 6.0),
          itemBuilder: (context, index) {
            final filter = _statusFilters[index];
            final isSelected = _selectedStatusFilter == filter;

            return InkWell(
              key: ValueKey('filter_chip_$filter'),
              onTap: () => setState(() => _selectedStatusFilter = filter),
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF0F172A))
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0)),
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? (isDark ? AppColors.primaryGold : Colors.white)
                          : (isDark
                              ? AppColors.textWhite
                              : AppColors.textMainLight),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSortAndCounterBar(bool isDark, int count) {
    String sortLabel;
    switch (_selectedSort) {
      case CargoSortOption.newestFirst:
        sortLabel = 'الأحدث أولاً';
        break;
      case CargoSortOption.oldestFirst:
        sortLabel = 'الأقدم أولاً';
        break;
      case CargoSortOption.highestWeight:
        sortLabel = 'الأعلى وزناً';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : AppColors.backgroundLight,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dynamic Registered Count (Right in RTL)
          Text(
            '$count حمولة مسجلة',
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),

          // Sort Dropdown Button (Left in RTL)
          PopupMenuButton<CargoSortOption>(
            initialValue: _selectedSort,
            onSelected: (val) => setState(() => _selectedSort = val),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: CargoSortOption.newestFirst,
                child: Text('الأحدث أولاً', style: GoogleFonts.cairo(fontSize: 12.0)),
              ),
              PopupMenuItem(
                value: CargoSortOption.oldestFirst,
                child: Text('الأقدم أولاً', style: GoogleFonts.cairo(fontSize: 12.0)),
              ),
              PopupMenuItem(
                value: CargoSortOption.highestWeight,
                child: Text('الأعلى وزناً', style: GoogleFonts.cairo(fontSize: 12.0)),
              ),
            ],
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.5),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.swap_vert_rounded,
                    size: 15.0,
                    color: AppColors.primaryGold,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    sortLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textWhite
                          : AppColors.textMainLight,
                    ),
                  ),
                  const SizedBox(width: 2.0),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 15.0,
                    color: AppColors.textSubtle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                color: const Color(0x1FF59E0B),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGold,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primaryGold,
                size: 28.0,
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              AppStrings.noCargosTitle,
              style: GoogleFonts.cairo(
                fontSize: 15.0,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              AppStrings.noCargosDesc,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12.0,
                color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 18.0),
            ElevatedButton.icon(
              onPressed: _openAddCargoFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 10.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18.0),
              label: Text(
                AppStrings.addCargo,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
