import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/router/app_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cargo_bid_opportunity.dart';
import '../../domain/models/driver_simulation_store.dart';

/// Screen representing "خريطة الحمولات" for truck drivers.
/// Allows drivers to explore cargo transport opportunities visually on an interactive map.
class DriverCargoMapScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<CargoBidOpportunity>? onOrderDetails;

  const DriverCargoMapScreen({
    super.key,
    this.onBack,
    this.onOrderDetails,
  });

  @override
  State<DriverCargoMapScreen> createState() => _DriverCargoMapScreenState();
}

class _DriverCargoMapScreenState extends State<DriverCargoMapScreen> {
  final MapController _mapController = MapController();

  String _activeFilter = 'الكل';
  CargoBidOpportunity? _selectedCargo;
  double _currentZoom = 6.0;
  bool _isSatellite = false;

  static const LatLng _centerPoint = LatLng(15.5, 46.0);

  // Geographic coordinates mapped to origin cities of cargo opportunities
  static const Map<String, LatLng> _cityCoordinates = {
    'صنعاء': LatLng(15.3694, 44.1910),
    'عدن': LatLng(12.7855, 45.0187),
    'تعز': LatLng(13.5795, 44.0209),
    'الحديدة': LatLng(14.7978, 42.9545),
    'ذمار': LatLng(14.5427, 44.4051),
    'إب': LatLng(13.9667, 44.1833),
    'المكلا': LatLng(14.5425, 49.1242),
    'مأرب': LatLng(15.4542, 45.3253),
    'الرياض': LatLng(24.7136, 46.6753),
    'الدمام': LatLng(26.4207, 50.0888),
    'القصيم': LatLng(26.3260, 43.9750),
    'الجبيل': LatLng(27.0046, 49.6606),
    'الهفوف': LatLng(25.3833, 49.5833),
  };

  LatLng _getCoordinatesForOpportunity(CargoBidOpportunity opp) {
    for (final entry in _cityCoordinates.entries) {
      if (opp.originCity.contains(entry.key)) {
        return entry.value;
      }
    }
    return const LatLng(15.3694, 44.1910);
  }

