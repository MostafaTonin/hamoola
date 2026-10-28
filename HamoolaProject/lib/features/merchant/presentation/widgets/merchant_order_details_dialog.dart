import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/merchant_order.dart';
import '../../domain/models/merchant_simulation_store.dart';
import '../screens/merchant_assignment_payment_screen.dart';

/// Professional Modal Dialog displaying complete transport order specifications,
/// status tracking, driver/office details, offers review, and safe edit/delete actions per Hamoula UX.
/// Strictly adheres to the business rule:
/// Orders can ONLY be edited if status is [draft], [pendingDriver], or [pendingOffice].
class MerchantOrderDetailsDialog extends StatefulWidget {
  final MerchantOrder order;
  final VoidCallback? onOrderUpdated;
  final VoidCallback? onOrderDeleted;
  final ValueChanged<String>? onReviewOffers;
  final ValueChanged<String>? onLiveTracking;
  final ValueChanged<String>? onDriverProfile;

  const MerchantOrderDetailsDialog({
    super.key,
    required this.order,
    this.onOrderUpdated,
    this.onOrderDeleted,
    this.onReviewOffers,
    this.onLiveTracking,
    this.onDriverProfile,
  });

  /// Static helper to display the details dialog
  static Future<void> show(
    BuildContext context,
    MerchantOrder order, {
    VoidCallback? onOrderUpdated,
    VoidCallback? onOrderDeleted,
    ValueChanged<String>? onReviewOffers,
    ValueChanged<String>? onLiveTracking,
    ValueChanged<String>? onDriverProfile,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => MerchantOrderDetailsDialog(
        order: order,
        onOrderUpdated: onOrderUpdated,
        onOrderDeleted: onOrderDeleted,
        onReviewOffers: onReviewOffers,
        onLiveTracking: onLiveTracking,
        onDriverProfile: onDriverProfile,
      ),
    );
  }

  @override
  State<MerchantOrderDetailsDialog> createState() =>
      _MerchantOrderDetailsDialogState();
}

