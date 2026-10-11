import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class MerchantDrawer extends StatelessWidget {
  final String merchantName;
  final String companyName;
  final VoidCallback? onProfile;
  final VoidCallback? onCargos;
  final VoidCallback? onMap;
  final VoidCallback? onWallet;
  final VoidCallback? onSettings;
  final VoidCallback? onServicePoints;
  final VoidCallback? onSupport;
  final VoidCallback? onLogout;
  final VoidCallback? onSwitchToDriver;

  const MerchantDrawer({
    super.key,
    this.merchantName = AppStrings.merchantDefaultName,
    this.companyName = AppStrings.merchantDefaultCompany,
    this.onProfile,
    this.onCargos,
    this.onMap,
    this.onWallet,
    this.onSettings,
    this.onServicePoints,
    this.onSupport,
    this.onLogout,
    this.onSwitchToDriver,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final drawerBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.borderLight;

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Merchant Profile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: const Color(0x2EF59E0B),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primaryGold,
                      size: 24.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchantName,
                          style: GoogleFonts.cairo(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          companyName,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                          decoration: BoxDecoration(
                            color: const Color(0x2EF59E0B),
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                              color: AppColors.primaryGold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            AppStrings.verifiedMerchantAccount,
                            style: GoogleFonts.cairo(
                              fontSize: 9.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Menu Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: AppStrings.profileTitle,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      onProfile?.call();
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.inventory_2_outlined,
                    title: AppStrings.navCargos,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      onCargos?.call();
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.map_outlined,
                    title: AppStrings.merchantMapTitle,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      onMap?.call();
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: AppStrings.navWallet,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      onWallet?.call();
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.place_outlined,
                    title: AppStrings.servicePoints,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      onServicePoints?.call();
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.headset_mic_outlined,
                    title: AppStrings.customerSupport,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSupport?.call();
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: AppStrings.settingsTitle,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSettings?.call();
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.local_shipping_outlined,
                    title: 'واجهة كابتن النقل (السائق)',
                    isDark: isDark,
                    textColor: AppColors.goldDark,
                    iconColor: AppColors.goldDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      onSwitchToDriver?.call();
                    },
                  ),
                ],
              ),
            ),

            // Logout Item
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: _buildDrawerItem(
                context: context,
                icon: Icons.logout_rounded,
                title: AppStrings.logout,
                isDark: isDark,
                textColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () {
                  Navigator.of(context).pop();
                  onLogout?.call();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isDark,
    Color? textColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final finalTextColor = textColor ??
        (isDark ? AppColors.textWhite : AppColors.textMainLight);
    final finalIconColor = iconColor ??
        (isDark ? AppColors.textSubtle : AppColors.textMutedLight);

    return ListTile(
      leading: Icon(icon, color: finalIconColor, size: 21.0),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: finalTextColor,
        ),
      ),
      trailing: Icon(
        Icons.arrow_back_ios_rounded,
        size: 13.0,
        color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
      ),
      onTap: onTap,
    );
  }
}
