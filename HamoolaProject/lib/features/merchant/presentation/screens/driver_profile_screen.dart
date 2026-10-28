import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/communication_launcher.dart';
import '../../domain/models/merchant_order.dart';
import '../../domain/models/transport_order_draft.dart';
import '../../../transport_office/domain/models/transport_office_drivers_store.dart';

/// Screen representing the Driver Profile screen in Hamoola.
/// Faithfully reproduces Image 1:
/// - Hero header with scenic truck photo, online status, and distance badge
/// - Floating driver avatar with verified badge
/// - 4 Quick stat cards: Completed trips (+200), In platform (3 years), Max load (20 ton), Vehicle type (Truck)
/// - "نبذة عني" (About me) section
/// - "معلومات المركبة" (Vehicle specs) with photo thumbnail and feature chips
/// - "أنواع الحمولات المنقولة" (Cargo types chips)
/// - "مناطق الخدمة" (Service routes)
/// - "تقييمات العملاء" (Customer reviews)
/// - Fixed bottom bar with "طلب نقل" CTA and "مراسلة" WhatsApp button
class DriverProfileScreen extends StatefulWidget {
  final DriverProfile driver;
  final VoidCallback? onBack;
  final ValueChanged<DriverProfile>? onDirectOrder;
  final ValueChanged<DriverProfile>? onCreateNewOrderWithDriver;
  final ValueChanged<String>? onCall;
  final ValueChanged<String>? onMessage;

  const DriverProfileScreen({
    super.key,
    this.driver = DriverProfile.demoDriver,
    this.onBack,
    this.onDirectOrder,
    this.onCreateNewOrderWithDriver,
    this.onCall,
    this.onMessage,
  });

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late String _selectedCargo;

  @override
  void initState() {
    super.initState();
    _selectedCargo = widget.driver.selectedCargoType;
    TransportOfficeDriversStore.instance.addListener(_onEndorsementStoreChanged);
  }

  @override
  void dispose() {
    TransportOfficeDriversStore.instance.removeListener(_onEndorsementStoreChanged);
    super.dispose();
  }

