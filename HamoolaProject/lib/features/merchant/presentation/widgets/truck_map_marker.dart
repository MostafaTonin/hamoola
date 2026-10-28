import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/tracking_models.dart';

/// Clean custom truck map marker matching Image 2:
/// - Isometric / flat cargo truck graphics (No bulky white square cards)
/// - ZERO tractors/harvesters/passenger cars! Only heavy freight vehicles
/// - Status indicator dot (Green: Available, Orange: Busy, Grey: Offline)
/// - Callout speech bubble: "متاح للعودة إلى اليمن" with green dot (Image 2)
/// - Cluster badge when multiple trucks are grouped (Dark circle with count e.g. "6")
class TruckMapMarker extends StatelessWidget {
  final AvailableTruckMarker? truck;
  final bool isSelected;
  final bool isCluster;
  final int clusterCount;
  final String? clusterCity;
  final bool showCallout;
  final bool isPhotoPin;
  final bool isBadge;
  final VoidCallback? onTap;

  const TruckMapMarker({
    super.key,
    this.truck,
    this.isSelected = false,
    this.isCluster = false,
    this.clusterCount = 1,
    this.clusterCity,
    this.showCallout = false,
    this.isPhotoPin = false,
    this.isBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isCluster) {
      return _buildClusterMarker();
    }

    if (truck == null) return const SizedBox.shrink();

    if (isPhotoPin) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: _buildPhotoPinMarker(),
      );
    }

    if (isBadge) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: _buildBadgeMarker(),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1. Return to Yemen Callout Speech Bubble (if applicable)
          if (showCallout && truck!.returnToYemenAvailable)
            Positioned(
              bottom: 46,
              child: _buildReturnToYemenCallout(),
            ),

          // 2. Truck Graphic with Availability Dot
          _buildTruckGraphic(),
        ],
      ),
    );
  }

  /// Photo avatar pin with green ring and bottom pointer matching reference map
  Widget _buildPhotoPinMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: isSelected ? 1.25 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF10B981),
                width: 3.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                truck!.avatarAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1E293B),
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _TrianglePointerPainter(color: const Color(0xFF10B981)),
        ),
      ],
    );
  }

  /// Circular badge with white border and white truck icon
  Widget _buildBadgeMarker() {
    final isAvailable = truck?.isAvailable ?? true;
    final color = isAvailable ? const Color(0xFF10B981) : const Color(0xFF64748B);

    return AnimatedScale(
      scale: isSelected ? 1.25 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// Dark circular cluster badge matching Image 2 (e.g. "6" over Sana'a)
  Widget _buildClusterMarker() {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Dark navy slate
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
              width: 3.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$clusterCount',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Callout badge matching Image 2 speech bubble
  Widget _buildReturnToYemenCallout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'متاح للعودة\nإلى اليمن',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
        // Downward Triangle Pointer
        CustomPaint(
          size: const Size(10, 6),
          painter: _TrianglePointerPainter(color: Colors.white),
        ),
      ],
    );
  }

  /// Clean vehicle graphic without bulky white borders (Image 2 style)
  Widget _buildTruckGraphic() {
    final t = truck!;
    final category = t.vehicleCategory;
    final isReefer = t.isRefrigerated || category == 'تبريد';

    Color bodyColor;
    Color cabColor;
    bool isTanker = false;

    if (isReefer) {
      bodyColor = const Color(0xFFF8FAFC); // White Reefer box
      cabColor = const Color(0xFFDC2626); // Red cab with snowflake
    } else if (category == 'قاطرات') {
      bodyColor = const Color(0xFFE2E8F0); // Heavy trailer
      cabColor = const Color(0xFF1E3A8A); // Deep blue cab
    } else if (category == 'دينات') {
      bodyColor = const Color(0xFFF8FAFC); // Compact dyna
      cabColor = const Color(0xFF0284C7); // Cyan/blue cab
    } else if (t.vehicleType.contains('صهريج') || category == 'صهريج') {
      bodyColor = const Color(0xFFCBD5E1); // Silver Tanker
      cabColor = const Color(0xFF475569);
      isTanker = true;
    } else {
      // General heavy freight trucks matching Image 1
      final hash = t.id.hashCode.abs() % 3;
      if (hash == 0) {
        bodyColor = const Color(0xFFE2E8F0);
        cabColor = const Color(0xFFDC2626); // Red cab matching Image 1
      } else if (hash == 1) {
        bodyColor = const Color(0xFFE2E8F0);
        cabColor = const Color(0xFF2563EB); // Blue cab matching Image 1
      } else {
        bodyColor = const Color(0xFFFFFFFF);
        cabColor = const Color(0xFF334155); // Slate cab matching Image 1
      }
    }

    // Status indicator color
    final Color statusColor = t.availabilityStatus == 'available'
        ? const Color(0xFF10B981) // Green
        : (t.availabilityStatus == 'busy'
            ? const Color(0xFFF59E0B) // Orange
            : const Color(0xFF94A3B8)); // Grey

    return AnimatedScale(
      scale: isSelected ? 1.25 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: 52,
        height: 38,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Custom vector canvas rendering the clean truck
            CustomPaint(
              size: const Size(46, 32),
              painter: _CargoTruckPainter(
                bodyColor: bodyColor,
                cabColor: cabColor,
                isReefer: isReefer,
                isTanker: isTanker,
                isSelected: isSelected,
              ),
            ),

            // Availability Status Dot on truck corner
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for crisp, lightweight, high-performance truck illustrations
class _CargoTruckPainter extends CustomPainter {
  final Color bodyColor;
  final Color cabColor;
  final bool isReefer;
  final bool isTanker;
  final bool isSelected;

  _CargoTruckPainter({
    required this.bodyColor,
    required this.cabColor,
    required this.isReefer,
    required this.isTanker,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isSelected ? 0.35 : 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // 1. Subtle drop shadow under truck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, size.height - 6, size.width - 4, 6),
        const Radius.circular(3),
      ),
      shadowPaint,
    );

    // 2. Cargo Box or Tanker Body
    final bodyPaint = Paint()..color = bodyColor;
    if (isTanker) {
      // Cylindrical Tanker
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 4, size.width - 16, size.height - 12),
          const Radius.circular(6),
        ),
        bodyPaint,
      );
    } else {
      // Rectangular Container Box
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 2, size.width - 15, size.height - 10),
          const Radius.circular(4),
        ),
        bodyPaint,
      );

      // Subtle container vertical ribs
      final ribPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..strokeWidth = 1.0;
      for (double x = 8; x < size.width - 18; x += 6) {
        canvas.drawLine(Offset(x, 4), Offset(x, size.height - 10), ribPaint);
      }
    }

    // 3. Snowflake emblem if Reefer (❄️)
    if (isReefer) {
      final snowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;

      final cx = (size.width - 15) / 2 + 1;
      final cy = (size.height - 10) / 2 + 1;
      const r = 4.5;
      // 3 intersecting lines for snowflake
      canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), snowPaint);
      canvas.drawLine(Offset(cx - r * 0.86, cy - r * 0.5),
          Offset(cx + r * 0.86, cy + r * 0.5), snowPaint);
      canvas.drawLine(Offset(cx - r * 0.86, cy + r * 0.5),
          Offset(cx + r * 0.86, cy - r * 0.5), snowPaint);
    }

    // 4. Truck Front Cab
    final cabPaint = Paint()..color = cabColor;
    final cabRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 16, 7, 14, size.height - 15),
      const Radius.circular(3),
    );
    canvas.drawRRect(cabRect, cabPaint);

    // Cab windshield
    final glassPaint = Paint()..color = const Color(0xFF93C5FD);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 11, 9, 8, 7),
        const Radius.circular(2),
      ),
      glassPaint,
    );

    // 5. Wheels
    final wheelPaint = Paint()..color = const Color(0xFF1E293B);
    final rimPaint = Paint()..color = const Color(0xFF94A3B8);

    void drawWheel(double cx, double cy) {
      canvas.drawCircle(Offset(cx, cy), 4.2, wheelPaint);
      canvas.drawCircle(Offset(cx, cy), 1.8, rimPaint);
    }

    drawWheel(9, size.height - 5);
    drawWheel(19, size.height - 5);
    drawWheel(size.width - 9, size.height - 5);

    // 6. Selected Accent Outline
    if (isSelected) {
      final selectBorder = Paint()
        ..color = const Color(0xFF2563EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(8),
        ),
        selectBorder,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CargoTruckPainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.cabColor != cabColor ||
      oldDelegate.isReefer != isReefer ||
      oldDelegate.isTanker != isTanker ||
      oldDelegate.isSelected != isSelected;
}

class _TrianglePointerPainter extends CustomPainter {
  final Color color;
  _TrianglePointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
