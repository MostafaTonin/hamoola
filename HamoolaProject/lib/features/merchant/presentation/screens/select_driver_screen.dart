import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/transport_order_draft.dart';
import 'driver_profile_screen.dart';

enum DriverViewMode {
  list,
  map,
}

/// Screen allowing the merchant to pick a specific verified driver (Image 4)
class SelectDriverScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<DriverProfile>? onDriverSelected;

  const SelectDriverScreen({
    super.key,
    this.onBack,
    this.onDriverSelected,
  });

  @override
  State<SelectDriverScreen> createState() => _SelectDriverScreenState();
}

class _SelectDriverScreenState extends State<SelectDriverScreen> {
  final _searchController = TextEditingController();
  DriverViewMode _viewMode = DriverViewMode.list;
  bool _sortByNearest = true;
  DriverProfile? _selectedMapDriver;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DriverProfile> get _filteredDrivers {
    final query = _searchController.text.trim().toLowerCase();
    var list = DriverProfile.demoDrivers.where((d) {
      if (!d.isVerified) return false;
      if (query.isEmpty) return true;
      return d.name.toLowerCase().contains(query) ||
          d.vehicleType.toLowerCase().contains(query) ||
          d.city.toLowerCase().contains(query);
    }).toList();

    if (_sortByNearest) {
      // Sort so available drivers appear first
      list.sort((a, b) {
        if (a.isOnline && !b.isOnline) return -1;
        if (!a.isOnline && b.isOnline) return 1;
        return 0;
      });
    }
    return list;
  }

