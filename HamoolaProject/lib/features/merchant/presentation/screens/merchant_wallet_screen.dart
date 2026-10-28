import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../domain/models/merchant_simulation_store.dart';
import '../../domain/models/wallet_models.dart';
import '../widgets/merchant_bottom_nav_bar.dart';

/// Redesigned unified Digital Wallet screen supporting Driver, Merchant,
/// Client, and Transport Office roles based on Hamoola design system.
class MerchantWalletScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onAddBalance;
  final VoidCallback? onWithdraw;
  final ValueChanged<MerchantTransaction>? onTransactionTap;
  final MerchantWalletData walletData;
  final AuthUserRole? userRole;

  const MerchantWalletScreen({
    super.key,
    this.onBack,
    this.onAddBalance,
    this.onWithdraw,
    this.onTransactionTap,
    this.walletData = MerchantWalletData.demoWallet,
    this.userRole,
  });

  @override
  State<MerchantWalletScreen> createState() => _MerchantWalletScreenState();
}

class _MerchantWalletScreenState extends State<MerchantWalletScreen> {
  String _activeFilter = 'all';
  bool _isBalanceHidden = false;
  MerchantNavTab _currentNavTab = MerchantNavTab.home;
  bool _isQuickActionsOpen = false;

  AuthUserRole get _effectiveRole =>
      widget.userRole ??
      AuthSimulationStore.instance.currentUser?.role ??
      AuthUserRole.merchant;

  MerchantWalletData get _effectiveData {
    if (widget.walletData != MerchantWalletData.demoWallet) {
      return widget.walletData;
    }
    final store = MerchantSimulationStore.instance;
    return MerchantWalletData(
      balance: store.getBalanceForRole(_effectiveRole),
      pendingBalance: store.getPendingBalanceForRole(_effectiveRole),
      totalWithdrawn: store.getTotalWithdrawnForRole(_effectiveRole),
      totalPaid: store.getTotalPaidForRole(_effectiveRole),
      transactions: store.getTransactionsForRole(_effectiveRole),
    );
  }

