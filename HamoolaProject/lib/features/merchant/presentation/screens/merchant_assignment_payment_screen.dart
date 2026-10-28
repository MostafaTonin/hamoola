import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/driver_offer.dart';
import '../../domain/models/merchant_order.dart';
import '../../domain/models/merchant_simulation_store.dart';

/// Screen representing Phase 5: Assignment Confirmation & Wallet Payment.
/// Verifies internal wallet balance before deducting and activating live trip tracking.
class MerchantAssignmentPaymentScreen extends StatefulWidget {
  final DriverOffer? offer;
  final String orderId;
  final VoidCallback? onBack;
  final VoidCallback? onAddBalance;
  final ValueChanged<String>? onPaymentSuccess;

  const MerchantAssignmentPaymentScreen({
    super.key,
    this.offer,
    required this.orderId,
    this.onBack,
    this.onAddBalance,
    this.onPaymentSuccess,
  });

  @override
  State<MerchantAssignmentPaymentScreen> createState() =>
      _MerchantAssignmentPaymentScreenState();
}

class _MerchantAssignmentPaymentScreenState
    extends State<MerchantAssignmentPaymentScreen> {
  static const double platformFee = 15000.0;

  double get baseFare {
    if (widget.offer != null) {
      return widget.offer!.price;
    }
    final order = MerchantSimulationStore.instance.getOrderById(widget.orderId);
    return order?.agreedFare ?? order?.expectedPrice ?? order?.maxBudget ?? 350000.0;
  }

  double get totalAmount => baseFare + platformFee;

  String _formatAmount(double amount) {
    final intVal = amount.toInt();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return intVal.toString().replaceAllMapped(reg, (match) => ',');
  }

  void _handleConfirmPayment(MerchantSimulationStore store, MerchantOrder? order) {
    if (order != null && order.isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تأكيد الدفع وإسناد الطلب ${widget.orderId} مسبقاً',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.primaryGold,
        ),
      );
      widget.onPaymentSuccess?.call(widget.orderId);
      return;
    }

    final providerName = widget.offer?.driverName ?? order?.driverName ?? 'الجهة المنفذة المعتمدة';
    final success = store.payForOrder(
      widget.orderId,
      totalAmount,
      driverName: providerName,
      routeDescription: '${order?.originCity ?? 'صنعاء'} ← ${order?.destinationCity ?? 'عدن'}',
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم خصم ${_formatAmount(totalAmount)} ر.ي وإسناد الطلب ${widget.orderId} إلى $providerName بنجاح!',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
      widget.onPaymentSuccess?.call(widget.orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = MerchantSimulationStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final order = store.getOrderById(widget.orderId);
        final currentBalance = store.walletBalance;
        final isBalanceSufficient = store.canPay(totalAmount);
        final deficit = totalAmount - currentBalance;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor:
                isDark ? AppColors.navyDark : AppColors.backgroundLight,
            bottomNavigationBar: SafeArea(
              top: false,
              child: _buildBottomBar(
                store: store,
                order: order,
                isSufficient: isBalanceSufficient,
                isDark: isDark,
              ),
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
                            vertical: AppDimensions.spaceSm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Order & Route Hero Card
                              _buildOrderHeroCard(order, isDark),
                              const SizedBox(height: 14.0),

                              // Driver / Transport Office Card
                              _buildDriverCard(order, isDark),
                              const SizedBox(height: 14.0),

                              // Price Breakdown Card
                              _buildFareBreakdownCard(isDark),
                              const SizedBox(height: 14.0),

                              // Internal Wallet Verification Card
                              _buildWalletStatusCard(
                                store: store,
                                isSufficient: isBalanceSufficient,
                                currentBalance: currentBalance,
                                deficit: deficit,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 24.0),
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
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20.0),
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            tooltip: AppStrings.back,
          ),
          Text(
            'تأكيد الإسناد والدفع',
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: const Color(0x24F59E0B),
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: AppColors.primaryGold, width: 1.0),
            ),
            child: Text(
              widget.orderId,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeroCard(MerchantOrder? order, bool isDark) {
    final cargoName = order?.cargoName ?? 'مواد غذائية وبضائع';
    final origin = order?.originCity ?? 'صنعاء';
    final dest = order?.destinationCity ?? 'عدن';

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'بيانات طلب النقل',
                style: GoogleFonts.cairo(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  cargoName,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              const Icon(Icons.trip_origin_rounded,
                  size: 16.0, color: AppColors.primaryGold),
              const SizedBox(width: 6.0),
              Text(
                origin,
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12.0),
              const Icon(Icons.arrow_back_rounded,
                  size: 18.0, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12.0),
              const Icon(Icons.location_on_rounded,
                  size: 16.0, color: AppColors.error),
              const SizedBox(width: 6.0),
              Text(
                dest,
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(MerchantOrder? order, bool isDark) {
    final isDirect = order?.isDirectOrder ?? false;
    final isOffice = order?.broadcastScope == 'office' || (order?.driverName?.contains('مكتب') ?? false);
    final providerTitle = isDirect
        ? (isOffice ? 'بيانات مكتب النقل المختار' : 'بيانات السائق المختار')
        : 'بيانات مقدم الخدمة المختار';
    final driverName = widget.offer?.driverName ?? order?.driverName ?? (isOffice ? 'مكتب الأمانة للنقل' : 'كابتن معتمد');
    final rating = widget.offer?.rating ?? 4.9;
    final tripsCount = widget.offer?.tripsCount ?? 140;
    final vehicleName = widget.offer?.vehicleName ?? order?.vehicleType ?? 'شاحنة نقل بري معتمدة';
    final vehiclePlate = widget.offer?.vehiclePlate ?? 'صنعاء 18-5021';
    final notes = widget.offer?.notes ?? order?.notes ?? '';
    final isPaid = order?.isPaid ?? false;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOffice ? Icons.apartment_rounded : Icons.person_pin_rounded,
                size: 18.0,
                color: AppColors.primaryGold,
              ),
              const SizedBox(width: 8.0),
              Text(
                providerTitle,
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              CircleAvatar(
                radius: 24.0,
                backgroundColor: const Color(0x2EF59E0B),
                child: Icon(
                  isOffice ? Icons.business_center_rounded : Icons.local_shipping_rounded,
                  color: AppColors.primaryGold,
                  size: 26.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: GoogleFonts.cairo(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 15.0, color: AppColors.primaryGold),
                        const SizedBox(width: 3.0),
                        Text(
                          rating.toString(),
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          '($tripsCount رحلة مكتملة)',
                          style: GoogleFonts.cairo(
                            fontSize: 11.0,
                            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vehicleName,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                Text(
                  vehiclePlate,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          // Contact Details Container (Section 12: Hidden/Masked before payment, revealed after payment)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isPaid
                  ? const Color(0x1F10B981)
                  : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isPaid
                    ? const Color(0xFF10B981)
                    : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFCBD5E1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isPaid ? Icons.phone_in_talk_rounded : Icons.lock_outline_rounded,
                      size: 16.0,
                      color: isPaid ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'رقم التواصل:',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Text(
                  isPaid
                      ? (order?.targetProviderPhone ?? '+967 775 112 345')
                      : (order?.maskedTargetPhone ?? '+967 77*** ***'),
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: isPaid ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFF10B981) : const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    isPaid ? 'مكشوف' : 'محجوب حتى الدفع',
                    style: GoogleFonts.cairo(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Text(
              'ملاحظات: "$notes"',
              style: GoogleFonts.cairo(
                fontSize: 11.0,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFareBreakdownCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded,
                  size: 18.0, color: AppColors.primaryGold),
              const SizedBox(width: 8.0),
              Text(
                'تفاصيل التكلفة والمبلغ الإجمالي',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          _buildBreakdownRow('أجرة النقل المتفق عليها',
              '${_formatAmount(baseFare)} ر.ي', isDark),
          const SizedBox(height: 8.0),
          _buildBreakdownRow('رسوم المنصة والتأمين اللوجستي المعتمد',
              '${_formatAmount(platformFee)} ر.ي', isDark),
          const Divider(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'إجمالي المبلغ المطلوب دفعه:',
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '${_formatAmount(totalAmount)} ر.ي',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.0,
              color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Text(
          value,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletStatusCard({
    required MerchantSimulationStore store,
    required bool isSufficient,
    required double currentBalance,
    required double deficit,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isSufficient
            ? const Color(0x1F10B981)
            : const Color(0x1FEF4444),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isSufficient ? AppColors.success : AppColors.error,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSufficient
                    ? Icons.account_balance_wallet_rounded
                    : Icons.warning_amber_rounded,
                size: 20.0,
                color: isSufficient ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 8.0),
              Text(
                isSufficient
                    ? 'رصيد المحفظة كافٍ لإتمام العملية'
                    : 'رصيد المحفظة غير كافٍ لإتمام التعاقد',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isSufficient ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الرصيد المتوفر حالياً بالمحفظة:',
                style: GoogleFonts.cairo(
                  fontSize: 12.0,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
              Text(
                '${_formatAmount(currentBalance)} ر.ي',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
            ],
          ),
          if (!isSufficient) ...[
            const SizedBox(height: 6.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المبلغ المطلوب شحنه:',
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  '${_formatAmount(deficit)} ر.ي',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            // Shortcut for quick prototype testing
            ElevatedButton.icon(
              key: const Key('sim_recharge_button'),
              onPressed: () {
                store.addDepositRequest(
                  amount: 500000.0,
                  walletName: 'محفظة جيب',
                  ref: 'SIM-${DateTime.now().millisecondsSinceEpoch % 10000}',
                );
                store.simulateApproveLatestDeposit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0x2EF59E0B),
                foregroundColor: AppColors.primaryGold,
                elevation: 0,
                side: const BorderSide(color: AppColors.primaryGold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              ),
              icon: const Icon(Icons.bolt_rounded, size: 16.0, color: AppColors.primaryGold),
              label: Text(
                'شحن رصيد تجريبي فوري (+500,000 ر.ي)',
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar({
    required MerchantSimulationStore store,
    required MerchantOrder? order,
    required bool isSufficient,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          if (order?.isPaid == true) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onPaymentSuccess?.call(widget.orderId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 20.0),
                label: Text(
                  'تم الدفع وتأكيد الإسناد بنجاح ✓',
                  style: GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ] else if (isSufficient) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleConfirmPayment(store, order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20.0),
                label: Text(
                  'تأكيد الإسناد والدفع من المحفظة',
                  style: GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (widget.onAddBalance != null) {
                    widget.onAddBalance!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: const Icon(Icons.account_balance_wallet_rounded, size: 20.0),
                label: Text(
                  'شحن المحفظة الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
