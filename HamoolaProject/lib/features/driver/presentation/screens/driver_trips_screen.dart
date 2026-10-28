import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/driver_simulation_store.dart';

/// Screen representing "رحلاتي" for the truck driver.
/// Dedicated trips view with categorized tabs:
/// - النشطة (Active ongoing trips)
/// - القادمة (Upcoming / accepted)
/// - المكتملة (Completed trips)
/// - الملغاة (Cancelled trips)
class DriverTripsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final String? initialCategory;
  final ValueChanged<String>? onTripDetails;

  const DriverTripsScreen({
    super.key,
    this.onBack,
    this.initialCategory,
    this.onTripDetails,
  });

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  late String _activeTab;
  bool _isLoading = false;

  final List<String> _tabs = [
    'النشطة',
    'القادمة',
    'المكتملة',
    'الملغاة',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      if (widget.initialCategory == 'المكتملة' || widget.initialCategory == 'المنتهية') {
        _activeTab = 'المكتملة';
      } else if (widget.initialCategory == 'القادمة') {
        _activeTab = 'القادمة';
      } else {
        _activeTab = 'النشطة';
      }
    } else {
      _activeTab = 'النشطة';
    }

    DriverSimulationStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    DriverSimulationStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final store = DriverSimulationStore.instance;

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
          title: Text(
            'رحلاتي',
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
                Icons.refresh_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
              onPressed: _refreshData,
            ),
          ],
        ),
        body: Column(
          children: [
            // Tabs Bar
            Container(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = _activeTab == tab;
                  int count = 0;
                  if (tab == 'النشطة') count = store.activeTrip != null ? 1 : 0;
                  if (tab == 'القادمة') count = store.upcomingTrips.length;
                  if (tab == 'المكتملة') count = store.completedTrips.length;
                  if (tab == 'الملغاة') count = 0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: ChoiceChip(
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                tab,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                ),
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$count',
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        onSelected: (val) {
                          if (val) setState(() => _activeTab = tab);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Main Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshData,
                      child: _buildTripsList(store, isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList(DriverSimulationStore store, bool isDark) {
    switch (_activeTab) {
      case 'النشطة':
        final activeTrip = store.activeTrip;
        if (activeTrip == null) {
          return _buildEmptyState(
            icon: Icons.navigation_rounded,
            title: 'لا توجد رحلة جارية حالياً',
            subtitle: 'عند قبول طلب نقل وبدء الرحلة، ستتمكن من متابعتها وإدارتها هنا.',
            isDark: isDark,
          );
        }
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          children: [
            _buildTripCard(activeTrip, isDark, isActive: true),
          ],
        );

      case 'القادمة':
        final upcoming = store.upcomingTrips;
        if (upcoming.isEmpty) {
          return _buildEmptyState(
            icon: Icons.access_time_rounded,
            title: 'لا توجد رحلات قادمة',
            subtitle: 'الرحلات المسندة إليك والمجدولة لاحقاً ستظهر هنا.',
            isDark: isDark,
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          itemCount: upcoming.length,
          itemBuilder: (ctx, index) => _buildTripCard(upcoming[index], isDark, isUpcoming: true),
        );

      case 'المكتملة':
        final completed = store.completedTrips;
        if (completed.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: 'لا توجد رحلات مكتملة',
            subtitle: 'جميع الرحلات التي تقوم بتسليمها وإغلاقها ستُحفظ في هذا السجل.',
            isDark: isDark,
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          itemCount: completed.length,
          itemBuilder: (ctx, index) => _buildTripCard(completed[index], isDark, isCompleted: true),
        );

      case 'الملغاة':
      default:
        return _buildEmptyState(
          icon: Icons.cancel_outlined,
          title: 'لا توجد رحلات ملغاة',
          subtitle: 'سجل الرحلات التي تم إلغاؤها من قبلك أو من قبل التاجر.',
          isDark: isDark,
        );
    }
  }

  Widget _buildTripCard(
    DriverTrip trip,
    bool isDark, {
    bool isActive = false,
    bool isUpcoming = false,
    bool isCompleted = false,
  }) {
    final statusColor = isActive
        ? const Color(0xFF2563EB)
        : isCompleted
            ? const Color(0xFF16A34A)
            : const Color(0xFFEA580C);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFF2563EB)
              : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: ID, Badge & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isActive
                            ? Icons.navigation_rounded
                            : isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                        color: statusColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trip.id,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trip.stageTitle,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cargo Title
          Text(
            trip.cargoTitle,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Route Details
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${trip.originCity} ← ${trip.destinationCity} (${trip.distanceKm} كم)',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Checkpoint
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trip.currentCheckpoint,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          if (isActive) ...[
            const SizedBox(height: 10),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: trip.progressRatio,
                minHeight: 6,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
          ],

          const Divider(height: 20),

          // Bottom Action Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? 'الأرباح المستلمة:' : 'المستحقات المتوقعة:',
                      style: GoogleFonts.cairo(fontSize: 10.5, color: const Color(0xFF64748B)),
                    ),
                    Text(
                      '${trip.payoutYmr} ريال',
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isActive) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onTripDetails != null) {
                      widget.onTripDetails!(trip.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.route_rounded, size: 16),
                  label: Text(
                    'متابعة الرحلة',
                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ] else if (isUpcoming) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onTripDetails != null) {
                      widget.onTripDetails!(trip.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: Text('بدء الرحلة', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              ] else ...[
                OutlinedButton(
                  onPressed: () => _showTripDetailsModal(trip),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  child: Text('عرض التفاصيل', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTripDetailsModal(DriverTrip trip) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('${trip.cargoTitle} (${trip.id})', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('التاجر: ${trip.merchantName}', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                const Divider(height: 16),
                Text('المسار: ${trip.originCity} ← ${trip.destinationCity} (${trip.distanceKm} كم)', style: GoogleFonts.cairo()),
                const SizedBox(height: 6),
                Text('موقع التحميل: ${trip.pickupLocation}', style: GoogleFonts.cairo(fontSize: 12)),
                const SizedBox(height: 4),
                Text('موقع التسليم: ${trip.dropoffLocation}', style: GoogleFonts.cairo(fontSize: 12)),
                const SizedBox(height: 6),
                Text('المقابل المالي: ${trip.payoutYmr} ريال', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: const Color(0xFF16A34A))),
                const SizedBox(height: 6),
                Text('الحالة: ${trip.stageTitle}', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: const Color(0xFF16A34A))),
                const SizedBox(height: 6),
                Text('تفاصيل الحمولة: ${trip.cargoDetails}', style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إغلاق', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }
}
