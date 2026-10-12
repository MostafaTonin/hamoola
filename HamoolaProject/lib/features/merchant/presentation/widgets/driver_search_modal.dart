import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/tracking_models.dart';

/// Modal search view faithfully reproducing Image 2 ("البحث"):
/// - Search input with live query matching and clear button
/// - Dynamic result count tabs: الكل (X), السائقون (Y), المدن والمناطق (Z), المحافظات (W)
/// - Cities and Districts section (المدن والمناطق) with navigation on tap
/// - Drivers section (السائقون) with photo, verified badge, rating, specs, distance, and truck thumbnail
/// - Fixed bottom action: "عرض جميع النتائج على الخريطة"
class DriverSearchModal extends StatefulWidget {
  final List<AvailableTruckMarker> allTrucks;
  final List<LocationSearchResult> allLocations;
  final DriverFilterCriteria currentFilter;
  final ValueChanged<AvailableTruckMarker> onSelectDriver;
  final ValueChanged<LocationSearchResult> onSelectLocation;
  final ValueChanged<String>? onSelectGovernorate;
  final VoidCallback onShowAllOnMap;
  final String initialQuery;

  const DriverSearchModal({
    super.key,
    required this.allTrucks,
    this.allLocations = LocationSearchResult.demoLocations,
    required this.currentFilter,
    required this.onSelectDriver,
    required this.onSelectLocation,
    this.onSelectGovernorate,
    required this.onShowAllOnMap,
    this.initialQuery = '',
  });

  static Future<void> show(
    BuildContext context, {
    required List<AvailableTruckMarker> allTrucks,
    List<LocationSearchResult> allLocations = LocationSearchResult.demoLocations,
    required DriverFilterCriteria currentFilter,
    required ValueChanged<AvailableTruckMarker> onSelectDriver,
    required ValueChanged<LocationSearchResult> onSelectLocation,
    ValueChanged<String>? onSelectGovernorate,
    required VoidCallback onShowAllOnMap,
    String initialQuery = '',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => DriverSearchModal(
        allTrucks: allTrucks,
        allLocations: allLocations,
        currentFilter: currentFilter,
        onSelectDriver: onSelectDriver,
        onSelectLocation: onSelectLocation,
        onSelectGovernorate: onSelectGovernorate,
        onShowAllOnMap: onShowAllOnMap,
        initialQuery: initialQuery,
      ),
    );
  }

  @override
  State<DriverSearchModal> createState() => _DriverSearchModalState();
}

class _DriverSearchModalState extends State<DriverSearchModal> {
  late final TextEditingController _searchController;
  String _selectedTab = 'all'; // 'all', 'drivers', 'locations', 'governorates'

  @override
  void initState() {
    super.initState();
    // Pre-populate with initialQuery or default to 'صنعاء' for demo realism if empty
    _searchController = TextEditingController(
      text: widget.initialQuery.isNotEmpty ? widget.initialQuery : 'صنعاء',
    );
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Normalizes Arabic text for lenient and intuitive matching
  String _normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[إأآا]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[\u064B-\u065F]'), ''); // remove harakat
  }