class _MerchantOrderDetailsDialogState
    extends State<MerchantOrderDetailsDialog> {

  void _handleEditOrder(BuildContext context, MerchantOrder currentOrder) {
    if (!currentOrder.isEditable) {
      _showEditRestrictedDialog(context, currentOrder);
      return;
    }

    _showEditOrderDialog(context, currentOrder);
  }

  void _showEditRestrictedDialog(BuildContext context, MerchantOrder order) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            const Icon(Icons.lock_outline_rounded,
                color: Color(0xFFEF4444), size: 26.0),
            const SizedBox(width: 8.0),
            Text(
              'لا يمكن تعديل الطلب',
              style: GoogleFonts.cairo(
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        content: Text(
          'لا يمكن التعديل على هذا الطلب نظراً لأن حالته الحالية هي "${order.statusLabel}".\n\nيُسمح بالتعديل فقط على الطلبات بحالة:\n• مسودة\n• بانتظار سائق\n• بانتظار مكتب',
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            height: 1.6,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'فهمت ذلك',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditOrderDialog(BuildContext context, MerchantOrder currentOrder) {
    final formKey = GlobalKey<FormState>();
    final cargoNameCtrl = TextEditingController(text: currentOrder.cargoName);
    final originCtrl = TextEditingController(text: currentOrder.originCity);
    final destCtrl = TextEditingController(text: currentOrder.destinationCity);
    final vehicleCtrl =
        TextEditingController(text: currentOrder.vehicleType ?? 'شاحنة');
    final priceCtrl = TextEditingController(
      text: currentOrder.expectedPrice != null
          ? currentOrder.expectedPrice!.toInt().toString()
          : '',
    );
    final notesCtrl = TextEditingController(text: currentOrder.notes ?? '');

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note_rounded,
                    color: AppColors.primaryGold, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعديل طلب النقل',
                      style: GoogleFonts.cairo(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${currentOrder.id} • ${currentOrder.statusLabel}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: cargoNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'اسم الحمولة / نوع البضاعة',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'يرجى إدخال اسم الحمولة'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: originCtrl,
                            decoration: const InputDecoration(
                              labelText: 'مدينة الانطلاق',
                              prefixIcon: Icon(Icons.my_location_rounded),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'مطلوب'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: destCtrl,
                            decoration: const InputDecoration(
                              labelText: 'مدينة الوصول',
                              prefixIcon: Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'مطلوب'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: vehicleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'نوع المركبة المطلوبة',
                        prefixIcon: Icon(Icons.local_shipping_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'السعر المتوقع / الميزانية',
                        prefixIcon: Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات وتعليمات النقل',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: AppColors.textSubtle,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final parsedPrice = double.tryParse(priceCtrl.text.trim());
                  final updated = currentOrder.copyWith(
                    cargoName: cargoNameCtrl.text.trim(),
                    originCity: originCtrl.text.trim(),
                    destinationCity: destCtrl.text.trim(),
                    vehicleType: vehicleCtrl.text.trim(),
                    expectedPrice: parsedPrice,
                    notes: notesCtrl.text.trim(),
                    timeAgo: 'معدل الآن',
                  );

                  MerchantSimulationStore.instance.updateOrder(updated);
                  Navigator.of(dialogCtx).pop();
                  widget.onOrderUpdated?.call();
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث الطلب ${updated.id} بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'حفظ التعديلات',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCancelOrder(BuildContext context, MerchantOrder currentOrder) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'تأكيد إلغاء الطلب',
          style: GoogleFonts.cairo(
            fontSize: 16.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في إلغاء وحذف الطلب "${currentOrder.id}"؟ سيتم حذف العروض المرتبطة به إن وجدت.',
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'رجوع',
              style: GoogleFonts.cairo(
                color: AppColors.textSubtle,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final success =
                  MerchantSimulationStore.instance.deleteOrder(currentOrder.id);
              if (success) {
                Navigator.of(context).pop(); // Close details dialog
                widget.onOrderDeleted?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم إلغاء الطلب ${currentOrder.id} بنجاح'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'تأكيد الإلغاء',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = MerchantSimulationStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final currentOrder =
            store.getOrderById(widget.order.id) ?? widget.order;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22.0),
              side: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            elevation: 12.0,
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Dialog Header with ID and Close Button
                  _buildDialogHeader(context, currentOrder, isDark),

                  // 2. Scrollable Body
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Status Badge and Edit Button Row (With Strict Edit Rule)
                          _buildStatusAndEditRow(context, currentOrder, isDark),
                          const SizedBox(height: 14.0),

                          // Route Visual Card (من صنعاء إلى الرياض)
                          _buildRouteCard(currentOrder, isDark),
                          const SizedBox(height: 14.0),

                          // Order Specifications Grid
                          _buildSpecsGrid(currentOrder, isDark),
                          const SizedBox(height: 14.0),

                          // Driver / Offers / Office Section
                          _buildActionableStatusSection(
                              context, currentOrder, isDark),
                          const SizedBox(height: 14.0),

                          // Special Notes Section
                          if (currentOrder.notes != null &&
                              currentOrder.notes!.isNotEmpty) ...[
                            _buildNotesSection(currentOrder, isDark),
                            const SizedBox(height: 14.0),
                          ],

                          // Secondary Cancel / Delete Action Button
                          if (currentOrder.isEditable)
                            _buildCancelActionButton(
                                context, currentOrder, isDark),
                        ],
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
  }

  Widget _buildDialogHeader(
    BuildContext context,
    MerchantOrder currentOrder,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primaryGold,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل طلب النقل',
                    style: GoogleFonts.cairo(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                  ),
                  Text(
                    '${currentOrder.id} • ${currentOrder.timeAgo}',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 11.5,
                      color:
                          isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: isDark ? AppColors.textWhite : const Color(0xFF475569),
            iconSize: 22.0,
            tooltip: 'إغلاق',
            splashRadius: 20.0,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusAndEditRow(
    BuildContext context,
    MerchantOrder currentOrder,
    bool isDark,
  ) {
    Color badgeBg;
    Color badgeBorder;
    Color badgeTextColor;

    switch (currentOrder.status) {
      case MerchantOrderStatus.draft:
        badgeBg = const Color(0x1F64748B);
        badgeBorder = const Color(0x4064748B);
        badgeTextColor = const Color(0xFF94A3B8);
        break;
      case MerchantOrderStatus.pendingDriver:
        badgeBg = const Color(0x2EF59E0B);
        badgeBorder = AppColors.primaryGold.withValues(alpha: 0.35);
        badgeTextColor = const Color(0xFFFBBF24);
        break;
      case MerchantOrderStatus.pendingOffice:
        badgeBg = const Color(0x2E8B5CF6);
        badgeBorder = const Color(0x598B5CF6);
        badgeTextColor = const Color(0xFFA78BFA);
        break;
      case MerchantOrderStatus.assignedDriver:
        badgeBg = const Color(0x2E3B82F6);
        badgeBorder = const Color(0x593B82F6);
        badgeTextColor = const Color(0xFF93C5FD);
        break;
      case MerchantOrderStatus.inTransit:
        badgeBg = const Color(0x2EF59E0B);
        badgeBorder = AppColors.primaryGold.withValues(alpha: 0.4);
        badgeTextColor = AppColors.primaryGold;
        break;
      case MerchantOrderStatus.completed:
        badgeBg = const Color(0x2E10B981);
        badgeBorder = const Color(0x5910B981);
        badgeTextColor = const Color(0xFF6EE7B7);
        break;
    }

    final canEdit = currentOrder.isEditable;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Status Badge
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: badgeBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.0,
                  height: 7.0,
                  decoration: BoxDecoration(
                    color: badgeTextColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7.0),
                Flexible(
                  child: Text(
                    currentOrder.statusLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Edit Button (Active if editable, Locked/Disabled if non-editable)
        InkWell(
          onTap: () => _handleEditOrder(context, currentOrder),
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: canEdit
                  ? AppColors.primaryGold.withValues(alpha: 0.15)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: canEdit
                    ? AppColors.primaryGold.withValues(alpha: 0.4)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  canEdit ? Icons.edit_rounded : Icons.lock_outline_rounded,
                  size: 15.0,
                  color: canEdit
                      ? (isDark ? AppColors.primaryGold : const Color(0xFFB45309))
                      : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                ),
                const SizedBox(width: 6.0),
                Text(
                  canEdit ? 'تعديل الطلب' : 'التعديل مقفل',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: canEdit
                        ? (isDark
                            ? AppColors.primaryGold
                            : const Color(0xFFB45309))
                        : (isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(MerchantOrder currentOrder, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مسار النقل',
                style: GoogleFonts.cairo(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  'رحلة شحن',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 10, color: Color(0xFF10B981)),
                  Container(
                    width: 2,
                    height: 24,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFFCBD5E1),
                  ),
                  const Icon(Icons.location_on, size: 14, color: Color(0xFFEF4444)),
                ],
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'من: ${currentOrder.originCity}',
                          style: GoogleFonts.cairo(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                        ),
                        Text(
                          'موقع التحميل',
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            color: AppColors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إلى: ${currentOrder.destinationCity}',
                          style: GoogleFonts.cairo(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                        ),
                        Text(
                          'موقع التسليم',
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            color: AppColors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid(MerchantOrder currentOrder, bool isDark) {
    final priceText = currentOrder.expectedPrice != null
        ? '${currentOrder.expectedPrice!.toInt()} ر.س'
        : 'حسب العروض';

    String broadcastText = 'كافة السائقين';
    if (currentOrder.broadcastScope == 'driver') {
      broadcastText = 'سائق محدد';
    } else if (currentOrder.broadcastScope == 'all_offices' ||
        currentOrder.status == MerchantOrderStatus.pendingOffice) {
      broadcastText = 'مكاتب النقل المعتمدة';
    } else if (currentOrder.broadcastScope == 'office') {
      broadcastText = 'مكتب نقل محدد';
    }

    final specs = [
      {
        'icon': Icons.inventory_2_outlined,
        'label': 'نوع الحمولة',
        'value': currentOrder.cargoName,
      },
      {
        'icon': Icons.local_shipping_outlined,
        'label': 'نوع المركبة',
        'value': currentOrder.vehicleType ?? 'شاحنة نقل عام',
      },
      {
        'icon': Icons.podcasts_rounded,
        'label': 'نطاق النشر',
        'value': broadcastText,
      },
      {
        'icon': Icons.payments_outlined,
        'label': 'الميزانية / السعر',
        'value': priceText,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مواصفات الطلب',
            style: GoogleFonts.cairo(
              fontSize: 12.0,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: specs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final item = specs[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 18.0,
                      color: AppColors.primaryGold,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['label'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 10.0,
                              color: isDark
                                  ? AppColors.textSubtle
                                  : AppColors.textMutedLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item['value'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionableStatusSection(
    BuildContext context,
    MerchantOrder currentOrder,
    bool isDark,
  ) {
    if (currentOrder.isDirectOrder) {
      if (currentOrder.directStatus == 'accepted' && !currentOrder.isPaid) {
        final agreedFareVal = (currentOrder.agreedFare ??
                currentOrder.expectedPrice ??
                currentOrder.maxBudget ??
                0)
            .toInt();
        final providerName = currentOrder.driverName ??
            (currentOrder.broadcastScope == 'office' ? 'مكتب النقل المحدد' : 'السائق المحدد');

        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تمت الموافقة على طلبك المباشر',
                          style: GoogleFonts.cairo(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textWhite
                                : const Color(0xFF065F46),
                          ),
                        ),
                        Text(
                          'وافق $providerName على تنفيذ الطلب بالأجرة المتفق عليها ($agreedFareVal ر.س).',
                          style: GoogleFonts.cairo(
                            fontSize: 11.0,
                            color: isDark
                                ? AppColors.textSubtle
                                : const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock_outlined,
                        size: 15, color: AppColors.primaryGold),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'رقم التواصل: ${currentOrder.maskedTargetPhone} (مشفر حتى إتمام الدفع)',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSubtle : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MerchantAssignmentPaymentScreen(
                        orderId: currentOrder.id,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.payment_rounded, size: 18),
                label: Text(
                  'تأكيد الاتفاق والدفع ($agreedFareVal ر.س)',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (currentOrder.directStatus == 'rejected') {
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cancel_outlined,
                    color: Color(0xFFEF4444), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اعتذار الجهة عن قبول الطلب المباشر',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF991B1B),
                      ),
                    ),
                    Text(
                      'اعتذر المزود المحدد عن تنفيذ هذا الطلب. لم يتم خصم أي مبالغ، ولا يتم تحويل الطلب تلقائياً وفقاً للسياسة.',
                      style: GoogleFonts.cairo(
                        fontSize: 10.5,
                        color: isDark ? AppColors.textSubtle : const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (currentOrder.directStatus == 'pending') {
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    color: Color(0xFF3B82F6), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب خاص موجه بانتظار الرد',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : const Color(0xFF1E40AF),
                      ),
                    ),
                    Text(
                      'الطلب مرسل حصرياً للجهة المحددة (${currentOrder.broadcastScope == "office" ? "مكتب نقل" : "سائق"}). بانتظار القبول أو الرفض.',
                      style: GoogleFonts.cairo(
                        fontSize: 10.5,
                        color: isDark ? AppColors.textSubtle : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }

    if (currentOrder.status == MerchantOrderStatus.assignedDriver ||
        currentOrder.status == MerchantOrderStatus.inTransit) {
      final driverName = currentOrder.driverName ?? 'كابتن معتمد';
      final phoneToDisplay = currentOrder.isPaid
          ? (currentOrder.targetProviderPhone ?? '+967 771 234 567')
          : currentOrder.maskedTargetPhone;

      return Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF10B981),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: GoogleFonts.cairo(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textWhite
                              : const Color(0xFF065F46),
                        ),
                      ),
                      Text(
                        'السائق المسند للرحلة • مرخص ومعتمد',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          color: isDark
                              ? AppColors.textSubtle
                              : const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white10
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (currentOrder.isPaid
                          ? const Color(0xFF10B981)
                          : AppColors.primaryGold)
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    currentOrder.isPaid
                        ? Icons.phone_enabled_rounded
                        : Icons.lock_clock_outlined,
                    size: 15,
                    color: currentOrder.isPaid
                        ? const Color(0xFF10B981)
                        : AppColors.primaryGold,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'رقم التواصل: $phoneToDisplay',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textWhite
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (currentOrder.isPaid
                              ? const Color(0xFF10B981)
                              : AppColors.primaryGold)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentOrder.isPaid ? 'الدفع مكتمل' : 'مشفر حتى الدفع',
                      style: GoogleFonts.cairo(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: currentOrder.isPaid
                            ? const Color(0xFF10B981)
                            : AppColors.primaryGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (widget.onDriverProfile != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onDriverProfile?.call(driverName);
                      },
                      icon: const Icon(Icons.person_outline, size: 16),
                      label: Text(
                        'ملف السائق',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (widget.onDriverProfile != null &&
                    widget.onLiveTracking != null)
                  const SizedBox(width: 8),
                if (widget.onLiveTracking != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onLiveTracking?.call(currentOrder.id);
                      },
                      icon: const Icon(Icons.near_me_outlined, size: 16),
                      label: Text(
                        'تتبع الرحلة',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    if (currentOrder.status == MerchantOrderStatus.pendingOffice) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAF5FF),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.apartment_rounded,
                  color: Color(0xFF8B5CF6), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الطلب بانتظار مكاتب النقل',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textWhite
                          : const Color(0xFF5B21B6),
                    ),
                  ),
                  Text(
                    'تم توجيه هذا الطلب إلى شبكة مكاتب النقل المعتمدة لتوفير أسطول شاحنات مناسب.',
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      height: 1.4,
                      color: isDark
                          ? AppColors.textSubtle
                          : const Color(0xFF6B21A8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Pending Driver or Draft
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_offer_outlined,
                    color: AppColors.primaryGold, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentOrder.offersCount > 0
                        ? '${currentOrder.offersCount} عروض متاحة حالياً'
                        : 'بانتظار عروض السائقين',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textWhite
                          : const Color(0xFF92400E),
                    ),
                  ),
                  Text(
                    currentOrder.offersCount > 0
                        ? 'يمكنك مراجعة أسعار وتقييمات السائقين'
                        : 'سيتم إشعارك فور تقديم أول عرض',
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      color: isDark
                          ? AppColors.textSubtle
                          : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (currentOrder.offersCount > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onReviewOffers?.call(currentOrder.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: const Color(0xFF0F172A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'مراجعة',
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(MerchantOrder currentOrder, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes_rounded,
                  size: 16.0, color: AppColors.primaryGold),
              const SizedBox(width: 6.0),
              Text(
                'ملاحظات وتعليمات الشحن',
                style: GoogleFonts.cairo(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w800,
                  color:
                      isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            currentOrder.notes!,
            style: GoogleFonts.cairo(
              fontSize: 12.0,
              height: 1.5,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelActionButton(
    BuildContext context,
    MerchantOrder currentOrder,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => _handleCancelOrder(context, currentOrder),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cancel_outlined,
              size: 16.0,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(width: 6.0),
            Text(
              currentOrder.status == MerchantOrderStatus.draft
                  ? 'حذف هذه المسودة'
                  : 'إلغاء طلب النقل',
              style: GoogleFonts.cairo(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
