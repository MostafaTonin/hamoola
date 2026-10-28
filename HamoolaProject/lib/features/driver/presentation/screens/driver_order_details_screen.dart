import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cargo_bid_opportunity.dart';
import '../../domain/models/driver_simulation_store.dart';
import '../widgets/driver_submit_bid_sheet.dart';

/// Screen implementing the Left Reference Screen:
/// "تفاصيل الطلب" with top bar (share, favorite), cargo header,
/// 3-image carousel with page counter & dots, transport route mini-map,
/// cargo specifications table, additional details & thumbnails, terms & conditions,
/// pre-bid warning notice, and bottom dynamic action buttons.
class DriverOrderDetailsScreen extends StatefulWidget {
  final CargoBidOpportunity? cargo;
  final VoidCallback? onBack;

  const DriverOrderDetailsScreen({
    super.key,
    this.cargo,
    this.onBack,
  });

  @override
  State<DriverOrderDetailsScreen> createState() => _DriverOrderDetailsScreenState();
}

class _DriverOrderDetailsScreenState extends State<DriverOrderDetailsScreen> {
  late CargoBidOpportunity _cargo;
  late final PageController _imagePageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default to the reference demo opportunity if none provided
    _cargo = widget.cargo ?? CargoBidOpportunity.demoOpportunities.first;
    _imagePageController = PageController();
    DriverSimulationStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    DriverSimulationStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ رابط الطلب ${_cargo.id} للمشاركة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleFavorite() {
    DriverSimulationStore.instance.toggleFavorite(_cargo.id);
    final isFav = DriverSimulationStore.instance.isFavorite(_cargo.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFav
              ? 'تمت إضافة الطلب للمفضلة'
              : 'تمت إزالة الطلب من المفضلة',
          style: GoogleFonts.cairo(),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSubmitBidModal() {
    DriverSubmitBidSheet.show(
      context,
      cargo: _cargo,
      onBidSubmitted: (amount) {
        if (mounted) setState(() {});
      },
    );
  }

  void _handlePrivateAccept() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('قبول الطلب الخاص', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          content: Text(
            'هل أنت متأكد من قبول هذا الطلب المباشر من التاجر ${_cargo.merchantName}؟',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                DriverSimulationStore.instance.acceptDirectRequest(_cargo.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم قبول الطلب الخاص بنجاح! بانتظار استكمال الإجراءات.',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFF16A34A),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
              child: Text('تأكيد القبول', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePrivateDecline() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('الاعتذار عن الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          content: Text(
            'هل تود الاعتذار عن تنفيذ هذا الطلب الخاص؟ سيتم إشعار التاجر بذلك.',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('تراجع', style: GoogleFonts.cairo()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                DriverSimulationStore.instance.declineDirectRequest(_cargo.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم الاعتذار عن الطلب الخاص.', style: GoogleFonts.cairo()),
                  ),
                );
              },
              child: Text('تأكيد الاعتذار', style: GoogleFonts.cairo(color: const Color(0xFFDC2626))),
            ),
          ],
        ),
      ),
    );
  }

