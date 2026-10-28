import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/domain/models/auth_simulation_store.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../domain/models/merchant_simulation_store.dart';
import '../../domain/models/wallet_models.dart';

/// Screen representing the unified Add Wallet Balance (إضافة رصيد)
/// for Merchant, Client, and Transport Office in the Hamula Platform.
/// Adheres strictly to the visual and behavioral 2-state design (Closed & Open dropdown).
class MerchantAddBalanceScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final ValueChanged<Map<String, dynamic>>? onSubmitDeposit;
  final VoidCallback? onSuccessDone;
  final AuthUserRole? userRole;
  final String? initialAmount;

  const MerchantAddBalanceScreen({
    super.key,
    this.onClose,
    this.onSubmitDeposit,
    this.onSuccessDone,
    this.userRole,
    this.initialAmount,
  });

  @override
  State<MerchantAddBalanceScreen> createState() =>
      _MerchantAddBalanceScreenState();
}

/// Convenience alias for clarity across non-merchant features
typedef AddBalanceScreen = MerchantAddBalanceScreen;

class _MerchantAddBalanceScreenState extends State<MerchantAddBalanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final _senderController = TextEditingController();

  static const List<int> _quickAmounts = [50000, 20000, 10000, 5000];
  static const List<String> _quickAmountLabels = [
    '50,000',
    '20,000',
    '10,000',
    '5,000',
  ];

  PaymentWallet _selectedWallet = PaymentWallet.supportedWallets.first;
  bool _isWalletDropdownOpen = false;
  String _selectedSubOption = 'purchases'; // 'purchases' or 'code'
  bool _isSuccessModalVisible = false;
  Map<String, dynamic>? _lastSubmittedData;

  AuthUserRole get _effectiveRole =>
      widget.userRole ??
      AuthSimulationStore.instance.currentUser?.role ??
      AuthUserRole.merchant;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount!.isNotEmpty) {
      _amountController.text = widget.initialAmount!;
    }
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _refController.dispose();
    _senderController.dispose();
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

  void _copyPointNumber() {
    Clipboard.setData(ClipboardData(text: _selectedWallet.point));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppStrings.pointCopiedSuccess}: ${_selectedWallet.point}',
          style: GoogleFonts.cairo(),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final amountNum = _parsedAmount ?? 0.0;
    final depositData = {
      'amount': _amountController.text.trim(),
      'wallet': _selectedWallet.name,
      'point': _selectedWallet.point,
      'subOption':
          _selectedSubOption == 'purchases' ? 'دفع مشتريات' : 'كود الشراء',
      'ref': _refController.text.trim(),
      'sender': _senderController.text.trim(),
      'role': _effectiveRole.name,
      'date': 'الآن',
    };

    if (amountNum > 0 && _effectiveRole != AuthUserRole.driver) {
      MerchantSimulationStore.instance.addDepositRequestForRole(
        role: _effectiveRole,
        amount: amountNum,
        walletName: _selectedWallet.name,
        ref: _refController.text.trim(),
        sender: _senderController.text.trim(),
      );
    }

    widget.onSubmitDeposit?.call(depositData);

    setState(() {
      _lastSubmittedData = depositData;
      _isSuccessModalVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Driver restriction check: Drivers cannot add balance per platform rules
    if (_effectiveRole == AuthUserRole.driver) {
      return _buildDriverRestrictedView(isDark);
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
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 1. Header with wallet badge, title, and close button
                      _buildHeader(isDark),

                      // 2. Form Body
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Field 1: Amount block + Quick buttons
                                _buildAmountSection(isDark),
                                const SizedBox(height: 18),

                                // Field 2: Payment Method Dropdown
                                _buildWalletDropdown(isDark),
                                const SizedBox(height: 14),

                                // State 1 ONLY: Sub-options, Direct Point Row, Trust Banner
                                if (!_isWalletDropdownOpen) ...[
                                  _buildSubOptionsList(isDark),
                                  const SizedBox(height: 14),
                                  _buildDirectPointRow(isDark),
                                  const SizedBox(height: 14),
                                  _buildTrustAssuranceBanner(isDark),
                                  const SizedBox(height: 16),
                                ],

                                // Field 3: Deposit Reference Number
                                _buildTextFieldBlock(
                                  label: AppStrings.depositRefLabel,
                                  controller: _refController,
                                  hint: AppStrings.depositRefHint,
                                  prefixIconText: '#',
                                  isDark: isDark,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'يرجى إدخال رقم الإيداع أو الحوالة';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Field 4: Sender Name
                                _buildTextFieldBlock(
                                  label: AppStrings.senderNameLabel,
                                  controller: _senderController,
                                  hint: AppStrings.senderNameHint,
                                  prefixIcon: Icons.person_outline_rounded,
                                  isDark: isDark,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'يرجى إدخال اسم المرسل';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Field 5: Confirm Payment Button
                                _buildSubmitButton(),
                                const SizedBox(height: 28),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Success / Review Modal Overlay
                  if (_isSuccessModalVisible)
                    _buildSuccessModalOverlay(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Driver Restricted Screen View
  Widget _buildDriverRestrictedView(bool isDark) {
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
                      'عذراً، إضافة الرصيد غير متاحة للسائق',
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
                      'وفق سياسات وقواعد منصة حمولة، لا يملك حساب السائق صلاحية شحن المحفظة. مستحقات السائق تسجل تلقائياً عبر إنجاز الرحلات فقط.',
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
                        onPressed: widget.onClose,
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

  /// Header with Left close button, centered/right title + subtitle, and Right wallet badge
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
          // Close button on the LEFT
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close_rounded, size: 24),
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            tooltip: AppStrings.cancelBtn,
          ),

          // Title & Subtitle in CENTER
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'إضافة رصيد',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.textWhite
                        : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'شحن محفظتك في حمولة',
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

  /// Amount input box and 4 quick buttons
  Widget _buildAmountSection(bool isDark) {
    final currentAmount = _parsedAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel('المبلغ المراد شحنه', isDark),
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
                    final numVal = double.tryParse(val.replaceAll(',', ''));
                    if (numVal == null || numVal <= 0) {
                      return 'المبلغ يجب أن يكون أكبر من 0';
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

        // 4 Quick Amount Buttons: 5,000 | 10,000 | 20,000 | 50,000
        Row(
          children: List.generate(_quickAmounts.length, (index) {
            final amt = _quickAmounts[index];
            final label = _quickAmountLabels[index];
            final isSelected = currentAmount != null &&
                currentAmount.toInt() == amt;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index == _quickAmounts.length - 1 ? 0 : 6,
                  right: index == 0 ? 0 : 6,
                ),
                child: InkWell(
                  onTap: () => _selectQuickAmount(amt),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEFF6FF)
                          : (isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white),
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
                        fontSize: 12.5,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
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
          }),
        ),
      ],
    );
  }

  /// Payment Method Dropdown (State 1: Closed Trigger, State 2: Open 8-wallets list)
  Widget _buildWalletDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(AppStrings.paymentMethodTitle, isDark),
        const SizedBox(height: 8),

        // Dropdown Trigger Container
        InkWell(
          onTap: () => setState(
              () => _isWalletDropdownOpen = !_isWalletDropdownOpen),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isWalletDropdownOpen
                    ? const Color(0xFF2563EB)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE2E8F0)),
                width: _isWalletDropdownOpen ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Right: Brand Icon Badge + Wallet Name
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _selectedWallet.brandColor
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _selectedWallet.icon,
                        color: _selectedWallet.brandColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedWallet.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textWhite
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),

                // Left: Chevron Icon (Up when open, Down when closed)
                Icon(
                  _isWalletDropdownOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 24,
                  color: isDark
                      ? AppColors.textSubtle
                      : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),

        // State 2 (Open Dropdown: List of all 8 e-wallets)
        if (_isWalletDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 8),
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
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: PaymentWallet.supportedWallets.map((w) {
                final isSelected = w.id == _selectedWallet.id;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedWallet = w;
                      _isWalletDropdownOpen = false;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEFF6FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(
                              color: const Color(0xFF2563EB),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Right: Brand Icon + Wallet Name
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: w.brandColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                w.icon,
                                color: w.brandColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              w.name,
                              style: GoogleFonts.cairo(
                                fontSize: 13.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isDark
                                    ? AppColors.textWhite
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),

                        // Left: Radio Circle Indicator
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFCBD5E1),
                              width: isSelected ? 2.0 : 1.5,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  /// Sub-options: Purchases (دفع مشتريات) vs Purchase Code (عبر كود الشراء)
  Widget _buildSubOptionsList(bool isDark) {
    return Column(
      children: [
        // 1. Purchases Option (دفع مشتريات)
        _buildSubOptionCard(
          id: 'purchases',
          title: AppStrings.subOptionPurchasesTitle,
          desc:
              '${AppStrings.subOptionPurchasesDescPrefix} ${_selectedWallet.point}',
          icon: Icons.point_of_sale_rounded,
          iconBgColor: const Color(0xFFF59E0B),
          isSelected: _selectedSubOption == 'purchases',
          isDark: isDark,
        ),
        const SizedBox(height: 10),

        // 2. Code Option (عبر كود الشراء)
        _buildSubOptionCard(
          id: 'code',
          title: AppStrings.subOptionCodeTitle,
          desc:
              'من ${_selectedWallet.name}${AppStrings.subOptionCodeDescSuffix}',
          icon: Icons.qr_code_2_rounded,
          iconBgColor: const Color(0xFF64748B),
          isSelected: _selectedSubOption == 'code',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSubOptionCard({
    required String id,
    required String title,
    required String desc,
    required IconData icon,
    required Color iconBgColor,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedSubOption = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEFF6FF)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
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
            // Right in RTL: Icon Badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconBgColor,
              ),
            ),
            const SizedBox(width: 12),

            // Middle: Title & Subtitle
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
                  ),
                ],
              ),
            ),

            // Left in RTL: Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFCBD5E1),
                  width: isSelected ? 2.0 : 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                                child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Direct Point Number Row with 1-tap Copy
  Widget _buildDirectPointRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right: Point Number Text
          Row(
            children: [
              Text(
                AppStrings.pointNumberLabel,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF92400E),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _selectedWallet.point,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFB45309),
                ),
              ),
            ],
          ),

          // Left: Copy Icon Button
          IconButton(
            onPressed: _copyPointNumber,
            icon: const Icon(Icons.copy_rounded, size: 20),
            color: const Color(0xFFD97706),
            tooltip: AppStrings.copyPointTooltip,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// Trust Assurance Banner
  Widget _buildTrustAssuranceBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.verified_rounded,
              size: 20,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.trustAssuranceText,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF15803D),
                  ),
                ),
                Text(
                  'تأكد من صحة البيانات قبل تأكيد عملية الشحن.',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Form Text Field Block
  Widget _buildTextFieldBlock({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    String? prefixIconText,
    required bool isDark,
    String? Function(String?)? validator,
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
              // Input (Starts from the Right in RTL)
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

              // Icon or Prefix on the Left in RTL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        size: 20,
                        color: isDark
                            ? AppColors.textSubtle
                            : const Color(0xFF64748B),
                      )
                    : Text(
                        prefixIconText ?? '#',
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
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  /// Submit Button (Hamoola Royal Blue)
  Widget _buildSubmitButton() {
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
          onTap: _handleSubmit,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.confirmPaymentBtn,
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

    String roleLabel = 'التاجر';
    if (_effectiveRole == AuthUserRole.client) {
      roleLabel = 'العميل';
    } else if (_effectiveRole == AuthUserRole.office) {
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
                AppStrings.depositSuccessTitle,
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
                AppStrings.depositSuccessSubtitle,
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
                'طلبك قيد المراجعة والتحقق من رقم الحوالة قبل إضافة الرصيد إلى محفظة $roleLabel.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSubtle
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),

              // Summary Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x660F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSummaryLine(
                      'المحفظة المستهدفة:',
                      'محفظة $roleLabel',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    _buildSummaryLine(
                      AppStrings.depositSuccessAmountLabel,
                      '${data['amount']} ${AppStrings.currencyYer}',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    _buildSummaryLine(
                      AppStrings.depositSuccessWalletLabel,
                      '${data['wallet']} (${data['subOption']})',
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    _buildSummaryLine(
                      AppStrings.depositSuccessRefLabel,
                      '#${data['ref']}',
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Quick Simulation Approval CTA
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () {
                    MerchantSimulationStore.instance
                        .simulateApproveLatestDepositForRole(_effectiveRole);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '⚡ تم اعتماد الإيداع وإضافته للرصيد المتاح لمحفظة $roleLabel بنجاح!',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    setState(() => _isSuccessModalVisible = false);
                    widget.onSuccessDone?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1D4ED8),
                    side: const BorderSide(
                      color: Color(0xFF1D4ED8),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: Text(
                    'محاكاة اعتماد الإيداع فورياً للمحفظة',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Close CTA
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isSuccessModalVisible = false);
                    widget.onSuccessDone?.call();
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
                      fontSize: 14,
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

  Widget _buildSummaryLine(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
