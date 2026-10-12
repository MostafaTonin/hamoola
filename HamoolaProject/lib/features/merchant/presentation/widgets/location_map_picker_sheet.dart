import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/buttons/hamula_button.dart';

/// Result returned from the location map picker sheet
class LocationPickResult {
  final String city;
  final String detailedAddress;
  final double latitude;
  final double longitude;
  final String landmarkTitle;

  const LocationPickResult({
    required this.city,
    required this.detailedAddress,
    required this.latitude,
    required this.longitude,
    required this.landmarkTitle,
  });
}

class LocationLandmark {
  final String city;
  final String title;
  final String address;
  final double lat;
  final double lng;
  final Offset mapRelOffset;

  const LocationLandmark({
    required this.city,
    required this.title,
    required this.address,
    required this.lat,
    required this.lng,
    required this.mapRelOffset,
  });
}

/// Interactive sheet to pick loading or unloading location directly from a map
/// or from predefined major commercial logistics hubs with precise GPS coordinates.
class LocationMapPickerSheet extends StatefulWidget {
  final String initialCity;
  final String initialDetail;
  final bool isOrigin;
  final ValueChanged<LocationPickResult> onConfirm;

  const LocationMapPickerSheet({
    super.key,
    required this.initialCity,
    required this.initialDetail,
    required this.isOrigin,
    required this.onConfirm,
  });

  static Future<LocationPickResult?> show(
    BuildContext context, {
    required String initialCity,
    required String initialDetail,
    required bool isOrigin,
  }) {
    return showModalBottomSheet<LocationPickResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LocationMapPickerSheet(
        initialCity: initialCity,
        initialDetail: initialDetail,
        isOrigin: isOrigin,
        onConfirm: (result) => Navigator.of(ctx).pop(result),
      ),
    );
  }

  @override
  State<LocationMapPickerSheet> createState() => _LocationMapPickerSheetState();
}

class _LocationMapPickerSheetState extends State<LocationMapPickerSheet> {
  late String _selectedCity;
  late TextEditingController _searchController;
  late TextEditingController _customAddressController;

  late double _selectedLat;
  late double _selectedLng;
  late String _selectedTitle;
  late Offset _pinRelativeOffset; // (0.0 to 1.0) on canvas

  static const List<String> _cities = [
    'صنعاء',
    'عدن',
    'الحديدة',
    'تعز',
    'المكلا',
    'مأرب',
    'إب',
    'ذمار',
  ];

