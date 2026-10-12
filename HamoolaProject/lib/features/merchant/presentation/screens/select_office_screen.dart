import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/buttons/hamula_button.dart';
import '../../domain/models/transport_order_draft.dart';

enum OfficeViewMode {
  list,
  map,
}

/// Screen allowing merchant to choose a certified transport office
class SelectOfficeScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<TransportOffice>? onOfficeSelected;

  const SelectOfficeScreen({
    super.key,
    this.onBack,
    this.onOfficeSelected,
  });

  @override
  State<SelectOfficeScreen> createState() => _SelectOfficeScreenState();
}

class _SelectOfficeScreenState extends State<SelectOfficeScreen> {
  final _searchController = TextEditingController();
  OfficeViewMode _viewMode = OfficeViewMode.list;
  String _selectedCity = 'all';
  TransportOffice? _selectedMapOffice;

  static const List<String> _cities = ['all', 'صنعاء', 'عدن', 'الحديدة', 'مأرب'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransportOffice> get _filteredOffices {
    return TransportOffice.demoOffices.where((office) {
      final matchesCity =
          _selectedCity == 'all' || office.city == _selectedCity;
      final q = _searchController.text.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          office.name.toLowerCase().contains(q) ||
          office.city.toLowerCase().contains(q) ||
          office.services.toLowerCase().contains(q);
      return matchesCity && matchesQuery;
    }).toList();
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
              child: Column(
                children: [
                  // 1. Header
                  _buildHeader(isDark),

                  // 2. Search & Filter Bar
                  _buildSearchBar(isDark),

                  // 3. City Chips
                  _buildCityFilterChips(isDark),

                  // 4. View Mode Toggle
                  _buildViewToggleBar(isDark),

                  // 5. Body (List or Map)
                  Expanded(
                    child: _viewMode == OfficeViewMode.list
                        ? _buildOfficeList(isDark)
                        : _buildOfficeMapView(isDark),
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            onPressed: widget.onBack,
            tooltip: AppStrings.back,
          ),
          Text(
            AppStrings.selectOfficeTitle,
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.cairo(
          fontSize: 13,
          color: isDark ? AppColors.textWhite : AppColors.textMainLight,
        ),
        decoration: InputDecoration(
          hintText: AppStrings.searchOfficeHint,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.borderLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCityFilterChips(bool isDark) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _cities.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = _cities[index];
          final isSelected = _selectedCity == city;
          final label = city == 'all' ? AppStrings.allFilter : city;

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) setState(() => _selectedCity = city);
            },
            selectedColor: AppColors.primaryGold,
            labelStyle: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.black
                  : (isDark ? AppColors.textWhite : AppColors.textMainLight),
            ),
            backgroundColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primaryGold
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.borderLight),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewToggleBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleBtn(
              label: AppStrings.officeListViewBtn,
              icon: Icons.format_list_bulleted_rounded,
              isActive: _viewMode == OfficeViewMode.list,
              onTap: () => setState(() => _viewMode = OfficeViewMode.list),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleBtn(
              label: AppStrings.officeMapViewBtn,
              icon: Icons.map_outlined,
              isActive: _viewMode == OfficeViewMode.map,
              onTap: () => setState(() => _viewMode = OfficeViewMode.map),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF2563EB) : const Color(0xFF1E3A8A))
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? Colors.white
                  : (isDark ? AppColors.textSubtle : AppColors.textMutedLight),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                  ? Colors.white
                  : (isDark ? AppColors.textSubtle : AppColors.textMutedLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeList(bool isDark) {
    final list = _filteredOffices;
    if (list.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مكاتب مطابقة للبحث',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final office = list[index];
        return _buildOfficeCard(office, isDark);
      },
    );
  }

  Widget _buildOfficeCard(TransportOffice office, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Office Badge Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            office.name,
                            style: GoogleFonts.cairo(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                          ),
                        ),
                        if (office.isVerified) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    size: 12, color: AppColors.success),
                                const SizedBox(width: 3),
                                Text(
                                  'موثق',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${office.city} · ${office.services}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textSubtle
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rating & Fleet Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.primaryGold),
                    const SizedBox(width: 4),
                    Text(
                      office.rating.toStringAsFixed(1),
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '📍 ${office.address}',
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
                  color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Select Button
          HamulaButton(
            label: AppStrings.selectOfficeConfirmBtn,
            onPressed: () => widget.onOfficeSelected?.call(office),
            variant: HamulaButtonVariant.primary,
            size: HamulaButtonSize.sm,
            icon: const Icon(Icons.check_rounded, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeMapView(bool isDark) {
    return Stack(
      children: [
        // Map Canvas Representation with City Markers
        Positioned.fill(
          child: Container(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            child: Stack(
              children: [
                // Stylized Road Grid Lines
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapGridPainter(isDark: isDark),
                  ),
                ),
                // City Office Markers
                ..._filteredOffices.map((office) {
                  return _buildMapOfficePin(office, isDark);
                }),
              ],
            ),
          ),
        ),

        // Bottom Sheet Preview on marker selection
        if (_selectedMapOffice != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildMapOfficePreviewCard(_selectedMapOffice!, isDark),
          ),
      ],
    );
  }

  Widget _buildMapOfficePin(TransportOffice office, bool isDark) {
    double top = 120;
    double left = 160;
    if (office.city == 'صنعاء') {
      top = 80;
      left = 130;
    } else if (office.city == 'عدن') {
      top = 260;
      left = 190;
    } else if (office.city == 'الحديدة') {
      top = 130;
      left = 60;
    } else if (office.city == 'مأرب') {
      top = 70;
      left = 240;
    }

    final isSelected = _selectedMapOffice?.id == office.id;

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => setState(() => _selectedMapOffice = office),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGold : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: isSelected ? Colors.white : AppColors.primaryGold,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.business_rounded,
                      size: 14, color: AppColors.navyDark),
                  const SizedBox(width: 4),
                  Text(
                    office.name.replaceAll('مكتب ', '').replaceAll('شركة ', ''),
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDark,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primaryGold,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapOfficePreviewCard(TransportOffice office, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  office.name,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => setState(() => _selectedMapOffice = null),
              ),
            ],
          ),
          Text(
            '${office.city} · ${office.services}',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 10),
          HamulaButton(
            label: AppStrings.selectOfficeConfirmBtn,
            onPressed: () => widget.onOfficeSelected?.call(office),
            variant: HamulaButtonVariant.primary,
            size: HamulaButtonSize.sm,
            icon: const Icon(Icons.check_rounded, size: 16),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final bool isDark;

  const _MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
