import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/tracking_models.dart';
import '../widgets/driver_filter_modal.dart';
import '../widgets/driver_search_modal.dart';
import '../widgets/merchant_bottom_nav_bar.dart';
import '../widgets/truck_map_marker.dart';

/// Screen representing the full Drivers Map in Hamoola.
/// Faithfully reproduces Image 2 (Target/Expected Visual Reference):
/// - Real interactive geographic map via flutter_map with CartoDB/OSM/ESRI tiles
/// - Default scope: Arabian Peninsula (Saudi Arabia, Yemen, Oman, UAE & transit borders)
/// - Default filter: Shows ONLY available drivers (86 drivers available now)
/// - ZERO tractors/harvesters! Only verified heavy cargo trucks
/// - Marker Clustering: Dense clusters grouped into dark circular badges (e.g. "6" or "8")
/// - Truck graphics: Clean isometric/flat vector trucks with small green status dot
/// - Key feature: "متاح للعودة إلى اليمن" Callout speech bubble on trucks in Saudi/Oman
/// - Floating map tools (Layers, Fullscreen, Zoom In, Zoom Out, GPS Recenter)
/// - Bottom summary sheet with dynamic counters:
///   86 سائقاً متاحاً الآن | مركبات نقل في السعودية وعُمان واليمن
///   السعودية 34, عمان 18, اليمن 25, الإمارات 6, + المزيد
/// - Bottom navigation bar matching Hamoola design system
class MerchantMapScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<AvailableTruckMarker>? onViewDriverProfile;
  final ValueChanged<AvailableTruckMarker>? onDirectOrder;
  final VoidCallback? onHome;
  final VoidCallback? onOrders;
  final VoidCallback? onAccount;
  final VoidCallback? onCreateOrder;
  final bool enableTileNetwork;

  const MerchantMapScreen({
    super.key,
    this.onBack,
    this.onViewDriverProfile,
    this.onDirectOrder,
    this.onHome,
    this.onOrders,
    this.onAccount,
    this.onCreateOrder,
    this.enableTileNetwork = true,
  });

  @override
  State<MerchantMapScreen> createState() => _MerchantMapScreenState();
}