  void _onEndorsementStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final driver = widget.driver;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.navyDark : const Color(0xFFF8FAFC),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.compactMax,
            ),
            child: Stack(
              children: [
                // Scrollable Content
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      // 1. Hero Cover Image & Driver Header
                      _buildHeroSection(driver, isDark),

                      // 2. Driver Identity Card (Name, Verified badge, Profession, Rating)
                      _buildIdentitySection(driver, isDark),

                      const SizedBox(height: 14),

                      // 3. 4 Quick Stats Cards
                      _buildStatsRow(driver, isDark),

                      const SizedBox(height: 14),

                      // 4. Section: نبذة عني
                      _buildBioSection(driver, isDark),

                      const SizedBox(height: 14),

                      // 5. Section: معلومات المركبة
                      _buildVehicleSection(driver, isDark),

                      const SizedBox(height: 14),

                      // 6. Section: أنواع الحمولات المنقولة
                      _buildCargoTypesSection(driver, isDark),

                      const SizedBox(height: 14),

                      // 7. Section: مناطق الخدمة
                      _buildServiceAreasSection(driver, isDark),

                      const SizedBox(height: 14),

                      // 8. Section: تقييمات العملاء
                      _buildReviewsSection(driver, isDark),

                      const SizedBox(height: 14),

                      // 8.5. Section: التزكيات (Endorsements)
                      _buildEndorsementsSection(driver, isDark),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // 9. Bottom Fixed Action Bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomActionBar(driver, isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(DriverProfile driver, bool isDark) {
    return SizedBox(
      height: 250,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Hero Truck Image
          Positioned.fill(
            child: Image.asset(
              driver.heroTruckAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF334155),
                child: const Center(
                  child: Icon(Icons.local_shipping_rounded,
                      size: 64, color: Colors.white54),
                ),
              ),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          // Top App Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  _buildCircleBtn(
                    icon: Icons.arrow_forward_ios_rounded,
                    onTap: widget.onBack,
                    tooltip: AppStrings.back,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الملف الشخصي للسائق',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCircleBtn(
                    icon: Icons.share_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ رابط ملف السائق'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    tooltip: 'مشاركة',
                  ),
                  const SizedBox(width: 8),
                  _buildCircleBtn(
                    icon: Icons.more_vert_rounded,
                    onTap: () {},
                    tooltip: 'خيارات',
                  ),
                ],
              ),
            ),
          ),

          // Status & Location Overlay (Bottom Left of Hero)
          Positioned(
            left: 14,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'متاح الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                // Location Pin & Distance
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.city} • ${driver.distance}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Circular Avatar Overlapping Bottom Edge (Bottom Right)
          Positioned(
            right: 18,
            bottom: -38,
            child: Stack(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.navyDark : Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      driver.avatarAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1E293B),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryGold,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
                // Green Verified Check Badge on Avatar
                Positioned(
                  bottom: 2,
                  left: 2,
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
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

  Widget _buildCircleBtn({
    required IconData icon,
    VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildIdentitySection(DriverProfile driver, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 46, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        driver.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // "موثق" badge
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 12, color: Color(0xFF16A34A)),
                          const SizedBox(width: 3),
                          Text(
                            'موثق',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  driver.profession,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                // Rating line
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 17, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      driver.rating.toStringAsFixed(1),
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '(${driver.reviewsCount} تقييم)',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11,
                        color: isDark ? AppColors.textSubtle : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DriverProfile driver, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 1. رحلة مكتملة: +200
          Expanded(
            child: _buildStatCard(
              icon: Icons.description_outlined,
              value: '+${driver.completedTrips}',
              label: 'رحلة مكتملة',
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),

          // 2. في المنصة: 3 سنوات
          Expanded(
            child: _buildStatCard(
              icon: Icons.shield_outlined,
              value: driver.yearsOnPlatform,
              label: 'في المنصة',
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),

          // 3. الحمولة القصوى: 20 طن
          Expanded(
            child: _buildStatCard(
              icon: Icons.fitness_center_rounded,
              value: driver.capacity,
              label: 'الحمولة القصوى',
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),

          // 4. نوع المركبة: شاحنة
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_shipping_outlined,
              value: driver.vehicleType,
              label: 'نوع المركبة',
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(DriverProfile driver, bool isDark) {
    return _buildSectionContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.person_rounded,
            title: 'نبذة عني',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Text(
            driver.bio,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              height: 1.6,
              color: isDark ? AppColors.textSubtle : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSection(DriverProfile driver, bool isDark) {
    return _buildSectionContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.local_shipping_rounded,
            title: 'معلومات المركبة',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                // Vehicle Thumbnail Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    driver.heroTruckAsset,
                    width: 92,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 92,
                      height: 70,
                      color: const Color(0xFFCBD5E1),
                      child: const Icon(Icons.local_shipping_rounded,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            driver.vehicleModel,
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              driver.vehicleType,
                              style: GoogleFonts.cairo(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'موديل ${driver.vehicleYear} | لوحة رقم: ${driver.plateNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          color: isDark
                              ? AppColors.textSubtle
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Mini Chips (جيدة جداً, مغلقة, 20 طن)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildVehicleMiniChip(
                            icon: Icons.build_rounded,
                            text: driver.vehicleCondition,
                            isDark: isDark,
                          ),
                          _buildVehicleMiniChip(
                            icon: Icons.inventory_2_outlined,
                            text: driver.vehicleBoxType,
                            isDark: isDark,
                          ),
                          _buildVehicleMiniChip(
                            icon: Icons.shopping_bag_outlined,
                            text: driver.capacity,
                            isDark: isDark,
                          ),
                        ],
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

  Widget _buildVehicleMiniChip({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: const Color(0xFF64748B)),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textWhite : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCargoTypesSection(DriverProfile driver, bool isDark) {
    return _buildSectionContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.all_inbox_rounded,
            title: 'أنواع الحمولات المنقولة',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: driver.supportedCargoTypes.map((type) {
              final isSelected = _selectedCargo == type;

              return InkWell(
                onTap: () => setState(() => _selectedCargo = type),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFCBD5E1)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        type,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textWhite
                                  : const Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceAreasSection(DriverProfile driver, bool isDark) {
    return _buildSectionContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.alt_route_rounded,
            title: 'مناطق الخدمة',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    driver.serviceRoutes,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3A8A),
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

  Widget _buildReviewsSection(DriverProfile driver, bool isDark) {
    return _buildSectionContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSectionHeader(
                  icon: Icons.star_rounded,
                  title: 'تقييمات العملاء',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('عرض سجل تقييمات العملاء الكامل'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
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
                    // Company Avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDBEAFE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.business_rounded,
                          size: 18, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.latestReviewer,
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            driver.latestReviewDate,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.textSubtle
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stars
                    Row(
                      children: [
                        Text(
                          driver.latestReviewRating.toStringAsFixed(1),
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ...List.generate(
                          5,
                          (i) => const Icon(Icons.star_rounded,
                              size: 14, color: Color(0xFFF59E0B)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '“${driver.latestReviewText}”',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    height: 1.5,
                    color: isDark
                        ? AppColors.textSubtle
                        : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section: التزكيات (Endorsements from Transport Offices)
  // ===========================================================================
  Widget _buildEndorsementsSection(DriverProfile driver, bool isDark) {
    final store = TransportOfficeDriversStore.instance;
    // Look up in store by ID or by name
    final matchingDriver = store.findDriverById(driver.id) ??
        store.searchDrivers(driver.name).firstOrNull;

    final List<EndorsingOfficeInfo> offices = matchingDriver?.endorsingOffices ??
        (driver.isVerified
            ? [
                const EndorsingOfficeInfo(
                  officeId: 'OFFICE-01',
                  officeName: 'مكتب النور للنقل السريع',
                  officeLogo: 'assets/images/merchant_company_logo.png',
                ),
              ]
            : const []);

    return _buildSectionContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSectionHeader(
                  icon: Icons.verified_user_rounded,
                  title: 'التزكيات',
                  isDark: isDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Text(
                  '${offices.length} مكاتب معتمدة',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (offices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'لا توجد تزكيات مسجلة من مكاتب النقل حالياً.',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                ),
              ),
            )
          else
            Column(
              children: offices.map((office) {
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dlgCtx) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.business_rounded,
                                    size: 20,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  office.officeName,
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            'مكتب نقل بري مرخص ومعتمد لدى منصة حمولة يزكي هذا السائق بناءً على سجل أدائه وسلامة المنقولات.',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              color: const Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dlgCtx),
                              child: Text(
                                'إغلاق',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Office Logo / Icon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEFF6FF),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              office.officeLogo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.business_rounded,
                                size: 18,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Office Name
                        Expanded(
                          child: Text(
                            office.officeName,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2563EB)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(DriverProfile driver, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // WhatsApp / Messaging Button (Left)
          Expanded(
            flex: 4,
            child: OutlinedButton.icon(
              onPressed: () {
                if (widget.onMessage != null) {
                  widget.onMessage!(driver.phone);
                } else {
                  CommunicationLauncher.openWhatsApp(
                    context,
                    phoneNumber: driver.phone,
                    message:
                        'مرحباً يا كابتن ${driver.name}، تواصلت معك عبر منصة حمولة بخصوص طلب نقل.',
                  );
                }
              },
              icon: const Icon(Icons.chat_bubble_rounded,
                  size: 18, color: Color(0xFF16A34A)),
              label: Text(
                'مراسلة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16A34A),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF86EFAC), width: 1.5),
                backgroundColor: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF0FDF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Primary Blue "طلب نقل" CTA (Right)
          Expanded(
            flex: 6,
            child: ElevatedButton.icon(
              onPressed: () => _showOrderSelectionModal(context, driver),
              icon: const Icon(Icons.local_shipping_outlined,
                  size: 20, color: Colors.white),
              label: Text(
                'طلب نقل',
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderSelectionModal(BuildContext context, DriverProfile driver) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingOrders = MerchantOrder.demoOrders
        .where((o) => o.status == MerchantOrderStatus.pendingDriver)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(sheetContext).padding.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.local_shipping_outlined,
                              size: 20, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طلب نقل من ${driver.name}',
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textWhite
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'اختر طلباً موجوداً أو أنشئ طلباً جديداً',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textSubtle
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Case A: Existing orders
                if (pendingOrders.isNotEmpty) ...[
                  Text(
                    'طلبات النقل الحالية (بانتظار سائق)',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: pendingOrders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (ctx, idx) {
                        final order = pendingOrders[idx];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  size: 18, color: Color(0xFFD97706)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${order.id} — ${order.cargoName}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.textWhite
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      '${order.originCity} ← ${order.destinationCity}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.textSubtle
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  // Assign driver to existing order simulation
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'تم إسناد الطلب ${order.id} إلى الكابتن ${driver.name} بنجاح'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  widget.onDirectOrder?.call(driver);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'إسناد للسائق',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Case B: Create new order
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.add_circle_outline_rounded,
                              size: 18, color: Color(0xFF2563EB)),
                          const SizedBox(width: 8),
                          Text(
                            'إنشاء طلب نقل جديد لهذا السائق',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textWhite
                                  : const Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'سيتم تحديد الكابتن ${driver.name} تلقائياً كجهة مستهدفة',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSubtle
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            if (widget.onCreateNewOrderWithDriver != null) {
                              widget.onCreateNewOrderWithDriver!(driver);
                            } else {
                              widget.onDirectOrder?.call(driver);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'إنشاء طلب نقل جديد',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
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
      },
    );
  }
}

