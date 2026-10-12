import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Service point entity model
class ServicePoint {
  final String id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final String workingHours;

  const ServicePoint({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    required this.workingHours,
  });
}

/// Screen 11 in Prototype: "نقاط الخدمة" (Service Points).
/// Faithfully reproduces `#screenServicePoints` with 5 Yemen regional hubs,
/// search filter, interactive map pins, and direct contact dialer.
class ServicePointsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ServicePointsScreen({
    super.key,
    this.onBack,
  });

  @override
  State<ServicePointsScreen> createState() => _ServicePointsScreenState();
}

class _ServicePointsScreenState extends State<ServicePointsScreen> {
  final _searchController = TextEditingController();
  String _selectedCity = '';

  static const List<ServicePoint> _points = [
    ServicePoint(
      id: 'sanaa',
      name: 'نقطة خدمة صنعاء المركزية',
      city: 'صنعاء',
      address: 'شارع الستين الجنوبي، المركز التجاري اللوجستي',
      phone: '+967 1 450001',
      workingHours: 'متاح على مدار 24 ساعة',
    ),
    ServicePoint(
      id: 'aden',
      name: 'نقطة خدمة ميناء عدن',
      city: 'عدن',
      address: 'المنطقة الحرة، قرب بوابة ميناء المعلا',
      phone: '+967 2 240002',
      workingHours: 'متاح على مدار 24 ساعة',
    ),
    ServicePoint(
      id: 'hodeida',
      name: 'نقطة خدمة ميناء الحديدة',
      city: 'الحديدة',
      address: 'خط الميناء الرئيسي، كيلو 7 التجاري',
      phone: '+967 3 210003',
      workingHours: '07:00 ص - 11:00 م',
    ),
    ServicePoint(
      id: 'taiz',
      name: 'نقطة خدمة تعز اللوجستية',
      city: 'تعز',
      address: 'منطقة الحوبان، المدخل التجاري الرئيسي',
      phone: '+967 4 220004',
      workingHours: '08:00 ص - 10:00 م',
    ),
    ServicePoint(
      id: 'mukalla',
      name: 'نقطة خدمة حضرموت - المكلا',
      city: 'المكلا',
      address: 'الشارع العام، منطقة روكب الصناعية',
      phone: '+967 5 310005',
      workingHours: '08:00 ص - 09:00 م',
    ),
  ];

  List<ServicePoint> get _filteredPoints {
    final query = _searchController.text.trim();
    return _points.where((p) {
      final matchesSearch = query.isEmpty ||
          p.city.contains(query) ||
          p.name.contains(query) ||
          p.address.contains(query);
      final matchesCity = _selectedCity.isEmpty || p.city == _selectedCity;
      return matchesSearch && matchesCity;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18.0),
          onPressed: widget.onBack,
          tooltip: AppStrings.back,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'نقاط الخدمة',
              style: GoogleFonts.cairo(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: AppColors.primaryGold, width: 0.8),
              ),
              child: Text(
                '${_filteredPoints.length} نقاط',
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryGold : AppColors.goldDark,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.compactMax),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceLg,
                vertical: AppDimensions.spaceMd,
              ),
              children: [
                // Search Input
                _buildSearchInput(isDark),
                const SizedBox(height: AppDimensions.spaceMd),
                // Interactive Yemen Map Graphic
                _buildInteractiveMap(isDark),
                const SizedBox(height: AppDimensions.spaceLg),
                // Section Title
                Text(
                  'المراكز والمحطات المعتمدة',
                  style: GoogleFonts.cairo(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                // Service Points Cards
                if (_filteredPoints.isEmpty)
                  _buildEmptyState(isDark)
                else
                  ..._filteredPoints.map((pt) => _buildPointCard(pt, isDark)),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput(bool isDark) {
    return TextFormField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.cairo(
        fontSize: 14.0,
        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
      ),
      decoration: InputDecoration(
        hintText: 'ابحث باسم المدينة أو الفرع (صنعاء، عدن، تعز...)',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGold),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18.0),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
      ),
    );
  }

  Widget _buildInteractiveMap(bool isDark) {
    return Container(
      height: 175.0,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background grid lines
          Positioned.fill(
            child: CustomPaint(painter: _YemenMapPainter()),
          ),
          // Top pill indicator
          Positioned(
            top: 10.0,
            right: 12.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.0,
                    height: 7.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    _selectedCity.isEmpty
                        ? 'انقر على المدينة لتصفية النقاط'
                        : 'تم تصفية: $_selectedCity',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Map City Pins
          _buildMapPin('صنعاء', 0.30, 0.40),
          _buildMapPin('الحديدة', 0.16, 0.50),
          _buildMapPin('تعز', 0.32, 0.70),
          _buildMapPin('عدن', 0.46, 0.76),
          _buildMapPin('المكلا', 0.78, 0.58),
        ],
      ),
    );
  }

  Widget _buildMapPin(String city, double leftFraction, double topFraction) {
    final isSelected = _selectedCity == city;

    return Positioned(
      left: 300.0 * leftFraction,
      top: 175.0 * topFraction,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCity = _selectedCity == city ? '' : city;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGold : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: isSelected ? Colors.white : AppColors.primaryGold,
                  width: 1.0,
                ),
              ),
              child: Text(
                city,
                style: GoogleFonts.cairo(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.navyDark : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            Container(
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : AppColors.primaryGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointCard(ServicePoint point, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  point.name,
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  point.city,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.primaryGold : AppColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16.0, color: AppColors.textSubtle),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  point.address,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16.0, color: AppColors.success),
              const SizedBox(width: 4.0),
              Text(
                point.workingHours,
                style: GoogleFonts.cairo(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          // Actions: Call button
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('الاتصال بـ ${point.name}: ${point.phone}')),
                    );
                  },
                  icon: const Icon(Icons.phone_rounded, size: 16.0),
                  label: Text(
                    'اتصال (${point.phone})',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.goldDark,
                    side: const BorderSide(color: AppColors.goldBorder),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderSm,
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

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space2xl),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.location_off_outlined, size: 48.0, color: AppColors.textSubtle),
          const SizedBox(height: 8.0),
          Text(
            'لا توجد نقاط خدمة مطابقة للبحث',
            style: GoogleFonts.cairo(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _YemenMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.5)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.40)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    // Grid horizontal and vertical
    canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width, size.height * 0.33), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.66), Offset(size.width, size.height * 0.66), gridPaint);
    canvas.drawLine(Offset(size.width * 0.33, 0), Offset(size.width * 0.33, size.height), gridPaint);
    canvas.drawLine(Offset(size.width * 0.66, 0), Offset(size.width * 0.66, size.height), gridPaint);

    // Highway connections between Yemen hubs
    final highwayPath = Path()
      ..moveTo(size.width * 0.16, size.height * 0.50) // Hodeida
      ..lineTo(size.width * 0.30, size.height * 0.40) // Sanaa
      ..lineTo(size.width * 0.32, size.height * 0.70) // Taiz
      ..lineTo(size.width * 0.46, size.height * 0.76) // Aden
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.68,
        size.width * 0.78,
        size.height * 0.58, // Mukalla
      );

    canvas.drawPath(highwayPath, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