class _MerchantMapScreenState extends State<MerchantMapScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _mapController = MapController();

  String _selectedCategory = 'all';
  String _selectedRegionFilter = 'all';
  String? _selectedScope; // null by default: shows both Saudi Arabia & Yemen per Image 1
  DriverFilterCriteria _activeFilterCriteria = const DriverFilterCriteria(
    availabilityStatus: 'available', // Default to available drivers only!
  );
  AvailableTruckMarker? _selectedMarker;
  double _currentZoom = 4.9;
  bool _isSatelliteMode = false;
  bool _isFullscreen = false;
  bool _showDriversPanel = false;

  static const LatLng _initialCenter = LatLng(20.5, 45.0); // South Arabian Peninsula (Saudi & Yemen centered)

  static const List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'label': 'الكل', 'icon': null},
    {'key': 'شاحنات', 'label': 'شاحنات', 'icon': Icons.local_shipping_outlined},
    {'key': 'قاطرات', 'label': 'قاطرات', 'icon': Icons.rv_hookup_rounded},
    {'key': 'دينات', 'label': 'دينات', 'icon': Icons.fire_truck_outlined},
    {'key': 'تبريد', 'label': 'تبريد', 'icon': Icons.ac_unit_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      // 0. Scope Tab Filter (القريب منك / السعودية / اليمن)
      if (_selectedScope == 'saudi') {
        if (!truck.currentCountry.contains('السعودية')) return false;
      } else if (_selectedScope == 'yemen') {
        if (!truck.currentCountry.contains('اليمن')) return false;
      }

      // 1. Category Filter
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

      // 2. Availability Status Filter (Default: Available Only)
      if (_activeFilterCriteria.availabilityStatus != 'all') {
        if (truck.availabilityStatus !=
            _activeFilterCriteria.availabilityStatus) {
          return false;
        }
      }

      // 3. Governorate / Region Filter
      if (_selectedRegionFilter != 'all') {
        final reg = _selectedRegionFilter;
        final matchesCountry = truck.currentCountry.contains(reg);
        final matchesGov = truck.governorate.contains(reg);
        final matchesCity = truck.currentCity.contains(reg);
        if (!matchesCountry && !matchesGov && !matchesCity) {
          return false;
        }
      }

      if (_activeFilterCriteria.governorate != 'all') {
        final gov = _activeFilterCriteria.governorate;
        final inCountry = truck.currentCountry.contains(gov);
        final inGov = truck.governorate.contains(gov);
        if (!inCountry && !inGov) return false;
      }

      // 4. City / District Filter
      if (_activeFilterCriteria.cityOrDistrict != 'all') {
        final dist = _activeFilterCriteria.cityOrDistrict;
        final matchesDist = truck.district != null && truck.district!.contains(dist);
        final matchesCity = truck.currentCity.contains(dist);
        if (!matchesDist && !matchesCity) return false;
      }

      // 5. Cargo Type Filter
      if (_activeFilterCriteria.cargoType != 'all') {
        final reqCargo = _activeFilterCriteria.cargoType;
        final supports = truck.supportedCargoTypes.any((c) => c.contains(reqCargo));
        if (!supports) return false;
      }

      // 6. Search Query
      final query = _normalize(_searchController.text);
      if (query.isNotEmpty) {
        final nameNorm = _normalize(truck.driverName);
        final cityNorm = _normalize(truck.currentCity);
        final govNorm = _normalize(truck.governorate);
        final countryNorm = _normalize(truck.currentCountry);
        final vehNorm = _normalize(truck.vehicleType);
        final catNorm = _normalize(truck.vehicleCategory);
        final idNorm = _normalize(truck.driverId);
        final distNorm = truck.district != null ? _normalize(truck.district!) : '';

        final matches = nameNorm.contains(query) ||
            cityNorm.contains(query) ||
            govNorm.contains(query) ||
            countryNorm.contains(query) ||
            vehNorm.contains(query) ||
            catNorm.contains(query) ||
            idNorm.contains(query) ||
            distNorm.contains(query);

        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  void _zoomIn() {
    final nextZoom = (_currentZoom + 1.0).clamp(3.5, 16.0);
    _mapController.move(_mapController.camera.center, nextZoom);
    setState(() => _currentZoom = nextZoom);
  }

  void _zoomOut() {
    final nextZoom = (_currentZoom - 1.0).clamp(3.5, 16.0);
    _mapController.move(_mapController.camera.center, nextZoom);
    setState(() => _currentZoom = nextZoom);
  }

  void _resetToBothCountries() {
    _mapController.move(_initialCenter, 4.9);
    setState(() {
      _currentZoom = 4.9;
      _selectedScope = null;
      _selectedRegionFilter = 'all';
      _selectedMarker = null;
    });
  }

  void _recenter() {
    const najran = LatLng(17.55, 44.22);
    _mapController.move(najran, 6.8);
    setState(() {
      _currentZoom = 6.8;
      _selectedScope = 'nearby';
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

  void _handleNearbyScope() {
    _showNearbyLocationDialog();
  }

  void _showNearbyLocationDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.near_me_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Text(
              'تحديد موقعك القريب',
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          'يمكن للتطبيق ترتيب وعرض السائقين الأقرب إليك. اختر موقعك المرجعي أو استخدم الموقع الحالي:',
          style: GoogleFonts.cairo(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _simulateUserLocation(const LatLng(15.3694, 44.1910), 'صنعاء، اليمن');
            },
            child: Text('صنعاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _simulateUserLocation(const LatLng(24.7136, 46.6753), 'الرياض، السعودية');
            },
            child: Text('الرياض', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _simulateUserLocation(const LatLng(17.55, 44.22), 'صنعاء، اليمن');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: Text('موقعي الحالي', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _simulateUserLocation(LatLng location, String label) {
    _mapController.move(location, 7.2);
    setState(() {
      _currentZoom = 7.2;
      _selectedScope = 'nearby';
      _selectedRegionFilter = 'all';
      _selectedMarker = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديد موقعك الحالي: $label'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _focusOnSaudi() {
    const saudiCenter = LatLng(24.5, 45.0);
    _mapController.move(saudiCenter, 5.8);
    setState(() {
      _currentZoom = 5.8;
      _selectedScope = 'saudi';
      _selectedRegionFilter = 'السعودية';
      _selectedMarker = null;
    });
  }

  void _focusOnYemen() {
    const yemenCenter = LatLng(15.5, 47.5);
    _mapController.move(yemenCenter, 6.8);
    setState(() {
      _currentZoom = 6.8;
      _selectedScope = 'yemen';
      _selectedRegionFilter = 'اليمن';
      _selectedMarker = null;
    });
  }

  void _focusOnOman() {
    const omanCenter = LatLng(21.5, 57.0);
    _mapController.move(omanCenter, 6.2);
    setState(() {
      _currentZoom = 6.2;
      _selectedScope = null;
      _selectedRegionFilter = 'عمان';
      _selectedMarker = null;
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
              child: Column(
                children: [
                  // 1. Header (خريطة السائقين • السائقين المتاحين بالقرب منك)
                  if (!_isFullscreen) _buildHeader(isDark),

                  // 2. Search Row with Filter Trigger Button
                  if (!_isFullscreen) _buildSearchRow(isDark),

                  // 3. Region Scope Pills (القريب منك • السعودية • اليمن)
                  if (!_isFullscreen) _buildScopePillsRow(isDark),

                  // 4. Category Filter Chips (الكل، شاحنات، قاطرات، دينات، تبريد ❄️، أخرى)
                  if (!_isFullscreen) _buildCategoryChipsBar(isDark),

                  // 5. Map Viewport & Interactive Layer
                  Expanded(
                    child: Stack(
                      children: [
                        // FlutterMap Interactive Canvas
                        Positioned.fill(
                          child: _buildFlutterMap(isDark),
                        ),

                        // Map Tools Floating Column (Layers, Fullscreen, +, -, GPS) on the LEFT
                        Positioned(
                          left: 14,
                          top: 14,
                          child: _buildMapToolsFloatingColumn(isDark),
                        ),

                        // Empty State Banner if 0 trucks match
                        if (_filteredTrucks.isEmpty)
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 64,
                            child: _buildNoResultsBanner(isDark),
                          ),

                        // Scale Indicator (0 100 200 300 كم) matching Image 1 on the RIGHT
                        Positioned(
                          right: 14,
                          bottom: _selectedMarker != null
                              ? 210
                              : (_showDriversPanel ? 305 : 18),
                          child: _buildMapScaleIndicator(isDark),
                        ),

                        // Bottom Overlay: Selected Driver Card or Draggable Drivers Panel if opened
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _selectedMarker != null
                              ? _buildSelectedDriverCard(_selectedMarker!, isDark)
                              : (_showDriversPanel
                                  ? _buildDraggableDriversPanel(isDark)
                                  : const SizedBox.shrink()),
                        ),
                      ],
                    ),
                  ),

                  // 5. Bottom Navigation Bar matching Image 2
                  if (!_isFullscreen)
                    MerchantBottomNavBar(
                      currentTab: MerchantNavTab.map,
                      showMapTab: true,
                      onTabSelected: (tab) {
                        if (tab == MerchantNavTab.home) {
                          widget.onHome?.call();
                        } else if (tab == MerchantNavTab.orders) {
                          widget.onOrders?.call();
                        } else if (tab == MerchantNavTab.account) {
                          widget.onAccount?.call();
                        }
                      },
                      onFabPressed: () => widget.onCreateOrder?.call(),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          // 1. Back button styled as a squircle container matching reference image
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              color: isDark ? AppColors.textWhite : const Color(0xFF334155),
              onPressed: widget.onBack,
              tooltip: AppStrings.back,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12),

          // 2. Title & Subtitle matching reference image
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.merchantMapTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  AppStrings.merchantMapSubtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3 Prominent Scope Pills matching target reference map:
  /// [القريب منك] • [السعودية] • [اليمن]
  Widget _buildScopePillsRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
      child: Row(
        children: [
          // 1. القريب منك (Red border & background tint when selected)
          Expanded(
            child: _buildScopePill(
              title: 'القريب منك',
              icon: Icons.near_me_outlined,
              isSelected: _selectedScope == 'nearby',
              isDark: isDark,
              onTap: () {
                if (_selectedScope == 'nearby') {
                  _resetToBothCountries();
                } else {
                  _handleNearbyScope();
                }
              },
            ),
          ),
          const SizedBox(width: 8),

          // 2. السعودية
          Expanded(
            child: _buildScopePill(
              title: 'السعودية',
              icon: Icons.map_outlined,
              isSelected: _selectedScope == 'saudi',
              isDark: isDark,
              onTap: () {
                if (_selectedScope == 'saudi') {
                  _resetToBothCountries();
                } else {
                  _focusOnSaudi();
                }
              },
            ),
          ),
          const SizedBox(width: 8),

          // 3. اليمن
          Expanded(
            child: _buildScopePill(
              title: 'اليمن',
              icon: Icons.map_outlined,
              isSelected: _selectedScope == 'yemen',
              isDark: isDark,
              onTap: () {
                if (_selectedScope == 'yemen') {
                  _resetToBothCountries();
                } else {
                  _focusOnYemen();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopePill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeColor = const Color(0xFFEF4444); // Red/Coral matching reference
    final borderColor = isSelected
        ? activeColor
        : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0));
    final bgColor = isSelected
        ? (isDark ? const Color(0x2EEF4444) : const Color(0xFFFEF2F2))
        : (isDark ? const Color(0xFF1E293B) : Colors.white);
    final textColor = isSelected
        ? activeColor
        : (isDark ? Colors.white : const Color(0xFF334155));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow(bool isDark) {
    final hasActiveFilter = !_activeFilterCriteria.isDefault;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          // Search Field Button (Right side in RTL)
          Expanded(
            child: InkWell(
              onTap: () => _openSearchModal(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        size: 20, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _searchController.text.isEmpty
                            ? AppStrings.searchDriversHint
                            : _searchController.text,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: _searchController.text.isEmpty
                              ? const Color(0xFF94A3B8)
                              : (isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight),
                          fontWeight: _searchController.text.isEmpty
                              ? FontWeight.w500
                              : FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: Color(0xFF94A3B8)),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Filter Trigger Button (Left side in RTL)
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
        });
      },
    );
  }

  void _openSearchModal(BuildContext context) {
    DriverSearchModal.show(
      context,
      allTrucks: AvailableTruckMarker.demoTrucks,
      initialQuery: _searchController.text,
      currentFilter: _activeFilterCriteria,
      onSelectDriver: (driver) {
        setState(() {
          _selectedMarker = driver;
          _searchController.text = driver.driverName;
        });
        _mapController.move(LatLng(driver.latitude, driver.longitude), 12.5);
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
        _mapController.move(LatLng(location.latitude, location.longitude), 11.5);
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
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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

  Widget _buildFlutterMap(bool isDark) {
    final trucks = _filteredTrucks;
    final markers = <Marker>[];

    // 1. Pulsing Blue GPS Location Marker (Image reference: Najran / Saudi-Yemen border)
    markers.add(
      Marker(
        point: const LatLng(17.55, 44.22),
        width: 80,
        height: 80,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.22),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
              ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2563EB),
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x662563EB),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 2. Clustering & Realistic Vector Truck Markers matching Image 1
    final riyadhTrucks =
        trucks.where((t) => t.currentCity.contains('الرياض')).toList();
    final sanaaTrucks =
        trucks.where((t) => t.currentCity.contains('صنعاء')).toList();

    final isClustered = _currentZoom < 7.0;

    // 2a. Riyadh Cluster
    if (isClustered && riyadhTrucks.length > 2) {
      markers.add(
        Marker(
          point: const LatLng(24.7136, 46.6753),
          width: 44,
          height: 44,
          child: TruckMapMarker(
            isCluster: true,
            clusterCount: riyadhTrucks.length,
            clusterCity: 'الرياض',
            onTap: () {
              _mapController.move(const LatLng(24.7136, 46.6753), 8.5);
              setState(() => _currentZoom = 8.5);
            },
          ),
        ),
      );
    }

    // 2b. Sana'a Cluster
    if (isClustered && sanaaTrucks.length > 2) {
      markers.add(
        Marker(
          point: const LatLng(15.3694, 44.1910),
          width: 44,
          height: 44,
          child: TruckMapMarker(
            isCluster: true,
            clusterCount: sanaaTrucks.length,
            clusterCity: 'صنعاء',
            onTap: () {
              _mapController.move(const LatLng(15.3694, 44.1910), 8.5);
              setState(() => _currentZoom = 8.5);
            },
          ),
        ),
      );
    }

    // 2c. Individual Realistic Vector Trucks with Small Green Status Dot
    for (int i = 0; i < trucks.length; i++) {
      final t = trucks[i];
      final inRiyadh = t.currentCity.contains('الرياض');
      final inSanaa = t.currentCity.contains('صنعاء');

      if (isClustered &&
          ((inRiyadh && riyadhTrucks.length > 2) ||
              (inSanaa && sanaaTrucks.length > 2))) {
        continue;
      }

      final latOffset = ((i % 5) - 2) * 0.035;
      final lngOffset = (((i ~/ 5) % 5) - 2) * 0.035;
      final lat = t.latitude + (isClustered ? 0 : latOffset);
      final lng = t.longitude + (isClustered ? 0 : lngOffset);

      final isSelected = _selectedMarker?.id == t.id;

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 52,
          height: 40,
          child: TruckMapMarker(
            truck: t,
            isSelected: isSelected,
            isBadge: false,
            isPhotoPin: false,
            showCallout: t.returnToYemenAvailable &&
                (t.currentCity == 'نجران' || t.currentCity == 'جيزان'),
            onTap: () {
              setState(() => _selectedMarker = t);
            },
          ),
        ),
      );
    }

    // High quality map tile URLs (OpenStreetMap: 100% Arabic geography, 0 API key, 0 watermark)
    final tileUrl = _isSatelliteMode
        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.jpg'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _initialCenter,
        initialZoom: _currentZoom,
        minZoom: 3.5,
        maxZoom: 18.0,
        onPositionChanged: (camera, hasGesture) {
          if ((camera.zoom - _currentZoom).abs() > 0.1) {
            setState(() => _currentZoom = camera.zoom);
          }
        },
        onTap: (tapPosition, point) {
          if (_selectedMarker != null) {
            setState(() => _selectedMarker = null);
          }
        },
      ),
      children: [
        // Real Geographic Tile Layer (OpenStreetMap / Esri Satellite)
        if (widget.enableTileNetwork)
          TileLayer(
            urlTemplate: tileUrl,
            userAgentPackageName: 'com.hamoola.app',
            maxZoom: 18,
            errorTileCallback: (tile, error, stackTrace) {},
          ),

        // Truck Markers Layer with Clustering
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }

  Widget _buildMapToolsFloatingColumn(bool isDark) {
    return Column(
      children: [
        _buildToolBtn(
          icon: _isSatelliteMode ? Icons.map_rounded : Icons.layers_rounded,
          tooltip: _isSatelliteMode ? 'خريطة الطرق' : 'صور الأقمار الصناعية',
          isDark: isDark,
          onTap: () {
            setState(() => _isSatelliteMode = !_isSatelliteMode);
          },
        ),
        const SizedBox(height: 8),
        _buildToolBtn(
          icon: _isFullscreen
              ? Icons.fullscreen_exit_rounded
              : Icons.fullscreen_rounded,
          tooltip: _isFullscreen ? 'خروج من ملء الشاشة' : 'ملء الشاشة',
          isDark: isDark,
          onTap: () {
            setState(() => _isFullscreen = !_isFullscreen);
          },
        ),
        const SizedBox(height: 8),
        _buildToolBtn(
          icon: Icons.add_rounded,
          tooltip: 'تكبير',
          isDark: isDark,
          onTap: _zoomIn,
        ),
        const SizedBox(height: 8),
        _buildToolBtn(
          icon: Icons.remove_rounded,
          tooltip: 'تصغير',
          isDark: isDark,
          onTap: _zoomOut,
        ),
        const SizedBox(height: 8),
        _buildToolBtn(
          icon: Icons.my_location_rounded,
          tooltip: 'موقعي الحالي',
          isDark: isDark,
          color: const Color(0xFF2563EB),
          onTap: _recenter,
        ),
      ],
    );
  }

  Widget _buildToolBtn({
    required IconData icon,
    required String tooltip,
    required bool isDark,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color ??
                  (isDark ? Colors.white : const Color(0xFF334155)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapScaleIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('0', style: GoogleFonts.cairo(fontSize: 8.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF475569))),
              const SizedBox(width: 14),
              Text('100', style: GoogleFonts.cairo(fontSize: 8.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF475569))),
              const SizedBox(width: 14),
              Text('200', style: GoogleFonts.cairo(fontSize: 8.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF475569))),
              const SizedBox(width: 14),
              Text('300 كم', style: GoogleFonts.cairo(fontSize: 8.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 1),
          SizedBox(
            width: 110,
            height: 5,
            child: CustomPaint(
              painter: _ScaleBarPainter(
                color: isDark ? Colors.white70 : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
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
                _activeFilterCriteria = const DriverFilterCriteria(
                  availabilityStatus: 'available',
                );
                _selectedCategory = 'all';
                _selectedRegionFilter = 'all';
                _selectedScope = 'nearby';
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

  /// Sliding Bottom Panel matching Target Reference Map:
  /// - Top drag handle
  /// - Header: "السائقين المتاحين بالقرب منك" • "12 سائق متاح"
  /// - List of available drivers with avatar, online dot, rating, distance, "عرض التفاصيل" button
  Widget _buildDraggableDriversPanel(bool isDark) {
    final availableTrucks = _filteredTrucks.where((t) => t.isAvailable).toList();
    final scopeTitle = _selectedScope == 'nearby'
        ? 'السائقين المتاحين بالقرب منك'
        : (_selectedScope == 'saudi'
            ? 'السائقين المتاحين في السعودية'
            : 'السائقين المتاحين في اليمن');

    return Container(
      height: 295,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Subtle Drag Handle
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Header Row: "السائقين المتاحين بالقرب منك" • "12 سائق متاح"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    scopeTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${availableTrucks.length} سائق متاح',
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => _showDriversPanel = false),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF1F5F9),
          ),

          // 3. Driver Cards List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              itemCount: availableTrucks.length,
              separatorBuilder: (context, index) => Divider(
                height: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF8FAFC),
              ),
              itemBuilder: (context, index) {
                final truck = availableTrucks[index];
                return _buildDriverListItem(truck, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverListItem(AvailableTruckMarker truck, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // 1. Action Button on the LEFT: "عرض التفاصيل"
          InkWell(
            onTap: () {
              setState(() => _selectedMarker = truck);
              widget.onViewDriverProfile?.call(truck);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5), // Soft mint green
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFA7F3D0), // Light emerald border
                  width: 1.0,
                ),
              ),
              child: Text(
                'عرض التفاصيل',
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF059669), // Emerald green
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 2. Middle Column: Rating and Distance
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Distance
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${truck.distanceKm} كم',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Rating
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    truck.rating.toStringAsFixed(1),
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 10),

          // 3. Driver Info Column in the middle (Expanded)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  truck.driverName,
                  style: GoogleFonts.cairo(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  truck.vehicleType,
                  style: GoogleFonts.cairo(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 11,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${truck.currentCity} - ${truck.currentCountry.replaceAll('المملكة العربية السعودية', 'السعودية')}',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // 4. Driver Avatar with Online Dot on RIGHT
          Stack(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage: AssetImage(truck.avatarAsset),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Compact Driver Details Sheet when a marker is tapped
  Widget _buildSelectedDriverCard(AvailableTruckMarker driver, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close Icon and Handle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => setState(() => _selectedMarker = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),

          const SizedBox(height: 8),

          // Driver Identity Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  driver.avatarAsset,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: const Color(0xFFE2E8F0),
                    child: const Icon(Icons.person, color: Color(0xFF64748B)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          driver.driverName,
                          style: GoogleFonts.cairo(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textWhite
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        if (driver.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded,
                              size: 15, color: Color(0xFF10B981)),
                        ],
                      ],
                    ),
                    Text(
                      '${driver.vehicleType}  •  ${driver.capacity}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textSubtle
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: Color(0xFF2563EB)),
                        const SizedBox(width: 4),
                        Text(
                          '${driver.currentCity}، ${driver.currentCountry}',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (driver.returnToYemenAvailable) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'متاح للعودة إلى اليمن',
                              style: GoogleFonts.cairo(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons: Direct Order / View Profile
          Row(
            children: [
              Expanded(
                flex: 4,
                child: OutlinedButton(
                  onPressed: () {
                    widget.onViewDriverProfile?.call(driver);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'عرض الملف',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onDirectOrder?.call(driver);
                  },
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: Text(
                    'طلب نقل',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
}

class _ScaleBarPainter extends CustomPainter {
  final Color color;
  _ScaleBarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    // Baseline along the bottom
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
    // Ticks at 0%, 33%, 66%, 100%
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.33, 0), Offset(size.width * 0.33, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.66, 0), Offset(size.width * 0.66, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
