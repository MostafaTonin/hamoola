import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/cargo_card_item.dart';
import '../widgets/merchant_bottom_nav_bar.dart';
import '../widgets/merchant_cargo_card_widget.dart';

class MerchantCargosScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onAddCargo;
  final ValueChanged<CargoCardItem>? onCargoSelected;
  final VoidCallback? onHome;
  final VoidCallback? onWallet;
  final VoidCallback? onAccount;

  const MerchantCargosScreen({
    super.key,
    this.onBack,
    this.onAddCargo,
    this.onCargoSelected,
    this.onHome,
    this.onWallet,
    this.onAccount,
  });

  @override
  State<MerchantCargosScreen> createState() => _MerchantCargosScreenState();
}

class _MerchantCargosScreenState extends State<MerchantCargosScreen> {
  final List<CargoCardItem> _cargos = CargoCardItem.demoCargos;
  MerchantNavTab _currentTab = MerchantNavTab.orders;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  // 1. Cargos Screen Header
                  _buildHeader(isDark),

                  // 2. Scrollable Cards List
                  Expanded(
                    child: _cargos.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spaceMd,
                              vertical: AppDimensions.spaceSm,
                            ),
                            itemCount: _cargos.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12.0),
                            itemBuilder: (context, index) {
                              final item = _cargos[index];
                              return MerchantCargoCardWidget(
                                cargo: item,
                                onTap: () => widget.onCargoSelected?.call(item),
                              );
                            },
                          ),
                  ),

                  // 3. Merchant Bottom Nav Bar
                  MerchantBottomNavBar(
                    currentTab: _currentTab,
                    onTabSelected: _handleTabSelected,
                    onFabPressed: () => widget.onAddCargo?.call(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20.0),
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            onPressed: widget.onBack,
            tooltip: AppStrings.back,
          ),

          // Title
          Text(
            AppStrings.myCargos,
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),

          // Add Cargo Button in Header
          InkWell(
            onTap: widget.onAddCargo,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: const Color(0x24F59E0B),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: AppColors.primaryGold,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 16.0,
                    color: AppColors.primaryGold,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    AppStrings.addCargo,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGold,
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
              onPressed: widget.onAddCargo,
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
