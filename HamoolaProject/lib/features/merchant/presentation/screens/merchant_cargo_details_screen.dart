import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/cargo_card_item.dart';
import '../../domain/models/merchant_simulation_store.dart';
import 'merchant_create_cargo_screen.dart';

/// Screen displaying comprehensive details of a merchant's cargo profile.
/// Enables editing, viewing specifications, or safe deletion.
class MerchantCargoDetailsScreen extends StatelessWidget {
  final CargoCardItem cargo;
  final VoidCallback? onBack;
  final ValueChanged<CargoCardItem>? onEditCargo;
  final ValueChanged<CargoCardItem>? onCreateOrder;
  final ValueChanged<String>? onOrderDetails;

  const MerchantCargoDetailsScreen({
    super.key,
    required this.cargo,
    this.onBack,
    this.onEditCargo,
    this.onCreateOrder,
    this.onOrderDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = MerchantSimulationStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final currentCargo = store.getCargoById(cargo.id) ?? cargo;
        final isLinkedToActive = store.isCargoLinkedToActiveOrder(currentCargo.id);

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
                      _buildHeader(context, currentCargo, isLinkedToActive, isDark),

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
                              // Hero Image / Gallery
                              _buildHeroMedia(currentCargo, isDark),
                              const SizedBox(height: 16.0),

                              // Quick Info Bar (ID, Category, Status)
                              _buildQuickInfoCard(currentCargo, isLinkedToActive, isDark),
                              const SizedBox(height: 16.0),

                              // Specifications Grid (Weight, Qty, Packaging, Volume)
                              _buildSpecsGrid(currentCargo, isDark),
                              const SizedBox(height: 16.0),

                              // Description
                              if (currentCargo.description != null &&
                                  currentCargo.description!.trim().isNotEmpty) ...[
                                _buildDescriptionCard(currentCargo, isDark),
                                const SizedBox(height: 16.0),
                              ],

                              // Handling Requirements
                              _buildHandlingCard(currentCargo, isDark),
                              const SizedBox(height: 16.0),

                              // Documents
                              _buildDocumentsCard(currentCargo, isDark),
                              const SizedBox(height: 16.0),

                              // Linked Orders Section
                              if (currentCargo.linkedOrderIds.isNotEmpty) ...[
                                _buildLinkedOrdersCard(context, currentCargo, isDark),
                                const SizedBox(height: 16.0),
                              ],

                              const SizedBox(height: 24.0),
                            ],
                          ),
                        ),
                      ),

                      // 3. Bottom Sticky Action Bar
                      _buildBottomActionBar(context, currentCargo, isDark),
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

  Widget _buildHeader(
    BuildContext context,
    CargoCardItem currentCargo,
    bool isLinkedToActive,
    bool isDark,
  ) {
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
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            tooltip: AppStrings.back,
          ),
          Text(
            'تفاصيل الحمولة',
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 22.0, color: AppColors.error),
            onPressed: () => _handleDeleteCargo(context, currentCargo, isLinkedToActive),
            tooltip: 'حذف الحمولة',
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMedia(CargoCardItem currentCargo, bool isDark) {
    final image = currentCargo.imageAsset ??
        (currentCargo.photos.isNotEmpty ? currentCargo.photos.first : null);

    return Container(
      height: 190.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 14.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => _buildDefaultBanner(isDark),
              )
            else
              _buildDefaultBanner(isDark),
            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x220F172A),
                    Color(0xDD0F172A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Title & ID Overlay
            Positioned(
              bottom: 12.0,
              right: 14.0,
              left: 14.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentCargo.name,
                          style: GoogleFonts.cairo(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          currentCargo.category,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0x3DF59E0B),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: AppColors.primaryGold,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      currentCargo.id,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBanner(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 64.0,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _buildQuickInfoCard(
    CargoCardItem currentCargo,
    bool isLinkedToActive,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: const Color(0x24F59E0B),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  currentCargo.categoryIcon,
                  color: AppColors.primaryGold,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حالة الحمولة',
                    style: GoogleFonts.cairo(
                      fontSize: 11.0,
                      color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                    ),
                  ),
                  Text(
                    isLinkedToActive ? 'مرتبطة بطلب نشط' : currentCargo.status,
                    style: GoogleFonts.cairo(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: isLinkedToActive
                          ? AppColors.primaryGold
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: isLinkedToActive
                  ? const Color(0x26F59E0B)
                  : const Color(0x1F10B981),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isLinkedToActive
                    ? AppColors.primaryGold
                    : AppColors.success,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLinkedToActive
                      ? Icons.hourglass_top_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 14.0,
                  color: isLinkedToActive
                      ? AppColors.primaryGold
                      : AppColors.success,
                ),
                const SizedBox(width: 4.0),
                Text(
                  isLinkedToActive ? 'قيد المعالجة' : 'متاحة للطلب',
                  style: GoogleFonts.cairo(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    color: isLinkedToActive
                        ? AppColors.primaryGold
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid(CargoCardItem currentCargo, bool isDark) {
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
          Text(
            'المواصفات الفنية والحجم',
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.scale_rounded,
                  title: 'الوزن الإجمالي',
                  value: currentCargo.weight,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.format_list_numbered_rounded,
                  title: 'الكمية والعدد',
                  value: currentCargo.quantity,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.inventory_rounded,
                  title: 'نوع التغليف',
                  value: currentCargo.packagingType,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: _buildSpecItem(
                  icon: Icons.aspect_ratio_rounded,
                  title: 'الحجم التقريبي',
                  value: currentCargo.volume ?? 'غير محدد',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (currentCargo.isPerishable) ...[
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0x2EF59E0B),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.ac_unit_rounded,
                      size: 16.0, color: AppColors.primaryGold),
                  const SizedBox(width: 6.0),
                  Text(
                    'هذه الشحنة قابلة للتلف أو تتطلب عناية حرارية خاصة أثناء النقل',
                    style: GoogleFonts.cairo(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.0, color: AppColors.primaryGold),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(CargoCardItem currentCargo, bool isDark) {
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
          Text(
            'وصف البضاعة وملاحظات الشحن',
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            currentCargo.description!,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              height: 1.5,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandlingCard(CargoCardItem currentCargo, bool isDark) {
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
              const Icon(Icons.security_rounded,
                  size: 18.0, color: AppColors.primaryGold),
              const SizedBox(width: 8.0),
              Text(
                'متطلبات المناولة والحماية',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0x1AF59E0B),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0x3DF59E0B)),
            ),
            child: Row(
              children: [
                if (currentCargo.handlingIcon != null) ...[
                  Icon(currentCargo.handlingIcon,
                      size: 16.0, color: AppColors.primaryGold),
                  const SizedBox(width: 8.0),
                ],
                Expanded(
                  child: Text(
                    currentCargo.handlingRequirement,
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(CargoCardItem currentCargo, bool isDark) {
    final docs = currentCargo.documents;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.description_outlined,
                      size: 18.0, color: AppColors.primaryGold),
                  const SizedBox(width: 8.0),
                  Text(
                    'الوثائق والمستندات المرفقة',
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                  ),
                ],
              ),
              Text(
                '${docs.length} وثائق',
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          if (docs.isEmpty)
            Text(
              'لا توجد مستندات مرفقة لهذه الحمولة.',
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
              ),
            )
          else
            Column(
              children: docs.map((doc) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded,
                          size: 18.0, color: AppColors.error),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          doc,
                          style: GoogleFonts.cairo(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded,
                          size: 16.0, color: AppColors.success),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildLinkedOrdersCard(
    BuildContext context,
    CargoCardItem currentCargo,
    bool isDark,
  ) {
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
              const Icon(Icons.link_rounded,
                  size: 18.0, color: AppColors.primaryGold),
              const SizedBox(width: 8.0),
              Text(
                'الطلبات المرتبطة بهذه الحمولة',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Column(
            children: currentCargo.linkedOrderIds.map((orderId) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: const Color(0x1FF59E0B),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0x40F59E0B)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب نقل رقم #$orderId',
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            'طلب نشط — لا يمكن حذف الحمولة حتى اكتمال الطلب',
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () => onOrderDetails?.call(orderId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      child: Text(
                        'عرض الطلب',
                        style: GoogleFonts.cairo(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    CargoCardItem currentCargo,
    bool isDark,
  ) {
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
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                if (onEditCargo != null) {
                  onEditCargo!(currentCargo);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MerchantCreateCargoScreen(
                        initialCargo: currentCargo,
                        onBack: () => Navigator.of(context).pop(),
                        onSubmitCargo: (updated) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'تم تحديث بيانات الحمولة بنجاح: ${updated.name}'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 13.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18.0),
              label: Text(
                'تعديل الحمولة',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isDark ? AppColors.textWhite : AppColors.textMainLight,
                side: BorderSide(
                  color: isDark ? Colors.white24 : AppColors.borderLight,
                ),
                padding: const EdgeInsets.symmetric(vertical: 13.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'إغلاق',
                style: GoogleFonts.cairo(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeleteCargo(
    BuildContext context,
    CargoCardItem currentCargo,
    bool isLinkedToActive,
  ) {
    if (isLinkedToActive) {
      showDialog(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 24.0),
                const SizedBox(width: 8.0),
                Text(
                  'تعذر حذف الحمولة',
                  style: GoogleFonts.cairo(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            content: Text(
              'لا يمكن حذف الحمولة (${currentCargo.name}) لأنها مرتبطة بطلب نقل نشط حالياً (${currentCargo.linkedOrderIds.join(', ')}). يجب إنهاء أو إلغاء الطلب أولاً.',
              style: GoogleFonts.cairo(fontSize: 13.0),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('حسناً',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              'تأكيد حذف الحمولة',
              style: GoogleFonts.cairo(
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              'هل أنت متأكد من رغبتك في حذف الحمولة (${currentCargo.name})؟ لن تتمكن من التراجع عن هذه الخطوة.',
              style: GoogleFonts.cairo(fontSize: 13.0),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('إلغاء',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  final deleted = MerchantSimulationStore.instance
                      .deleteCargo(currentCargo.id);
                  if (deleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم حذف الحمولة بنجاح: ${currentCargo.name}'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.of(context).maybePop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: Text('حذف',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }
  }
}
