import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../domain/models/transport_office_trips_store.dart';

/// Screen representing "السجل الزمني للرحلة" (Trip Timeline)
class TransportOfficeTripTimelineScreen extends StatelessWidget {
  final String tripId;
  final VoidCallback? onBack;

  const TransportOfficeTripTimelineScreen({
    super.key,
    required this.tripId,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final trip = TransportOfficeTripsStore.instance.getTripById(tripId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Column(
                children: [
                  // 1. Independent Sub-screen Header
                  _buildHeader(context),

                  // 2. Timeline Body
                  Expanded(
                    child: trip == null
                        ? _buildNotFound()
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Trip Summary Card
                                _buildTripSummaryCard(trip),

                                const SizedBox(height: 20.0),

                                // Timeline Section Title
                                Text(
                                  'تسلسل الأحداث المسجلة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 14.0),

                                // Milestones Vertical List
                                _buildTimelineList(trip),
                              ],
                            ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          InkWell(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18.0,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          // Title
          Text(
            'السجل الزمني',
            style: GoogleFonts.cairo(
              fontSize: 18.0,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),

          // Spacer for symmetry
          const SizedBox(width: 40.0),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard(OfficeTrip trip) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Route and ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'رحلة رقم #${trip.id}',
                  style: GoogleFonts.cairo(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  trip.formattedRoute,
                  style: GoogleFonts.cairo(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Status Badge
          _buildStatusBadge(trip.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OfficeTripStatus status) {
    Color bg;
    Color border;
    Color text;
    String label = status.label;

    switch (status) {
      case OfficeTripStatus.pendingStart:
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFDE68A);
        text = const Color(0xFFD97706);
        break;
      case OfficeTripStatus.inProgress:
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFF86EFAC);
        text = const Color(0xFF16A34A);
        break;
      case OfficeTripStatus.completed:
        bg = const Color(0xFFEFF6FF);
        border = const Color(0xFFBFDBFE);
        text = const Color(0xFF2563EB);
        break;
      case OfficeTripStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFFECACA);
        text = const Color(0xFFDC2626);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12.0,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }

  Widget _buildTimelineList(OfficeTrip trip) {
    final milestones = trip.milestones;

    if (milestones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(
            'لا توجد أحداث مسجلة لهذه الرحلة حتى الآن.',
            style: GoogleFonts.cairo(
              fontSize: 13.0,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(milestones.length, (index) {
          final item = milestones[index];
          final isLast = index == milestones.length - 1;

          return _buildTimelineItem(
            milestone: item,
            isLast: isLast,
            isCancelled: trip.status == OfficeTripStatus.cancelled && isLast,
          );
        }),
      ),
    );
  }

  Widget _buildTimelineItem({
    required OfficeTripMilestone milestone,
    required bool isLast,
    required bool isCancelled,
  }) {
    final Color nodeColor = isCancelled
        ? const Color(0xFFDC2626)
        : const Color(0xFF2563EB);

    final Color nodeBg = isCancelled
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFEFF6FF);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator column (dot + line)
          Column(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: nodeBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeColor, width: 2.0),
                ),
                child: Center(
                  child: Icon(
                    milestone.icon,
                    size: 18.0,
                    color: nodeColor,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14.0),

          // Milestone Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    milestone.title,
                    style: GoogleFonts.cairo(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isCancelled ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2.0),

                  // Description
                  Text(
                    milestone.description,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 6.0),

                  // Formatted Timestamp
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13.0,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4.0),
                      Flexible(
                        child: Text(
                          _formatDateTime(milestone.timestamp),
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
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
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    final monthName = months[dt.month - 1];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'م' : 'ص';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} $monthName ${dt.year} • $hour:$minuteStr $period';
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48.0,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12.0),
          Text(
            'لم يتم العثور على بيانات الرحلة',
            style: GoogleFonts.cairo(
              fontSize: 15.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
