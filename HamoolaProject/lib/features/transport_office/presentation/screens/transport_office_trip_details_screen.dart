// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../domain/models/transport_office_trips_store.dart';
import 'transport_office_trip_timeline_screen.dart';

/// Screen representing "تفاصيل الرحلة" (Trip Details)
class TransportOfficeTripDetailsScreen extends StatefulWidget {
  final String tripId;
  final VoidCallback? onBack;

  const TransportOfficeTripDetailsScreen({
    super.key,
    required this.tripId,
    this.onBack,
  });

  @override
  State<TransportOfficeTripDetailsScreen> createState() =>
      _TransportOfficeTripDetailsScreenState();
}

class _TransportOfficeTripDetailsScreenState
    extends State<TransportOfficeTripDetailsScreen> {
  final TransportOfficeTripsStore _store = TransportOfficeTripsStore.instance;
  bool _isProcessingAction = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  OfficeTrip? get _trip => _store.getTripById(widget.tripId);

  @override
  Widget build(BuildContext context) {
    final trip = _trip;

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
                  _buildHeader(trip),

                  // 2. Scrollable Body
                  Expanded(
                    child: trip == null
                        ? _buildNotFound()
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top Status & ID Box
                                _buildTopStatusBox(trip),

                                const SizedBox(height: 12.0),

                                // Route Card
                                _buildRouteCard(trip),

                                const SizedBox(height: 12.0),

                                // Metrics Card (Distance & Duration)
                                _buildMetricsCard(trip),

                                const SizedBox(height: 12.0),

                                // Special section for Cancelled (Reason) or Completed (Rating)
                                if (trip.status == OfficeTripStatus.cancelled &&
                                    trip.cancellationReason != null) ...[
                                  _buildCancellationBox(trip),
                                  const SizedBox(height: 12.0),
                                ],

                                if (trip.status == OfficeTripStatus.completed &&
                                    trip.rating != null) ...[
                                  _buildRatingBox(trip.rating!),
                                  const SizedBox(height: 12.0),
                                ],

                                // Truck & Cargo Details
                                _buildTruckDetailsCard(trip),

                                const SizedBox(height: 12.0),

                                // Client Details
                                _buildClientCard(trip),

                                const SizedBox(height: 12.0),

                                // Assigned Driver Details
                                _buildDriverCard(trip),

                                const SizedBox(height: 14.0),

                                // Timeline Teaser Card
                                _buildTimelineTeaserCard(trip),

                                const SizedBox(height: 20.0),
                              ],
                            ),
                          ),
                  ),

                  // 3. Bottom Action Bar (if operational buttons available)
                  if (trip != null &&
                      (trip.status == OfficeTripStatus.pendingStart ||
                          trip.status == OfficeTripStatus.inProgress))
                    _buildBottomActionBar(trip),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Sub-screen Header
  // ===========================================================================
  Widget _buildHeader(OfficeTrip? trip) {
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
            onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
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
            'تفاصيل الرحلة',
            style: GoogleFonts.cairo(
              fontSize: 18.0,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),

          // 3-Dots popup menu
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF64748B),
              size: 22.0,
            ),
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            onSelected: (value) {
              if (value == 'timeline') {
                _openTimeline();
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem<String>(
                value: 'timeline',
                child: Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: Color(0xFF2563EB),
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'السجل الزمني للرحلة',
                      style: GoogleFonts.cairo(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Content Cards
  // ===========================================================================

  Widget _buildTopStatusBox(OfficeTrip trip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
          // Status Badge
          _buildStatusBadge(trip.status),

          const SizedBox(width: 8.0),

          // Trip ID & Agreed Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '#${trip.id}',
                  style: GoogleFonts.cairo(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'المبلغ: ${trip.agreedPriceSar} ر.س',
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OfficeTripStatus status) {
    Color bg;
    Color border;
    Color text;
    IconData icon;

    switch (status) {
      case OfficeTripStatus.pendingStart:
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFDE68A);
        text = const Color(0xFFD97706);
        icon = Icons.access_time_rounded;
        break;
      case OfficeTripStatus.inProgress:
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFF86EFAC);
        text = const Color(0xFF16A34A);
        icon = Icons.local_shipping_rounded;
        break;
      case OfficeTripStatus.completed:
        bg = const Color(0xFFEFF6FF);
        border = const Color(0xFFBFDBFE);
        text = const Color(0xFF2563EB);
        icon = Icons.check_circle_rounded;
        break;
      case OfficeTripStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFFECACA);
        text = const Color(0xFFDC2626);
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: text),
          const SizedBox(width: 4.0),
          Text(
            status.label,
            style: GoogleFonts.cairo(
              fontSize: 12.0,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(OfficeTrip trip) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alt_route_rounded,
                  color: Color(0xFF2563EB),
                  size: 18.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  trip.formattedRoute,
                  style: GoogleFonts.cairo(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),
          const Divider(height: 1.0, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12.0),

          // Origin Area
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.radio_button_checked_rounded,
                size: 16.0,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نقطة الانطلاق: ${trip.originCity}${trip.originCountry.isNotEmpty ? '، ${trip.originCountry}' : ''}',
                      style: GoogleFonts.cairo(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (trip.originArea != null)
                      Text(
                        trip.originArea!,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // Destination Area
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16.0,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وجهة الوصول: ${trip.destinationCity}${trip.destinationCountry.isNotEmpty ? '، ${trip.destinationCountry}' : ''}',
                      style: GoogleFonts.cairo(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (trip.destinationArea != null)
                      Text(
                        trip.destinationArea!,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // Scheduled Date Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 15.0,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'الموعد المجدول: ${_formatDateTime(trip.scheduledDate)}',
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(OfficeTrip trip) {
    final bool isInProgress = trip.status == OfficeTripStatus.inProgress;

    return Row(
      children: [
        // Left Column: Distance
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Text(
                  isInProgress ? 'المسافة المتبقية' : 'المسافة',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  isInProgress
                      ? '${trip.remainingDistanceKm ?? trip.distanceKm} كم'
                      : '${trip.distanceKm} كم',
                  style: GoogleFonts.cairo(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10.0),

        // Right Column: Duration
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Text(
                  trip.status == OfficeTripStatus.completed
                      ? 'المدة الفعلية'
                      : 'المدة التقديرية',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${trip.estimatedDurationHours} ساعات',
                  style: GoogleFonts.cairo(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTruckDetailsCard(OfficeTrip trip) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بيانات الشاحنة والحمولة',
            style: GoogleFonts.cairo(
              fontSize: 14.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Truck Type
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_rounded,
                      size: 18.0,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        trip.truckType,
                        style: GoogleFonts.cairo(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8.0),

              // Payload
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.scale_rounded,
                    size: 18.0,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    '${trip.weightTons.toInt()} طن',
                    style: GoogleFonts.cairo(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            'وصف الحمولة: ${trip.cargoTitle}',
            style: GoogleFonts.cairo(
              fontSize: 12.0,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(OfficeTrip trip) {
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
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.business_rounded,
                color: Color(0xFF2563EB),
                size: 22.0,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.clientName,
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  trip.clientCompany,
                  style: GoogleFonts.cairo(
                    fontSize: 12.0,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(OfficeTrip trip) {
    final driver = trip.driver;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'السائق المعيّن',
            style: GoogleFonts.cairo(
              fontSize: 14.0,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12.0),
          if (driver != null)
            Row(
              children: [
                // Avatar
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      driver.avatarAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFEFF6FF),
                        child: Center(
                          child: Text(
                            driver.name.substring(0, 1),
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),

                // Name & Plate
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: GoogleFonts.cairo(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'لوحة: ${driver.vehiclePlate} • ${driver.phone}',
                        style: GoogleFonts.cairo(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Phone Call Action Icon
                InkWell(
                  onTap: () => _callDriver(driver),
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Icon(
                      Icons.phone_rounded,
                      color: Color(0xFF2563EB),
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16.0,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'لم يتم تعيين سائق بعد لهذه الرحلة.',
                    style: GoogleFonts.cairo(
                      fontSize: 12.0,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCancellationBox(OfficeTrip trip) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cancel_rounded,
                color: Color(0xFFDC2626),
                size: 18.0,
              ),
              const SizedBox(width: 6.0),
              Text(
                'سبب الإلغاء',
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            trip.cancellationReason ?? 'تم الإلغاء بدون ذكر سبب محدد.',
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF991B1B),
              height: 1.45,
            ),
          ),
          if (trip.cancelledAt != null) ...[
            const SizedBox(height: 4.0),
            Text(
              'تاريخ الإلغاء: ${_formatDateTime(trip.cancelledAt!)}',
              style: GoogleFonts.cairo(
                fontSize: 11.0,
                color: const Color(0xFFB91C1C),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingBox(OfficeTripRating rating) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFFEF08A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تقييم العميل للمكتب',
                style: GoogleFonts.cairo(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF854D0E),
                ),
              ),
              Row(
                children: [
                  Text(
                    rating.stars.toStringAsFixed(1),
                    style: GoogleFonts.cairo(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF854D0E),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFEAB308),
                    size: 18.0,
                  ),
                ],
              ),
            ],
          ),
          if (rating.comment != null) ...[
            const SizedBox(height: 6.0),
            Text(
              '«${rating.comment!}»',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF713F12),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineTeaserCard(OfficeTrip trip) {
    return InkWell(
      onTap: _openTimeline,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    size: 18.0,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السجل الزمني للرحلة',
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${trip.milestones.length} أحداث مسجلة حتى الآن',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14.0,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Bottom Action Bar
  // ===========================================================================
  Widget _buildBottomActionBar(OfficeTrip trip) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary Action Button (بدء الرحلة أو إنهاء الرحلة)
          if (trip.status == OfficeTripStatus.pendingStart)
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                onPressed: _isProcessingAction ? null : () => _confirmStartTrip(trip),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isProcessingAction
                    ? const SizedBox(
                        width: 22.0,
                        height: 22.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'بدء الرحلة',
                        style: GoogleFonts.cairo(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            )
          else if (trip.status == OfficeTripStatus.inProgress)
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                onPressed: _isProcessingAction ? null : () => _confirmCompleteTrip(trip),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isProcessingAction
                    ? const SizedBox(
                        width: 22.0,
                        height: 22.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'إنهاء الرحلة',
                        style: GoogleFonts.cairo(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),

          const SizedBox(height: 8.0),

          // Secondary Action Button (إلغاء الرحلة)
          SizedBox(
            width: double.infinity,
            height: 44.0,
            child: OutlinedButton(
              onPressed: _isProcessingAction ? null : () => _confirmCancelTrip(trip),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFECACA), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'إلغاء الرحلة',
                style: GoogleFonts.cairo(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Action Dialogs
  // ===========================================================================

  Future<void> _confirmStartTrip(OfficeTrip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(
            'بدء الرحلة #${trip.id}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في بدء الرحلة الآن وانطلاق الشاحنة من ${trip.originCity} إلى ${trip.destinationCity}؟',
            style: GoogleFonts.cairo(fontSize: 13.5, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('تراجع', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('تأكيد بدء الرحلة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessingAction = true);
      final success = await _store.startTrip(trip.id);
      if (mounted) {
        setState(() => _isProcessingAction = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم بدء الرحلة بنجاح ✓', style: GoogleFonts.cairo()),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmCompleteTrip(OfficeTrip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(
            'إنهاء الرحلة #${trip.id}',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'هل تم تسليم الشحنة في ${trip.destinationCity} وتوقيع سند الاستلام من قبل العميل؟',
            style: GoogleFonts.cairo(fontSize: 13.5, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('تراجع', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('تأكيد إنهاء الرحلة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessingAction = true);
      final success = await _store.completeTrip(trip.id);
      if (mounted) {
        setState(() => _isProcessingAction = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إنهاء الرحلة وتأكيد التسليم بنجاح ✓', style: GoogleFonts.cairo()),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmCancelTrip(OfficeTrip trip) async {
    String selectedReason = 'طلب العميل تأجيل الشحنة';
    final customReasonController = TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                title: Text(
                  'إلغاء الرحلة #${trip.id}',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'يرجى تحديد سبب إلغاء الرحلة لتوثيقه في السجل الزمني وإشعار الأطراف المعنية:',
                        style: GoogleFonts.cairo(fontSize: 13.0, height: 1.5),
                      ),
                      const SizedBox(height: 12.0),
                      ...[
                        'طلب العميل تأجيل الشحنة',
                        'ظروف تشغيلية طارئة على خط السير',
                        'عطل فني في الشاحنة يتعذر إصلاحه فورا',
                        'سبب آخر',
                      ].map((reason) {
                        return RadioListTile<String>(
                          value: reason,
                          groupValue: selectedReason,
                          title: Text(
                            reason,
                            style: GoogleFonts.cairo(fontSize: 12.5),
                          ),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedReason = val);
                            }
                          },
                        );
                      }),
                      if (selectedReason == 'سبب آخر') ...[
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: customReasonController,
                          style: GoogleFonts.cairo(fontSize: 13.0),
                          decoration: InputDecoration(
                            hintText: 'اكتب سبب الإلغاء هنا...',
                            hintStyle: GoogleFonts.cairo(fontSize: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: Text('تراجع', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final finalReason = selectedReason == 'سبب آخر'
                          ? (customReasonController.text.trim().isNotEmpty
                              ? customReasonController.text.trim()
                              : 'إلغاء لسبب تشغيلي غير محدد')
                          : selectedReason;
                      Navigator.of(ctx).pop(finalReason);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    child: Text('تأكيد الإلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _isProcessingAction = true);
      final success = await _store.cancelTrip(trip.id, result);
      if (mounted) {
        setState(() => _isProcessingAction = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إلغاء الرحلة بنجاح', style: GoogleFonts.cairo()),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    }
  }

  void _callDriver(OfficeTripDriver driver) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            'الاتصال بالسائق',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'جاري الاتصال بالسائق ${driver.name} على الرقم:\n${driver.phone}',
            style: GoogleFonts.cairo(fontSize: 13.5, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('إغلاق', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _openTimeline() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransportOfficeTripTimelineScreen(tripId: widget.tripId),
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
