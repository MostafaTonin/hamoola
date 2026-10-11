import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/wallet_models.dart';

/// Screen representing Merchant Add Balance / Payment Method
/// with 8 Yemeni e-wallets, point copying, sub-methods, and deposit confirmation.
class MerchantAddBalanceScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final ValueChanged<Map<String, dynamic>>? onSubmitDeposit;
  final VoidCallback? onSuccessDone;

  const MerchantAddBalanceScreen({
    super.key,
    this.onClose,
    this.onSubmitDeposit,
    this.onSuccessDone,
  });

  @override
  State<MerchantAddBalanceScreen> createState() =>
      _MerchantAddBalanceScreenState();
}

class _MerchantAddBalanceScreenState extends State<MerchantAddBalanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final _senderController = TextEditingController();

  PaymentWallet _selectedWallet = PaymentWallet.supportedWallets.first;
  bool _isWalletDropdownOpen = false;
  String _selectedSubOption = 'purchases'; // 'purchases' or 'code'
  bool _isSuccessModalVisible = false;
  Map<String, dynamic>? _lastSubmittedData;

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _senderController.dispose();
    super.dispose();
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

    final depositData = {
      'amount': _amountController.text.trim(),
      'wallet': _selectedWallet.name,
      'point': _selectedWallet.point,
      'subOption': _selectedSubOption == 'purchases' ? 'دفع مشتريات' : 'كود الشراء',
      'ref': _refController.text.trim(),
      'sender': _senderController.text.trim(),
      'date': 'الآن',
    };

    widget.onSubmitDeposit?.call(depositData);

    setState(() {
      _lastSubmittedData = depositData;
      _isSuccessModalVisible = true;
    });
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
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 1. Header
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
                                // Field 1: Amount
                                _buildAmountField(isDark),
                                const SizedBox(height: 16),

                                // Field 2: Electronic Wallet Dropdown
                                _buildWalletDropdown(isDark),
                                const SizedBox(height: 16),

                                // Field 3: Sub-options (Purchases / Code)
                                _buildSubOptionsList(isDark),
                                const SizedBox(height: 14),

                                // Field 4: Direct Point Number Row with Copy
                                _buildDirectPointRow(isDark),
                                const SizedBox(height: 14),

                                // Field 5: Trust Assurance Banner
                                _buildTrustAssuranceBanner(isDark),
                                const SizedBox(height: 16),

                                // Field 6: Deposit Reference Number
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

                                // Field 7: Sender Name
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

                                // Field 8: Submit Button
                                _buildSubmitButton(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Success Modal Overlay
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
          Text(
            AppStrings.paymentMethodTitle,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close_rounded, size: 22),
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            tooltip: AppStrings.cancelBtn,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(AppStrings.transferredAmountLabel, isDark),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              // Cash Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.payments_outlined,
                  size: 22,
                  color: isDark
                      ? AppColors.textSubtle
                      : AppColors.textMutedLight,
                ),
              ),

              // Input Amount
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color:
                        isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.amountPlaceholder,
                    hintStyle: GoogleFonts.ibmPlexSansArabic(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.2),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى تحديد المبلغ';
                    }
                    final numVal = double.tryParse(val);
                    if (numVal == null || numVal <= 0) {
                      return 'المبلغ يجب أن يكون أكبر من 0';
                    }
                    return null;
                  },
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 28,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.borderLight,
              ),

              // Currency Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  AppStrings.currencyYer,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textSubtle
                        : AppColors.textMutedLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel(AppStrings.paymentMethodDropdownLabel, isDark),
        const SizedBox(height: 6),

        // Dropdown Trigger
        InkWell(
          onTap: () => setState(
              () => _isWalletDropdownOpen = !_isWalletDropdownOpen),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isWalletDropdownOpen
                    ? AppColors.primaryGold
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.borderLight),
                width: _isWalletDropdownOpen ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _selectedWallet.brandColor.withValues(alpha: 0.15),
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textMainLight,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isWalletDropdownOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: isDark
                      ? AppColors.textSubtle
                      : AppColors.textMutedLight,
                ),
              ],
            ),
          ),
        ),

        // Dropdown Panel (8 Wallets)
        if (_isWalletDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 6),
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
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGold.withValues(alpha: 0.08)
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: w.brandColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(w.icon,
                                  color: w.brandColor, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              w.name,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textMainLight,
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: AppColors.primaryGold,
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

  Widget _buildSubOptionsList(bool isDark) {
    return Column(
      children: [
        // 1. Purchases Option
        _buildSubOptionCard(
          id: 'purchases',
          title: AppStrings.subOptionPurchasesTitle,
          desc:
              '${AppStrings.subOptionPurchasesDescPrefix} ${_selectedWallet.point}',
          icon: Icons.storefront_rounded,
          isSelected: _selectedSubOption == 'purchases',
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        // 2. Code Option
        _buildSubOptionCard(
          id: 'code',
          title: AppStrings.subOptionCodeTitle,
          desc:
              'من ${_selectedWallet.name}${AppStrings.subOptionCodeDescSuffix}',
          icon: Icons.qr_code_rounded,
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
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedSubOption = id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.borderLight),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGold.withValues(alpha: 0.15)
                    : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.primaryGold
                    : (isDark ? AppColors.textSubtle : AppColors.textMutedLight),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textWhite
                          : AppColors.textMainLight,
                    ),
                  ),
                  Text(
                    desc,
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
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGold
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.25)),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGold,
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

  Widget _buildDirectPointRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x1AF59E0B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                AppStrings.pointNumberLabel,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _selectedWallet.point,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _copyPointNumber,
            icon: const Icon(Icons.copy_rounded, size: 18),
            color: AppColors.primaryGold,
            tooltip: AppStrings.copyPointTooltip,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustAssuranceBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.trustAssuranceText,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        size: 20,
                        color: isDark
                            ? AppColors.textSubtle
                            : AppColors.textMutedLight,
                      )
                    : Text(
                        prefixIconText ?? '#',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textSubtle
                              : AppColors.textMutedLight,
                        ),
                      ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color:
                        isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSubtle
                          : AppColors.textMutedLight,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: validator,
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
            color: AppColors.error,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleSubmit,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.confirmPaymentBtn,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.shield_rounded,
                size: 18,
                color: Color(0xFF0F172A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessModalOverlay(bool isDark) {
    final data = _lastSubmittedData ?? {};
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

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
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color:
                      isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.depositSuccessSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  color:
                      isDark ? AppColors.textSubtle : AppColors.textMutedLight,
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
                        : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
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
              const SizedBox(height: 18),

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
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: const Color(0xFF0F172A),
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
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
      ],
    );
  }
}
