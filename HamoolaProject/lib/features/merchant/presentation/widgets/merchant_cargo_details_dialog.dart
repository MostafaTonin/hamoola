import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cargo_card_item.dart';
import '../../domain/models/merchant_simulation_store.dart';
import '../screens/merchant_create_cargo_screen.dart';

/// Professional Modal Dialog displaying complete cargo specifications,
/// gallery, usage history, and safe edit/delete actions per Hamoula UX.
class MerchantCargoDetailsDialog extends StatefulWidget {
  final CargoCardItem cargo;
  final VoidCallback? onCargoUpdated;
  final VoidCallback? onCargoDeleted;

  const MerchantCargoDetailsDialog({
    super.key,
    required this.cargo,
    this.onCargoUpdated,
    this.onCargoDeleted,
  });

  /// Static helper to display the details dialog
  static Future<void> show(
    BuildContext context,
    CargoCardItem cargo, {
    VoidCallback? onCargoUpdated,
    VoidCallback? onCargoDeleted,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => MerchantCargoDetailsDialog(
        cargo: cargo,
        onCargoUpdated: onCargoUpdated,
        onCargoDeleted: onCargoDeleted,
      ),
    );
  }

  @override
  State<MerchantCargoDetailsDialog> createState() =>
      _MerchantCargoDetailsDialogState();
}

