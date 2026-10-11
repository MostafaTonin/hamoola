import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/wallet_models.dart';

/// Screen representing Merchant Digital Wallet with balance card,
/// transactions filter, and instant balance top-up CTA.
class MerchantWalletScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onAddBalance;
  final ValueChanged<MerchantTransaction>? onTransactionTap;
  final MerchantWalletData walletData;

  const MerchantWalletScreen({
    super.key,
    this.onBack,
    this.onAddBalance,
    this.onTransactionTap,
    this.walletData = MerchantWalletData.demoWallet,
  });

  @override
  State<MerchantWalletScreen> createState() => _MerchantWalletScreenState();
}

class _MerchantWalletScreenState extends State<MerchantWalletScreen> {
  String _activeFilter = 'all'; // 'all', 'deposit', 'payment'

  List<MerchantTransaction> get _filteredTransactions {
    return widget.walletData.transactions.where((tx) {
      if (_activeFilter == 'all') return true;
      if (_activeFilter == 'deposit') {
        return tx.type == TransactionType.deposit ||
            tx.type == TransactionType.refund;
      }
      if (_activeFilter == 'payment') {
        return tx.type == TransactionType.payment;
      }
      return true;
    }).toList();
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
                  // 1. Header
                  _buildHeader(isDark),

                  // 2. Scrollable Body
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
                          // A. Top Action Button: Add Balance
                          _buildAddBalanceTopButton(),
                          const SizedBox(height: 12),

                          // B. Compact Balance Card
                          _buildCompactBalanceCard(isDark),
                          const SizedBox(height: 20),

                          // C. Filter Chips Bar
                          _buildFilterBar(isDark),
                          const SizedBox(height: 14),

                          // D. Transactions List
                          _buildTransactionsList(isDark),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
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
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            onPressed: widget.onBack,
            tooltip: AppStrings.back,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.merchantWalletTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color:
                        isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                Text(
                  AppStrings.merchantWalletSub,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color:
                        isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x2EF59E0B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 20,
              color: AppColors.primaryGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBalanceTopButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.32),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onAddBalance,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 20,
                color: Color(0xFF0F172A),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.addBalanceBtn,
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactBalanceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meta Line
                Row(
                  children: [
                    Text(
                      AppStrings.currentBalanceLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textSubtle
                            : AppColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x2EF59E0B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppStrings.currencyTagYer,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Amount Line
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      widget.walletData.balance.toInt().toString(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.currencyYer,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textSubtle
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Pending Line
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.pendingReviewLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textSubtle
                            : AppColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.walletData.pendingBalance.toInt()} ${AppStrings.currencyYerShort}',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Icon Box
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0x1AF59E0B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primaryGold,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.financialTransactionsSection,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        Row(
          children: [
            _buildFilterChip('all', AppStrings.txFilterAll, isDark),
            const SizedBox(width: 6),
            _buildFilterChip('deposit', AppStrings.txFilterDeposits, isDark),
            const SizedBox(width: 6),
            _buildFilterChip('payment', AppStrings.txFilterPayments, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label, bool isDark) {
    final isSelected = _activeFilter == key;
    return InkWell(
      onTap: () => setState(() => _activeFilter = key),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.black
                : (isDark ? AppColors.textWhite : AppColors.textMainLight),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(bool isDark) {
    final list = _filteredTransactions;

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: Text(
          AppStrings.noTransactionsFound,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
        ),
      );
    }

    return Column(
      children: list.map((tx) => _buildTransactionCard(tx, isDark)).toList(),
    );
  }

  Widget _buildTransactionCard(MerchantTransaction tx, bool isDark) {
    final isPos = tx.amount > 0;
    final formattedAmount =
        '${isPos ? '+' : '-'} ${tx.amount.abs().toInt()} ${AppStrings.currencyYerShort}';

    Color iconBg;
    Color iconColor;
    IconData icon;

    if (tx.type == TransactionType.deposit) {
      iconBg = const Color(0x1F10B981);
      iconColor = AppColors.success;
      icon = Icons.south_west_rounded;
    } else if (tx.type == TransactionType.refund) {
      iconBg = const Color(0x1F2563EB);
      iconColor = const Color(0xFF2563EB);
      icon = Icons.refresh_rounded;
    } else {
      iconBg = const Color(0x1FF59E0B);
      iconColor = AppColors.primaryGold;
      icon = Icons.local_shipping_rounded;
    }

    Color statusColor;
    if (tx.status == TransactionStatus.completed) {
      statusColor = AppColors.success;
    } else if (tx.status == TransactionStatus.pending) {
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusColor = AppColors.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onTransactionTap?.call(tx),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),

                // Details (Title & Date)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.textMainLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tx.date,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSubtle
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Amount & Status Pill
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedAmount,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isPos
                            ? AppColors.success
                            : (isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx.statusLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