  void _openInMaps() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'جارٍ فتح مسار النقل (${_cargo.pickupLocationDisplay} ← ${_cargo.dropoffLocationDisplay}) في تطبيق الخرائط...',
          style: GoogleFonts.cairo(),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = DriverSimulationStore.instance;
    final isFav = store.isFavorite(_cargo.id);
    final hasAlreadyBid = store.hasBidOnCargo(_cargo.id);
    final existingBid = store.getBidForCargo(_cargo.id);

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
            tooltip: 'رجوع',
          ),
          title: Text(
            'تفاصيل الطلب',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                size: 22,
              ),
              onPressed: _handleShare,
              tooltip: 'مشاركة الطلب',
            ),
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? const Color(0xFFDC2626) : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                size: 22,
              ),
              onPressed: _toggleFavorite,
              tooltip: isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Order Header Card (Badge, ID, Title, Cargo type, Weight, Schedule)
              _buildOrderHeaderCard(isDark),
              const SizedBox(height: 12),

              // 2. Main Cargo Image Carousel & Indicators
              _buildImageCarousel(isDark),
              const SizedBox(height: 16),

              // 3. Transport Route Section with Mini Map
              _buildTransportRouteSection(isDark),
              const SizedBox(height: 16),

              // 4. Cargo Specifications Table
              _buildCargoSpecsTable(isDark),
              const SizedBox(height: 16),

              // 5. Additional Details Section
              _buildAdditionalDetailsSection(isDark),
              const SizedBox(height: 16),

              // 6. Additional Thumbnails (if available)
              _buildAdditionalThumbnailsSection(isDark),
              const SizedBox(height: 16),

              // 7. Instructions & Terms of Transport
              _buildTermsSection(isDark),
              const SizedBox(height: 16),

              // 8. Pre-bid Notice Box verbatim
              _buildPreBidNotice(isDark),
              const SizedBox(height: 80), // Padding for sticky bottom button
            ],
          ),
        ),
        bottomSheet: _buildBottomActionBar(isDark, hasAlreadyBid, existingBid),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Order Header Card
  // ---------------------------------------------------------------------------
  Widget _buildOrderHeaderCard(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Type Badge & Order ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _cargo.isPrivate ? const Color(0xFFDCFCE7) : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _cargo.isPrivate ? 'طلب خاص' : 'طلب عام',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: _cargo.isPrivate ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                  ),
                ),
              ),
              Text(
                'رقم الطلب: ${_cargo.id}',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Title
          Text(
            _cargo.title,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Metadata row (Cargo category | Weight | Truck Type)
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                _cargo.cargoCategoryDisplay,
                style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('|', style: TextStyle(color: isDark ? Colors.white24 : const Color(0xFFCBD5E1))),
              ),
              const Icon(Icons.fitness_center_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                _cargo.weightDisplay,
                style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('|', style: TextStyle(color: isDark ? Colors.white24 : const Color(0xFFCBD5E1))),
              ),
              Expanded(
                child: Text(
                  _cargo.requiredTruckType,
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Loading Window (Orange clock icon)
          Row(
            children: [
              const Icon(Icons.access_time_filled_rounded, size: 16, color: Color(0xFFD97706)),
              const SizedBox(width: 6),
              Text(
                'موعد التحميل: ${_cargo.loadingWindow}',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Cargo Image Carousel & Indicators
  // ---------------------------------------------------------------------------
  Widget _buildImageCarousel(bool isDark) {
    final images = _cargo.imagesList;

    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          Stack(
            children: [
              // Swipeable Image Carousel
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: PageView.builder(
                    controller: _imagePageController,
                    itemCount: images.length,
                    onPageChanged: (idx) {
                      setState(() => _currentImageIndex = idx);
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          child: const Center(
                            child: Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Image Counter Pill (e.g. 1/3) with image icon in bottom left
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image_outlined, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${_currentImageIndex + 1}/${images.length}',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Dots Indicator
          if (images.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (idx) {
                final isCurrent = idx == _currentImageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isCurrent ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Transport Route Section with Mini Map
  // ---------------------------------------------------------------------------
  Widget _buildTransportRouteSection(bool isDark) {
    final pickupLat = _cargo.pickupLat ?? 15.3694;
    final pickupLng = _cargo.pickupLng ?? 44.1910;
    final dropoffLat = _cargo.dropoffLat ?? 13.5795;
    final dropoffLng = _cargo.dropoffLng ?? 44.0209;

    final pickupPoint = LatLng(pickupLat, pickupLng);
    final dropoffPoint = LatLng(dropoffLat, dropoffLng);

    // Calculate center for map camera
    final centerLat = (pickupLat + dropoffLat) / 2;
    final centerLng = (pickupLng + dropoffLng) / 2;
    final centerPoint = LatLng(centerLat, centerLng);

    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(
                'مسار النقل',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mini Map Container
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 160,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: centerPoint,
                      initialZoom: 7.2,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none, // Smooth non-blocking in scroll
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.hamula.app',
                      ),
                      // Polyline route connecting pickup & dropoff
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              pickupPoint,
                              LatLng((pickupLat + centerLat) / 2, (pickupLng + centerLng) / 2 + 0.05),
                              LatLng(centerLat, centerLng - 0.08),
                              dropoffPoint,
                            ],
                            color: const Color(0xFF2563EB),
                            strokeWidth: 3.5,
                          ),
                        ],
                      ),
                      // Marker pins
                      MarkerLayer(
                        markers: [
                          // Pickup Green Pin
                          Marker(
                            point: pickupPoint,
                            width: 32,
                            height: 32,
                            child: const Icon(Icons.location_on, color: Color(0xFF16A34A), size: 30),
                          ),
                          // Dropoff Red Pin
                          Marker(
                            point: dropoffPoint,
                            width: 32,
                            height: 32,
                            child: const Icon(Icons.location_on, color: Color(0xFFDC2626), size: 30),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Open in Maps Button (Bottom Left of Map)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: InkWell(
                      onTap: _openInMaps,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.map_outlined, color: Color(0xFF2563EB), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'فتح في الخرائط',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Distance and Duration Stats
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.route_rounded, color: Color(0xFF64748B), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المسافة التقديرية',
                              style: GoogleFonts.cairo(fontSize: 10.5, color: const Color(0xFF64748B)),
                            ),
                            Text(
                              '${_cargo.distanceKm} كيلومتر',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded, color: Color(0xFF64748B), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المدة التقديرية',
                              style: GoogleFonts.cairo(fontSize: 10.5, color: const Color(0xFF64748B)),
                            ),
                            Text(
                              '${_cargo.durationHours.toInt()} ساعة تقريباً',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pickup Location Row
          _buildLocationDetailRow(
            icon: Icons.location_on,
            iconColor: const Color(0xFF16A34A),
            title: 'نقطة التحميل',
            subtitle: _cargo.pickupLocationDisplay,
            isDark: isDark,
          ),
          const Divider(height: 16),

          // Dropoff Location Row
          _buildLocationDetailRow(
            icon: Icons.location_on,
            iconColor: const Color(0xFFDC2626),
            title: 'وجهة التسليم',
            subtitle: _cargo.dropoffLocationDisplay,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: isDark ? Colors.white30 : const Color(0xFFCBD5E1),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Cargo Specifications Table
  // ---------------------------------------------------------------------------
  Widget _buildCargoSpecsTable(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_rounded, color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 8),
              Text(
                'بيانات الحمولة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildTableRow('نوع الحمولة', _cargo.cargoSubCategoryDisplay, isDark, isFirst: true),
                _buildTableRow('الكمية / الوزن', _cargo.weightDisplay, isDark),
                _buildTableRow('نوع التعبئة', _cargo.packagingDisplay, isDark),
                _buildTableRow('طريقة التحميل', _cargo.loadingMethodDisplay, isDark),
                _buildTableRow('متطلبات الناقلة', _cargo.truckRequirementsDisplay, isDark, isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String key, String value, bool isDark, {bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: isDark ? Colors.white12 : const Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Additional Details Section
  // ---------------------------------------------------------------------------
  Widget _buildAdditionalDetailsSection(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 8),
              Text(
                'تفاصيل إضافية',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _cargo.additionalDetailsDisplay,
            style: GoogleFonts.cairo(
              fontSize: 13,
              height: 1.6,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Additional Thumbnails
  // ---------------------------------------------------------------------------
  Widget _buildAdditionalThumbnailsSection(bool isDark) {
    final images = _cargo.imagesList;

    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined, color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 8),
              Text(
                'صور إضافية (إن وجدت)',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                return InkWell(
                  onTap: () {
                    _imagePageController.animateToPage(
                      idx,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 96,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentImageIndex == idx
                              ? const Color(0xFF2563EB)
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        images[idx],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(Icons.image, color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Instructions & Terms of Transport
  // ---------------------------------------------------------------------------
  Widget _buildTermsSection(bool isDark) {
    final terms = _cargo.termsList;

    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 8),
              Text(
                'تعليمات وشروط النقل',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...terms.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        t,
                        style: GoogleFonts.cairo(
                          fontSize: 12.5,
                          height: 1.5,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. Pre-bid Notice Box verbatim
  // ---------------------------------------------------------------------------
  Widget _buildPreBidNotice(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFF2563EB), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تأكد من ملاءمة الحمولة لناقلتك وقدرتك على تنفيذ متطلبات الطلب. السعر الذي تقدمه هو السعر الإجمالي للنقل وفق الشروط الموضحة.',
              style: GoogleFonts.cairo(
                fontSize: 12,
                height: 1.5,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 9. Bottom Action Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomActionBar(bool isDark, bool hasAlreadyBid, DriverBidItem? existingBid) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _buildActionButtons(hasAlreadyBid, existingBid),
      ),
    );
  }

  Widget _buildActionButtons(bool hasAlreadyBid, DriverBidItem? existingBid) {
    // 1. Order is closed or expired
    if (_cargo.isExpiredOrClosed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'هذا الطلب غير متاح للعروض حالياً',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    // 2. Private direct request
    if (_cargo.isPrivate) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: _handlePrivateAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'قبول الطلب',
                style: GoogleFonts.cairo(fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: _handlePrivateDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'اعتذار',
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      );
    }

    // 3. Public order where driver already submitted a bid
    if (hasAlreadyBid && existingBid != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
            const SizedBox(width: 8),
            Text(
              'تم تقديم عرضك بمبلغ ${existingBid.bidAmount} ${existingBid.currencyLabel} (قيد الانتظار)',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF15803D),
              ),
            ),
          ],
        ),
      );
    }

    // 4. Public open order: "تقديم عرض سعر" primary action button
    return ElevatedButton(
      onPressed: _openSubmitBidModal,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_offer_outlined, size: 20),
          const SizedBox(width: 8),
          Text(
            'تقديم عرض سعر',
            style: GoogleFonts.cairo(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