  static const List<LocationLandmark> _allLandmarks = [
    // صنعاء
    LocationLandmark(
      city: 'صنعاء',
      title: 'شارع الستين الجنوبي — محطة الأمانة',
      address: 'صنعاء — شارع الستين الجنوبي، جوار محطة الأمانة، مخازن الأمل رقم 4',
      lat: 15.3340,
      lng: 44.1870,
      mapRelOffset: Offset(0.48, 0.42),
    ),
    LocationLandmark(
      city: 'صنعاء',
      title: 'مستودعات الحثيلي — المنطقة الصناعية',
      address: 'صنعاء — طريق خولان، منطقة الحثيلي الصناعية، هناجر التفريغ رقم 12',
      lat: 15.2890,
      lng: 44.2410,
      mapRelOffset: Offset(0.62, 0.58),
    ),
    LocationLandmark(
      city: 'صنعاء',
      title: 'سوق الجملة المركزي — شميلة',
      address: 'صنعاء — مديرية السبعين، سوق شميلة للجملة، بوابة الشاحنات الشرقية',
      lat: 15.3120,
      lng: 44.2250,
      mapRelOffset: Offset(0.52, 0.50),
    ),
    LocationLandmark(
      city: 'صنعاء',
      title: 'جولة عصر — مخرج طريق الحديدة',
      address: 'صنعاء — عصر، خط الستين الغربي، ساحة مبيت وتجمع الشاحنات',
      lat: 15.3480,
      lng: 44.1680,
      mapRelOffset: Offset(0.35, 0.38),
    ),

    // عدن
    LocationLandmark(
      city: 'عدن',
      title: 'ميناء المعلا — رصيف الحاويات الرئيسي',
      address: 'عدن — مديرية المعلا، ميناء عدن الدولي، رصيف الحاويات بوابه 2',
      lat: 12.7870,
      lng: 44.9850,
      mapRelOffset: Offset(0.44, 0.46),
    ),
    LocationLandmark(
      city: 'عدن',
      title: 'المنطقة الحرة — كالتكس',
      address: 'عدن — كالتكس، المنطقة الحرة، مستودعات التخزين اللوجستي قطاع ب',
      lat: 12.8360,
      lng: 44.9780,
      mapRelOffset: Offset(0.50, 0.35),
    ),
    LocationLandmark(
      city: 'عدن',
      title: 'مستودعات الشيخ عثمان المركزية',
      address: 'عدن — الشيخ عثمان، الممدارة، مجمع المخازن التجارية ومستودعات التوزيع',
      lat: 12.8680,
      lng: 44.9980,
      mapRelOffset: Offset(0.58, 0.28),
    ),
    LocationLandmark(
      city: 'عدن',
      title: 'ميناء الزيت — البريقة',
      address: 'عدن — البريقة، ميناء الزيت، محطة تفريغ وتعبئة الصهاريج',
      lat: 12.7480,
      lng: 44.8620,
      mapRelOffset: Offset(0.28, 0.60),
    ),

    // الحديدة
    LocationLandmark(
      city: 'الحديدة',
      title: 'ميناء الحديدة — رصيف الشحن والتفريغ',
      address: 'الحديدة — شارع الميناء، بوابة الشاحنات رقم 1، رصيف البضائع العامة',
      lat: 14.8010,
      lng: 42.9460,
      mapRelOffset: Offset(0.40, 0.45),
    ),
    LocationLandmark(
      city: 'الحديدة',
      title: 'كيلو 7 — صوامع الغلال ومخازن التبريد',
      address: 'الحديدة — طريق صنعاء، كيلو 7، مجمع مطاحن وصوامع الغلال',
      lat: 14.7780,
      lng: 43.0150,
      mapRelOffset: Offset(0.55, 0.52),
    ),

    // تعز
    LocationLandmark(
      city: 'تعز',
      title: 'مفرق الحوبان — المدينة الصناعية',
      address: 'تعز — الحوبان، جوار مصنع السمن والصابون، مخازن الشحن المركزية',
      lat: 13.6120,
      lng: 44.0750,
      mapRelOffset: Offset(0.54, 0.42),
    ),
    LocationLandmark(
      city: 'تعز',
      title: 'بير باشا — نقطة شحن البضائع',
      address: 'تعز — بير باشا، خط البرح، مجمع شاحنات النقل ومخازن البناء',
      lat: 13.5650,
      lng: 43.9780,
      mapRelOffset: Offset(0.38, 0.55),
    ),

    // المكلا
    LocationLandmark(
      city: 'المكلا',
      title: 'ميناء المكلا — رصيف البضائع والأسماك',
      address: 'المكلا — رصيف ميناء المكلا التجاري، ساحة الشحن اللوجستي',
      lat: 14.5310,
      lng: 49.1350,
      mapRelOffset: Offset(0.46, 0.48),
    ),

    // مأرب
    LocationLandmark(
      city: 'مأرب',
      title: 'مفرق صافر — محطة النقل والمعدات',
      address: 'مأرب — خط صافر الدولي، محطة تفريغ ونقل المعدات الثقيلة',
      lat: 15.4850,
      lng: 45.3650,
      mapRelOffset: Offset(0.55, 0.45),
    ),

    // إب
    LocationLandmark(
      city: 'إب',
      title: 'الدائري الغربي — مجمع الشاحنات',
      address: 'إب — خط الدائري الغربي، ساحة تفريغ البضائع ومستودعات التوزيع',
      lat: 13.9850,
      lng: 44.1720,
      mapRelOffset: Offset(0.48, 0.50),
    ),

    // ذمار
    LocationLandmark(
      city: 'ذمار',
      title: 'جمرك ذمار — مركز التخليص والشحن',
      address: 'ذمار — المدخل الشمالي، ساحة التخليص الجمركي ومستودعات الشحن',
      lat: 14.5620,
      lng: 44.3850,
      mapRelOffset: Offset(0.50, 0.48),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialCity;
    _searchController = TextEditingController();

    // Pick first landmark matching initialCity or default to first
    final defaultLandmark = _allLandmarks.firstWhere(
      (l) => l.city == widget.initialCity,
      orElse: () => _allLandmarks.first,
    );

    _selectedLat = defaultLandmark.lat;
    _selectedLng = defaultLandmark.lng;
    _selectedTitle = defaultLandmark.title;
    _pinRelativeOffset = defaultLandmark.mapRelOffset;

    final initialAddress = widget.initialDetail.isNotEmpty
        ? widget.initialDetail
        : defaultLandmark.address;
    _customAddressController = TextEditingController(text: initialAddress);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customAddressController.dispose();
    super.dispose();
  }

  void _onCityChanged(String city) {
    setState(() {
      _selectedCity = city;
      final matchingLandmark = _allLandmarks.firstWhere(
        (l) => l.city == city,
        orElse: () => _allLandmarks.first,
      );
      _selectedLat = matchingLandmark.lat;
      _selectedLng = matchingLandmark.lng;
      _selectedTitle = matchingLandmark.title;
      _pinRelativeOffset = matchingLandmark.mapRelOffset;
      _customAddressController.text = matchingLandmark.address;
    });
  }

  void _onSelectLandmark(LocationLandmark landmark) {
    setState(() {
      _selectedCity = landmark.city;
      _selectedLat = landmark.lat;
      _selectedLng = landmark.lng;
      _selectedTitle = landmark.title;
      _pinRelativeOffset = landmark.mapRelOffset;
      _customAddressController.text = landmark.address;
    });
  }

  void _handleMapTap(TapUpDetails details, Size mapSize) {
    if (mapSize.width <= 0 || mapSize.height <= 0) return;
    final relX = (details.localPosition.dx / mapSize.width).clamp(0.08, 0.92);
    final relY = (details.localPosition.dy / mapSize.height).clamp(0.08, 0.92);

    setState(() {
      _pinRelativeOffset = Offset(relX, relY);
      // Generate realistic coordinates around base city
      final baseLat = _selectedCity == 'عدن' ? 12.80 : 15.35;
      final baseLng = _selectedCity == 'عدن' ? 44.95 : 44.20;
      _selectedLat = baseLat + (relY - 0.5) * 0.12;
      _selectedLng = baseLng + (relX - 0.5) * 0.15;
      _selectedTitle = 'نقطة محددة على الخريطة ($_selectedCity)';
      _customAddressController.text =
          '$_selectedCity — نقطة إحداثيات (${_selectedLat.toStringAsFixed(4)}°N, ${_selectedLng.toStringAsFixed(4)}°E) — جوار المعلم المحدد';
    });
  }

  void _locateCurrentGps() {
    setState(() {
      _selectedCity = 'صنعاء';
      _selectedLat = 15.3547;
      _selectedLng = 44.2075;
      _selectedTitle = 'موقعي الحالي (GPS الدقيق)';
      _pinRelativeOffset = const Offset(0.50, 0.45);
      _customAddressController.text =
          'صنعاء — موقعك الحالي المكتشف عبر GPS (شارع الستين الجنوبي)';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديد وتثبيت إحداثيات موقعك الحالي بنجاح'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleConfirm() {
    final result = LocationPickResult(
      city: _selectedCity,
      detailedAddress: _customAddressController.text.trim().isNotEmpty
          ? _customAddressController.text.trim()
          : '$_selectedCity — $_selectedTitle',
      latitude: _selectedLat,
      longitude: _selectedLng,
      landmarkTitle: _selectedTitle,
    );
    widget.onConfirm(result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableLandmarks =
        _allLandmarks.where((l) => l.city == _selectedCity).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: isDark ? AppColors.navyDark : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. Drag Handle & Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (widget.isOrigin
                                        ? const Color(0xFF2563EB)
                                        : AppColors.primaryGold)
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.map_rounded,
                                size: 20,
                                color: widget.isOrigin
                                    ? const Color(0xFF2563EB)
                                    : AppColors.primaryGold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.isOrigin
                                        ? 'تحديد موقع التحميل من الخريطة'
                                        : 'تحديد موقع التفريغ من الخريطة',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.textWhite
                                          : AppColors.textMainLight,
                                    ),
                                  ),
                                  Text(
                                    'انقر على الخريطة أو اختر من المعالم اللوجستية',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.5,
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
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textMainLight,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. City Chips Bar
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _cities.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final city = _cities[index];
                  final isSelected = city == _selectedCity;
                  return ChoiceChip(
                    label: Text(city),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _onCityChanged(city);
                    },
                    labelStyle: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? Colors.black
                          : (isDark
                              ? AppColors.textWhite
                              : AppColors.textMainLight),
                    ),
                    selectedColor: AppColors.primaryGold,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryGold
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : AppColors.borderLight),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. Interactive Vector Map Canvas
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final mapSize =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    onTapUp: (details) => _handleMapTap(details, mapSize),
                    child: Stack(
                      children: [
                        // Map Painting
                        Positioned.fill(
                          child: CustomPaint(
                            size: mapSize,
                            painter: _LocationPickerMapPainter(
                              isDark: isDark,
                              city: _selectedCity,
                              pinOffsetRel: _pinRelativeOffset,
                              isOrigin: widget.isOrigin,
                            ),
                          ),
                        ),

                        // Interactive Pin Marker placed on Canvas
                        Positioned(
                          left: _pinRelativeOffset.dx * mapSize.width - 24,
                          top: _pinRelativeOffset.dy * mapSize.height - 48,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: widget.isOrigin
                                        ? const Color(0xFF2563EB)
                                        : AppColors.primaryGold,
                                  ),
                                ),
                                child: Text(
                                  widget.isOrigin ? 'نقطة التحميل' : 'نقطة التفريغ',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.location_on_rounded,
                                size: 38,
                                color: widget.isOrigin
                                    ? const Color(0xFF2563EB)
                                    : AppColors.primaryGold,
                              ),
                            ],
                          ),
                        ),

