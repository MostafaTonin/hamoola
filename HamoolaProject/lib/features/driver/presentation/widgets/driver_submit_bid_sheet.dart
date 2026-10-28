import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/cargo_bid_opportunity.dart';
import '../../domain/models/driver_simulation_store.dart';

/// Available Currencies for Driver Bidding
enum BidCurrency {
  yer('YER', 'ريال يمني', 'ر.ي'),
  sar('SAR', 'ريال سعودي', 'ر.س'),
  usd('USD', 'دولار أمريكي', '\$');

  final String code;
  final String label;
  final String symbol;

  const BidCurrency(this.code, this.label, this.symbol);
}

/// Interactive modal sheet implementing the right reference image:
/// "تقديم عرض سعر" with Order Summary, Amount + 3-Currency Selector Dropdown,
/// Notes with live 0/500 char counter, pre-submit alert, and the mandatory
/// intermediate "مراجعة العرض قبل الإرسال" review step.
class DriverSubmitBidSheet extends StatefulWidget {
  final CargoBidOpportunity cargo;
  final ValueChanged<int>? onBidSubmitted;

  const DriverSubmitBidSheet({
    super.key,
    required this.cargo,
    this.onBidSubmitted,
  });

  static Future<bool?> show(
    BuildContext context, {
    required CargoBidOpportunity cargo,
    ValueChanged<int>? onBidSubmitted,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (_) => DriverSubmitBidSheet(
        cargo: cargo,
        onBidSubmitted: onBidSubmitted,
      ),
    );
  }

  @override
  State<DriverSubmitBidSheet> createState() => _DriverSubmitBidSheetState();
}