  List<AvailableTruckMarker> get _matchingDrivers {
    final q = _normalize(_searchController.text);
    final filter = widget.currentFilter;

    return widget.allTrucks.where((truck) {
      // 1. Vehicle category filter
      if (filter.vehicleCategory != 'all') {
        if (filter.vehicleCategory == 'تبريد') {
          if (!truck.isRefrigerated && truck.vehicleCategory != 'تبريد') {
            return false;
          }
        } else if (truck.vehicleCategory != filter.vehicleCategory &&
            !truck.vehicleType.contains(filter.vehicleCategory)) {
          return false;
        }
      }

      // 2. Availability status filter
      if (filter.availabilityStatus != 'all') {
        if (truck.availabilityStatus != filter.availabilityStatus) {
          return false;
        }
      }

      // 3. Governorate filter
      if (filter.governorate != 'all') {
        if (!truck.governorate.contains(filter.governorate) &&
            !truck.currentCountry.contains(filter.governorate)) {
          return false;
        }
      }

      // 4. District filter
      if (filter.cityOrDistrict != 'all') {
        if (!truck.currentCity.contains(filter.cityOrDistrict) &&
            !(truck.district?.contains(filter.cityOrDistrict) ?? false)) {
          return false;
        }
      }

      // 5. Cargo type filter
      if (filter.cargoType != 'all') {
        if (!truck.supportedCargoTypes.contains(filter.cargoType)) {
          return false;
        }
      }

      // 6. Query matching
      if (q.isNotEmpty) {
        final matchName = _normalize(truck.driverName).contains(q);
        final matchCity = _normalize(truck.currentCity).contains(q);
        final matchGov = _normalize(truck.governorate).contains(q);
        final matchCountry = _normalize(truck.currentCountry).contains(q);
        final matchDistrict =
            truck.district != null && _normalize(truck.district!).contains(q);
        final matchType = _normalize(truck.vehicleType).contains(q);
        final matchId = truck.driverId.toLowerCase().contains(q);

        if (!matchName &&
            !matchCity &&
            !matchGov &&
            !matchCountry &&
            !matchDistrict &&
            !matchType &&
            !matchId) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<LocationSearchResult> get _matchingLocations {
    final q = _normalize(_searchController.text);
    if (q.isEmpty) return widget.allLocations;

    return widget.allLocations.where((loc) {
      final matchName = _normalize(loc.name).contains(q);
      final matchSub = _normalize(loc.subtitle).contains(q);
      final matchGov = _normalize(loc.governorate).contains(q);
      final matchCountry = _normalize(loc.country).contains(q);

      return matchName || matchSub || matchGov || matchCountry;
    }).toList();
  }

  List<String> get _matchingGovernorates {
    final q = _normalize(_searchController.text);
    final Set<String> govs = {};

    for (final loc in _matchingLocations) {
      if (q.isEmpty || _normalize(loc.governorate).contains(q)) {
        govs.add(loc.governorate);
      }
    }
    for (final truck in _matchingDrivers) {
      if (q.isEmpty || _normalize(truck.governorate).contains(q)) {
        govs.add(truck.governorate);
      }
    }

    return govs.toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final drivers = _matchingDrivers;
    final locations = _matchingLocations;
    final governorates = _matchingGovernorates;

    // Image 2 calculation: Total = drivers count + locations count
    final totalCount = drivers.length + locations.length;
    final driversCount = drivers.length;
    final locationsCount = locations.length;
    final governoratesCount = governorates.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Top Drag Handle
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

              // Modal Header: Close Button (Left in RTL) & Centered Title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: isDark
                          ? AppColors.textWhite
                          : const Color(0xFF64748B),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Text(
                        'البحث',
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
                    const SizedBox(width: 24), // Balance the close button
                  ],
                ),
              ),

              // Search Text Field (Image 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    style: GoogleFonts.cairo(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textWhite
                          : AppColors.textMainLight,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن سائق أو مدينة أو منطقة...',
                      hintStyle: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 20, color: Color(0xFF64748B)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.cancel_rounded,
                                  size: 18, color: Color(0xFF94A3B8)),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter Tabs Row (الكل, السائقون, المدن والمناطق, المحافظات)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildTabChip(
                      key: 'all',
                      label: 'الكل ($totalCount)',
                      isDark: isDark,
                    ),
                    _buildTabChip(
                      key: 'drivers',
                      label: 'السائقون ($driversCount)',
                      isDark: isDark,
                    ),
                    _buildTabChip(
                      key: 'locations',
                      label: 'المدن والمناطق ($locationsCount)',
                      isDark: isDark,
                    ),
                    _buildTabChip(
                      key: 'governorates',
                      label: 'المحافظات ($governoratesCount)',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Scrollable Results Body
              Expanded(
                child: totalCount == 0
                    ? _buildEmptyState(isDark)
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        children: [
                          // 1. Cities & Districts Section (المدن والمناطق)
                          if ((_selectedTab == 'all' ||
                                  _selectedTab == 'locations') &&
                              locations.isNotEmpty) ...[
                            _buildSectionHeader(
                              icon: Icons.location_on_outlined,
                              title: 'المدن والمناطق',
                              onShowAll: () =>
                                  setState(() => _selectedTab = 'locations'),
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            _buildCitiesGrid(locations, isDark),
                            const SizedBox(height: 16),
                          ],

                          // 2. Drivers Section (السائقون)
                          if ((_selectedTab == 'all' ||
                                  _selectedTab == 'drivers') &&
                              drivers.isNotEmpty) ...[
                            _buildSectionHeader(
                              icon: Icons.person_outline_rounded,
                              title: 'السائقون',
                              onShowAll: () =>
                                  setState(() => _selectedTab = 'drivers'),
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            ...drivers
                                .map((driver) => _buildDriverCard(driver, isDark)),
                          ],

                          // 3. Governorates Section (المحافظات)
                          if (_selectedTab == 'governorates' &&
                              governorates.isNotEmpty) ...[
                            _buildSectionHeader(
                              icon: Icons.map_outlined,
                              title: 'المحافظات',
                              onShowAll: null,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            ...governorates.map(
                                (gov) => _buildGovernorateTile(gov, isDark)),
                          ],
                        ],
                      ),
              ),

              // Bottom Fixed CTA: "عرض جميع النتائج على الخريطة" (Image 2)
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
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onShowAllOnMap();
                    },
                    icon: const Icon(Icons.near_me_rounded,
                        size: 18, color: Colors.white),
                    label: Text(
                      'عرض جميع النتائج على الخريطة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabChip({
    required String key,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedTab == key;

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedTab = key),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F172A)
                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textWhite : const Color(0xFF475569)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    VoidCallback? onShowAll,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2563EB)),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        if (onShowAll != null)
          TextButton(
            onPressed: onShowAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'عرض الكل',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCitiesGrid(List<LocationSearchResult> locations, bool isDark) {
    // Show horizontal cards for cities/districts as in Image 2
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final loc = locations[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).pop();
              widget.onSelectLocation(loc);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 125,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          loc.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textWhite
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          loc.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: loc.isMajor
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDriverCard(AvailableTruckMarker driver, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          widget.onSelectDriver(driver);
        },
        child: Row(
          children: [
            // Chevron arrow on right (RTL start)
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: Color(0xFF94A3B8)),
            const SizedBox(width: 6),

            // Driver Circular Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  driver.avatarAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1E293B),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Middle Driver Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver Name & Verified Badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          driver.driverName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textWhite
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      if (driver.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            size: 14, color: Color(0xFF16A34A)),
                      ],
                    ],
                  ),

                  // Rating & Reviews Count
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 2),
                      Text(
                        '${driver.rating} (${driver.reviewsCount})',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Vehicle Type & Capacity
                      Flexible(
                        child: Text(
                          '${driver.vehicleCategory} · ${driver.capacity}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Location, Distance, and Availability Dot
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: driver.isAvailable
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        driver.isAvailable
                            ? '${driver.currentCity} · ${driver.distanceKm} كم'
                            : 'قيد النقل · ${driver.distanceKm} كم',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Truck Thumbnail Photo on left (RTL end)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 68,
                height: 48,
                color: const Color(0xFFE2E8F0),
                child: Image.asset(
                  driver.vehicleAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF334155),
                    child: const Icon(Icons.local_shipping_rounded,
                        color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernorateTile(String gov, bool isDark) {
    final count =
        widget.allTrucks.where((t) => t.governorate.contains(gov)).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context).pop();
          widget.onSelectGovernorate?.call(gov);
        },
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.map_outlined,
              size: 20, color: Color(0xFF2563EB)),
        ),
        title: Text(
          'محافظة $gov',
          style: GoogleFonts.cairo(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          '$count ناقلات متوفرة',
          style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF64748B)),
        ),
        trailing: const Icon(Icons.chevron_left_rounded,
            size: 20, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 32, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد نتائج مطابقة لـ "${_searchController.text}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'جرب البحث بكلمات أخرى أو قم بإعادة تعيين الفلاتر',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
