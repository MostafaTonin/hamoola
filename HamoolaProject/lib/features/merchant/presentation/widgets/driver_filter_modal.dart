import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/tracking_models.dart';

/// Bottom Sheet modal for filtering drivers and vehicles on the map.
/// Faithfully reproduces Image 1 ("تصفية السائقين"):
/// - Top drag handle, close button (X), and reset button ("إعادة تعيين")
/// - Vehicle Category grid: الكل, شاحنات, قاطرات, دينات, تبريد ❄️, أخرى (No tractors!)
/// - Driver Status options: متاح الآن (Green), قيد النقل (Orange), غير متاح (Grey)
/// - Governorate dropdown (جميع المحافظات, صنعاء, عدن, تعز, الحديدة, مأرب, حضرموت, etc.)
/// - City / District dropdown (reactive to chosen governorate)
/// - Cargo Type selection: مواد بناء, مواد غذائية, أثاث, مواد نفطية, أخرى
/// - Primary Action CTA: "تطبيق الفلتر" with "سيتم تحديث الخريطة والنتائج تلقائياً"
class DriverFilterModal extends StatefulWidget {
  final DriverFilterCriteria initialCriteria;
  final ValueChanged<DriverFilterCriteria> onApply;
  final VoidCallback? onReset;

  const DriverFilterModal({
    super.key,
    required this.initialCriteria,
    required this.onApply,
    this.onReset,
  });