class _DriverSubmitBidSheetState extends State<DriverSubmitBidSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  BidCurrency _selectedCurrency = BidCurrency.yer;
  String? _amountErrorText;
  int _charCount = 0;
  bool _isReviewStep = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default to target budget if available, or empty
    final initialPrice = widget.cargo.targetBudgetYmr > 0
        ? widget.cargo.targetBudgetYmr.toString()
        : '';
    _amountController = TextEditingController(text: initialPrice);
    _notesController = TextEditingController();

    _notesController.addListener(() {
      if (mounted) {
        setState(() {
          _charCount = _notesController.text.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Parses input that might contain Arabic-Indic or English digits
  int? _parseAmount(String input) {
    if (input.trim().isEmpty) return null;

    // Convert Arabic-Indic numerals to standard digits
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String normalized = input.replaceAll(',', '').replaceAll(' ', '').trim();
    for (int i = 0; i < arabicIndic.length; i++) {
      normalized = normalized.replaceAll(arabicIndic[i], i.toString());
    }

    return int.tryParse(normalized);
  }

  void _validateAndReview() {
    final parsed = _parseAmount(_amountController.text);
    if (parsed == null || parsed <= 0) {
      setState(() {
        _amountErrorText = 'يرجى إدخال مبلغ صحيح أكبر من صفر';
      });
      return;
    }

    setState(() {
      _amountErrorText = null;
      _isReviewStep = true;
    });
  }

  void _confirmAndSubmit() {
    final parsed = _parseAmount(_amountController.text);
    if (parsed == null || parsed <= 0) return;

    final store = DriverSimulationStore.instance;

    // Duplicate bid check
    if (store.hasBidOnCargo(widget.cargo.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لقد قمت بتقديم عرض سعر على هذا الطلب مسبقاً!',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(false);
      return;
    }

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      final success = store.submitBid(
        cargo: widget.cargo,
        amount: parsed,
        currencyCode: _selectedCurrency.code,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      widget.onBidSubmitted?.call(parsed);
      Navigator.of(context).pop(success);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تم إرسال عرضك بمبلغ $parsed ${_selectedCurrency.label} بنجاح!',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: EdgeInsets.only(
          top: 12,
          left: 18,
          right: 18,
          bottom: 18 + bottomInset,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isReviewStep
              ? _buildReviewView(isDark)
              : _buildFormView(isDark),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Form View (Right Reference Screen)
  // ---------------------------------------------------------------------------
  Widget _buildFormView(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('form_view'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 46,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header: Close Icon + Title with Tag Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'إغلاق',
              ),
              Row(
                children: [
                  Text(
                    'تقديم عرض سعر',
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Order Summary Card
          _buildOrderSummaryCard(isDark),
          const SizedBox(height: 16),

          // Bid Value & Currency Section
          _buildBidAmountSection(isDark),
          const SizedBox(height: 16),

          // Additional Notes Section (Max 500 chars)
          _buildNotesSection(isDark),
          const SizedBox(height: 16),

          // Pre-submission Alert Notice
          _buildPreSubmitAlert(isDark),
          const SizedBox(height: 20),

          // Action Buttons: Review Bid (Primary) & Cancel (Secondary)
          ElevatedButton(
            onPressed: _validateAndReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  'مراجعة العرض',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Order summary mini card matching the right reference image
  Widget _buildOrderSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cargo Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: Image.asset(
                    widget.cargo.imagesList.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title and Order Number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.cargo.isPrivate ? 'طلب خاص' : 'طلب عام',
                            style: GoogleFonts.cairo(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                        Text(
                          'رقم الطلب: ${widget.cargo.id}',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.cargo.title,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Pickup Location
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.cargo.pickupLocationDisplay,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Dropoff Location
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.cargo.dropoffLocationDisplay,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
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
            ],
          ),
          const Divider(height: 16),
          // Weight and Distance footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Icon(Icons.fitness_center_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.cargo.weightTons} طن',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 14, color: const Color(0xFFE2E8F0)),
              Row(
                children: [
                  const Icon(Icons.route_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.cargo.distanceKm} كيلومتر',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
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

  /// Bid amount section with interactive 3-currency selector
  Widget _buildBidAmountSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            const Icon(Icons.payments_rounded, color: Color(0xFF2563EB), size: 18),
            const SizedBox(width: 6),
            Text(
              'قيمة العرض',
              style: GoogleFonts.cairo(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Field Label
        Row(
          children: [
            Text(
              'المبلغ الإجمالي للنقل',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 2),
            const Text(
              ' *',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Input Box + Currency Selector Row
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _amountErrorText != null
                  ? const Color(0xFFDC2626)
                  : (isDark ? Colors.white12 : const Color(0xFFCBD5E1)),
              width: _amountErrorText != null ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Amount text input
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩,]')),
                  ],
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'أدخل المبلغ',
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 13.5,
                      color: const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (_) {
                    if (_amountErrorText != null) {
                      setState(() => _amountErrorText = null);
                    }
                  },
                ),
              ),

              // Currency Selector Popup
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: PopupMenuButton<BidCurrency>(
                  initialValue: _selectedCurrency,
                  tooltip: 'اختر العملة',
                  onSelected: (currency) {
                    setState(() {
                      _selectedCurrency = currency;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: BidCurrency.yer,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الريال اليمني (YER)',
                              style: GoogleFonts.cairo(
                                fontWeight: _selectedCurrency == BidCurrency.yer
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (_selectedCurrency == BidCurrency.yer)
                              const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 18),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: BidCurrency.sar,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الريال السعودي (SAR)',
                              style: GoogleFonts.cairo(
                                fontWeight: _selectedCurrency == BidCurrency.sar
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (_selectedCurrency == BidCurrency.sar)
                              const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 18),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: BidCurrency.usd,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الدولار الأمريكي (USD)',
                              style: GoogleFonts.cairo(
                                fontWeight: _selectedCurrency == BidCurrency.usd
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (_selectedCurrency == BidCurrency.usd)
                              const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedCurrency.label,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Error message if validation fails
        if (_amountErrorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: Text(
              _amountErrorText!,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

        // Subtext description
        const SizedBox(height: 6),
        Text(
          'أدخل المبلغ الإجمالي الذي تقترحه لتنفيذ عملية النقل.',
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  /// Additional notes section (optional, max 500 chars with live counter)
  Widget _buildNotesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2563EB), size: 17),
            const SizedBox(width: 6),
            Text(
              'ملاحظات إضافية (اختياري)',
              style: GoogleFonts.cairo(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _notesController,
                maxLength: 500,
                maxLines: 3,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'أضف أي ملاحظات أو شروط خاصة بعرضك...',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 12.5,
                    color: const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  counterText: '', // Hide default counter
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$_charCount / 500',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Light blue alert card matching the right reference image
  Widget _buildPreSubmitAlert(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2563EB),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قبل الإرسال',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'تأكد من ملاءمة الحمولة لناقلتك وقدرتك على تنفيذ متطلبات الطلب. السعر الذي تقدمه هو السعر الإجمالي للنقل.',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    height: 1.45,
                    color: isDark ? Colors.white70 : const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Review View (Mandatory Step before Final Submission)
  // ---------------------------------------------------------------------------
  Widget _buildReviewView(bool isDark) {
    final parsed = _parseAmount(_amountController.text) ?? 0;
    final notes = _notesController.text.trim();

    return SingleChildScrollView(
      key: const ValueKey('review_view'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onPressed: () => setState(() => _isReviewStep = false),
                tooltip: 'تعديل العرض',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'مراجعة العرض قبل الإرسال',
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Order details review card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewRow('رقم الطلب', widget.cargo.id),
                const Divider(height: 16),
                _buildReviewRow('عنوان الحمولة', widget.cargo.title),
                const Divider(height: 16),
                _buildReviewRow(
                  'مسار النقل',
                  '${widget.cargo.pickupLocationDisplay} ← ${widget.cargo.dropoffLocationDisplay}',
                ),
                const Divider(height: 16),
                _buildReviewRow(
                  'المسافة والوزن',
                  '${widget.cargo.distanceKm} كم • ${widget.cargo.weightTons} طن',
                ),
                const Divider(height: 16),
                // Highlighted Bid Amount Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إجمالي قيمة العرض:',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$parsed ${_selectedCurrency.label}',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF16A34A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (notes.isNotEmpty) ...[
                  const Divider(height: 16),
                  Text(
                    'الملاحظات المرفقة:',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notes,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF334155),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Confirmation notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: Color(0xFFB45309), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تأكيدك يعني التزامك بتقديم خدمة النقل وفق الشروط والمبلغ الموضح أعلاه.',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: const Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Buttons: Confirm & Submit (Primary) / Edit Bid (Secondary)
          ElevatedButton(
            onPressed: _isSubmitting ? null : _confirmAndSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'تأكيد وإرسال العرض',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => setState(() => _isReviewStep = false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'تعديل العرض',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
