import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/tracking_models.dart';

/// Waypoint along the realistic Yemeni transport corridor (Sana'a to Aden)
class WaypointRoutePoint {
  final String name;
  final String shortName;
  final Offset relativePos;
  final double fraction; // 0.0 to 1.0
  final int distanceKm;
  final int roadSpeed;
  final String statusDescription;

  const WaypointRoutePoint({
    required this.name,
    required this.shortName,
    required this.relativePos,
    required this.fraction,
    required this.distanceKm,
    required this.roadSpeed,
    required this.statusDescription,
  });
}

/// Screen representing the live trip tracking with interactive vector map,
/// milestone timeline, container sensors, driver contact, and realistic live simulation
class MerchantTripTrackingScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<String>? onCallDriver;
  final VoidCallback? onEmergencyCall;
  final LiveTripTrackingData tripData;

  const MerchantTripTrackingScreen({
    super.key,
    this.onBack,
    this.onCallDriver,
    this.onEmergencyCall,
    this.tripData = LiveTripTrackingData.demoTrip,
  });

  @override
  State<MerchantTripTrackingScreen> createState() =>
      _MerchantTripTrackingScreenState();
}

class _MerchantTripTrackingScreenState
    extends State<MerchantTripTrackingScreen> {
  late TripStage _currentStage;
  late double _progressPercent;
  late String _statusText;
  bool _isSheetExpanded = false;

  // Real-time live simulation engine states
  Timer? _simulationTimer;
  bool _isSimulating = false;
  double _simulationSpeed = 1.0; // 1.0x, 2.0x, 5.0x
  double _radarPulse = 0.0;
  int _currentSpeed = 68;
  String _currentRoadLocationName = 'نقيل سمارة — عقبة يريم';
  String _remainingDistanceText = '183 كم';
  String _remainingEtaText = '2 س 45 د';

  static const List<WaypointRoutePoint> _waypoints = [
    WaypointRoutePoint(
      name: 'صنعاء — شارع الستين الجنوبي',
      shortName: 'صنعاء',
      relativePos: Offset(0.35, 0.16),
      fraction: 0.0,
      distanceKm: 0,
      roadSpeed: 45,
      statusDescription: 'موقع التحميل ومستودعات الأمانة',
    ),
    WaypointRoutePoint(
      name: 'نقيل يسلح — مرتفعات بلاد الروس',
      shortName: 'يسلح',
      relativePos: Offset(0.44, 0.26),
      fraction: 0.13,
      distanceKm: 45,
      roadSpeed: 38,
      statusDescription: 'عقبة يسلح الجبلية وممر العبور',
    ),
    WaypointRoutePoint(
      name: 'مدينة ذمار — مركز التخليص الجمركي',
      shortName: 'ذمار',
      relativePos: Offset(0.48, 0.38),
      fraction: 0.28,
      distanceKm: 100,
      roadSpeed: 75,
      statusDescription: 'نقطة التفتيش والمطابقة الجمركية',
    ),
    WaypointRoutePoint(
      name: 'نقيل سمارة — عقبة يريم',
      shortName: 'سمارة',
      relativePos: Offset(0.41, 0.49),
      fraction: 0.45,
      distanceKm: 165,
      roadSpeed: 35,
      statusDescription: 'عقبة سمارة الشهيرة - مسار جبلي حذر',
    ),
    WaypointRoutePoint(
      name: 'مدينة إب — استراحة الشاحنات المركزية',
      shortName: 'إب',
      relativePos: Offset(0.38, 0.58),
      fraction: 0.56,
      distanceKm: 195,
      roadSpeed: 65,
      statusDescription: 'محطة استراحة الشاحنات وفحص الإطارات',
    ),
    WaypointRoutePoint(
      name: 'تعز — مفرق الحوبان الصناعي',
      shortName: 'الحوبان',
      relativePos: Offset(0.42, 0.68),
      fraction: 0.70,
      distanceKm: 245,
      roadSpeed: 70,
      statusDescription: 'مجمع الصناعات ومستودعات التوزيع',
    ),
    WaypointRoutePoint(
      name: 'الراهدة — محطة الميزان المحوري',
      shortName: 'الراهدة',
      relativePos: Offset(0.49, 0.76),
      fraction: 0.79,
      distanceKm: 275,
      roadSpeed: 78,
      statusDescription: 'نقطة وزن الحمولات والشحن',
    ),
    WaypointRoutePoint(
      name: 'العند — مثلث لحج السريع',
      shortName: 'العند',
      relativePos: Offset(0.55, 0.83),
      fraction: 0.89,
      distanceKm: 310,
      roadSpeed: 85,
      statusDescription: 'طريق سريع ممهد باتجاه عدن',
    ),
    WaypointRoutePoint(
      name: 'عدن — ميناء المعلا ورصيف الحاويات',
      shortName: 'عدن',
      relativePos: Offset(0.62, 0.90),
      fraction: 1.0,
      distanceKm: 348,
      roadSpeed: 45,
      statusDescription: 'وجهة التسليم والتفريغ النهائية',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentStage = widget.tripData.currentStage;
    _progressPercent = widget.tripData.progressPercent;
    _statusText = widget.tripData.currentStatusText;
    _updateTelemetryFromProgress(_progressPercent);
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _updateTelemetryFromProgress(double progress) {
    int segIdx = 0;
    for (int i = 0; i < _waypoints.length - 1; i++) {
      if (progress >= _waypoints[i].fraction &&
          progress <= _waypoints[i + 1].fraction) {
        segIdx = i;
        break;
      }
    }
    if (progress >= 1.0) segIdx = _waypoints.length - 2;

    final w1 = _waypoints[segIdx];
    final w2 = _waypoints[segIdx + 1];
    final segSpan = w2.fraction - w1.fraction;
    final t = segSpan > 0
        ? ((progress - w1.fraction) / segSpan).clamp(0.0, 1.0)
        : 0.0;

    _currentSpeed =
        (w1.roadSpeed + (w2.roadSpeed - w1.roadSpeed) * t).round();
    _currentRoadLocationName = t < 0.6 ? w1.name : 'بالقرب من ${w2.name}';

    final remainingKm = ((1.0 - progress) * 348).round();
    _remainingDistanceText = '$remainingKm كم';

    final totalMinutes = ((1.0 - progress) * 320).round();
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (progress >= 0.99) {
      _remainingEtaText = 'تم الوصول';
    } else if (hours > 0) {
      _remainingEtaText = '$hours س $mins د';
    } else {
      _remainingEtaText = '$mins دقيقة';
    }

    if (progress <= 0.20) {
      _currentStage = TripStage.toLoading;
      _statusText = 'الشاحنة في طريقها إلى موقع التحميل';
    } else if (progress <= 0.40) {
      _currentStage = TripStage.loaded;
      _statusText = 'تم اكتمال التحميل وتأكيد البوليصة';
    } else if (progress < 0.98) {
      _currentStage = TripStage.inTransit;
      _statusText = 'في الطريق إلى وجهة التسليم (${widget.tripData.destCity})';
    } else {
      _currentStage = TripStage.arrived;
      _statusText = 'تم وصول الشاحنة إلى وجهة التسليم بنجاح';
    }
  }

  void _toggleSimulation() {
    if (_isSimulating) {
      _stopSimulation();
    } else {
      _startSimulation();
    }
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    setState(() => _isSimulating = true);

    if (_progressPercent >= 1.0) {
      _progressPercent = 0.0;
    }

    _simulationTimer =
        Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _radarPulse = (_radarPulse + 0.1) % (math.pi * 2);
        _progressPercent += 0.003 * _simulationSpeed;
        if (_progressPercent >= 1.0) {
          _progressPercent = 1.0;
          _isSimulating = false;
          timer.cancel();
        }
        _updateTelemetryFromProgress(_progressPercent);
      });
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    setState(() => _isSimulating = false);
  }

  void _resetSimulation() {
    _stopSimulation();
    setState(() {
      _progressPercent = 0.0;
      _updateTelemetryFromProgress(0.0);
    });
  }

  void _setTripStage(TripStage stage) {
    setState(() {
      _currentStage = stage;
      switch (stage) {
        case TripStage.toLoading:
          _progressPercent = 0.15;
          _statusText = 'الشاحنة في طريقها إلى موقع التحميل';
          break;
        case TripStage.loaded:
          _progressPercent = 0.35;
          _statusText = 'تم اكتمال التحميل وتأكيد البوليصة';
          break;
        case TripStage.inTransit:
          _progressPercent = 0.65;
          _statusText = 'في الطريق إلى وجهة التسليم (${widget.tripData.destCity})';
          break;
        case TripStage.arrived:
          _progressPercent = 1.0;
          _statusText = 'تم وصول الشاحنة إلى وجهة التسليم بنجاح';
          break;
      }
      _updateTelemetryFromProgress(_progressPercent);
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
              child: Stack(
                children: [
                  // 1. Live Interactive Route Map Canvas with Simulation
                  Positioned.fill(
                    child: _buildRouteMapCanvas(isDark),
                  ),

                  // 2. Floating Top Header
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildHeader(isDark),
                  ),

                  // 3. Floating Live Simulation Telemetry HUD Card
                  Positioned(
                    top: 66,
                    left: 0,
                    right: 0,
                    child: _buildLiveTelemetryHUD(isDark),
                  ),

                  // 4. Left Floating Map Controls
                  Positioned(
                    left: 16,
                    bottom: _isSheetExpanded ? 340 : 220,
                    child: _buildFloatingControls(isDark),
                  ),

                  // 5. Interactive Bottom Sheet
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildTrackingBottomSheet(isDark),
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
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.navyDark : Colors.white)
            .withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            onPressed: widget.onBack,
            tooltip: AppStrings.back,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.liveTripTrackingTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${AppStrings.tripOngoingBadge} • ${widget.tripData.orderId}',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _remainingEtaText,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTelemetryHUD(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF1E293B) : Colors.white)
            .withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Speedometer, Current Road Location, Distance & ETA
          Row(
            children: [
              // Speed Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isSimulating ? AppColors.success : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$_currentSpeed كم/س',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Road segment location text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentRoadLocationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textMainLight,
                      ),
                    ),
                    Text(
                      'المتبقي: $_remainingDistanceText  •  وصول متوقع: $_remainingEtaText',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 10,
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
          const SizedBox(height: 6),

          // Row 2: Live Simulation Controls (Play/Pause, Speed 1x 2x 5x, Replay)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Play / Pause Button
              InkWell(
                onTap: _toggleSimulation,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isSimulating
                        ? AppColors.primaryGold
                        : AppColors.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSimulating
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 15,
                        color:
                            _isSimulating ? Colors.black : AppColors.primaryGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isSimulating ? 'إيقاف مؤقت' : '▶ تشغيل المحاكاة الحية',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: _isSimulating
                              ? Colors.black
                              : AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Speed selector (1x, 2x, 5x) + Reset
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpeedChip(1.0, '1x', isDark),
                  const SizedBox(width: 4),
                  _buildSpeedChip(2.0, '2x', isDark),
                  const SizedBox(width: 4),
                  _buildSpeedChip(5.0, '5x', isDark),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 24, minHeight: 24),
                    tooltip: 'إعادة الرحلة من البداية',
                    onPressed: _resetSimulation,
                    color: isDark
                        ? AppColors.textSubtle
                        : AppColors.textMutedLight,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedChip(double speed, String label, bool isDark) {
    final isSelected = _simulationSpeed == speed;
    return InkWell(
      onTap: () => setState(() => _simulationSpeed = speed),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : (isDark ? const Color(0x660F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.black
                : (isDark ? AppColors.textWhite : AppColors.textMainLight),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteMapCanvas(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          child: CustomPaint(
            painter: _TripRoutePainter(
              isDark: isDark,
              progressPercent: _progressPercent,
              originCity: widget.tripData.originCity,
              destCity: widget.tripData.destCity,
              driverName: widget.tripData.driverName,
              currentSpeed: _currentSpeed,
              waypoints: _waypoints,
              radarPulse: _radarPulse,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingControls(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Re-center on Truck
        Tooltip(
          message: AppStrings.recenterTruckTooltip,
          child: _buildControlCircle(
            icon: Icons.filter_center_focus_rounded,
            color: const Color(0xFF2563EB),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم التمركز على موقع الشاحنة الحالي'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 8),

        // Fit Full Route
        Tooltip(
          message: AppStrings.fitRouteTooltip,
          child: _buildControlCircle(
            icon: Icons.polyline_rounded,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('عرض كامل مسار الرحلة'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 8),

        // Emergency Call
        Tooltip(
          message: AppStrings.emergencyContactTooltip,
          child: _buildControlCircle(
            icon: Icons.sos_rounded,
            color: Colors.white,
            backgroundColor: AppColors.error,
            onTap: widget.onEmergencyCall,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildControlCircle({
    required IconData icon,
    required Color color,
    Color? backgroundColor,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isDark ? const Color(0xFF1E293B) : Colors.white),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildTrackingBottomSheet(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: _isSheetExpanded ? 470 : 210,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          GestureDetector(
            onTap: () => setState(() => _isSheetExpanded = !_isSheetExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // Header Summary Row (Status & ETA)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
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
                TextButton(
                  onPressed: () =>
                      setState(() => _isSheetExpanded = !_isSheetExpanded),
                  child: Text(
                    _isSheetExpanded ? 'تصغير' : 'تفاصيل',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trip Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progressPercent,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? const Color(0x660F172A)
                        : const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.tripData.originCity,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSubtle
                            : AppColors.textMutedLight,
                      ),
                    ),
                    Text(
                      'المتبقي $_remainingDistanceText (${(_progressPercent * 100).toInt()}%)',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGold,
                      ),
                    ),
                    Text(
                      widget.tripData.destCity,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textSubtle
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Driver Compact Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x660F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.primaryGold, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.tripData.driverName,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textMainLight,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded,
                                size: 12, color: AppColors.success),
                          ],
                        ),
                        Text(
                          '${widget.tripData.vehicleName} • ${widget.tripData.plateNumber}',
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
                  IconButton.filledTonal(
                    onPressed: () =>
                        widget.onCallDriver?.call(widget.tripData.driverPhone),
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppColors.success.withValues(alpha: 0.15),
                      foregroundColor: AppColors.success,
                    ),
                    tooltip: AppStrings.callDriver,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content (Stepper, Milestones, Sensors)
          if (_isSheetExpanded)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Simulation Stepper for Presentation
                    _buildSimulationStepper(isDark),

                    const SizedBox(height: 14),

                    // Milestone Timeline
                    _buildMilestonesTimeline(isDark),

                    const SizedBox(height: 14),

                    // Container Sensors Reading
                    _buildSensorsCard(isDark),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSimulationStepper(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x1AF59E0B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded,
                      size: 16, color: AppColors.primaryGold),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.simulationControlTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _toggleSimulation,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _isSimulating
                        ? AppColors.primaryGold
                        : AppColors.primaryGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSimulating
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 12,
                        color:
                            _isSimulating ? Colors.black : AppColors.primaryGold,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _isSimulating ? 'إيقاف' : 'تشغيل حي',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _isSimulating
                              ? Colors.black
                              : AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStepBtn(
                  label: AppStrings.simulationStep1,
                  stage: TripStage.toLoading,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildStepBtn(
                  label: AppStrings.simulationStep2,
                  stage: TripStage.loaded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildStepBtn(
                  label: AppStrings.simulationStep3,
                  stage: TripStage.inTransit,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildStepBtn(
                  label: AppStrings.simulationStep4,
                  stage: TripStage.arrived,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepBtn({
    required String label,
    required TripStage stage,
    required bool isDark,
  }) {
    final isActive = _currentStage == stage;
    return InkWell(
      onTap: () => _setTripStage(stage),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryGold
              : (isDark ? const Color(0x660F172A) : Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 9.5,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive
                ? Colors.black
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildMilestonesTimeline(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.tripTimelineTitle,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textWhite : AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.tripData.milestones.map((m) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    color: m.isCompleted
                        ? AppColors.success
                        : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1)),
                    shape: BoxShape.circle,
                  ),
                  child: m.isCompleted
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            m.title,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: m.isCurrent
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            m.time,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSubtle
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        m.subtitle,
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
          );
        }),
      ],
    );
  }

  Widget _buildSensorsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x660F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.thermostat_rounded,
                  color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.cargoSensorTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                  ),
                  Text(
                    'درجة التبريد: ${widget.tripData.temperatureReading}°C • ${AppStrings.tempNormalStatus}',
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'نشط 100%',
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripRoutePainter extends CustomPainter {
  final bool isDark;
  final double progressPercent;
  final String originCity;
  final String destCity;
  final String driverName;
  final int currentSpeed;
  final List<WaypointRoutePoint> waypoints;
  final double radarPulse;

  const _TripRoutePainter({
    required this.isDark,
    required this.progressPercent,
    required this.originCity,
    required this.destCity,
    required this.driverName,
    required this.currentSpeed,
    required this.waypoints,
    required this.radarPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid background pattern
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (waypoints.isEmpty) return;

    // Convert relative coordinates to canvas pixels
    final pts = waypoints.map((w) {
      return Offset(w.relativePos.dx * size.width, w.relativePos.dy * size.height);
    }).toList();

    // 2. Draw Full Inactive Route Path (Gray highway line)
    final fullPath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      fullPath.lineTo(pts[i].dx, pts[i].dy);
    }

    final fullRoutePaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(fullPath, fullRoutePaint);

    // 3. Calculate interpolated truck position & segment angle
    int segIdx = 0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      if (progressPercent >= waypoints[i].fraction &&
          progressPercent <= waypoints[i + 1].fraction) {
        segIdx = i;
        break;
      }
    }
    if (progressPercent >= 1.0) segIdx = waypoints.length - 2;

    final w1 = waypoints[segIdx];
    final w2 = waypoints[segIdx + 1];
    final p1 = pts[segIdx];
    final p2 = pts[segIdx + 1];

    final segSpan = w2.fraction - w1.fraction;
    final t = segSpan > 0
        ? ((progressPercent - w1.fraction) / segSpan).clamp(0.0, 1.0)
        : 0.0;

    final currentTruckPt = Offset(
      p1.dx + (p2.dx - p1.dx) * t,
      p1.dy + (p2.dy - p1.dy) * t,
    );

    // Heading direction
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final bearingAngle = math.atan2(dy, dx);

    // 4. Draw Traveled Route with vibrant Gold Glow
    final activePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i <= segIdx; i++) {
      activePath.lineTo(pts[i].dx, pts[i].dy);
    }
    activePath.lineTo(currentTruckPt.dx, currentTruckPt.dy);

    final glowPaint = Paint()
      ..color = AppColors.primaryGold.withValues(alpha: 0.28)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(activePath, glowPaint);

    final activeRoutePaint = Paint()
      ..color = AppColors.primaryGold
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(activePath, activeRoutePaint);

    // 5. Draw Waypoint Nodes and Labels along the route
    for (int i = 0; i < waypoints.length; i++) {
      final isVisited = waypoints[i].fraction <= progressPercent;
      final pt = pts[i];

      if (i != 0 && i != waypoints.length - 1) {
        // Intermediate node
        final nodeColor = isVisited ? AppColors.success : const Color(0xFF64748B);
        final fillPaint = Paint()..color = nodeColor;
        final ringPaint = Paint()
          ..color = isVisited ? Colors.white : (isDark ? const Color(0xFF1E293B) : Colors.white)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke;

        canvas.drawCircle(pt, 4.5, fillPaint);
        canvas.drawCircle(pt, 4.5, ringPaint);

        // Waypoint name text
        final textSpan = TextSpan(
          text: waypoints[i].shortName,
          style: GoogleFonts.cairo(
            fontSize: 9.5,
            fontWeight: isVisited ? FontWeight.w800 : FontWeight.w600,
            color: isVisited
                ? (isDark ? AppColors.textWhite : AppColors.textMainLight)
                : (isDark ? AppColors.textSubtle : AppColors.textMutedLight),
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.rtl,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(pt.dx - textPainter.width - 8, pt.dy - textPainter.height / 2),
        );
      }
    }

    // 6. Draw Origin & Destination Pins
    _drawPin(canvas, pts.first, const Color(0xFF16A34A), 'التحميل: $originCity');
    _drawPin(canvas, pts.last, const Color(0xFFDC2626), 'التسليم: $destCity');

    // 7. Animated Pulsating Radar Rings around Truck
    final pulseAlpha1 = ((math.sin(radarPulse) + 1) / 2 * 0.35 + 0.1).clamp(0.0, 1.0);
    final pulseAlpha2 = ((math.cos(radarPulse) + 1) / 2 * 0.25 + 0.05).clamp(0.0, 1.0);

    canvas.drawCircle(
      currentTruckPt,
      24,
      Paint()..color = AppColors.primaryGold.withValues(alpha: pulseAlpha2),
    );
    canvas.drawCircle(
      currentTruckPt,
      17,
      Paint()..color = AppColors.primaryGold.withValues(alpha: pulseAlpha1),
    );

    // 8. Rotating Directional Truck Marker
    canvas.save();
    canvas.translate(currentTruckPt.dx, currentTruckPt.dy);
    canvas.rotate(bearingAngle);

    // Headlight light cone forward
    final lightCone = Path()
      ..moveTo(0, 0)
      ..lineTo(28, -12)
      ..lineTo(28, 12)
      ..close();
    canvas.drawPath(
      lightCone,
      Paint()
        ..color = AppColors.primaryGold.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill,
    );

    // Truck Body
    final truckCirclePaint = Paint()..color = const Color(0xFF0F172A);
    final truckStrokePaint = Paint()
      ..color = AppColors.primaryGold
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset.zero, 12, truckCirclePaint);
    canvas.drawCircle(Offset.zero, 12, truckStrokePaint);

    // Forward direction arrow
    final arrowPath = Path()
      ..moveTo(6, 0)
      ..lineTo(-3, -5)
      ..lineTo(-1, 0)
      ..lineTo(-3, 5)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = AppColors.primaryGold);

    canvas.restore();

    // 9. Floating Truck Callout Label above Truck
    final calloutText = '🚛 $driverName ($currentSpeed كم/س)';
    final calloutSpan = TextSpan(
      text: calloutText,
      style: GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );
    final calloutPainter = TextPainter(
      text: calloutSpan,
      textDirection: TextDirection.rtl,
    )..layout();

    final calloutRect = Rect.fromLTWH(
      currentTruckPt.dx - (calloutPainter.width / 2) - 8,
      currentTruckPt.dy - 34,
      calloutPainter.width + 16,
      20,
    );

    final bgBadge = RRect.fromRectAndRadius(calloutRect, const Radius.circular(10));
    canvas.drawRRect(bgBadge, Paint()..color = const Color(0xEE0F172A));
    canvas.drawRRect(
      bgBadge,
      Paint()
        ..color = AppColors.primaryGold.withValues(alpha: 0.8)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    calloutPainter.paint(
      canvas,
      Offset(calloutRect.left + 8, calloutRect.top + 2),
    );
  }

  void _drawPin(Canvas canvas, Offset pt, Color color, String label) {
    final fillPaint = Paint()..color = color;
    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(pt, 8, fillPaint);
    canvas.drawCircle(pt, 8, strokePaint);

    // Pin shadow
    canvas.drawCircle(
      Offset(pt.dx, pt.dy + 2),
      9,
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // Pin label
    final textSpan = TextSpan(
      text: label,
      style: GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
    )..layout();

    final badgeRect = Rect.fromLTWH(
      pt.dx - (textPainter.width / 2) - 6,
      pt.dy - 24,
      textPainter.width + 12,
      18,
    );
    final rrect = RRect.fromRectAndRadius(badgeRect, const Radius.circular(6));
    canvas.drawRRect(rrect, Paint()..color = (isDark ? const Color(0xDD0F172A) : const Color(0xEEFFFFFF)));
    canvas.drawRRect(rrect, Paint()..color = color.withValues(alpha: 0.5)..strokeWidth = 1.0..style = PaintingStyle.stroke);

    textPainter.paint(canvas, Offset(badgeRect.left + 6, badgeRect.top + 1));
  }

  @override
  bool shouldRepaint(covariant _TripRoutePainter oldDelegate) {
    return oldDelegate.progressPercent != progressPercent ||
        oldDelegate.isDark != isDark ||
        oldDelegate.currentSpeed != currentSpeed ||
        oldDelegate.radarPulse != radarPulse;
  }
}
