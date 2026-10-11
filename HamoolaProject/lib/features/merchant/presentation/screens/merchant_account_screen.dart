import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../widgets/merchant_bottom_nav_bar.dart';

/// Screen representing Merchant Account Hub with profile verification,
/// stats, wallet shortcuts, settings, support, and bottom nav.
class MerchantAccountScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final VoidCallback? onOrders;
  final VoidCallback? onMap;
  final VoidCallback? onWallet;
  final VoidCallback? onVerification;
  final VoidCallback? onSettings;
  final VoidCallback? onSupport;
  final VoidCallback? onTerms;
  final VoidCallback? onLogout;
  final VoidCallback? onFab;

  final String userName;
  final String organizationName;
  final String phoneNumber;
  final int completedTrips;
  final double rating;
  final int commitmentPercent;
  final double walletBalance;

  const MerchantAccountScreen({
    super.key,
    this.onBack,
    this.onHome,
    this.onOrders,
    this.onMap,
    this.onWallet,
    this.onVerification,
    this.onSettings,
    this.onSupport,
    this.onTerms,
    this.onLogout,
    this.onFab,
    this.userName = 'محمد أحمد',
    this.organizationName = 'مؤسسة الأمل التجارية',
    this.phoneNumber = '+967 777 123 456',
    this.completedTrips = 24,
    this.rating = 4.9,
    this.commitmentPercent = 98,
    this.walletBalance = 2000.0,
  });

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
                  // 1. Header
                  _buildHeader(isDark),

                  // 2. Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceMd,
                        vertical: AppDimensions.spaceSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // A. Profile Card & Stats
                          _buildProfileCard(isDark),
                          const SizedBox(height: 18),

                          // B. Financial & Verification Group
                          _buildMenuGroup(
                            title: AppStrings.financeAndVerifyGroup,
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.account_balance_wallet_outlined,
                                iconColor: const Color(0xFFB45309),
                                iconBg: const Color(0x26B45309),
                                title: AppStrings.myWalletMenuTitle,
                                subtitle:
                                    '${AppStrings.walletAvailableBalanceSub} ${walletBalance.toInt()} ${AppStrings.currencyYer}',
                                isDark: isDark,
                                onTap: onWallet,
                                isSubtitleHighlighted: true,
                              ),
                              _buildMenuItem(
                                icon: Icons.verified_user_outlined,
                                iconColor: const Color(0xFF2563EB),
                                iconBg: const Color(0x262563EB),
                                title: AppStrings.companyVerifyMenuTitle,
                                subtitle: AppStrings.companyVerifyMenuSub,
                                badgeText: AppStrings.verificationCompleteBadge,
                                badgeColor: AppColors.success,
                                isDark: isDark,
                                onTap: onVerification,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // C. Settings & Help Group
                          _buildMenuGroup(
                            title: AppStrings.settingsAndHelpGroup,
                            isDark: isDark,
                            children: [
                              _buildMenuItem(
                                icon: Icons.tune_rounded,
                                iconColor: const Color(0xFF475569),
                                iconBg: const Color(0x26475569),
                                title: AppStrings.generalSettingsMenuTitle,
                                subtitle: AppStrings.generalSettingsMenuSub,
                                isDark: isDark,
                                onTap: onSettings,
                              ),
                              _buildMenuItem(
                                icon: Icons.support_agent_rounded,
                                iconColor: const Color(0xFF059669),
                                iconBg: const Color(0x26059669),
                                title: AppStrings.customerSupportMenuTitle,
                                subtitle: AppStrings.customerSupportMenuSub,
                                isDark: isDark,
                                onTap: onSupport,
                              ),
                              _buildMenuItem(
                                icon: Icons.description_outlined,
                                iconColor: const Color(0xFF64748B),
                                iconBg: const Color(0x2664748B),
                                title: AppStrings.termsAndPrivacyMenuTitle,
                                subtitle: AppStrings.termsAndPrivacyMenuSub,
                                isDark: isDark,
                                onTap: onTerms,
                              ),
                              _buildMenuItem(
                                icon: Icons.logout_rounded,
                                iconColor: AppColors.error,
                                iconBg: const Color(0x26DC2626),
                                title: AppStrings.logoutMenuTitle,
                                subtitle: AppStrings.logoutMenuSub,
                                isDark: isDark,
                                onTap: onLogout,
                                isDestructive: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // 3. Bottom Navigation Bar
                  MerchantBottomNavBar(
                    currentTab: MerchantNavTab.account,
                    onTabSelected: (tab) {
                      if (tab == MerchantNavTab.home) {
                        onHome?.call();
                      } else if (tab == MerchantNavTab.orders) {
                        onOrders?.call();
                      } else if (tab == MerchantNavTab.wallet) {
                        onWallet?.call();
                      }
                    },
                    onFabPressed: onFab ?? () {},
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            onPressed: onBack,
            tooltip: AppStrings.back,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.merchantAccountTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balancing back button
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Identity Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0x2EF59E0B),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryGold,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),

                // Info Group
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    AppColors.success.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 13,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  AppStrings.merchantVerifiedBadge,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        organizationName,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSubtle
                              : AppColors.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        phoneNumber,
                        textDirection: TextDirection.ltr,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderLight,
          ),

          // Bottom Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCol(
                    number: '$completedTrips',
                    label: AppStrings.completedTripsStatLabel,
                    isDark: isDark,
                  ),
                ),
                _buildStatDivider(isDark),
                Expanded(
                  child: _buildStatCol(
                    number: '$rating ★',
                    label: AppStrings.ratingStatLabel,
                    isDark: isDark,
                    numberColor: AppColors.primaryGold,
                  ),
                ),
                _buildStatDivider(isDark),
                Expanded(
                  child: _buildStatCol(
                    number: '$commitmentPercent%',
                    label: AppStrings.commitmentStatLabel,
                    isDark: isDark,
                    numberColor: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol({
    required String number,
    required String label,
    required bool isDark,
    Color? numberColor,
  }) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: numberColor ??
                (isDark ? AppColors.textWhite : AppColors.textMainLight),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 28,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.borderLight,
    );
  }

  Widget _buildMenuGroup({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              final isLast = index == children.length - 1;
              return Column(
                children: [
                  children[index],
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 14,
                      endIndent: 14,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppColors.borderLight,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool isDark,
    VoidCallback? onTap,
    String? badgeText,
    Color? badgeColor,
    bool isSubtitleHighlighted = false,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Icon Box
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDestructive
                            ? AppColors.error
                            : (isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isSubtitleHighlighted
                            ? AppColors.primaryGold
                            : (isDark
                                ? AppColors.textSubtle
                                : AppColors.textMutedLight),
                        fontWeight: isSubtitleHighlighted
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge or Chevron
              if (badgeText != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppColors.success)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: badgeColor ?? AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.arrow_back_ios_rounded,
                size: 14,
                color: isDestructive
                    ? AppColors.error.withValues(alpha: 0.6)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.25)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
