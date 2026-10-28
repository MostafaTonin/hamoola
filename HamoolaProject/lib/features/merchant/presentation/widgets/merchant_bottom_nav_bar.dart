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
  final bool isQuickActionsOpen;

  const MerchantBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.onFabPressed,
    this.showMapTab = true,
    this.isQuickActionsOpen = false,
  });

  static const Color activeColor = Color(0xFFE11D48); // Brand Red matching Image 3 & 4

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final barBg = isDark
        ? const Color(0xF20F172A)
        : Colors.white.withValues(alpha: 0.98);

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
          height: 62.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. الرئيسية (Rightmost in RTL)
              _buildNavItem(
                context: context,
                tab: MerchantNavTab.home,
                icon: Icons.home_rounded,
                label: AppStrings.navHome,
                isDark: isDark,
              ),

              // 2. الخريطة (Map)
              _buildNavItem(
                context: context,
                tab: MerchantNavTab.map,
                icon: Icons.location_on_outlined,
                label: 'الخريطة',
                isDark: isDark,
              ),

              // 3. Center FAB Slot (+) or (X)
              _buildCenterFab(isDark),

              // 4. طلباتي (Orders)
              _buildNavItem(
                context: context,
                tab: MerchantNavTab.orders,
                icon: Icons.assignment_outlined,
                label: AppStrings.navOrders,
                isDark: isDark,
              ),

              // 5. حسابي (Account - Leftmost in RTL)
              _buildNavItem(
                context: context,
                tab: MerchantNavTab.account,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
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
    IconData? activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isActive = currentTab == tab;
    final color = isActive
        ? activeColor
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
                child: Icon(
                  isActive && activeIcon != null ? activeIcon : icon,
                  size: 22.0,
                  color: color,
                ),
              ),
              const SizedBox(height: 3.0),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
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
      width: 56.0,
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 46.0,
        height: 46.0,
        decoration: BoxDecoration(
          color: isQuickActionsOpen
              ? const Color(0xFF1E293B)
              : null,
          gradient: isQuickActionsOpen
              ? null
              : const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          shape: BoxShape.circle,
          border: isQuickActionsOpen
              ? Border.all(color: const Color(0xFF475569), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: isQuickActionsOpen
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color(0xFFEF4444).withValues(alpha: 0.4),
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
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isQuickActionsOpen
                      ? Icons.close_rounded
                      : Icons.add_rounded,
                  key: ValueKey<bool>(isQuickActionsOpen),
                  size: 26.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
