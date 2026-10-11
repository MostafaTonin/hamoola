import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/communication_launcher.dart';
import '../../domain/models/tracking_models.dart';
import '../widgets/driver_filter_modal.dart';
import '../widgets/driver_search_modal.dart';

/// Screen representing the full Drivers Map in Hamoola.
/// Faithfully reproduces Image 2 (Regional Arabian Peninsula view)
/// and Image 3 (Detailed Yemen Zoom view):
/// - Default regional scope: Yemen, Saudi Arabia, Oman, UAE & neighboring areas (Image 2)
/// - Full interactive zoom & pan with InteractiveViewer, Zoom In (+), Zoom Out (-), Recenter
/// - Smooth transition to detailed Yemen governorates & cities when zoomed in (Image 3)
/// - ZERO tractors/harvesters! Only verified heavy cargo transport vehicles:
///   (Heavy Truck, Semi-Trailer, Reefer ❄️, Dyna, Tipper)
/// - Custom heavy truck markers with status indicators (Green: Available, Orange: Busy, Grey: Offline)
/// - Key Feature: "متاح للعودة إلى اليمن" Callout badges for trucks outside Yemen
/// - Dynamic clustering for regional view (Sana'a 8, Aden 4, Taiz 5) which expands on zoom
/// - Bottom Sheet with real-time counters and filter pills:
///   Regional: 68 available drivers | السعودية 18, عمان 7, الإمارات 5, اليمن 24
///   Yemen: 24 available drivers | صنعاء 8, عدن 5, تعز 4, الحديدة 3
class MerchantMapScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<AvailableTruckMarker>? onViewDriverProfile;
  final ValueChanged<AvailableTruckMarker>? onDirectOrder;

  const MerchantMapScreen({
    super.key,
    this.onBack,
    this.onViewDriverProfile,
    this.onDirectOrder,
  });

  @override
  State<MerchantMapScreen> createState() => _MerchantMapScreenState();
}

