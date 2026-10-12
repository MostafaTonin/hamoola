import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

enum MerchantNavTab {
  home,
  orders,
  map,
  wallet,
  account,
}

class MerchantBottomNavBar extends StatelessWidget {
  final MerchantNavTab currentTab;
  final ValueChanged<MerchantNavTab> onTabSelected;
  final VoidCallback onFabPressed;
  final bool showMapTab;

  const MerchantBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.onFabPressed,
    this.showMapTab = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final barBg = isDark
        ? const Color(0xF20F172A)
        : Colors.white.withValues(alpha: 0.96);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: barBg,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home Tab
              _buildNavItem(
                context: context,
                tab: MerchantNavTab.home,
                icon: Icons.home_rounded,
                label: AppStrings.navHome,
                isDark: isDark,
              ),

              // 2. Orders Tab
              _buildNavItem(
                context: context,
                tab: MerchantNavTab.orders,
                icon: Icons.receipt_long_rounded,
                label: AppStrings.navOrders,
                isDark: isDark,
              ),

              // 3. Center FAB Slot
              _buildCenterFab(isDark),

              // 4. Map or Wallet Tab
              showMapTab
                  ? _buildNavItem(
                      context: context,
                      tab: MerchantNavTab.map,
                      icon: Icons.map_outlined,
                      label: 'الخريطة',
                      isDark: isDark,
                    )
                  : _buildNavItem(
                      context: context,
                      tab: MerchantNavTab.wallet,
                      icon: Icons.account_balance_wallet_rounded,
                      label: AppStrings.navWallet,
                      isDark: isDark,
                    ),

              // 5. Account Tab
              _buildNavItem(
                context: context,
                tab: MerchantNavTab.account,
                icon: Icons.person_rounded,
                label: AppStrings.navAccount,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required MerchantNavTab tab,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isActive = currentTab == tab;
    final color = isActive
        ? AppColors.primaryGold
        : (isDark ? AppColors.textSubtle : AppColors.textMutedLight);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTabSelected(tab),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.translationValues(0, isActive ? -2 : 0, 0),
                child: Icon(icon, size: 21.0, color: color),
              ),
              const SizedBox(height: 3.0),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 10.0,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFab(bool isDark) {
    return Container(
      width: 54.0,
      alignment: Alignment.center,
      child: Container(
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.45),
              blurRadius: 10.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onFabPressed,
            customBorder: const CircleBorder(),
            child: const Center(
              child: Icon(
                Icons.add_rounded,
                size: 26.0,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