  List<MerchantTransaction> get _filteredTransactions {
    return _effectiveData.transactions.where((tx) {
      if (_activeFilter == 'all') return true;

      if (_effectiveRole == AuthUserRole.driver) {
        if (_activeFilter == 'dues') {
          return tx.type == TransactionType.payment ||
              tx.type == TransactionType.deposit ||
              tx.amount > 0;
        }
        if (_activeFilter == 'withdrawals') {
          return tx.type == TransactionType.withdrawal || tx.amount < 0;
        }
        return true;
      }

      // Merchant & Client & Office
      if (_activeFilter == 'deposit') {
        return tx.type == TransactionType.deposit;
      }
      if (_activeFilter == 'payment') {
        return tx.type == TransactionType.payment;
      }
      if (_activeFilter == 'refund') {
        return tx.type == TransactionType.refund;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = MerchantSimulationStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor:
                isDark ? AppColors.navyDark : const Color(0xFFF8FAFC),
            bottomNavigationBar: MerchantBottomNavBar(
              currentTab: _currentNavTab,
              isQuickActionsOpen: _isQuickActionsOpen,
              onTabSelected: (tab) {
                if (_isQuickActionsOpen) {
                  setState(() => _isQuickActionsOpen = false);
                }
                setState(() => _currentNavTab = tab);
                if (tab == MerchantNavTab.home) {
                  widget.onBack?.call();
                }
              },
              onFabPressed: () {
                setState(() => _isQuickActionsOpen = !_isQuickActionsOpen);
              },
            ),
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
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // A. Main Navy Gradient Balance Card
                              _buildPrimaryBalanceCard(isDark),
                              const SizedBox(height: 14),

                              // B. Action Card (Withdrawal for Driver / Add Balance for Merchant/Client)
                              _buildActionCard(isDark),
                              const SizedBox(height: 20),

                              // C. Transactions Header & Filters
                              _buildTransactionsHeaderAndFilters(isDark),
                              const SizedBox(height: 14),

                              // D. Transaction Cards List
                              _buildTransactionsList(isDark),
                              const SizedBox(height: 20),
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
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            onPressed: widget.onBack,
            tooltip: AppStrings.back,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.merchantWalletTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  AppStrings.merchantWalletSub,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 22,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PRIMARY BALANCE CARD (البطاقة الزرقاء الداكنة بتدرج لوني مطابق للصورة)
  // ===========================================================================
  Widget _buildPrimaryBalanceCard(bool isDark) {
    final isDriver = _effectiveRole == AuthUserRole.driver;
    final isOffice = _effectiveRole == AuthUserRole.office;

    final balanceLabel = (isDriver || isOffice)
        ? AppStrings.availableBalanceForWithdrawal
        : AppStrings.currentBalanceLabel;

    final balanceVal = _effectiveData.balance.toInt().toString();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF1E3A8A),
            Color(0xFF0F172A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Background subtle wallet watermark shape
            Positioned(
              left: -15,
              top: 15,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 130,
                  color: Colors.white,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Pill: Wallet Icon + Label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          balanceLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Amount Line with Eye Toggle
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Eye Toggle Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isBalanceHidden = !_isBalanceHidden;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              _isBalanceHidden
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 22,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Scaled Amount (20-25% smaller than the original 34px -> ~24px)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          _isBalanceHidden ? '••••••' : balanceVal,
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: _isBalanceHidden ? 2.0 : 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.currencyYerShort,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Subtle Divider
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 14),

                  // Bottom Two-Column Split
                  _buildBottomMetricsRow(isDriver, isOffice),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomMetricsRow(bool isDriver, bool isOffice) {
    if (isDriver) {
      // Driver metrics: Pending Dues (المستحقات المعلّقة) & Total Withdrawn (إجمالي المسحوبات)
      final pendingVal = _isBalanceHidden
          ? '••••••'
          : '${_effectiveData.pendingBalance.toInt()} ${AppStrings.currencyYerShort}';
      final withdrawnVal = _isBalanceHidden
          ? '••••••'
          : '${_effectiveData.totalWithdrawn.toInt()} ${AppStrings.currencyYerShort}';

      return Row(
        children: [
          // 1. المستحقات المعلقة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        AppStrings.pendingDuesLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    pendingVal,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          const SizedBox(width: 14),

          // 2. إجمالي المسحوبات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        AppStrings.totalWithdrawnLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    withdrawnVal,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Merchant / Client / Office metrics:
    // Pending Review (المبالغ المعلّقة) & Total Payments (إجمالي المدفوعات)
    final pendingVal = _isBalanceHidden
        ? '••••••'
        : '${_effectiveData.pendingBalance.toInt()} ${AppStrings.currencyYerShort}';
    final paymentsVal = _isBalanceHidden
        ? '••••••'
        : '${(isOffice ? _effectiveData.totalWithdrawn : _effectiveData.totalPaid).toInt()} ${AppStrings.currencyYerShort}';
    final secondLabel = isOffice
        ? AppStrings.totalWithdrawnLabel
        : AppStrings.totalPaymentsLabel;

    return Row(
      children: [
        // 1. المبالغ المعلقة
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      AppStrings.pendingReviewLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  pendingVal,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 28,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        const SizedBox(width: 14),

        // 2. إجمالي المدفوعات / المسحوبات
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isOffice
                        ? Icons.file_upload_outlined
                        : Icons.payment_rounded,
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      secondLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  paymentsVal,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // ACTION CARD (سحب الرصيد للسائق / إضافة رصيد للتاجر والعميل)
  // ===========================================================================
  Widget _buildActionCard(bool isDark) {
    if (_effectiveRole == AuthUserRole.driver) {
      // Driver: ONLY Withdrawal Card (Green, matches screenshot)
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.25) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFBBF7D0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onWithdraw ?? () => _showDriverWithdrawalSheet(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Green icon box
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: Color(0xFF16A34A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.withdrawBalanceBtn,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          AppStrings.withdrawBalanceSub,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Left Chevron
                  const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFF16A34A),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Merchant / Client / Office: "إضافة رصيد"
    final addBalanceCard = Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onAddBalance,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Blue icon box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFF1D4ED8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.addBalanceBtn,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        AppStrings.addBalanceSub,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Left Chevron
                const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF1D4ED8),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // If Transport Office, also retain "طلب سحب أرباح المكتب" (Criteria 10)
    if (_effectiveRole == AuthUserRole.office) {
      return Column(
        children: [
          addBalanceCard,
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF9333EA),
                width: 1.2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onWithdraw ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'طلب سحب أرباح مكتب النقل قيد المراجعة المصرفية',
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: const Color(0xFF9333EA),
                        ),
                      );
                    },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_rounded,
                        size: 18,
                        color: Color(0xFF9333EA),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'طلب سحب أرباح المكتب',
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF9333EA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return addBalanceCard;
  }

  // ===========================================================================
  // TRANSACTIONS HEADER & FILTER CHIPS (الحركات المالية والفلاتر)
  // ===========================================================================
  Widget _buildTransactionsHeaderAndFilters(bool isDark) {
    final isDriver = _effectiveRole == AuthUserRole.driver;

    final chips = isDriver
        ? [
            {'key': 'all', 'label': AppStrings.txFilterAll},
            {'key': 'dues', 'label': AppStrings.txFilterDues},
            {'key': 'withdrawals', 'label': AppStrings.txFilterWithdrawals},
          ]
        : [
            {'key': 'all', 'label': AppStrings.txFilterAll},
            {'key': 'deposit', 'label': AppStrings.txFilterDeposits},
            {'key': 'payment', 'label': AppStrings.txFilterPayments},
            {'key': 'refund', 'label': AppStrings.txFilterRefunds},
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.financialTransactionsSection,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: chips.map((c) {
              final isSelected = _activeFilter == c['key'];
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: () => setState(() => _activeFilter = c['key']!),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1D4ED8)
                          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1D4ED8)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Text(
                      c['label']!,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.textWhite
                                : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TRANSACTIONS LIST (بطاقات الحركات المستقلة المطابقة للصورة)
  // ===========================================================================
  Widget _buildTransactionsList(bool isDark) {
    final list = _filteredTransactions;

    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderLight,
          ),
        ),
        child: Text(
          AppStrings.noTransactionsFound,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
          textAlign: TextAlign.center,
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

    final isWithdrawal = tx.type == TransactionType.withdrawal;

    if (isWithdrawal) {
      iconBg = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFD97706);
      icon = Icons.account_balance_rounded;
    } else if (tx.type == TransactionType.deposit) {
      iconBg = const Color(0xFFDCFCE7);
      iconColor = const Color(0xFF16A34A);
      icon = Icons.south_west_rounded;
    } else if (tx.type == TransactionType.refund) {
      iconBg = const Color(0xFFDBEAFE);
      iconColor = const Color(0xFF2563EB);
      icon = Icons.refresh_rounded;
    } else {
      // Trip due / payment
      iconBg = const Color(0xFFDCFCE7);
      iconColor = const Color(0xFF16A34A);
      icon = Icons.local_shipping_rounded;
    }

    Color statusBg;
    Color statusTextColor;
    if (tx.status == TransactionStatus.completed) {
      statusBg = const Color(0xFFDCFCE7);
      statusTextColor = const Color(0xFF16A34A);
    } else if (tx.status == TransactionStatus.pending) {
      statusBg = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFD97706);
    } else {
      statusBg = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onTransactionTap?.call(tx);
            if (widget.onTransactionTap == null) {
              _showTransactionDetailsSheet(context, tx);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),

                // Details (Title & Ref / Date)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textWhite
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tx.ref} • ${tx.date}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textSubtle
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

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
                            ? const Color(0xFF16A34A)
                            : (isDark
                                ? AppColors.textWhite
                                : const Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 100),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx.statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),

                // Left Arrow
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // INTERACTIVE WITHDRAWAL REQUEST SHEET FOR DRIVER (طلب سحب الرصيد)
  // ===========================================================================
  void _showDriverWithdrawalSheet(BuildContext context) {
    final available = _effectiveData.balance;
    final amountController = TextEditingController(
      text: available > 0 ? (available >= 5000 ? '5000' : available.toInt().toString()) : '0',
    );
    String selectedBank = 'بنك الكريمي للتمويل الأصغر الإسلامي';
    String selectedAccount = '300458112';

    final accounts = [
      {
        'bank': 'بنك الكريمي للتمويل الأصغر الإسلامي',
        'account': '300458112',
        'icon': Icons.credit_card_rounded,
      },
      {
        'bank': 'البنك الأهلي اليمني',
        'account': '10892344',
        'icon': Icons.account_balance_rounded,
      },
      {
        'bank': 'محفظة ون كاش',
        'account': '770123456',
        'icon': Icons.phone_android_rounded,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'طلب سحب المستحقات المالية',
                              style: GoogleFonts.cairo(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Balance banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'الرصيد المتاح للسحب:',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF166534),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${available.toInt()} ${AppStrings.currencyYerShort}',
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bank selector label
                      Text(
                        'الحساب البنكي / المحفظة المعتمدة',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Bank accounts list
                      ...accounts.map((acc) {
                        final isSelected = selectedAccount == acc['account'];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF0FDF4)
                                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF16A34A)
                                  : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedBank = acc['bank'] as String;
                                selectedAccount = acc['account'] as String;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Icon(
                                    acc['icon'] as IconData,
                                    color: isSelected ? const Color(0xFF16A34A) : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          acc['bank'] as String,
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          'رقم الحساب: ${acc['account']}',
                                          style: GoogleFonts.ibmPlexSansArabic(
                                            fontSize: 11,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF16A34A),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),

                      // Amount input
                      Text(
                        'المبلغ المطلوب سحبه',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: InputDecoration(
                          suffixText: AppStrings.currencyYerShort,
                          suffixStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          hintText: 'أدخل المبلغ',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Quick Amount Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [5000, 10000, 20000].map((amt) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: ActionChip(
                                label: Text(
                                  '${amt ~/ 1000}k',
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    amountController.text = amt.toString();
                                  });
                                },
                                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }).toList()
                            ..add(
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: ActionChip(
                                  label: Text(
                                    'كامل الرصيد',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      amountController.text = available.toInt().toString();
                                    });
                                  },
                                  backgroundColor: const Color(0xFFDCFCE7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Notice
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'يتم إيداع الحوالة المصرفية في حسابك المعتمد خلال 24 ساعة عمل بدون رسوم تحويل.',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.5,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Confirm Submit Button
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final parsed = double.tryParse(amountController.text.trim()) ?? 0.0;
                            if (parsed <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('يرجى إدخال مبلغ صحيح للسحب', style: GoogleFonts.cairo()),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }
                            if (parsed > available) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('المبلغ المطلوب يتجاوز الرصيد المتاح للسحب', style: GoogleFonts.cairo()),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            Navigator.pop(ctx);
                            MerchantSimulationStore.instance.requestDriverWithdrawal(
                              amount: parsed,
                              bankName: selectedBank,
                              accountNumber: selectedAccount,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم تقديم طلب سحب ${parsed.toInt()} ر.ي بنجاح وهو قيد المعالجة',
                                  style: GoogleFonts.cairo(),
                                ),
                                backgroundColor: const Color(0xFF16A34A),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'تأكيد إرسال طلب السحب',
                            style: GoogleFonts.cairo(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // TRANSACTION DETAILS BOTTOM SHEET (تفاصيل الحركة المالية عند الضغط عليها)
  // ===========================================================================
  void _showTransactionDetailsSheet(BuildContext context, MerchantTransaction tx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPos = tx.amount > 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title & ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tx.title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tx.id,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Amount
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مبلغ العملية:',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${isPos ? '+' : '-'} ${tx.amount.abs().toInt()} ${AppStrings.currencyYerShort}',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: isPos ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Meta table
                _buildReceiptRow('الحالة:', tx.statusLabel, isDark),
                _buildReceiptRow('المرجع / الرقم:', tx.ref, isDark),
                _buildReceiptRow('التاريخ والوقت:', tx.date, isDark),
                _buildReceiptRow('الوسيلة / الحساب:', tx.wallet, isDark),
                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إغلاق',
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