class _MerchantCargoDetailsDialogState
    extends State<MerchantCargoDetailsDialog> {
  int _selectedPhotoIndex = 0;

  List<String> _getPhotos(CargoCardItem cargo) {
    if (cargo.photos.isNotEmpty) return cargo.photos;
    if (cargo.imageAsset != null) return [cargo.imageAsset!];
    return ['assets/images/cargo_ref_1.jpg'];
  }

  void _handleEditCargo(BuildContext context, CargoCardItem currentCargo) {
    Navigator.of(context).pop(); // Close dialog first
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MerchantCreateCargoScreen(
          initialCargo: currentCargo,
          onBack: () => Navigator.of(context).pop(),
          onSubmitCargo: (updated) {
            MerchantSimulationStore.instance.updateCargo(updated);
            widget.onCargoUpdated?.call();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم تحديث بيانات الحمولة "${updated.name}" بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleDeleteCargo(BuildContext context, CargoCardItem currentCargo) {
    final store = MerchantSimulationStore.instance;
    final isLinked = store.isCargoLinkedToActiveOrder(currentCargo.id);

    if (isLinked) {
      // Rule: Never delete cargo linked to active order
      final linkedIds = currentCargo.linkedOrderIds.join('، #');
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 26.0),
              const SizedBox(width: 8.0),
              Text(
                'تعذر حذف الحمولة',
                style: GoogleFonts.cairo(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          content: Text(
            'هذه الحمولة مرتبطة بطلب نقل نشط حالياً (#$linkedIds). يُمنع حذف الحمولة للحفاظ على سلامة سجلات النقل والعقود المبرمة حتى اكتمال الطلب.',
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              height: 1.5,
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
                'حسناً',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Confirm deletion
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'تأكيد حذف الحمولة',
            style: GoogleFonts.cairo(
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف حمولة "${currentCargo.name}" من سجلك؟ لا يمكن التراجع عن هذا الإجراء.',
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
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
                Navigator.of(ctx).pop(); // Close confirm dialog
                final success = store.deleteCargo(currentCargo.id);
                if (success) {
                  Navigator.of(context).pop(); // Close details dialog
                  widget.onCargoDeleted?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حذف الحمولة "${currentCargo.name}" بنجاح'),
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
                'حذف نهائي',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = MerchantSimulationStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final currentCargo = store.getCargoById(widget.cargo.id) ?? widget.cargo;
        final photos = _getPhotos(currentCargo);
        final clampedIndex = _selectedPhotoIndex.clamp(0, photos.length - 1);
        final activePhoto = photos[clampedIndex];

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            backgroundColor:
                isDark ? const Color(0xFF1E293B) : Colors.white,
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
                  // 1. Dialog Header with Title and Close Button
                  _buildDialogHeader(context, currentCargo, isDark),

                  // 2. Scrollable Body
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Gallery: Main Photo + Thumbnails
                          _buildMediaGallery(photos, activePhoto, isDark),
                          const SizedBox(height: 14.0),

                          // Status Badge and Edit Button Row
                          _buildStatusAndEditRow(context, currentCargo, isDark),
                          const SizedBox(height: 14.0),

                          // Cargo Title, Category & Description
                          _buildTitleAndDescription(currentCargo, isDark),
                          const SizedBox(height: 16.0),

                          // Specifications Grid (Weight, Qty, Packaging, Perishable)
                          _buildSpecsGrid(currentCargo, isDark),
                          const SizedBox(height: 16.0),

                          // Additional Information Section
                          _buildAdditionalInfoSection(currentCargo, isDark),
                          const SizedBox(height: 16.0),

                          // Usage History Section
                          _buildUsageHistorySection(currentCargo, isDark),
                          const SizedBox(height: 18.0),

                          // Secondary Safe Delete Action Button
                          _buildDeleteActionButton(context, currentCargo, isDark),
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
    CargoCardItem currentCargo,
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
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primaryGold,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الحمولة',
                    style: GoogleFonts.cairo(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                  ),
                  Text(
                    'معلومات الحمولة الكاملة',
                    style: GoogleFonts.cairo(
                      fontSize: 11.0,
                      color:
                          isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22.0),
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallery(
    List<String> photos,
    String activePhoto,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Image Frame
        ClipRRect(
          borderRadius: BorderRadius.circular(14.0),
          child: Stack(
            children: [
              Container(
                height: 160.0,
                width: double.infinity,
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                child: Image.asset(
                  activePhoto,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Center(
                    child: Icon(
                      Icons.inventory_2_rounded,
                      size: 54.0,
                      color: AppColors.primaryGold.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              // Counter Badge: 1/4
              Positioned(
                bottom: 8.0,
                right: 8.0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_outlined,
                          size: 13.0, color: Colors.white),
                      const SizedBox(width: 4.0),
                      Text(
                        '${_selectedPhotoIndex + 1}/${photos.length}',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Thumbnails Bar if multiple photos exist
        if (photos.length > 1) ...[
          const SizedBox(height: 8.0),
          SizedBox(
            height: 48.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (ctx, idx) => const SizedBox(width: 8.0),
              itemBuilder: (ctx, idx) {
                final isSelected = idx == _selectedPhotoIndex;
                return InkWell(
                  onTap: () => setState(() => _selectedPhotoIndex = idx),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    width: 58.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGold
                            : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: Image.asset(
                        photos[idx],
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: const Color(0xFF334155),
                          child: const Icon(Icons.image_outlined, size: 20.0),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusAndEditRow(
    BuildContext context,
    CargoCardItem currentCargo,
    bool isDark,
  ) {
    Color badgeColor;
    Color badgeBg;
    String statusText = currentCargo.status;

    if (currentCargo.status == 'مرتبطة بطلب نشط' ||
        currentCargo.hasActiveOrder ||
        currentCargo.status == 'قيد النقل') {
      badgeColor = const Color(0xFF3B82F6);
      badgeBg = const Color(0x1A3B82F6);
      statusText = 'مرتبطة بطلب نشط';
    } else if (currentCargo.status == 'مكتملة' ||
        currentCargo.status == 'مكتملة الاستخدام') {
      badgeColor = const Color(0xFF64748B);
      badgeBg = const Color(0x1A64748B);
      statusText = 'مكتملة الاستخدام';
    } else {
      badgeColor = const Color(0xFF10B981);
      badgeBg = const Color(0x1A10B981);
      statusText = 'متاحة للاستخدام';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7.0,
                height: 7.0,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6.0),
              Text(
                statusText,
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ],
          ),
        ),

        // Edit Cargo Button
        OutlinedButton.icon(
          onPressed: () => _handleEditCargo(context, currentCargo),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                isDark ? AppColors.textWhite : AppColors.textMainLight,
            side: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xFFCBD5E1),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            minimumSize: const Size(0, 32),
          ),
          icon: const Icon(Icons.edit_outlined, size: 14.0),
          label: Text(
            'تعديل الحمولة',
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndDescription(
    CargoCardItem currentCargo,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Icon in subtle box
        Container(
          width: 42.0,
          height: 42.0,
          decoration: BoxDecoration(
            color: const Color(0x1A3B82F6),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(
            currentCargo.categoryIcon,
            color: const Color(0xFF2563EB),
            size: 22.0,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentCargo.name,
                style: GoogleFonts.cairo(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
              Row(
                children: [
                  Text(
                    currentCargo.category,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSubtle
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (currentCargo.subCategory != null) ...[
                    Text(
                      ' • ${currentCargo.subCategory}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textSubtle
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
              if (currentCargo.description != null &&
                  currentCargo.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 6.0),
                Text(
                  currentCargo.description!,
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    height: 1.45,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF475569),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsGrid(
    CargoCardItem currentCargo,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.scale_rounded,
                  iconColor: AppColors.primaryGold,
                  label: 'الوزن الإجمالي',
                  value: currentCargo.weight,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1.0,
                height: 38.0,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
              ),
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  label: 'الكمية',
                  value: currentCargo.quantity,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const Divider(height: 16.0, thickness: 1.0),
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.layers_outlined,
                  iconColor: const Color(0xFF10B981),
                  label: 'نوع التغليف',
                  value: currentCargo.packagingType,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1.0,
                height: 38.0,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0),
              ),
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.shield_outlined,
                  iconColor: currentCargo.isPerishable
                      ? AppColors.error
                      : const Color(0xFF64748B),
                  label: 'قابل للتلف',
                  value: currentCargo.isPerishable ? 'نعم (حساس)' : 'لا',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18.0, color: iconColor),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    color: isDark
                        ? AppColors.textSubtle
                        : AppColors.textMutedLight,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(
    CargoCardItem currentCargo,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined,
                  size: 16.0, color: Color(0xFF2563EB)),
              const SizedBox(width: 6.0),
              Text(
                'معلومات إضافية',
                style: GoogleFonts.cairo(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          _buildInfoRow(
            icon: Icons.tag_rounded,
            title: 'تصنيف فرعي',
            detail: currentCargo.subCategory ?? currentCargo.category,
            isDark: isDark,
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.checklist_rounded,
            title: 'تعليمات المناولة',
            detail: currentCargo.handlingRequirement,
            isDark: isDark,
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.comment_outlined,
            title: 'ملاحظات',
            detail: currentCargo.notes ??
                (currentCargo.description ?? 'لا توجد ملاحظات إضافية'),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageHistorySection(
    CargoCardItem currentCargo,
    bool isDark,
  ) {
    final date = currentCargo.createdAtFormatted ?? '2026/10/05';
    final usageText = currentCargo.usageCount > 0
        ? '${currentCargo.usageCount} طلب نقل'
        : (currentCargo.linkedOrderIds.isNotEmpty
            ? '${currentCargo.linkedOrderIds.length} طلب نقل'
            : 'لم تُستخدم بعد');
    final lastOrder = currentCargo.linkedOrderIds.isNotEmpty
        ? currentCargo.linkedOrderIds.last
        : 'لا يوجد';

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 16.0, color: Color(0xFF2563EB)),
              const SizedBox(width: 6.0),
              Text(
                'سجل الاستخدام',
                style: GoogleFonts.cairo(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            title: 'تاريخ الإضافة',
            detail: date,
            isDark: isDark,
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.repeat_rounded,
            title: 'عدد مرات الاستخدام',
            detail: usageText,
            isDark: isDark,
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            icon: Icons.receipt_long_rounded,
            title: 'آخر طلب مرتبط',
            detail: lastOrder,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String detail,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.0, color: const Color(0xFF64748B)),
        const SizedBox(width: 8.0),
        SizedBox(
          width: 105.0,
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            detail,
            style: GoogleFonts.cairo(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteActionButton(
    BuildContext context,
    CargoCardItem currentCargo,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => _handleDeleteCargo(context, currentCargo),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0x12EF4444),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: const Color(0x4DEF4444),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  size: 18.0,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'حذف الحمولة',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_back_ios_rounded,
              size: 12.0,
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}
