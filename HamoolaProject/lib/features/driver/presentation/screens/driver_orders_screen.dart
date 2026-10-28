import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/driver_simulation_store.dart';

/// Screen representing "طلباتي" for the truck driver.
/// Shows orders linked to the driver:
/// - Bids placed on public marketplace cargos
/// - Direct private orders requested from the driver
/// - Accepted & assigned orders
/// - Completed and closed orders
class DriverOrdersScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final String? initialCategory;
  final ValueChanged<String>? onTripDetails;

  const DriverOrdersScreen({
    super.key,
    this.onBack,
    this.initialCategory,
    this.onTripDetails,
  });

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
  late String _activeTab;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  final List<String> _tabs = [
    'الكل',
    'عروضي النشطة',
    'طلبات خاصة',
    'المقبولة والمسندة',
    'المنتهية',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      if (widget.initialCategory == 'النشطة' || widget.initialCategory == 'عروضي النشطة') {
        _activeTab = 'عروضي النشطة';
      } else if (widget.initialCategory == 'الخاصة' || widget.initialCategory == 'طلبات خاصة') {
        _activeTab = 'طلبات خاصة';
      } else if (widget.initialCategory == 'المكتملة' || widget.initialCategory == 'المنتهية') {
        _activeTab = 'المنتهية';
      } else {
        _activeTab = 'الكل';
      }
    } else {
      _activeTab = 'الكل';
    }

    DriverSimulationStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
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
            'طلباتي',
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
            // Tabs Row
            Container(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _tabs.map((tab) {
                    final isSelected = _activeTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          tab,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : const Color(0xFF475569)),
                          ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refreshData,
                      child: _buildTabContent(store, isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(DriverSimulationStore store, bool isDark) {
    switch (_activeTab) {
      case 'عروضي النشطة':
        final bids = store.bids.where((b) => b.status == 'pending').toList();
        if (bids.isEmpty) {
          return _buildEmptyState(
            icon: Icons.gavel_rounded,
            title: 'لا توجد عروض أسعار نشطة',
            subtitle: 'لم تقدم أي عروض أسعار جديدة قيد انتظار موافقة التاجر.',
            isDark: isDark,
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          itemCount: bids.length,
          itemBuilder: (ctx, index) => _buildBidCard(bids[index], isDark),
        );

      case 'طلبات خاصة':
        final requests = store.directRequests;
        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.mark_email_unread_rounded,
            title: 'لا توجد طلبات خاصة حاليًا',
            subtitle: 'لا توجد طلبات نقل مباشرة موجهة لناقلتك في الوقت الحالي.',
            isDark: isDark,
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (ctx, index) => _buildDirectRequestCard(requests[index], isDark),
        );

      case 'المقبولة والمسندة':
        final acceptedBids = store.bids.where((b) => b.status == 'accepted').toList();
        final acceptedDirect = store.directRequests.where((d) => d.status == 'accepted').toList();
        final upcomingTrips = store.upcomingTrips;

        if (acceptedBids.isEmpty && acceptedDirect.isEmpty && upcomingTrips.isEmpty && store.activeTrip == null) {
          return _buildEmptyState(
            icon: Icons.assignment_turned_in_rounded,
            title: 'لا توجد طلبات مقبولة أو مسندة',
            subtitle: 'عند قبول عرضك أو إسناد رحلة لك، ستظهر تفاصيلها هنا.',
            isDark: isDark,
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          children: [
            if (store.activeTrip != null) ...[
              _buildSectionHeader('الرحلة الجارية الآن', isDark),
              _buildTripSummaryCard(store.activeTrip!, isDark, isActive: true),
              const SizedBox(height: 16),
            ],
            if (upcomingTrips.isNotEmpty) ...[
              _buildSectionHeader('رحلات معتمدة قادمة', isDark),
              ...upcomingTrips.map((t) => _buildTripSummaryCard(t, isDark, isActive: false)),
              const SizedBox(height: 16),
            ],
            if (acceptedDirect.isNotEmpty) ...[
              _buildSectionHeader('طلبات خاصة مقبولة', isDark),
              ...acceptedDirect.map((r) => _buildDirectRequestCard(r, isDark)),
              const SizedBox(height: 16),
            ],
            if (acceptedBids.isNotEmpty) ...[
              _buildSectionHeader('عروض تمت الموافقة عليها', isDark),
              ...acceptedBids.map((b) => _buildBidCard(b, isDark)),
            ],
          ],
        );

      case 'المنتهية':
        final completedTrips = store.completedTrips;
        if (completedTrips.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_rounded,
            title: 'لا توجد طلبات منتهية',
            subtitle: 'سجل الطلبات والرحلات المكتملة يظهر هنا بعد التسليم والتسوية.',
            isDark: isDark,
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          itemCount: completedTrips.length,
          itemBuilder: (ctx, index) => _buildTripSummaryCard(completedTrips[index], isDark, isCompleted: true),
        );

      case 'الكل':
      default:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          children: [
            if (store.activeTrip != null) ...[
              _buildSectionHeader('الرحلة النشطة', isDark),
              _buildTripSummaryCard(store.activeTrip!, isDark, isActive: true),
              const SizedBox(height: 16),
            ],
            if (store.directRequests.isNotEmpty) ...[
              _buildSectionHeader('طلبات خاصة موجهة لك', isDark),
              ...store.directRequests.map((r) => _buildDirectRequestCard(r, isDark)),
              const SizedBox(height: 16),
            ],
            if (store.bids.isNotEmpty) ...[
              _buildSectionHeader('عروض الأسعار المقدمة (${store.bids.length})', isDark),
              ...store.bids.map((b) => _buildBidCard(b, isDark)),
              const SizedBox(height: 16),
            ],
            if (store.completedTrips.isNotEmpty) ...[
              _buildSectionHeader('آخر الطلبات المكتملة', isDark),
              ...store.completedTrips.take(3).map((t) => _buildTripSummaryCard(t, isDark, isCompleted: true)),
            ],
          ],
        );
    }
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildBidCard(DriverBidItem bid, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Color(0xFF2563EB), size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bid.id,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bid.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bid.statusLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: bid.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            bid.cargoTitle,
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${bid.originCity} ← ${bid.destinationCity} (${bid.distanceKm} كم)',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عرض السعر المقدم:',
                    style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF64748B)),
                  ),
                  Text(
                    '${bid.bidAmount} ${bid.currencyLabel}',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () => _showBidDetailsDialog(bid),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: Text('عرض التفاصيل', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectRequestCard(DriverDirectRequestItem req, bool isDark) {
    final isPending = req.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? const Color(0xFFF59E0B) : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          width: isPending ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'طلب خاص موجه لك',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                req.status == 'accepted'
                    ? 'تم القبول'
                    : req.status == 'declined'
                        ? 'تم الاعتذار'
                        : 'بانتظار ردك',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: req.status == 'accepted'
                      ? const Color(0xFF16A34A)
                      : req.status == 'declined'
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            req.cargoTitle,
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'من: ${req.merchantName}',
            style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${req.originCity} ← ${req.destinationCity}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المقابل المالي المعروض:',
                      style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                    Text(
                      '${req.offeredFare} ريال',
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
              if (isPending) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        DriverSimulationStore.instance.acceptDirectRequest(req.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم قبول الطلب الخاص بنجاح! بانتظار تأكيد الدفع.', style: GoogleFonts.cairo()),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('قبول', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        DriverSimulationStore.instance.declineDirectRequest(req.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم الاعتذار عن الطلب الخاص.', style: GoogleFonts.cairo()),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('اعتذار', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              ] else ...[
                OutlinedButton(
                  onPressed: () => _showDirectRequestDetailsDialog(req),
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

  Widget _buildTripSummaryCard(DriverTrip trip, bool isDark, {bool isActive = false, bool isCompleted = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                        color: isActive
                            ? const Color(0xFFEFF6FF)
                            : isCompleted
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isActive
                            ? Icons.navigation_rounded
                            : isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                        color: isActive
                            ? const Color(0xFF2563EB)
                            : isCompleted
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF64748B),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        trip.id,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
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
                    color: (isActive
                            ? const Color(0xFF2563EB)
                            : isCompleted
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF64748B))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trip.stageTitle,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF2563EB)
                          : isCompleted
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            trip.cargoTitle,
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${trip.originCity} ← ${trip.destinationCity} • ${trip.currentCheckpoint}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أجرة النقل المستحقة:',
                      style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF64748B)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.route_rounded, size: 16),
                  label: Text('متابعة الرحلة', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ] else ...[
                OutlinedButton(
                  onPressed: () => _showTripDetailsDialog(trip),
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

  void _showBidDetailsDialog(DriverBidItem bid) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(bid.cargoTitle, style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رقم العرض: ${bid.id}', style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B))),
              const Divider(height: 16),
              Text('المسار: ${bid.originCity} ← ${bid.destinationCity} (${bid.distanceKm} كم)', style: GoogleFonts.cairo()),
              const SizedBox(height: 6),
              Text('عرض السعر المقدم: ${bid.bidAmount} ${bid.currencyLabel}', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: const Color(0xFF16A34A))),
              const SizedBox(height: 6),
              Text('الميزانية المقترحة من التاجر: ${bid.targetBudget} ${bid.currencyLabel}', style: GoogleFonts.cairo()),
              const SizedBox(height: 6),
              Text('الناقلة: ${bid.truckType}', style: GoogleFonts.cairo()),
              const SizedBox(height: 6),
              Text('الحالة: ${bid.statusLabel}', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: bid.statusColor)),
              if (bid.notes != null && bid.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('الملاحظات: ${bid.notes}', style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF475569))),
              ],
            ],
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

  void _showDirectRequestDetailsDialog(DriverDirectRequestItem req) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(req.cargoTitle, style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('التاجر: ${req.merchantName}', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              const Divider(height: 16),
              Text('المسار: ${req.originCity} ← ${req.destinationCity}', style: GoogleFonts.cairo()),
              const SizedBox(height: 6),
              Text('المقابل المالي: ${req.offeredFare} ريال', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: const Color(0xFF16A34A))),
              const SizedBox(height: 6),
              Text('وقت التحميل: ${req.loadingWindow}', style: GoogleFonts.cairo()),
              const SizedBox(height: 6),
              Text('ملاحظات الشحنة: ${req.notes}', style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B))),
            ],
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

  void _showTripDetailsDialog(DriverTrip trip) {
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
                Text('المقابل المالي المستحق: ${trip.payoutYmr} ريال', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: const Color(0xFF16A34A))),
                const SizedBox(height: 6),
                Text('الحالة: ${trip.stageTitle}', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: const Color(0xFF2563EB))),
                const SizedBox(height: 6),
                Text('ملاحظات: ${trip.cargoDetails}', style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B))),
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