class _MerchantMapScreenState extends State<MerchantMapScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _transformationController = TransformationController();

  String _selectedCategory = 'all';
  String _selectedRegionFilter = 'all'; // 'all', 'السعودية', 'عمان', 'الإمارات', 'اليمن', 'صنعاء', etc.
  DriverFilterCriteria _activeFilterCriteria = const DriverFilterCriteria();
  AvailableTruckMarker? _selectedMarker;
  double _currentScale = 1.0;
  bool _isSatelliteMode = false;
  bool _isFullscreen = false;

  static const double _zoomThresholdYemen = 1.75;

  static const List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'label': 'الكل', 'icon': null},
    {'key': 'شاحنات', 'label': 'شاحنات', 'icon': Icons.local_shipping_outlined},
    {'key': 'قاطرات', 'label': 'قاطرات', 'icon': Icons.rv_hookup_rounded},
    {'key': 'دينات', 'label': 'دينات', 'icon': Icons.fire_truck_outlined},
    {'key': 'تبريد', 'label': 'تبريد ❄️', 'icon': Icons.ac_unit_rounded},
    {'key': 'أخرى', 'label': 'أخرى', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.05) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool get _isZoomedIntoYemen => _currentScale >= _zoomThresholdYemen;

  static String _normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[إأآا]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '');
  }

  List<AvailableTruckMarker> get _filteredTrucks {
    return AvailableTruckMarker.demoTrucks.where((truck) {
      // 1. Category Filter (combines quick chips and filter modal)
      final activeCat = _activeFilterCriteria.vehicleCategory != 'all'
          ? _activeFilterCriteria.vehicleCategory
          : _selectedCategory;
      if (activeCat != 'all') {
        if (activeCat == 'تبريد') {
          if (!truck.isRefrigerated && truck.vehicleCategory != 'تبريد') {
            return false;
          }
        } else if (truck.vehicleCategory != activeCat &&
            !truck.vehicleType.contains(activeCat)) {
          return false;
        }
      }

      // 2. Availability Status Filter
      if (_activeFilterCriteria.availabilityStatus != 'all') {
        if (truck.availabilityStatus !=
            _activeFilterCriteria.availabilityStatus) {
          return false;
        }
      }

      // 3. Governorate Filter
      if (_activeFilterCriteria.governorate != 'all') {
        final gov = _normalize(_activeFilterCriteria.governorate);
        final matchGov = _normalize(truck.governorate).contains(gov) ||
            _normalize(truck.currentCountry).contains(gov) ||
            _normalize(truck.currentCity).contains(gov);
        if (!matchGov) return false;
      }

      // 4. District / City Filter
      if (_activeFilterCriteria.cityOrDistrict != 'all') {
        final dist = _normalize(_activeFilterCriteria.cityOrDistrict);
        final matchDist = _normalize(truck.currentCity).contains(dist) ||
            (truck.district != null &&
                _normalize(truck.district!).contains(dist));
        if (!matchDist) return false;
      }

      // 5. Cargo Type Filter
      if (_activeFilterCriteria.cargoType != 'all') {
        if (!truck.supportedCargoTypes
            .contains(_activeFilterCriteria.cargoType)) {
          return false;
        }
      }

      // 6. Regional Filter (quick chips)
      if (_selectedRegionFilter != 'all') {
        final reg = _normalize(_selectedRegionFilter);
        final matchesRegion =
            _normalize(truck.currentCountry).contains(reg) ||
            _normalize(truck.currentCity).contains(reg) ||
            _normalize(truck.governorate).contains(reg);
        if (!matchesRegion) return false;
      }

      // 7. Search Query (normalized)
      final q = _normalize(_searchController.text);
      if (q.isNotEmpty) {
        final matchName = _normalize(truck.driverName).contains(q);
        final matchCity = _normalize(truck.currentCity).contains(q);
        final matchGov = _normalize(truck.governorate).contains(q);
        final matchCountry = _normalize(truck.currentCountry).contains(q);
        final matchDistrict =
            truck.district != null && _normalize(truck.district!).contains(q);
        final matchType = _normalize(truck.vehicleType).contains(q);
        final matchId = truck.driverId.toLowerCase().contains(q);
        final matchDest = truck.preferredReturnDestination != null &&
            _normalize(truck.preferredReturnDestination!).contains(q);

        if (!matchName &&
            !matchCity &&
            !matchGov &&
            !matchCountry &&
            !matchDistrict &&
            !matchType &&
            !matchId &&
            !matchDest) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get _yemenDriversCount =>
      _filteredTrucks.where((t) => t.currentCountry == 'اليمن').length;

  int get _saudiDriversCount =>
      _filteredTrucks.where((t) => t.currentCountry.contains('السعودية')).length;

  int get _omanDriversCount =>
      _filteredTrucks.where((t) => t.currentCountry.contains('عمان')).length;

  int get _uaeDriversCount =>
      _filteredTrucks.where((t) => t.currentCountry.contains('الإمارات')).length;

  void _zoomIn() {
    final newScale = (_currentScale * 1.45).clamp(1.0, 4.0);
    _animateScale(newScale);
  }

  void _zoomOut() {
    final newScale = (_currentScale / 1.45).clamp(1.0, 4.0);
    _animateScale(newScale);
  }

  void _recenter() {
    _animateScale(1.0, translate: Offset.zero);
    setState(() {
      _selectedRegionFilter = 'all';
      _selectedMarker = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديد موقعك الحالي: صنعاء، اليمن'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _focusOnYemen() {
    _animateScale(2.2, translate: const Offset(-80, -220));
    setState(() {
      _selectedRegionFilter = 'اليمن';
    });
  }

  void _focusOnSaudi() {
    _animateScale(1.6, translate: const Offset(-20, 10));
    setState(() {
      _selectedRegionFilter = 'السعودية';
    });
  }

  void _focusOnOman() {
    _animateScale(1.8, translate: const Offset(-180, -100));
    setState(() {
      _selectedRegionFilter = 'عمان';
    });
  }

  void _animateScale(double targetScale, {Offset? translate}) {
    final tx = translate?.dx ?? 0.0;
    final ty = translate?.dy ?? 0.0;
    final matrix = Matrix4.identity();
    matrix.storage[0] = targetScale;
    matrix.storage[5] = targetScale;
    matrix.storage[12] = tx;
    matrix.storage[13] = ty;
    _transformationController.value = matrix;
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
                  // 1. Header (خريطة السائقين • 68 سائقاً متاحاً الآن)
                  if (!_isFullscreen) _buildHeader(isDark),

                  // 2. Search Field
                  if (!_isFullscreen) _buildSearchRow(isDark),

                  // 3. Category Filter Chips (الكل، شاحنات، قاطرات، دينات، تبريد ❄️، أخرى)
                  if (!_isFullscreen) _buildCategoryChipsBar(isDark),

                  // 4. Map Viewport & Interactive Layer
                  Expanded(
                    child: Stack(
                      children: [
                        // Interactive Map Surface
                        Positioned.fill(
                          child: _buildInteractiveMap(isDark),
                        ),

                        // Map Control Floating Buttons (Right/Left)
                        Positioned(
                          right: 14,
                          top: 14,
                          child: _buildMapToolsFloatingColumn(isDark),
                        ),

                        // Empty State Floating Banner when no trucks match
                        if (_filteredTrucks.isEmpty)
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 64,
                            child: _buildNoResultsBanner(isDark),
                          ),

                        // Scale Indicator & Attribution (Bottom Right)
                        Positioned(
                          right: 16,
                          bottom: _selectedMarker != null ? 220 : 130,
                          child: _buildMapScaleAndAttribution(isDark),
                        ),

                        // Bottom Overlay / Summary Sheet
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _selectedMarker != null
                              ? _buildSelectedDriverCard(_selectedMarker!, isDark)
                              : _buildBottomStatsSheet(isDark),
                        ),
                      ],
                    ),
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
    final totalAvailable = _filteredTrucks.where((t) => t.isAvailable).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            onPressed: widget.onBack,
            tooltip: AppStrings.back,
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0x1F2563EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.map_outlined,
                size: 20, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خريطة السائقين',
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                Text(
                  _isZoomedIntoYemen
                      ? '$_yemenDriversCount سائقاً متاحاً الآن'
                      : '$totalAvailable سائقاً متاحاً الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(bool isDark) {
    final hasActiveFilter = !_activeFilterCriteria.isDefault;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          // 1. Filter Trigger Button (Image 1)
          Tooltip(
            message: 'تصفية السائقين',
            child: InkWell(
              onTap: () => _openFilterModal(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasActiveFilter
                      ? (isDark
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFFEFF6FF))
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasActiveFilter
                        ? const Color(0xFF2563EB)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.borderLight),
                    width: hasActiveFilter ? 1.6 : 1.0,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: hasActiveFilter
                          ? const Color(0xFF2563EB)
                          : (isDark ? Colors.white : const Color(0xFF475569)),
                    ),
                    if (hasActiveFilter)
                      Positioned(
                        top: 7,
                        right: 7,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Search Text Field & Dedicated Modal Trigger (Image 2)
          Expanded(
            child: TextField(
              controller: _searchController,
              onTap: () => _openSearchModal(context),
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.searchDriversHint,
                hintStyle: GoogleFonts.cairo(
                  fontSize: 12.5,
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search_rounded,
                      size: 20, color: Color(0xFF64748B)),
                  onPressed: () => _openSearchModal(context),
                ),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
          ),
        ],
      ),
    );
  }

  void _openFilterModal(BuildContext context) {
    DriverFilterModal.show(
      context,
      initialCriteria: _activeFilterCriteria,
      onApply: (newCriteria) {
        setState(() {
          _activeFilterCriteria = newCriteria;
          if (newCriteria.vehicleCategory != 'all') {
            _selectedCategory = newCriteria.vehicleCategory;
          }
          if (newCriteria.governorate != 'all') {
            _selectedRegionFilter = newCriteria.governorate;
          }
        });
      },
      onReset: () {
        setState(() {
          _activeFilterCriteria = const DriverFilterCriteria();
          _selectedCategory = 'all';
          _selectedRegionFilter = 'all';
        });
      },
    );
  }

  void _openSearchModal(BuildContext context) {
    DriverSearchModal.show(
      context,
      allTrucks: AvailableTruckMarker.demoTrucks,
      allLocations: LocationSearchResult.demoLocations,
      currentFilter: _activeFilterCriteria,
      initialQuery: _searchController.text,
      onSelectDriver: (driver) {
        setState(() {
          _selectedMarker = driver;
          _searchController.text = driver.driverName;
        });
        if (driver.currentCountry == 'اليمن' && driver.xRatioYemen != null) {
          _animateScale(2.6,
              translate: Offset(
                -(driver.xRatioYemen! * 500 - 150),
                -(driver.yRatioYemen! * 700 - 250),
              ));
        } else {
          _animateScale(1.8,
              translate: Offset(
                -(driver.xRatio * 500 - 150),
                -(driver.yRatio * 700 - 250),
              ));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'تم تحديد السائق: ${driver.driverName} (${driver.currentCity})'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      onSelectLocation: (location) {
        setState(() {
          _searchController.text = location.name;
          _selectedRegionFilter = location.governorate;
        });
        if (location.country == 'اليمن' && location.xRatioYemen != null) {
          _animateScale(2.5,
              translate: Offset(
                -(location.xRatioYemen! * 500 - 150),
                -(location.yRatioYemen! * 700 - 250),
              ));
        } else {
          _animateScale(1.8,
              translate: Offset(
                -(location.xRatio * 500 - 150),
                -(location.yRatio * 700 - 250),
              ));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'تم الانتقال إلى: ${location.name} (${location.subtitle})'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      onSelectGovernorate: (gov) {
        setState(() {
          _searchController.text = gov;
          _selectedRegionFilter = gov;
        });
        if (gov.contains('السعودية')) {
          _focusOnSaudi();
        } else if (gov.contains('عمان')) {
          _focusOnOman();
        } else {
          _focusOnYemen();
        }
      },
      onShowAllOnMap: () {
        setState(() {});
        if (_searchController.text.contains('السعودية')) {
          _focusOnSaudi();
        } else if (_searchController.text.contains('عمان')) {
          _focusOnOman();
        } else {
          _focusOnYemen();
        }
      },
    );
  }

  Widget _buildNoResultsBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_off_rounded,
              size: 20, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'لا توجد مركبات مطابقة لمعايير البحث والتصفية المحددة',
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : const Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: () {
              setState(() {
                _activeFilterCriteria = const DriverFilterCriteria();
                _selectedCategory = 'all';
                _selectedRegionFilter = 'all';
                _searchController.clear();
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'إعادة تعيين',
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChipsBar(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _categories.length,
        separatorBuilder: (_, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['key'];
          final IconData? icon = cat['icon'];

          return ChoiceChip(
            avatar: icon != null
                ? Icon(
                    icon,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textWhite : const Color(0xFF334155)),
                  )
                : null,
            label: Text(cat['label']),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedCategory = cat['key'];
                  _activeFilterCriteria = _activeFilterCriteria.copyWith(
                    vehicleCategory: cat['key'],
                  );
                });
              }
            },
            selectedColor: const Color(0xFF0F172A),
            labelStyle: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textWhite : const Color(0xFF334155)),
            ),
            backgroundColor: isDark
                ? const Color(0xFF1E293B)
                : Colors.white,
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0)),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInteractiveMap(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1.0,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(80),
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Stylized Background Cartography
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RegionalMapPainter(
                      isDark: isDark,
                      isSatellite: _isSatelliteMode,
                      isZoomedYemen: _isZoomedIntoYemen,
                    ),
                  ),
                ),

                // 2. Geographic Labels (Yemen, Saudi Arabia, Oman, UAE & Water Bodies)
                ..._buildGeographicLabels(w, h, isDark),

                // 3. Cluster Badges when in Regional Scope (Sana'a 8, Aden 4, Taiz 5)
                if (!_isZoomedIntoYemen) ...[
                  _buildClusterBadge(
                    label: '8',
                    cityName: 'صنعاء',
                    x: w * 0.40,
                    y: h * 0.69,
                    onTap: _focusOnYemen,
                  ),
                  _buildClusterBadge(
                    label: '4',
                    cityName: 'عدن',
                    x: w * 0.47,
                    y: h * 0.81,
                    onTap: _focusOnYemen,
                  ),
                  _buildClusterBadge(
                    label: '5',
                    cityName: 'تعز',
                    x: w * 0.36,
                    y: h * 0.77,
                    onTap: _focusOnYemen,
                  ),
                ],

                // 4. Truck Markers
                ..._filteredTrucks.where((truck) {
                  // In regional mode, hide the trucks represented by clusters in Yemen center
                  if (!_isZoomedIntoYemen && truck.currentCountry == 'اليمن') {
                    if (truck.currentCity == 'صنعاء' && truck.id != 'TRK-YE-01') {
                      return false;
                    }
                    if (truck.currentCity == 'عدن' && truck.id != 'TRK-YE-09') {
                      return false;
                    }
                    if (truck.currentCity == 'تعز' && truck.id != 'TRK-YE-14') {
                      return false;
                    }
                  }
                  return true;
                }).map((truck) {
                  final double x;
                  final double y;
                  if (_isZoomedIntoYemen && truck.xRatioYemen != null) {
                    x = truck.xRatioYemen! * w;
                    y = truck.yRatioYemen! * h;
                  } else {
                    x = truck.xRatio * w;
                    y = truck.yRatio * h;
                  }

                  final isSelected = _selectedMarker?.id == truck.id;

                  return Positioned(
                    left: x - 24,
                    top: y - 24,
                    child: _buildTruckMarkerItem(truck, isSelected),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGeographicLabels(double w, double h, bool isDark) {
    if (_isZoomedIntoYemen) {
      // Zoomed Yemen Labels (Image 3)
      return [
        _buildCityLabel('صنعاء', w * 0.38, h * 0.28, isDark, isMajor: true),
        _buildCityLabel('عمران', w * 0.34, h * 0.22, isDark),
        _buildCityLabel('صعدة', w * 0.28, h * 0.12, isDark),
        _buildCityLabel('حجة', w * 0.24, h * 0.20, isDark),
        _buildCityLabel('الجوف', w * 0.52, h * 0.14, isDark),
        _buildCityLabel('مأرب', w * 0.64, h * 0.24, isDark),
        _buildCityLabel('الحديدة', w * 0.18, h * 0.38, isDark, isMajor: true),
        _buildCityLabel('ذمار', w * 0.40, h * 0.44, isDark),
        _buildCityLabel('إب', w * 0.38, h * 0.54, isDark),
        _buildCityLabel('البيضاء', w * 0.54, h * 0.48, isDark),
        _buildCityLabel('تعز', w * 0.33, h * 0.64, isDark, isMajor: true),
        _buildCityLabel('لحج', w * 0.40, h * 0.72, isDark),
        _buildCityLabel('أبين', w * 0.58, h * 0.66, isDark),
        _buildCityLabel('عدن', w * 0.48, h * 0.78, isDark, isMajor: true),
        _buildCityLabel('شبوة', w * 0.68, h * 0.52, isDark),
        _buildCityLabel('حضرموت', w * 0.82, h * 0.48, isDark),
        _buildCityLabel('المهرة', w * 0.90, h * 0.26, isDark),
        _buildCityLabel('سقطرى', w * 0.85, h * 0.84, isDark),
        _buildSeaLabel('البحر الأحمر', w * 0.12, h * 0.56),
        _buildSeaLabel('خليج عدن', w * 0.60, h * 0.86),
      ];
    } else {
      // Regional Arabian Peninsula Labels (Image 2)
      return [
        _buildCountryLabel('المملكة العربية السعودية', w * 0.46, h * 0.30),
        _buildCountryLabel('اليمن', w * 0.44, h * 0.72),
        _buildCountryLabel('عمان', w * 0.78, h * 0.58),
        _buildCountryLabel('الإمارات العربية المتحدة', w * 0.70, h * 0.34),
        _buildCountryLabel('الكويت', w * 0.56, h * 0.16),
        _buildCountryLabel('قطر', w * 0.64, h * 0.32),
        _buildCountryLabel('الأردن', w * 0.22, h * 0.18),
        _buildCountryLabel('العراق', w * 0.36, h * 0.12),
        _buildCountryLabel('مصر', w * 0.14, h * 0.32),
        _buildCountryLabel('السودان', w * 0.16, h * 0.52),
        _buildCountryLabel('إريتريا', w * 0.22, h * 0.68),
        _buildCountryLabel('جيبوتي', w * 0.32, h * 0.82),
        _buildCountryLabel('الصومال', w * 0.44, h * 0.92),
        _buildCityLabel('الرياض', w * 0.50, h * 0.34, isDark),
        _buildCityLabel('جدة', w * 0.28, h * 0.44, isDark),
        _buildCityLabel('الدمام', w * 0.62, h * 0.30, isDark),
        _buildCityLabel('أبوظبي', w * 0.68, h * 0.38, isDark),
        _buildCityLabel('مسقط', w * 0.80, h * 0.44, isDark),
        _buildCityLabel('صلالة', w * 0.70, h * 0.66, isDark),
        _buildSeaLabel('البحر الأحمر', w * 0.24, h * 0.54),
        _buildSeaLabel('الخليج العربي', w * 0.62, h * 0.26),
        _buildSeaLabel('بحر العرب', w * 0.80, h * 0.76),
      ];
    }
  }

  Widget _buildCountryLabel(String text, double x, double y) {
    return Positioned(
      left: x,
      top: y,
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1E293B),
          shadows: const [
            Shadow(color: Colors.white, blurRadius: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildCityLabel(String name, double x, double y, bool isDark,
      {bool isMajor = false}) {
    return Positioned(
      left: x,
      top: y,
      child: Text(
        name,
        style: GoogleFonts.cairo(
          fontSize: isMajor ? 11.5 : 10,
          fontWeight: isMajor ? FontWeight.w800 : FontWeight.w600,
          color: isMajor
              ? const Color(0xFF0F172A)
              : const Color(0xFF64748B),
          shadows: const [
            Shadow(color: Colors.white, blurRadius: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSeaLabel(String name, double x, double y) {
    return Positioned(
      left: x,
      top: y,
      child: Text(
        name,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0284C7),
        ),
      ),
    );
  }

  Widget _buildClusterBadge({
    required String label,
    required String cityName,
    required double x,
    required double y,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: x - 18,
      top: y - 18,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTruckMarkerItem(AvailableTruckMarker truck, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMarker = truck),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. "متاح للعودة إلى اليمن" Callout Bubble (Image 2)
          if (truck.returnToYemenAvailable && !_isZoomedIntoYemen) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              margin: const EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'متاح للعودة\nإلى اليمن',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 8.5,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 2. Heavy Truck Graphic with separate status indicator dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Custom Heavy Truck Visual
              _buildHeavyTruckIcon(truck, isSelected),

              // Status Indicator Dot (Green = Available, Orange = Busy, Grey = Offline)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: truck.isAvailable
                        ? const Color(0xFF16A34A)
                        : (truck.isBusy ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8)),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeavyTruckIcon(AvailableTruckMarker truck, bool isSelected) {
    Color truckColor;
    if (truck.isRefrigerated) {
      truckColor = const Color(0xFF0284C7); // Light blue for reefer
    } else if (truck.vehicleCategory == 'قاطرات') {
      truckColor = const Color(0xFF334155); // Slate for semi-trailers
    } else if (truck.vehicleCategory == 'دينات') {
      truckColor = const Color(0xFFD97706); // Amber for dyna
    } else {
      truckColor = const Color(0xFF15803D); // Green for heavy box truck
    }

    return Container(
      width: 44,
      height: 34,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFEF3C7) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primaryGold : const Color(0xFFCBD5E1),
          width: isSelected ? 2.2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              truck.isRefrigerated
                  ? Icons.ac_unit_rounded
                  : (truck.vehicleCategory == 'قاطرات'
                      ? Icons.rv_hookup_rounded
                      : Icons.local_shipping_rounded),
              size: 20,
              color: truckColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapToolsFloatingColumn(bool isDark) {
    return Column(
      children: [
        // Layers Switcher
        _buildMapToolBtn(
          icon: Icons.layers_outlined,
          tooltip: 'تبديل طبقات الخريطة',
          onTap: () {
            setState(() => _isSatelliteMode = !_isSatelliteMode);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isSatelliteMode
                    ? 'تم تفعيل طبقة الخريطة الطبوغرافية الفضائية'
                    : 'تم تفعيل طبقة الخريطة اللوجستية القياسية'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        // Fullscreen Toggle
        _buildMapToolBtn(
          icon: _isFullscreen
              ? Icons.fullscreen_exit_rounded
              : Icons.fullscreen_rounded,
          tooltip: 'ملء الشاشة',
          onTap: () => setState(() => _isFullscreen = !_isFullscreen),
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        // Zoom In (+)
        _buildMapToolBtn(
          icon: Icons.add_rounded,
          tooltip: 'تكبير',
          onTap: _zoomIn,
          isDark: isDark,
        ),
        const SizedBox(height: 4),

        // Zoom Out (-)
        _buildMapToolBtn(
          icon: Icons.remove_rounded,
          tooltip: 'تصغير',
          onTap: _zoomOut,
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        // Recenter / GPS location
        _buildMapToolBtn(
          icon: Icons.my_location_rounded,
          tooltip: AppStrings.currentLocateTooltip,
          onTap: _recenter,
          iconColor: const Color(0xFF2563EB),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildMapToolBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? iconColor,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 19,
            color: iconColor ?? (isDark ? Colors.white : const Color(0xFF334155)),
          ),
        ),
      ),
    );
  }

  Widget _buildMapScaleAndAttribution(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _isZoomedIntoYemen ? '100 كم' : '500 كم',
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0055FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'maptiler',
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStatsSheet(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // Header summary row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    size: 20, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _isZoomedIntoYemen
                              ? '$_yemenDriversCount سائقاً متاحاً الآن'
                              : '${_filteredTrucks.where((t) => t.isAvailable).length} سائقاً متاحاً الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _isZoomedIntoYemen
                          ? 'مركبات قريبة منك في مختلف المحافظات'
                          : 'مركبات في اليمن والدول المجاورة متاحة للنقل',
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
              OutlinedButton.icon(
                onPressed: () => _showDriversListModal(context, isDark),
                icon: const Icon(Icons.format_list_bulleted_rounded, size: 16),
                label: Text(
                  'عرض القائمة',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  minimumSize: const Size(0, 36),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Regional / Governorate filter chips (Image 2 & Image 3)
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _isZoomedIntoYemen
                  ? [
                      _buildRegionChip('صنعاء 8', 'صنعاء', isDark),
                      _buildRegionChip('عدن 5', 'عدن', isDark),
                      _buildRegionChip('تعز 4', 'تعز', isDark),
                      _buildRegionChip('الحديدة 3', 'الحديدة', isDark),
                      _buildRegionChip('إب 2', 'إب', isDark),
                      _buildRegionChip('+ المزيد', 'all', isDark),
                    ]
                  : [
                      _buildRegionChip(
                          'السعودية $_saudiDriversCount', 'السعودية', isDark,
                          onTap: _focusOnSaudi),
                      _buildRegionChip('عمان $_omanDriversCount', 'عمان', isDark,
                          onTap: _focusOnOman),
                      _buildRegionChip(
                          'الإمارات $_uaeDriversCount', 'الإمارات', isDark),
                      _buildRegionChip(
                          'اليمن $_yemenDriversCount', 'اليمن', isDark,
                          onTap: _focusOnYemen),
                      _buildRegionChip('+ المزيد', 'all', isDark),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionChip(String label, String filterKey, bool isDark,
      {VoidCallback? onTap}) {
    final isSelected = _selectedRegionFilter == filterKey;

    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: ActionChip(
        label: Text(label),
        onPressed: () {
          if (onTap != null) {
            onTap();
          } else {
            setState(() {
              _selectedRegionFilter = isSelected ? 'all' : filterKey;
            });
          }
        },
        backgroundColor: isSelected
            ? const Color(0xFF0F172A)
            : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
        labelStyle: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.textWhite : const Color(0xFF334155)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF0F172A)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _buildSelectedDriverCard(AvailableTruckMarker truck, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryGold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          truck.driverName,
                          style: GoogleFonts.cairo(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'موثق ✓',
                            style: GoogleFonts.cairo(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${truck.vehicleType} · ${truck.capacity} · ${truck.currentCity} (${truck.currentCountry})',
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
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => setState(() => _selectedMarker = null),
              ),
            ],
          ),

          // Return to Yemen Special Banner (Section 6)
          if (truck.returnToYemenAvailable) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_return_rounded,
                      size: 16, color: Color(0xFF16A34A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'متاح للعودة إلى اليمن 🇾🇪 • الوجهة المطلوبة: ${truck.preferredReturnDestination ?? 'صنعاء / عدن'}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              // Direct Order CTA
              Expanded(
                flex: 5,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onDirectOrder?.call(truck),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    AppStrings.directOrderForDriver,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // View Profile Button
              Expanded(
                flex: 4,
                child: OutlinedButton(
                  onPressed: () => widget.onViewDriverProfile?.call(truck),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    AppStrings.viewOfficeProfileBtn,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textWhite
                          : AppColors.textMainLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // WhatsApp Messaging
              IconButton.filledTonal(
                onPressed: () {
                  CommunicationLauncher.openWhatsApp(
                    context,
                    phoneNumber: truck.phone,
                    message:
                        'مرحباً كابتن ${truck.driverName}، رأيت شاحنتك على خريطة حمولة في ${truck.currentCity}، هل أنت متاح للشحن؟',
                  );
                },
                icon: const Icon(Icons.chat_bubble_rounded,
                    size: 18, color: Color(0xFF16A34A)),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFDCFCE7),
                ),
                tooltip: 'واتساب',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDriversListModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'قائمة الناقلات المتاحة (${_filteredTrucks.length})',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _filteredTrucks.length,
                  separatorBuilder: (_, index) => const Divider(height: 16),
                  itemBuilder: (context, i) {
                    final t = _filteredTrucks[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: t.isRefrigerated
                              ? const Color(0xFFDBEAFE)
                              : const Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          t.isRefrigerated
                              ? Icons.ac_unit_rounded
                              : Icons.local_shipping_rounded,
                          color: t.isRefrigerated
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF16A34A),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            t.driverName,
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (t.returnToYemenAvailable) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF86EFAC)),
                              ),
                              child: Text(
                                'عودة لليمن 🇾🇪',
                                style: GoogleFonts.cairo(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF166534),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '${t.vehicleType} · ${t.capacity} · ${t.currentCity} (${t.currentCountry})',
                        style: GoogleFonts.cairo(fontSize: 11),
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() => _selectedMarker = t);
                        },
                        child: const Text('عرض'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for the Arabian Peninsula and Yemen topographic map.
/// Faithfully reproduces the regional cartography of Image 2 & Image 3.
class _RegionalMapPainter extends CustomPainter {
  final bool isDark;
  final bool isSatellite;
  final bool isZoomedYemen;

  const _RegionalMapPainter({
    required this.isDark,
    required this.isSatellite,
    required this.isZoomedYemen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Water Background (Red Sea, Arabian Sea, Persian Gulf)
    final waterColor = isDark
        ? const Color(0xFF0A192F)
        : (isSatellite ? const Color(0xFF1E3A5F) : const Color(0xFFBAE6FD));
    final waterPaint = Paint()..color = waterColor;
    canvas.drawRect(Offset.zero & size, waterPaint);

    // 2. Arabian Peninsula Landmass Polygon
    final landColor = isDark
        ? const Color(0xFF1E293B)
        : (isSatellite ? const Color(0xFFD4C5A9) : const Color(0xFFFEF3C7));
    final landPaint = Paint()
      ..color = landColor
      ..style = PaintingStyle.fill;

    final peninsulaPath = Path();
    // Rough stylized polygon of the Arabian Peninsula
    peninsulaPath.moveTo(size.width * 0.20, size.height * 0.15); // Jordan / North
    peninsulaPath.lineTo(size.width * 0.65, size.height * 0.15); // Iraq / Kuwait
    peninsulaPath.lineTo(size.width * 0.72, size.height * 0.32); // Gulf / Qatar
    peninsulaPath.lineTo(size.width * 0.85, size.height * 0.38); // UAE / Hormuz
    peninsulaPath.lineTo(size.width * 0.92, size.height * 0.48); // Oman coast
    peninsulaPath.lineTo(size.width * 0.82, size.height * 0.70); // Salalah
    peninsulaPath.lineTo(size.width * 0.60, size.height * 0.80); // Yemen south coast
    peninsulaPath.lineTo(size.width * 0.45, size.height * 0.86); // Aden
    peninsulaPath.lineTo(size.width * 0.33, size.height * 0.84); // Bab al-Mandab
    peninsulaPath.lineTo(size.width * 0.26, size.height * 0.65); // Red Sea coast (Hodeidah / Jizan)
    peninsulaPath.lineTo(size.width * 0.22, size.height * 0.45); // Jeddah
    peninsulaPath.lineTo(size.width * 0.18, size.height * 0.28); // Yanbu / Tabuk
    peninsulaPath.close();

    canvas.drawPath(peninsulaPath, landPaint);

    // 3. African Coastline (Egypt, Sudan, Eritrea, Djibouti, Somalia)
    final africaPaint = Paint()
      ..color = isDark
          ? const Color(0xFF162032)
          : (isSatellite ? const Color(0xFFC7B89C) : const Color(0xFFFDE68A));

    final africaPath = Path();
    africaPath.moveTo(0, size.height * 0.20);
    africaPath.lineTo(size.width * 0.14, size.height * 0.30); // Egypt
    africaPath.lineTo(size.width * 0.12, size.height * 0.52); // Sudan
    africaPath.lineTo(size.width * 0.22, size.height * 0.72); // Eritrea
    africaPath.lineTo(size.width * 0.28, size.height * 0.84); // Djibouti
    africaPath.lineTo(size.width * 0.40, size.height * 0.94); // Somalia Horn
    africaPath.lineTo(0, size.height);
    africaPath.close();
    canvas.drawPath(africaPath, africaPaint);

    // 4. International Borders / Boundaries
    final borderPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.15)
          : const Color(0xFF94A3B8).withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Saudi - Yemen Border
    final saudiYemenBorder = Path();
    saudiYemenBorder.moveTo(size.width * 0.28, size.height * 0.63); // Midi / Haradh
    saudiYemenBorder.lineTo(size.width * 0.42, size.height * 0.60); // Saada / Najran
    saudiYemenBorder.lineTo(size.width * 0.58, size.height * 0.62); // Al-Wadiah / Rub al-Khali
    canvas.drawPath(saudiYemenBorder, borderPaint);

    // Oman - Yemen Border
    final omanYemenBorder = Path();
    omanYemenBorder.moveTo(size.width * 0.58, size.height * 0.62);
    omanYemenBorder.lineTo(size.width * 0.68, size.height * 0.72); // Shahan / Sarfayt
    canvas.drawPath(omanYemenBorder, borderPaint);

    // 5. Main Trade & Highway Corridors
    final roadPaint = Paint()
      ..color = isDark
          ? const Color(0xFF475569)
          : const Color(0xFFCBD5E1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Riyadh -> Jeddah highway
    canvas.drawLine(Offset(size.width * 0.50, size.height * 0.34),
        Offset(size.width * 0.28, size.height * 0.44), roadPaint);

    // Riyadh -> Al-Wadiah -> Sana'a
    final riyadhSanaaRoute = Path();
    riyadhSanaaRoute.moveTo(size.width * 0.50, size.height * 0.34);
    riyadhSanaaRoute.lineTo(size.width * 0.49, size.height * 0.62); // Wadiah
    riyadhSanaaRoute.lineTo(size.width * 0.40, size.height * 0.69); // Sana'a
    canvas.drawPath(riyadhSanaaRoute, roadPaint);

    // Sana'a -> Taiz -> Aden highway
    final yemenMainArtery = Path();
    yemenMainArtery.moveTo(size.width * 0.40, size.height * 0.69);
    yemenMainArtery.lineTo(size.width * 0.36, size.height * 0.77); // Taiz
    yemenMainArtery.lineTo(size.width * 0.47, size.height * 0.81); // Aden
    canvas.drawPath(yemenMainArtery, roadPaint);

    // Salalah -> Shahan -> Mukalla
    final omanYemenRoute = Path();
    omanYemenRoute.moveTo(size.width * 0.70, size.height * 0.66); // Salalah
    omanYemenRoute.lineTo(size.width * 0.65, size.height * 0.70); // Shahan
    omanYemenRoute.lineTo(size.width * 0.58, size.height * 0.78); // Mukalla
    canvas.drawPath(omanYemenRoute, roadPaint);
  }

  @override
  bool shouldRepaint(covariant _RegionalMapPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.isSatellite != isSatellite ||
        oldDelegate.isZoomedYemen != isZoomedYemen;
  }
}