  static Future<void> show(
    BuildContext context, {
    required DriverFilterCriteria initialCriteria,
    required ValueChanged<DriverFilterCriteria> onApply,
    VoidCallback? onReset,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => DriverFilterModal(
        initialCriteria: initialCriteria,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<DriverFilterModal> createState() => _DriverFilterModalState();
}

class _DriverFilterModalState extends State<DriverFilterModal> {
  late DriverFilterCriteria _tempCriteria;

  // List of Yemeni and Regional Governorates
  static const List<Map<String, String>> _governorates = [
    {'key': 'all', 'label': 'جميع المحافظات'},
    {'key': 'صنعاء', 'label': 'صنعاء (العاصمة والمحافظة)'},
    {'key': 'عدن', 'label': 'عدن'},
    {'key': 'تعز', 'label': 'تعز'},
    {'key': 'الحديدة', 'label': 'الحديدة'},
    {'key': 'مأرب', 'label': 'مأرب'},
    {'key': 'حضرموت', 'label': 'حضرموت'},
    {'key': 'إب', 'label': 'إب'},
    {'key': 'ذمار', 'label': 'ذمار'},
    {'key': 'صعدة', 'label': 'صعدة'},
    {'key': 'المهرة', 'label': 'المهرة'},
    {'key': 'شبوة', 'label': 'شبوة'},
    {'key': 'السعودية', 'label': 'المملكة العربية السعودية (إقليمي)'},
    {'key': 'عمان', 'label': 'سلطنة عُمان (إقليمي)'},
    {'key': 'الإمارات', 'label': 'الإمارات العربية المتحدة (إقليمي)'},
  ];

  // Districts / Cities mapping for each governorate
  static const Map<String, List<Map<String, String>>> _districtsByGov = {
    'all': [
      {'key': 'all', 'label': 'جميع المدن والمناطق'},
    ],
    'صنعاء': [
      {'key': 'all', 'label': 'جميع مدن ومناطق صنعاء'},
      {'key': 'أمانة العاصمة', 'label': 'أمانة العاصمة'},
      {'key': 'همدان', 'label': 'همدان'},
      {'key': 'بني الحارث', 'label': 'بني الحارث'},
      {'key': 'سنحان', 'label': 'سنحان'},
      {'key': 'معين', 'label': 'معين'},
      {'key': 'السبعين', 'label': 'السبعين'},
    ],
    'عدن': [
      {'key': 'all', 'label': 'جميع مناطق عدن'},
      {'key': 'المنصورة', 'label': 'المنصورة'},
      {'key': 'المعلا', 'label': 'المعلا'},
      {'key': 'كريتر', 'label': 'كريتر'},
      {'key': 'الشيخ عثمان', 'label': 'الشيخ عثمان'},
      {'key': 'خور مكسر', 'label': 'خور مكسر'},
    ],
    'تعز': [
      {'key': 'all', 'label': 'جميع مناطق تعز'},
      {'key': 'الحوبان', 'label': 'الحوبان'},
      {'key': 'المظفر', 'label': 'المظفر'},
      {'key': 'القاهرة', 'label': 'القاهرة'},
      {'key': 'التربة', 'label': 'التربة'},
    ],
    'الحديدة': [
      {'key': 'all', 'label': 'جميع مناطق الحديدة'},
      {'key': 'الميناء', 'label': 'الميناء'},
      {'key': 'الحالي', 'label': 'الحالي'},
      {'key': 'الحوك', 'label': 'الحوك'},
      {'key': 'باجل', 'label': 'باجل'},
    ],
    'مأرب': [
      {'key': 'all', 'label': 'جميع مناطق مأرب'},
      {'key': 'المدينة', 'label': 'المدينة'},
      {'key': 'الوادي', 'label': 'الوادي'},
      {'key': 'حريب', 'label': 'حريب'},
    ],
    'حضرموت': [
      {'key': 'all', 'label': 'جميع مناطق حضرموت'},
      {'key': 'المكلا', 'label': 'المكلا'},
      {'key': 'سيئون', 'label': 'سيئون'},
      {'key': 'الشحر', 'label': 'الشحر'},
    ],
    'السعودية': [
      {'key': 'all', 'label': 'جميع مدن السعودية'},
      {'key': 'الرياض', 'label': 'الرياض'},
      {'key': 'جدة', 'label': 'جدة'},
      {'key': 'الدمام', 'label': 'الدمام'},
      {'key': 'جازان', 'label': 'جازان'},
      {'key': 'نجران', 'label': 'نجران'},
    ],
    'عمان': [
      {'key': 'all', 'label': 'جميع مدن عُمان'},
      {'key': 'مسقط', 'label': 'مسقط'},
      {'key': 'صلالة', 'label': 'صلالة'},
      {'key': 'صحار', 'label': 'صحار'},
      {'key': 'المزيونة', 'label': 'المزيونة'},
    ],
    'الإمارات': [
      {'key': 'all', 'label': 'جميع مدن الإمارات'},
      {'key': 'أبوظبي', 'label': 'أبوظبي'},
      {'key': 'دبي', 'label': 'دبي'},
      {'key': 'الشارقة', 'label': 'الشارقة'},
    ],
  };

  static const List<Map<String, dynamic>> _vehicleCategories = [
    {'key': 'all', 'label': 'الكل', 'icon': Icons.local_shipping_rounded},
    {'key': 'شاحنات', 'label': 'شاحنات', 'icon': Icons.local_shipping_outlined},
    {'key': 'قاطرات', 'label': 'قاطرات', 'icon': Icons.rv_hookup_rounded},
    {'key': 'دينات', 'label': 'دينات', 'icon': Icons.fire_truck_outlined},
    {'key': 'تبريد', 'label': 'تبريد', 'icon': Icons.ac_unit_rounded},
    {'key': 'أخرى', 'label': 'أخرى', 'icon': Icons.more_horiz_rounded},
  ];

  static const List<Map<String, dynamic>> _cargoTypes = [
    {'key': 'مواد بناء', 'label': 'مواد بناء', 'icon': Icons.foundation_rounded},
    {'key': 'مواد غذائية', 'label': 'مواد غذائية', 'icon': Icons.apple_rounded},
    {'key': 'أثاث', 'label': 'أثاث', 'icon': Icons.chair_rounded},
    {'key': 'مواد نفطية', 'label': 'مواد نفطية', 'icon': Icons.water_drop_rounded},
    {'key': 'أخرى', 'label': 'أخرى', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tempCriteria = widget.initialCriteria;
  }

  void _resetFilters() {
    setState(() {
      _tempCriteria = const DriverFilterCriteria();
    });
    widget.onReset?.call();
  }

  void _applyFilters() {
    widget.onApply(_tempCriteria);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row: Reset Button (Right) | Title | Close (Left)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: Row(
                  children: [
                    // Reset Button (Right side in RTL)
                    TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh_rounded,
                          size: 16, color: Color(0xFF2563EB)),
                      label: Text(
                        'إعادة تعيين',
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),

                    // Centered Title
                    Expanded(
                      child: Text(
                        'تصفية السائقين',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.textMainLight,
                        ),
                      ),
                    ),

                    // Close Button (Left side in RTL)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: isDark
                          ? AppColors.textWhite
                          : const Color(0xFF64748B),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'إغلاق',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Scrollable Filter Sections
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Vehicle Category Section
                      _buildSectionTitle(
                        icon: Icons.local_shipping_outlined,
                        title: 'نوع المركبة',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildVehicleCategoryGrid(isDark),
                      const SizedBox(height: 18),

                      // 2. Driver Availability Status Section
                      _buildSectionTitle(
                        icon: Icons.radio_button_checked_rounded,
                        title: 'حالة السائق',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildDriverStatusPills(isDark),
                      const SizedBox(height: 18),

                      // 3. Governorate Dropdown
                      _buildSectionTitle(
                        icon: Icons.location_on_outlined,
                        title: 'المحافظة',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildGovernorateDropdown(isDark),
                      const SizedBox(height: 18),

                      // 4. City / District Dropdown (اختياري)
                      _buildSectionTitle(
                        icon: Icons.location_city_rounded,
                        title: 'المدينة / المنطقة (اختياري)',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildDistrictDropdown(isDark),
                      const SizedBox(height: 18),

                      // 5. Cargo Type Section (اختياري)
                      _buildSectionTitle(
                        icon: Icons.inventory_2_outlined,
                        title: 'نوع الحمولة (اختياري)',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _buildCargoTypeChips(isDark),
                    ],
                  ),
                ),
              ),

              // Bottom Actions Bar: Apply CTA & helper note
              Container(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFF1F5F9),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.filter_alt_rounded,
                            size: 18, color: Colors.white),
                        label: Text(
                          'تطبيق الفلتر',
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
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'سيتم تحديث الخريطة والنتائج تلقائياً',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSubtle
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2563EB)),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCategoryGrid(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Render in 3 columns
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _vehicleCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final cat = _vehicleCategories[index];
            final isSelected = _tempCriteria.vehicleCategory == cat['key'];
            final icon = cat['icon'] as IconData;

            return InkWell(
              onTap: () {
                setState(() {
                  _tempCriteria =
                      _tempCriteria.copyWith(vehicleCategory: cat['key']);
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFFEFF6FF))
                      : (isDark ? const Color(0xFF0F172A) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFE2E8F0)),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Stack(
                  children: [
                    // Checkmark badge in corner when selected
                    if (isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              size: 10, color: Colors.white),
                        ),
                      ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 22,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF475569)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat['label'],
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : (isDark
                                      ? AppColors.textWhite
                                      : const Color(0xFF334155)),
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
      },
    );
  }

  Widget _buildDriverStatusPills(bool isDark) {
    final statuses = [
      {
        'key': 'available',
        'label': 'متاح الآن',
        'color': const Color(0xFF16A34A)
      },
      {'key': 'busy', 'label': 'قيد النقل', 'color': const Color(0xFFF59E0B)},
      {'key': 'offline', 'label': 'غير متاح', 'color': const Color(0xFF94A3B8)},
    ];

    return Row(
      children: statuses.map((st) {
        final key = st['key'] as String;
        final isSelected = _tempCriteria.availabilityStatus == key;
        final color = st['color'] as Color;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () {
                setState(() {
                  // If already selected, toggle back to 'all'
                  final newStatus = isSelected ? 'all' : key;
                  _tempCriteria =
                      _tempCriteria.copyWith(availabilityStatus: newStatus);
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFFEFF6FF))
                      : (isDark ? const Color(0xFF0F172A) : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      st['label'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : (isDark
                                ? AppColors.textWhite
                                : const Color(0xFF334155)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 14,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGovernorateDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _tempCriteria.governorate,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B)),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              // Reset city if not applicable to new governorate
              _tempCriteria = _tempCriteria.copyWith(
                governorate: val,
                cityOrDistrict: 'all',
              );
            });
          },
          items: _governorates.map((g) {
            return DropdownMenuItem<String>(
              value: g['key'],
              child: Text(
                g['label']!,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown(bool isDark) {
    final gov = _tempCriteria.governorate;
    final districts = _districtsByGov[gov] ?? _districtsByGov['all']!;

    // Validate current selection
    final validKeys = districts.map((d) => d['key']).toSet();
    final currentVal = validKeys.contains(_tempCriteria.cityOrDistrict)
        ? _tempCriteria.cityOrDistrict
        : 'all';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B)),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _tempCriteria = _tempCriteria.copyWith(cityOrDistrict: val);
            });
          },
          items: districts.map((d) {
            return DropdownMenuItem<String>(
              value: d['key'],
              child: Text(
                d['label']!,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCargoTypeChips(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _cargoTypes.map((cargo) {
          final isSelected = _tempCriteria.cargoType == cargo['key'];
          final icon = cargo['icon'] as IconData;

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  final newCargo = isSelected ? 'all' : cargo['key'] as String;
                  _tempCriteria = _tempCriteria.copyWith(cargoType: newCargo);
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFFEFF6FF))
                      : (isDark ? const Color(0xFF0F172A) : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cargo['label'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : (isDark
                                ? AppColors.textWhite
                                : const Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
