import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/driver_offer.dart';
import '../../domain/models/merchant_simulation_store.dart';

enum OffersFilter {
  all,
  lowestPrice,
  highestRating,
  fastest,
}

/// Screen allowing the merchant to review incoming competitive offers from drivers,
/// negotiate counter-offers, view driver profiles, and accept an offer to dispatch the trip.
class MerchantOffersReviewScreen extends StatefulWidget {
  final String orderId;
  final VoidCallback? onBack;
  final ValueChanged<DriverOffer>? onOfferAccepted;
  final ValueChanged<String>? onDriverProfile;

  const MerchantOffersReviewScreen({
    super.key,
    this.orderId = 'REQ-1024',
    this.onBack,
    this.onOfferAccepted,
    this.onDriverProfile,
  });

  @override
  State<MerchantOffersReviewScreen> createState() =>
      _MerchantOffersReviewScreenState();
}

class _MerchantOffersReviewScreenState
    extends State<MerchantOffersReviewScreen> {
  OffersFilter _currentFilter = OffersFilter.all;
  late List<DriverOffer> _offers;

  @override
  void initState() {
    super.initState();
    final storeOffers =
        MerchantSimulationStore.instance.getOffersForOrder(widget.orderId);
    _offers = storeOffers.isNotEmpty
        ? List.from(storeOffers)
        : List.from(DriverOffer.demoOffers);
  }

  List<DriverOffer> get _filteredOffers {
    final list = List<DriverOffer>.from(_offers);
    switch (_currentFilter) {
      case OffersFilter.all:
        return list;
      case OffersFilter.lowestPrice:
        list.sort((a, b) => a.price.compareTo(b.price));
        return list;
      case OffersFilter.highestRating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        return list;
      case OffersFilter.fastest:
        return list.where((o) => o.isFastest || o.pickupTimeText.contains('ساعة')).toList();
    }
  }

  void _showAcceptConfirmationModal(DriverOffer offer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Shield Icon
                Center(
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: Color(0x2E10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  AppStrings.contractConfirmTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.contractConfirmSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 18),

                // Details Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildConfirmRow('السائق المتعاقد:', offer.driverName, isDark),
                      const SizedBox(height: 6),
                      _buildConfirmRow('المركبة:', offer.vehicleName, isDark),
                      const SizedBox(height: 6),
                      _buildConfirmRow('الموعد:', offer.pickupTimeText, isDark),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المبلغ المتفق عليه:',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '${offer.formattedPrice} ر.ي',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm CTA Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onOfferAccepted?.call(offer);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppStrings.confirmAndDispatchBtn,
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              size: 20,
            ),
            onPressed: widget.onBack ?? () => Navigator.maybePop(context),
          ),
          title: Text(
            AppStrings.offersReviewTitle,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(left: 14),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_offers.length} عروض',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Column(
                children: [
                  // 1. Order Summary Hero Card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceMd,
                      vertical: AppDimensions.spaceXs,
                    ),
                    child: _buildOrderHeroCard(isDark),
                  ),

                  // 2. Filter & Sort Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceMd,
                      vertical: AppDimensions.spaceXs,
                    ),
                    child: _buildFilterBar(isDark),
                  ),
                  const SizedBox(height: 6),

                  // 3. Offers List
                  Expanded(
                    child: _filteredOffers.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spaceMd,
                              vertical: AppDimensions.spaceSm,
                            ),
                            itemCount: _filteredOffers.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (ctx, index) {
                              return _buildOfferCard(
                                _filteredOffers[index],
                                isDark,
                              );
                            },
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

  /// Sticky Order Summary Hero Card
  Widget _buildOrderHeroCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.orderId,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.cargoFoodstuff,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x2E10B981),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'نشط ومفتوح',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Route row
          Row(
            children: [
              const Icon(Icons.route_rounded, size: 16, color: AppColors.primaryGold),
              const SizedBox(width: 6),
              Text(
                AppStrings.routeSanaaAden,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Budget vs best price chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'الميزانية: 450,000 ر.ي',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0x2E10B981),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'وفر حتى 40,000 ر.ي',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
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

  /// Filter Chips Row
  Widget _buildFilterBar(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip('الكل (${_offers.length})', OffersFilter.all, isDark),
          const SizedBox(width: 8),
          _buildFilterChip(AppStrings.filterLowestPrice, OffersFilter.lowestPrice, isDark),
          const SizedBox(width: 8),
          _buildFilterChip(AppStrings.filterHighestRating, OffersFilter.highestRating, isDark),
          const SizedBox(width: 8),
          _buildFilterChip(AppStrings.filterFastestPickup, OffersFilter.fastest, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, OffersFilter filter, bool isDark) {
    final isSelected = _currentFilter == filter;
    return InkWell(
      onTap: () => setState(() => _currentFilter = filter),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected
                ? const Color(0xFF0F172A)
                : (isDark ? AppColors.textWhite : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  /// Individual Driver Offer Card
  Widget _buildOfferCard(DriverOffer offer, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: offer.isBestPrice
              ? AppColors.primaryGold.withValues(alpha: 0.5)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0)),
          width: offer.isBestPrice ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top row: Driver Avatar, Name, Rating, Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E3A5F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: offer.isVerified
                        ? AppColors.primaryGold
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    offer.driverName.substring(0, 1),
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Name & Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            offer.driverName,
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textWhite
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (offer.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              size: 15, color: Color(0xFF3B82F6)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 15, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          '${offer.rating}',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textWhite
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${offer.tripsCount} رحلة)',
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

              // Highlight Badge
              if (offer.isBestPrice)
                _buildBadge(AppStrings.bestPriceBadge, AppColors.primaryGold, isDark)
              else if (offer.isHighestRated)
                _buildBadge(AppStrings.topRatedBadge, const Color(0xFF3B82F6), isDark)
              else if (offer.isFastest)
                _buildBadge(AppStrings.fastestBadge, AppColors.success, isDark),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Vehicle Info Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined,
                    size: 16, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${offer.vehicleName} • ${offer.vehiclePlate}',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textWhite : const Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Timing row
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 15, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                'التحميل: ${offer.pickupTimeText}',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              if (offer.hasInsurance) ...[
                const Icon(Icons.shield_outlined,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  'تأمين حمولة',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // 4. Driver Notes
          if (offer.notes.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x33F59E0B)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 0.8,
                ),
              ),
              child: Text(
                '"${offer.notes}"',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textWhite : const Color(0xFF92400E),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 5. Price & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Price
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'عرض السعر:',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '${offer.formattedPrice} ر.ي',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Accept Button
                  ElevatedButton.icon(
                    onPressed: () => _showAcceptConfirmationModal(offer),
                    icon: const Icon(Icons.check_rounded, size: 14),
                    label: Text(
                      AppStrings.acceptOfferBtn,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد عروض تطابق الفلتر المحدد',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}