  List<CargoBidOpportunity> get _filteredOpportunities {
    final list = DriverSimulationStore.instance.opportunities;
    switch (_activeFilter) {
      case 'العامة':
        return list.where((c) => !c.isPrivate).toList();
      case 'الخاصة':
        return list.where((c) => c.isPrivate).toList();
      case 'مطابق لشاحنتي':
        return list.where((c) => c.requiredTruckType.contains('براد') || c.requiredTruckType.contains('ثقيل')).toList();
      case 'تحميل فوري':
        return list.where((c) => c.isUrgent).toList();
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opportunities = _filteredOpportunities;

    final tileUrl = _isSatellite
        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.jpg'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.navyDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              size: 20,
            ),
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          title: Column(
            children: [
              Text(
                'خريطة الحمولات',
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                '${opportunities.length} فرصة نقل متاحة على الخريطة',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _isSatellite ? Icons.map_rounded : Icons.satellite_alt_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
              tooltip: _isSatellite ? 'الخريطة العادية' : 'صور الأقمار الصناعية',
              onPressed: () => setState(() => _isSatellite = !_isSatellite),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Map Canvas
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _centerPoint,
                initialZoom: _currentZoom,
                minZoom: 3.5,
                maxZoom: 18.0,
                onPositionChanged: (camera, hasGesture) {
                  if ((camera.zoom - _currentZoom).abs() > 0.1) {
                    setState(() => _currentZoom = camera.zoom);
                  }
                },
                onTap: (tapPosition, point) {
                  if (_selectedCargo != null) {
                    setState(() => _selectedCargo = null);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  userAgentPackageName: 'com.hamula.app',
                ),
                MarkerLayer(
                  markers: opportunities.map((opp) {
                    final pos = _getCoordinatesForOpportunity(opp);
                    final isSelected = _selectedCargo?.id == opp.id;

                    return Marker(
                      point: pos,
                      width: 58,
                      height: 58,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedCargo = opp);
                          _mapController.move(pos, (_currentZoom < 7.5 ? 7.5 : _currentZoom));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer pulse ring if urgent or selected
                              if (opp.isUrgent || isSelected)
                                Container(
                                  width: isSelected ? 56 : 46,
                                  height: isSelected ? 56 : 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (isSelected
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFFEA580C))
                                        .withValues(alpha: 0.25),
                                  ),
                                ),

                              // Pin Body
                              Container(
                                width: isSelected ? 38 : 32,
                                height: isSelected ? 38 : 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : opp.isPrivate
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFF1E3A8A),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  opp.isPrivate ? Icons.lock_rounded : Icons.inventory_2_rounded,
                                  size: isSelected ? 20 : 16,
                                  color: Colors.white,
                                ),
                              ),

                              // Urgency red dot
                              if (opp.isUrgent)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDC2626),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // Top Filter Chips Bar
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    'الكل',
                    'العامة',
                    'الخاصة',
                    'مطابق لشاحنتي',
                    'تحميل فوري',
                  ].map((filter) {
                    final isSelected = _activeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.transparent,
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2563EB),
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          onSelected: (val) {
                            if (val) setState(() => _activeFilter = filter);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Floating Map Controls (Zoom In, Zoom Out, Recenter)
            Positioned(
              left: 14,
              bottom: _selectedCargo != null ? 220 : 24,
              child: Column(
                children: [
                  _buildFloatingMapTool(
                    icon: Icons.add,
                    onTap: () {
                      final targetZoom = (_currentZoom + 1.0).clamp(3.5, 18.0);
                      _mapController.move(_mapController.camera.center, targetZoom);
                      setState(() => _currentZoom = targetZoom);
                    },
                    tooltip: 'تكبير',
                  ),
                  const SizedBox(height: 8),
                  _buildFloatingMapTool(
                    icon: Icons.remove,
                    onTap: () {
                      final targetZoom = (_currentZoom - 1.0).clamp(3.5, 18.0);
                      _mapController.move(_mapController.camera.center, targetZoom);
                      setState(() => _currentZoom = targetZoom);
                    },
                    tooltip: 'تصغير',
                  ),
                  const SizedBox(height: 8),
                  _buildFloatingMapTool(
                    icon: Icons.my_location_rounded,
                    onTap: () {
                      _mapController.move(_centerPoint, 6.0);
                      setState(() => _currentZoom = 6.0);
                    },
                    tooltip: 'إعادة التمركز',
                  ),
                ],
              ),
            ),

            // Bottom Selected Cargo Card
            if (_selectedCargo != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildSelectedCargoCard(_selectedCargo!, isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMapTool({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: const Color(0xFF0F172A)),
        ),
      ),
    );
  }

  Widget _buildSelectedCargoCard(CargoBidOpportunity cargo, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cargo.isUrgent ? const Color(0xFFEA580C) : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row: Cargo Title & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF2563EB), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cargo.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _selectedCargo = null),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Route & Distance
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${cargo.originCity} ← ${cargo.destinationCity} (${cargo.distanceKm} كم)',
                  style: GoogleFonts.cairo(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                ),
              ),
              if (cargo.isPrivate)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'طلب خاص',
                    style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF92400E)),
                  ),
                ),
            ],
          ),
          const Divider(height: 16),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الميزانية المقترحة:', style: GoogleFonts.cairo(fontSize: 10.5, color: const Color(0xFF64748B))),
                  Text(
                    '${cargo.targetBudgetYmr} ريال',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.push(AppRoutes.driverOrderDetails, extra: cargo);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(
                  cargo.isPrivate ? 'عرض التفاصيل' : 'تفاصيل الطلب والعرض',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