  void _confirmDriver(DriverProfile driver) {
    if (!driver.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('السائق مشغول حالياً، يرجى اختيار سائق متاح الآن.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    widget.onDriverSelected?.call(driver);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(driver);
    }
  }

  void _openDriverProfile(DriverProfile driver) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverProfileScreen(
          driver: driver,
          onBack: () => Navigator.of(context).pop(),
          onDirectOrder: (d) {
            Navigator.of(context).pop();
            _confirmDriver(d);
          },
        ),
      ),
    );
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

                  // 2. Search Field
                  _buildSearchBar(isDark),

                  // 3. Filter Tools (الأقرب مني + التبديل بين القائمة والخريطة)
                  _buildFilterTools(isDark),

                  // 4. Main Body: List view or Map view
                  Expanded(
                    child: _viewMode == DriverViewMode.list
                        ? _buildDriverList(isDark)
                        : _buildDriverMap(isDark),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. HEADER
  // ===========================================================================
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          Tooltip(
            message: AppStrings.back,
            child: InkWell(
              onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.0,
                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.selectDriverTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color:
                        isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  AppStrings.selectDriverSubtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Captain Badge Icon
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Icon(
              Icons.sports_motorsports_rounded,
              size: 24.0,
              color: Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. SEARCH BAR
  // ===========================================================================
  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      color: isDark ? AppColors.navyDark : Colors.white,
      child: Container(
        height: 44.0,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.cairo(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: AppStrings.searchDriverHint,
            hintStyle: GoogleFonts.cairo(
              fontSize: 12.5,
              color: const Color(0xFF94A3B8),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20.0,
              color: Color(0xFF64748B),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18.0),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. FILTER TOOLS BAR
  // ===========================================================================
  Widget _buildFilterTools(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
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
          // "الأقرب مني" Tool Button
          InkWell(
            onTap: () => setState(() => _sortByNearest = !_sortByNearest),
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: _sortByNearest
                    ? const Color(0xFFEFF6FF)
                    : (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: _sortByNearest
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.near_me_rounded,
                    size: 14.0,
                    color: _sortByNearest
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5.0),
                  Text(
                    'الأقرب مني',
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: _sortByNearest
                          ? const Color(0xFF1D4ED8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // View Mode Switcher: القائمة / الخريطة
          Container(
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                _buildViewTab(
                  mode: DriverViewMode.list,
                  label: 'القائمة',
                  icon: Icons.list_alt_rounded,
                  isDark: isDark,
                ),
                const SizedBox(width: 4.0),
                _buildViewTab(
                  mode: DriverViewMode.map,
                  label: 'الخريطة',
                  icon: Icons.map_rounded,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTab({
    required DriverViewMode mode,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () => setState(() => _viewMode = mode),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3.0,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14.0,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? AppColors.textWhite : const Color(0xFF0F172A))
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. DRIVER LIST VIEW
  // ===========================================================================
  Widget _buildDriverList(bool isDark) {
    final drivers = _filteredDrivers;

    if (drivers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 48.0,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12.0),
              Text(
                'لا يوجد سائقين مطابقين للبحث',
                style: GoogleFonts.cairo(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'يرجى التأكد من كتابة الاسم أو تجربة بحث آخر',
                style: GoogleFonts.cairo(
                  fontSize: 12.0,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 24.0),
      children: [
        // Section Title: السائقون القريبون
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 16.0,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(width: 6.0),
            Text(
              AppStrings.nearbyDriversLabel,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                '${drivers.length} سائقين',
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

        // Driver Cards
        ...drivers.map((driver) => _buildDriverCard(driver, isDark)),
      ],
    );
  }

  Widget _buildDriverCard(DriverProfile driver, bool isDark) {
    final isAvailable = driver.isOnline;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Vehicle / Driver Avatar Box
              InkWell(
                onTap: () => _openDriverProfile(driver),
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  children: [
                    Container(
                      width: 58.0,
                      height: 58.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9.0),
                        child: Image.asset(
                          driver.avatarAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(
                              Icons.local_shipping_rounded,
                              size: 28.0,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Online / Busy indicator dot
                    Positioned(
                      bottom: 2.0,
                      right: 2.0,
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),

              // Driver Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            driver.name,
                            style: GoogleFonts.cairo(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textWhite
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        const Icon(
                          Icons.verified_rounded,
                          size: 15.0,
                          color: Color(0xFF2563EB),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),

                    // Rating & Reviews
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15.0,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          driver.rating.toString(),
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textWhite
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '(${driver.reviewsCount} تقييم)',
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3.0),

                    // Distance & Vehicle Info
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13.0,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          driver.distance,
                          style: GoogleFonts.cairo(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text('•', style: TextStyle(color: Colors.grey.shade400)),
                        const SizedBox(width: 8.0),
                        Text(
                          driver.vehicleType,
                          style: GoogleFonts.cairo(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.primaryGold
                                : const Color(0xFFB45309),
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        // Status badge (متاح الآن / مشغول حالياً)
                        Text(
                          isAvailable ? 'متاح الآن' : 'مشغول حالياً',
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isAvailable
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEA580C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Button: اختيار
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: isAvailable ? () => _confirmDriver(driver) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  minimumSize: const Size(68.0, 36.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 6.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isAvailable ? AppStrings.chooseDriverBtn : 'مشغول',
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. DRIVER MAP VIEW
  // ===========================================================================
  Widget _buildDriverMap(bool isDark) {
    final drivers = _filteredDrivers;

    return Stack(
      children: [
        // Simulated Interactive Map Surface
        Container(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          child: CustomPaint(
            painter: _DriverMapPainter(
              drivers: drivers,
              selectedDriver: _selectedMapDriver,
              isDark: isDark,
            ),
            child: GestureDetector(
              onTapUp: (details) {
                // Approximate hit-testing for driver pins
                final size = context.size ?? const Size(400, 500);
                for (int i = 0; i < drivers.length; i++) {
                  final offset = _getDriverPinOffset(i, drivers.length, size);
                  if ((details.localPosition - offset).distance < 30.0) {
                    setState(() {
                      _selectedMapDriver = drivers[i];
                    });
                    return;
                  }
                }
              },
              child: const SizedBox.expand(),
            ),
          ),
        ),

        // Floating Toggle Button: "عرض في القائمة"
        Positioned(
          top: 14.0,
          left: 14.0,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _viewMode = DriverViewMode.list),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 4.0,
              minimumSize: const Size(120.0, 36.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            icon: const Icon(
              Icons.list_alt_rounded,
              size: 16.0,
              color: Color(0xFF2563EB),
            ),
            label: Text(
              'عرض في القائمة',
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ),

        // Selected Driver Floating Bottom Card
        if (_selectedMapDriver != null)
          Positioned(
            bottom: 20.0,
            left: 14.0,
            right: 14.0,
            child: _buildDriverCard(_selectedMapDriver!, isDark),
          ),
      ],
    );
  }

  Offset _getDriverPinOffset(int index, int total, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    // Disperse pins around center
    final angle = (index * 2 * 3.14159) / (total > 0 ? total : 1);
    final radius = 90.0 + (index % 2) * 35.0;
    return Offset(
      cx + radius * (angle > 3.14 ? -0.8 : 0.8),
      cy + radius * (index.isEven ? -0.6 : 0.6),
    );
  }
}

class _DriverMapPainter extends CustomPainter {
  final List<DriverProfile> drivers;
  final DriverProfile? selectedDriver;
  final bool isDark;

  _DriverMapPainter({
    required this.drivers,
    required this.selectedDriver,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Grid lines for map feel
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // User / Merchant Center Pin with ripple effect
    final ripplePaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 32.0, ripplePaint);

    final merchantPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 10.0, merchantPaint);

    final whiteCenter = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 4.0, whiteCenter);

    // Driver Pins
    for (int i = 0; i < drivers.length; i++) {
      final driver = drivers[i];
      final isSelected = selectedDriver?.id == driver.id;
      final angle = (i * 2 * 3.14159) / drivers.length;
      final radius = 90.0 + (i % 2) * 35.0;
      final pos = Offset(
        cx + radius * (angle > 3.14 ? -0.8 : 0.8),
        cy + radius * (i.isEven ? -0.6 : 0.6),
      );

      // Pin circle
      final pinBg = Paint()
        ..color = isSelected
            ? const Color(0xFFF59E0B)
            : (driver.isOnline
                ? const Color(0xFF0F172A)
                : const Color(0xFF94A3B8))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, isSelected ? 18.0 : 14.0, pinBg);

      final pinBorder = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(pos, isSelected ? 18.0 : 14.0, pinBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _DriverMapPainter oldDelegate) => true;
}