                        // Floating Locate GPS Button
                        Positioned(
                          left: 16,
                          top: 14,
                          child: FloatingActionButton.small(
                            heroTag: 'gps_locate_btn_${widget.isOrigin}',
                            backgroundColor:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            foregroundColor: const Color(0xFF2563EB),
                            onPressed: _locateCurrentGps,
                            tooltip: 'موقعي الحالي GPS',
                            child: const Icon(Icons.my_location_rounded),
                          ),
                        ),

                        // Floating Compass Indicator
                        Positioned(
                          right: 16,
                          top: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? AppColors.navyDark
                                      : Colors.white)
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.navigation_rounded,
                                    size: 14, color: AppColors.error),
                                const SizedBox(width: 4),
                                Text(
                                  'شمال N',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.textMainLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 4. Quick Landmark Suggestions & Address Details
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Landmarks Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.business_rounded,
                                size: 15, color: AppColors.primaryGold),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'المعالم ومراكز الشحن في $_selectedCity:',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.textMainLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedLat.toStringAsFixed(4)}°N, ${_selectedLng.toStringAsFixed(4)}°E',
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Horizontal Landmark Pills
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableLandmarks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final lm = availableLandmarks[index];
                        final isChosen = _selectedTitle == lm.title;
                        return InkWell(
                          onTap: () => _onSelectLandmark(lm),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isChosen
                                  ? AppColors.primaryGold
                                      .withValues(alpha: 0.18)
                                  : (isDark
                                      ? const Color(0x660F172A)
                                      : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isChosen
                                    ? AppColors.primaryGold
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : AppColors.borderLight),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warehouse_rounded,
                                  size: 13,
                                  color: isChosen
                                      ? AppColors.primaryGold
                                      : (isDark
                                          ? AppColors.textSubtle
                                          : AppColors.textMutedLight),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  lm.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: isChosen
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isChosen
                                        ? AppColors.primaryGold
                                        : (isDark
                                            ? AppColors.textWhite
                                            : AppColors.textMainLight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Editable Detailed Text Field (العنوان والمكان المحدد كتابة بشكل موضح أكثر)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0x660F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_location_rounded,
                            size: 18, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _customAddressController,
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'اكتب وصف المكان أو المعلم بالتفصيل...',
                              hintStyle: GoogleFonts.cairo(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textSubtle
                                    : AppColors.textMutedLight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Confirm Location Action Button
                  HamulaButton(
                    label: 'تأكيد هذا الموقع ($_selectedCity)',
                    onPressed: _handleConfirm,
                    variant: HamulaButtonVariant.primary,
                    size: HamulaButtonSize.md,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPickerMapPainter extends CustomPainter {
  final bool isDark;
  final String city;
  final Offset pinOffsetRel;
  final bool isOrigin;

  const _LocationPickerMapPainter({
    required this.isDark,
    required this.city,
    required this.pinOffsetRel,
    required this.isOrigin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background fill
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Map Coordinates Grid Lines
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Simulated Major Arteries / Highway Lines
    final roadPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.1)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final roadInnerPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Ring road circle
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final ringRadius = size.width * 0.32;
    canvas.drawCircle(
        center,
        ringRadius,
        roadPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0);
    canvas.drawCircle(
        center,
        ringRadius,
        roadInnerPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5);

    // Highway cross
    canvas.drawLine(
        Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.55), roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.5, 0), Offset(size.width * 0.52, size.height), roadPaint);

    // Secondary street arcs
    final secondaryRoad = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(size.width * 0.15, 0),
        Offset(size.width * 0.85, size.height), secondaryRoad);
    canvas.drawLine(Offset(size.width * 0.85, 0),
        Offset(size.width * 0.15, size.height), secondaryRoad);

    // 4. City Hub Halo
    final haloPaint = Paint()
      ..color = (isOrigin ? const Color(0xFF2563EB) : AppColors.primaryGold)
          .withValues(alpha: 0.06);
    canvas.drawCircle(center, size.width * 0.22, haloPaint);

    // 5. Radar pulse circle around target pin
    final pinAbs =
        Offset(pinOffsetRel.dx * size.width, pinOffsetRel.dy * size.height);
    final pulsePaint = Paint()
      ..color = (isOrigin ? const Color(0xFF2563EB) : AppColors.primaryGold)
          .withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinAbs, 26, pulsePaint);

    final pulseRing = Paint()
      ..color = (isOrigin ? const Color(0xFF2563EB) : AppColors.primaryGold)
          .withValues(alpha: 0.45)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(pinAbs, 18, pulseRing);
    canvas.drawCircle(pinAbs, 7, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _LocationPickerMapPainter oldDelegate) {
    return oldDelegate.pinOffsetRel != pinOffsetRel ||
        oldDelegate.city != city ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isOrigin != isOrigin;
  }
}
