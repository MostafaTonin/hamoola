import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../domain/models/merchant_simulation_store.dart';

/// Screen representing the unified Withdrawal (سحب الرصيد)
/// for Driver and Transport Office roles in the Hamoola Platform.
/// Matches the reference 5-state visual specification in layout and behavior,
/// styled with Hamoola's signature White & Royal Blue design system.
class WalletWithdrawBalanceScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<Map<String, dynamic>>? onSubmitWithdrawal;
  final VoidCallback? onSuccessDone;
  final AuthUserRole? userRole;
  final String? initialAmount;

  const WalletWithdrawBalanceScreen({
    super.key,
    this.onBack,
    this.onSubmitWithdrawal,
    this.onSuccessDone,
    this.userRole,
    this.initialAmount,
  });

  @override
  State<WalletWithdrawBalanceScreen> createState() =>
      _WalletWithdrawBalanceScreenState();
}

/// Convenience alias for clarity across non-merchant features
typedef WithdrawBalanceScreen = WalletWithdrawBalanceScreen;

class _WalletWithdrawBalanceScreenState
    extends State<WalletWithdrawBalanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _posPointController = TextEditingController();
  final _posCommercialNameController = TextEditingController();

  bool _isBalanceHidden = false;
  String _selectedMethod = 'subscriber'; // 'subscriber' or 'pos'
  bool _isMethodModalOpen = false;
  bool _isSuccessModalVisible = false;
  Map<String, dynamic>? _lastSubmittedData;

  AuthUserRole get _effectiveRole =>
      widget.userRole ??
      AuthSimulationStore.instance.currentUser?.role ??
      AuthUserRole.driver;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount!.isNotEmpty) {
      _amountController.text = widget.initialAmount!;
    }
    _amountController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _posPointController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _posPointController.removeListener(_onFieldChanged);
    _amountController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    _posPointController.dispose();
    _posCommercialNameController.dispose();
    super.dispose();
  }

  double? get _parsedAmount {
    final clean = _amountController.text.replaceAll(',', '').trim();
    return double.tryParse(clean);
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  void _selectMaxAmount(double maxBalance) {
    setState(() {
      _amountController.text = maxBalance.toInt().toString();
    });
  }

  void _switchMethod(String method) {
    setState(() {
      _selectedMethod = method;
      _isMethodModalOpen = false;
    });
  }

  void _handleSubmit(double availableBalance) {
    if (!_formKey.currentState!.validate()) return;

    final amountNum = _parsedAmount ?? 0.0;
    if (amountNum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إدخال مبلغ صالح أكبر من 0',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (amountNum > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'المبلغ المطلوب يتجاوز الرصيد المتاح للسحب (${availableBalance.toInt()} ${AppStrings.currencyYerShort})',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    final isSubscriber = _selectedMethod == 'subscriber';
    final recipientId = isSubscriber
        ? _phoneController.text.trim()
        : _posPointController.text.trim();
    final recipientName = isSubscriber
        ? _fullNameController.text.trim()
        : _posCommercialNameController.text.trim();

    // Register withdrawal request in simulation store
    final refNum = MerchantSimulationStore.instance.requestWithdrawalForRole(
      role: _effectiveRole,
      amount: amountNum,
      methodType: _selectedMethod,
      recipientIdentifier: recipientId,
      recipientName: recipientName,
    );

    final withdrawalData = {
      'amount': amountNum.toString(),
      'method': _selectedMethod,
      'methodLabel': isSubscriber
          ? AppStrings.withdrawMethodSubscriberTitle
          : AppStrings.withdrawMethodPosTitle,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'role': _effectiveRole.name,
      'ref': refNum ?? 'WD-9999',
      'date': 'الآن',
      'status': 'قيد المراجعة',
    };

    widget.onSubmitWithdrawal?.call(withdrawalData);

    setState(() {
      _lastSubmittedData = withdrawalData;
      _isSuccessModalVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Role Guard: Only Driver and Transport Office have access to withdrawal
    if (_effectiveRole != AuthUserRole.driver &&
        _effectiveRole != AuthUserRole.office) {
      return _buildRestrictedView(isDark);
    }

    return ListenableBuilder(
      listenable: MerchantSimulationStore.instance,
      builder: (context, _) {
        final store = MerchantSimulationStore.instance;
        final availableBalance = store.getBalanceForRole(_effectiveRole);
        final pendingDues = store.getPendingBalanceForRole(_effectiveRole);

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
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // 1. Header (Back button, Title & Subtitle, Wallet Badge)
                          _buildHeader(isDark),

                          // 2. Scrollable Body
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spaceMd,
                                vertical: AppDimensions.spaceSm,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // A. Balance Card (Available & Pending Dues)
                                    _buildBalanceCard(
                                      availableBalance: availableBalance,
                                      pendingDues: pendingDues,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 18),

                                    // B. Amount Section with 4 Quick Options
                                    _buildAmountSection(
                                      availableBalance: availableBalance,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 18),

                                    // C. Withdrawal Method Selector
                                    _buildMethodSelector(isDark),
                                    const SizedBox(height: 18),

                                    // D. Recipient Details Form
                                    _buildRecipientDetails(isDark),
                                    const SizedBox(height: 24),

                                    // E. Submit Button
                                    _buildSubmitButton(availableBalance),
                                    const SizedBox(height: 28),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Method Picker Modal Overlay (Mockup 2 & Bottom Inset)
                      if (_isMethodModalOpen)
                        _buildMethodPickerModal(isDark),

                      // Success / Review Confirmation Overlay
                      if (_isSuccessModalVisible)
                        _buildSuccessModalOverlay(isDark),
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

  /// Restricted View for Unauthorized Roles (Merchant & Client)
  Widget _buildRestrictedView(bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.navyDark : AppColors.backgroundLight,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.gpp_bad_rounded,
                        color: Color(0xFFEF4444),
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'سحب الرصيد مخصص للسائقين ومكاتب النقل',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.textWhite
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'وفق سياسات منصة حمولة، تقتصر خاصية سحب الرصيد على السائقين ومكاتب النقل لتحصيل مستحقاتهم وأرباحهم التشغيلية.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark
                            ? AppColors.textSubtle
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: widget.onBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'العودة للمحفظة',
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
          ),
        ),
      ),
    );
  }

  /// 1. Header (Left Back Button, Center Titles, Right Wallet Badge)
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
          // Back button on the LEFT
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            tooltip: 'رجوع',
          ),

          // Title & Subtitle in CENTER
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppStrings.withdrawBalanceTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.textWhite
                        : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  AppStrings.withdrawBalanceHeaderSub,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSubtle
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Wallet Badge on the RIGHT
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1D4ED8).withValues(alpha: 0.2)
                  : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: isDark
                  ? const Color(0xFF60A5FA)
                  : const Color(0xFF1D4ED8),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  /// A. Balance Card (Dark Blue Gradient, Eye Toggle, Pending Dues)
  Widget _buildBalanceCard({
    required double availableBalance,
    required double pendingDues,
    required bool isDark,
  }) {
    final formattedAvailable = availableBalance.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    final formattedPending = pendingDues.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF1D4ED8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Translucent Wallet Outline on the Left in RTL
          Positioned(
            left: -12,
            bottom: -10,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Subtitle: Available for withdrawal
                Text(
                  AppStrings.availableBalanceForWithdrawal,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 6),

                // Main Amount Row: Eye Toggle + Value + Currency
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Amount
                    Text(
                      _isBalanceHidden ? '••••••' : formattedAvailable,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: _isBalanceHidden ? 3.0 : 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Currency
                    Text(
                      AppStrings.currencyYerShort,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Eye Toggle
                    InkWell(
                      onTap: () =>
                          setState(() => _isBalanceHidden = !_isBalanceHidden),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          _isBalanceHidden
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Sub-Row: Pending Dues (المستحقات المعلقة)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _isBalanceHidden
                              ? '${AppStrings.pendingDuesLabel}: ••••'
                              : '${AppStrings.pendingDuesLabel}: $formattedPending ${AppStrings.currencyYerShort}',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// B. Amount Section with 4 Quick Buttons (Max, 20k, 10k, 5k)
  Widget _buildAmountSection({
    required double availableBalance,
    required bool isDark,
  }) {
    final currentAmount = _parsedAmount;
    final maxAmountInt = availableBalance.toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel('المبلغ المراد سحبه', isDark),
        const SizedBox(height: 8),

        // Input Box (Currency | Amount | Cash Icon)
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              // Cash Icon on the RIGHT in RTL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  Icons.payments_outlined,
                  size: 22,
                  color: isDark
                      ? AppColors.textSubtle
                      : const Color(0xFF64748B),
                ),
              ),

              // Amount Input Field
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textWhite
                        : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى تحديد المبلغ';
                    }
                    final numVal =
                        double.tryParse(val.replaceAll(',', '').trim());
                    if (numVal == null || numVal <= 0) {
                      return 'المبلغ يجب أن يكون أكبر من 0';
                    }
                    if (numVal > availableBalance) {
                      return 'المبلغ يتجاوز الرصيد المتاح للسحب';
                    }
                    return null;
                  },
                ),
              ),

              // Vertical Divider
              Container(
                width: 1,
                height: 28,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E8F0),
              ),

              // Currency Label on the LEFT in RTL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  AppStrings.currencyYer,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textSubtle
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 4 Quick Buttons in RTL: Max | 20,000 | 10,000 | 5,000
        Row(
          children: [
            // 1. Max Amount Option (Rightmost in RTL)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: InkWell(
                  onTap: () => _selectMaxAmount(availableBalance),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: currentAmount != null &&
                              currentAmount.toInt() == maxAmountInt &&
                              maxAmountInt > 0
                          ? const Color(0xFFEFF6FF)
                          : (isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: currentAmount != null &&
                                currentAmount.toInt() == maxAmountInt &&
                                maxAmountInt > 0
                            ? const Color(0xFF2563EB)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFE2E8F0)),
                        width: currentAmount != null &&
                                currentAmount.toInt() == maxAmountInt &&
                                maxAmountInt > 0
                            ? 1.5
                            : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.maxAmountLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1D4ED8),
                          ),
                        ),
                        Text(
                          maxAmountInt.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 9.5,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textSubtle
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. 20,000
            _buildQuickAmountChip(
              amount: 20000,
              label: '20,000',
              currentAmount: currentAmount,
              isDark: isDark,
            ),

            // 3. 10,000
            _buildQuickAmountChip(
              amount: 10000,
              label: '10,000',
              currentAmount: currentAmount,
              isDark: isDark,
            ),

            // 4. 5,000 (Leftmost in RTL)
            _buildQuickAmountChip(
              amount: 5000,
              label: '5,000',
              currentAmount: currentAmount,
              isDark: isDark,
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAmountChip({
    required int amount,
    required String label,
    required double? currentAmount,
    required bool isDark,
    bool isLast = false,
  }) {
    final isSelected =
        currentAmount != null && currentAmount.toInt() == amount;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: isLast ? 0 : 4, right: 4),
        child: InkWell(
          onTap: () => _selectQuickAmount(amount),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEFF6FF)
                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF1D4ED8)
                    : (isDark
                        ? AppColors.textWhite
                        : const Color(0xFF1E293B)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// C. Withdrawal Method Selector Card (Interactive Trigger)
  Widget _buildMethodSelector(bool isDark) {
    final isSubscriber = _selectedMethod == 'subscriber';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(AppStrings.withdrawMethodTitle, isDark),
        const SizedBox(height: 8),

        // Method Card Trigger
        InkWell(
          onTap: () => setState(() => _isMethodModalOpen = true),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Right: Method Icon Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSubscriber
                        ? Icons.person_outline_rounded
                        : Icons.storefront_outlined,
                    color: const Color(0xFF1D4ED8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Center: Method Details (Expanded)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSubscriber
                            ? AppStrings.withdrawMethodSubscriberTitle
                            : AppStrings.withdrawMethodPosTitle,
                        style: GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textWhite
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isSubscriber
                            ? AppStrings.withdrawMethodSubscriberDesc
                            : AppStrings.withdrawMethodPosDesc,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textSubtle
                              : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Left: Chevron Down
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 24,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Modal Popup for Method Selection (Mockup 2 & Bottom Zoomed Inset)
  Widget _buildMethodPickerModal(bool isDark) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _isMethodModalOpen = false),
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onTap: () {}, // Prevent tap through
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.withdrawMethodTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textWhite
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Option 1: Subscriber (تحويل لمشترك)
                  _buildMethodOptionCard(
                    id: 'subscriber',
                    title: AppStrings.withdrawMethodSubscriberTitle,
                    desc: AppStrings.withdrawMethodSubscriberDesc,
                    icon: Icons.person_outline_rounded,
                    isSelected: _selectedMethod == 'subscriber',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),

                  // Option 2: POS (دفع مشتريات)
                  _buildMethodOptionCard(
                    id: 'pos',
                    title: AppStrings.withdrawMethodPosTitle,
                    desc: AppStrings.withdrawMethodPosDesc,
                    icon: Icons.storefront_outlined,
                    isSelected: _selectedMethod == 'pos',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodOptionCard({
    required String id,
    required String title,
    required String desc,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => _switchMethod(id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEFF6FF)
              : (isDark ? const Color(0xFF0F172A) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Right: Icon Badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF1D4ED8),
              ),
            ),
            const SizedBox(width: 12),

            // Middle: Text Details (Expanded)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textWhite
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    desc,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSubtle
                          : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Left: Checkmark Indicator
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2563EB),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// D. Recipient Details Section (Conditionally swapped according to selected method)
  Widget _buildRecipientDetails(bool isDark) {
    final isSubscriber = _selectedMethod == 'subscriber';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recipientDetailsTitle,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        if (isSubscriber) ...[
          // Field 1: Phone Number (رقم الهاتف)
          _buildPhoneFieldBlock(isDark),
          const SizedBox(height: 14),

          // Field 2: Full Name (الاسم الرباعي)
          _buildNameFieldBlock(
            label: AppStrings.recipientFullNameLabel,
            hint: AppStrings.recipientFullNameHint,
            controller: _fullNameController,
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'يرجى إدخال الاسم الرباعي للمستلم';
              }
              final parts = v.trim().split(RegExp(r'\s+'));
              if (parts.length < 2) {
                return 'يرجى إدخال اسم المستلم كاملاً';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Information Notice for Subscriber
          _buildNoticeBox(
            notice: AppStrings.subscriberWarningNotice,
            isDark: isDark,
          ),
        ] else ...[
          // Field 1: POS Point Number (نقطة البيع)
          _buildPosPointFieldBlock(isDark),
          const SizedBox(height: 14),

          // Field 2: Commercial Name (اسم نقطة البيع / الاسم التجاري بالكامل)
          _buildNameFieldBlock(
            label: AppStrings.posCommercialNameLabel,
            hint: AppStrings.posCommercialNameHint,
            controller: _posCommercialNameController,
            icon: Icons.storefront_outlined,
            isDark: isDark,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'يرجى إدخال الاسم التجاري الكامل لنقطة البيع';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Information Notice for POS
          _buildNoticeBox(
            notice: AppStrings.posWarningNotice,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  /// Phone Number Input with +967 Prefix, Clear Icon, and Phone Badge
  Widget _buildPhoneFieldBlock(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(AppStrings.recipientPhoneLabel, isDark),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              // Phone Input (Starts from the Right in RTL)
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textWhite
                        : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.recipientPhoneHint,
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.textSubtle
                          : const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    final clean = v.trim();
                    if (clean.length < 9) {
                      return 'يرجى إدخال رقم هاتف يمني صالح (9 أرقام)';
                    }
                    return null;
                  },
                ),
              ),

              // Clear Button (if text present)
              if (_phoneController.text.isNotEmpty)
                IconButton(
                  onPressed: () => _phoneController.clear(),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: const Color(0xFF94A3B8),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),

              // Country Code & SIM/Phone Icon on the Left in RTL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+967',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textWhite
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 20,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE2E8F0),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.phone_android_outlined,
                      size: 18,
                      color: isDark
                          ? AppColors.textSubtle
                          : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// POS Point Number Input with # Prefix and Clear Icon
  Widget _buildPosPointFieldBlock(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(AppStrings.posPointNumberLabel, isDark),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              // Point Input (Starts from the Right in RTL)
              Expanded(
                child: TextFormField(
                  controller: _posPointController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textWhite
                        : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.posPointNumberHint,
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.textSubtle
                          : const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'يرجى إدخال رقم نقطة البيع';
                    }
                    return null;
                  },
                ),
              ),

              // Clear Button (if text present)
              if (_posPointController.text.isNotEmpty)
                IconButton(
                  onPressed: () => _posPointController.clear(),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: const Color(0xFF94A3B8),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),

              // '#' Symbol on the Left in RTL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '#',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textSubtle
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Full Name / Commercial Name Text Field
  Widget _buildNameFieldBlock({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(label, isDark),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              // Text Field on the Right in RTL
              Expanded(
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    color: isDark
                        ? AppColors.textWhite
                        : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.textSubtle
                          : const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: validator,
                ),
              ),

              // Icon on the Left in RTL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDark
                      ? AppColors.textSubtle
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Warning / Notice Box
  Widget _buildNoticeBox({
    required String notice,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notice,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSubtle
                    : const Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredLabel(String text, bool isDark) {
    return Row(
      children: [
        const Text(
          '* ',
          style: TextStyle(
            color: Color(0xFFDC2626),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  /// E. Submit Button (Hamoola Royal Blue with Paper Plane Icon)
  Widget _buildSubmitButton(double availableBalance) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1D4ED8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSubmit(availableBalance),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.send_rounded,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.sendWithdrawalRequestBtn,
                style: GoogleFonts.cairo(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Success / Review Modal Overlay
  Widget _buildSuccessModalOverlay(bool isDark) {
    final data = _lastSubmittedData ?? {};
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    String roleLabel = 'السائق';
    if (_effectiveRole == AuthUserRole.office) {
      roleLabel = 'مكتب النقل';
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0x1F10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 38,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 14),

              // Title & Subtitle
              Text(
                AppStrings.withdrawalSuccessTitle,
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textWhite
                      : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.withdrawalSuccessSub,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSubtle
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'طلب السحب خاص بـ $roleLabel وسيتم تدقيقه قبل الخصم والتنفيذ البنكي.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 18),

              // Summary Details
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    _buildModalRow(
                      'رقم الطلب:',
                      '#${data['ref'] ?? ''}',
                      isBold: true,
                      isDark: isDark,
                    ),
                    const Divider(height: 16),
                    _buildModalRow(
                      'المبلغ المطلوب:',
                      '${data['amount'] ?? '0'} ${AppStrings.currencyYerShort}',
                      isDark: isDark,
                    ),
                    const Divider(height: 16),
                    _buildModalRow(
                      'طريقة السحب:',
                      '${data['methodLabel'] ?? ''}',
                      isDark: isDark,
                    ),
                    const Divider(height: 16),
                    _buildModalRow(
                      'المستلم:',
                      '${data['recipientName'] ?? ''} (${data['recipientId'] ?? ''})',
                      isDark: isDark,
                    ),
                    const Divider(height: 16),
                    _buildModalRow(
                      'الحالة:',
                      'قيد المراجعة',
                      valueColor: const Color(0xFFD97706),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isSuccessModalVisible = false);
                    if (widget.onSuccessDone != null) {
                      widget.onSuccessDone!.call();
                    } else if (widget.onBack != null) {
                      widget.onBack!.call();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppStrings.depositSuccessCloseBtn,
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
  }

  Widget _buildModalRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ??
                  (isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
