import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/buttons/hamula_button.dart';
import '../../domain/models/cargo_card_item.dart';
import '../../domain/models/transport_order_draft.dart';
import '../widgets/location_map_picker_sheet.dart';
import '../widgets/order_published_modal_sheet.dart';
import '../widgets/review_order_modal_sheet.dart';

/// Screen representing the 7-Card Transport Order Creation form
class MerchantCreateOrderScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onAddNewCargo;
  final VoidCallback? onSelectOffice;
  final VoidCallback? onSelectDriver;
  final ValueChanged<TransportOrderDraft>? onSubmitOrder;
  final VoidCallback? onOrderPublishedHome;
  final VoidCallback? onOrderPublishedOffers;
  final DriverProfile? initialDriver;
  final TransportOffice? initialOffice;

  const MerchantCreateOrderScreen({
    super.key,
    this.onBack,
    this.onAddNewCargo,
    this.onSelectOffice,
    this.onSelectDriver,
    this.onSubmitOrder,
    this.onOrderPublishedHome,
    this.onOrderPublishedOffers,
    this.initialDriver,
    this.initialOffice,
  });

  @override
  State<MerchantCreateOrderScreen> createState() =>
      _MerchantCreateOrderScreenState();
}

class _MerchantCreateOrderScreenState extends State<MerchantCreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Locations
  String _originCity = 'صنعاء';
  String _destCity = 'عدن';
  late final TextEditingController _originDetailAddressController;
  late final TextEditingController _destDetailAddressController;
  double? _originLat = 15.3340;
  double? _originLng = 44.1870;
  double? _destLat = 12.7870;
  double? _destLng = 44.9850;

  // Cargo selection
  late List<CargoCardItem> _availableCargos;
  CargoCardItem? _selectedCargo;

  // Requirements
  String _vehicleType = 'شاحنة';
  final _loadingDateController = TextEditingController(text: '2026/09/22');
  String _loadingTime = '08:00 صباحاً';
  ScheduleFlexibility _flexibility = ScheduleFlexibility.exact;

  // Budget
  final _minBudgetController = TextEditingController(text: '400,000');
  final _maxBudgetController = TextEditingController(text: '500,000');
  bool _isBudgetNegotiable = true;

  // Publish Target
  PublishTarget _target = PublishTarget.specificDriver;
  DriverProfile? _selectedDriver;
  TransportOffice? _selectedOffice;

  // Additional Info & Contact
  final _notesController = TextEditingController();
  ContactMethod _contactMethod = ContactMethod.whatsapp;
  final _phoneController = TextEditingController(text: '77 123 4567');

  bool _showValidationAlert = false;

  static const List<String> _cities = [
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'المكلا',
    'مأرب',
    'إب',
    'ذمار',
  ];

  static const List<String> _vehicleTypes = [
    'شاحنة',
    'قاطرة',
    'دينا',
    'شاحنة تبريد',
    'قلاب',
    'صهريج',
  ];

  static const List<String> _loadingTimes = [
    '08:00 صباحاً',
    '12:00 ظهراً',
    '04:00 عصراً',
    '08:00 مساءً',
  ];

  @override
  void initState() {
    super.initState();
    _originDetailAddressController = TextEditingController(
      text: 'صنعاء — شارع الستين الجنوبي، جوار محطة الأمانة ومخازن الأمل رقم 4',
    );
    _destDetailAddressController = TextEditingController(
      text: 'عدن — مديرية المعلا، ميناء عدن الدولي، مستودع الحاويات بوابه 2',
    );
    _availableCargos = List.from(CargoCardItem.demoCargos);
    _selectedCargo = _availableCargos.isNotEmpty ? _availableCargos.first : null;
    _selectedDriver = widget.initialDriver ?? DriverProfile.demoDriver;
    _selectedOffice = widget.initialOffice ?? TransportOffice.demoOffices.first;
  }

  @override
  void dispose() {
    _originDetailAddressController.dispose();
    _destDetailAddressController.dispose();
    _loadingDateController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _openLocationMapPicker(bool isOrigin) async {
    final result = await LocationMapPickerSheet.show(
      context,
      initialCity: isOrigin ? _originCity : _destCity,
      initialDetail: isOrigin
          ? _originDetailAddressController.text.trim()
          : _destDetailAddressController.text.trim(),
      isOrigin: isOrigin,
    );
    if (result != null) {
      setState(() {
        if (isOrigin) {
          _originCity = result.city;
          _originDetailAddressController.text = result.detailedAddress;
          _originLat = result.latitude;
          _originLng = result.longitude;
        } else {
          _destCity = result.city;
          _destDetailAddressController.text = result.detailedAddress;
          _destLat = result.latitude;
          _destLng = result.longitude;
        }
      });
    }
  }

  void _handleSubmit() {
    if (_selectedCargo == null ||
        _minBudgetController.text.trim().isEmpty ||
        _maxBudgetController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      setState(() => _showValidationAlert = true);
      return;
    }

    setState(() => _showValidationAlert = false);

    final draft = TransportOrderDraft(
      originCity: _originCity,
      destCity: _destCity,
      originAddressDetail: _originDetailAddressController.text.trim(),
      destAddressDetail: _destDetailAddressController.text.trim(),
      originLatitude: _originLat,
      originLongitude: _originLng,
      destLatitude: _destLat,
      destLongitude: _destLng,
      cargo: _selectedCargo!,
      vehicleType: _vehicleType,
      loadingDate: _loadingDateController.text.trim(),
      loadingTime: _loadingTime,
      flexibility: _flexibility,
      minBudget: _minBudgetController.text.trim(),
      maxBudget: _maxBudgetController.text.trim(),
      isBudgetNegotiable: _isBudgetNegotiable,
      target: _target,
      selectedDriver: _target == PublishTarget.specificDriver ? _selectedDriver : null,
      selectedOffice: _target == PublishTarget.specificOffice ? _selectedOffice : null,
      notes: _notesController.text.trim(),
      contactMethod: _contactMethod,
      phone: _phoneController.text.trim(),
    );

    ReviewOrderModalSheet.show(
      context,
      order: draft,
      onConfirm: () {
        widget.onSubmitOrder?.call(draft);
        OrderPublishedModalSheet.show(
          context,
          orderId: 'ORD-5542',
          routeSummary: '${draft.originCity} ← ${draft.destCity}',
          onReturnHome: () => widget.onOrderPublishedHome?.call(),
          onViewOffers: () => widget.onOrderPublishedOffers?.call(),
        );
      },
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
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Column(
                children: [
                  // 1. Screen Header
                  _buildHeader(isDark),

                  // 2. Scrollable 7-Card Form
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Validation Alert Banner
                            if (_showValidationAlert) ...[
                              _buildValidationBanner(),
                              const SizedBox(height: 12),
                            ],

                            // Card 1 — مواقع النقل
                            _buildLocationsCard(isDark),
                            const SizedBox(height: 14),

                            // Card 2 — الحمولة المطلوبة
                            _buildCargoCard(isDark),
                            const SizedBox(height: 14),

                            // Card 3 — متطلبات النقل
                            _buildRequirementsCard(isDark),
                            const SizedBox(height: 14),

                            // Card 4 — الميزانية المتوقعة للنقل
                            _buildBudgetCard(isDark),
                            const SizedBox(height: 14),

                            // Card 5 — نشر الطلب إلى
                            _buildPublishTargetCard(isDark),
                            const SizedBox(height: 14),

                            // Card 6 — معلومات إضافية
                            _buildNotesCard(isDark),
                            const SizedBox(height: 14),

                            // Card 7 — معلومات التواصل
                            _buildContactCard(isDark),
                            const SizedBox(height: 20),

                            // Submit Primary Action Button
                            HamulaButton(
                              label: AppStrings.submitTransportOrderBtn,
                              onPressed: _handleSubmit,
                              variant: HamulaButtonVariant.primary,
                              size: HamulaButtonSize.lg,
                              icon: const Icon(Icons.send_rounded, size: 18),
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
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderLight,
          ),
        ),
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
                  AppStrings.createOrderTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                ),
                Text(
                  AppStrings.createOrderSubtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 20, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.orderValidationMissing,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({
    required String title,
    required int stepNumber,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // --- CARD 1: مواقع النقل ---
  Widget _buildLocationsCard(bool isDark) {
    return _buildCardContainer(
      title: AppStrings.orderLocationsTitle,
      stepNumber: 1,
      isDark: isDark,
      child: Column(
        children: [
          // Origin City & Detailed Address
          _buildLocationSelector(
            label: AppStrings.originLocationLabel,
            value: _originCity,
            detailController: _originDetailAddressController,
            isOrigin: true,
            lat: _originLat,
            lng: _originLng,
            onChanged: (val) {
              if (val != null) setState(() => _originCity = val);
            },
            onPickMap: () => _openLocationMapPicker(true),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Destination City & Detailed Address
          _buildLocationSelector(
            label: AppStrings.destLocationLabel,
            value: _destCity,
            detailController: _destDetailAddressController,
            isOrigin: false,
            lat: _destLat,
            lng: _destLng,
            onChanged: (val) {
              if (val != null) setState(() => _destCity = val);
            },
            onPickMap: () => _openLocationMapPicker(false),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Miniature Route Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x660F172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.borderLight,
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.route_rounded,
                        size: 18, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Text(
                      '$_originCity ← $_destCity',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${AppStrings.routeDistanceEstimate}  •  ${AppStrings.routeDurationEstimate}',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 11,
                    color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector({
    required String label,
    required String value,
    required TextEditingController detailController,
    required bool isOrigin,
    required double? lat,
    required double? lng,
    required ValueChanged<String?> onChanged,
    required VoidCallback onPickMap,
    required bool isDark,
  }) {
    final themeColor =
        isOrigin ? const Color(0xFF2563EB) : AppColors.primaryGold;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x660F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon, Label & Map Picker Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 19,
                    color: themeColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('*', style: TextStyle(color: AppColors.error)),
                ],
              ),
              InkWell(
                onTap: onPickMap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: themeColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_rounded, size: 14, color: themeColor),
                      const SizedBox(width: 5),
                      Text(
                        'تحديد من الخريطة',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // City Dropdown Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.borderLight,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                ),
                items: _cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text('المحافظة: $city، اليمن'),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Detailed Text Input Field (كتابة المكان المحدد بشكل موضح)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.borderLight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.edit_location_alt_rounded,
                    size: 16,
                    color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: detailController,
                    maxLines: 2,
                    minLines: 1,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: isOrigin
                          ? 'اكتب اسم الشارع، المعلم، رقم الهنجر أو المستودع بدقة...'
                          : 'اكتب عنوان نقطة التفريغ، المستودع، أو رصيف الميناء بدقة...',
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

          // Coordinates indicator chip if available
          if (lat != null && lng != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.gps_fixed_rounded,
                    size: 11, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  'إحداثيات GPS: ${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSubtle
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- CARD 2: الحمولة المطلوبة ---
  Widget _buildCargoCard(bool isDark) {
    return _buildCardContainer(
      title: AppStrings.requestedCargoTitle,
      stepNumber: 2,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Cargo from Mine
          DropdownButtonFormField<CargoCardItem>(
            initialValue: _selectedCargo,
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
            decoration: InputDecoration(
              labelText: AppStrings.selectCargoFromMine,
              prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
            ),
            items: _availableCargos.map((cargo) {
              return DropdownMenuItem(
                value: cargo,
                child: Text('${cargo.name} (${cargo.weight})'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedCargo = val),
          ),
          const SizedBox(height: 12),

          // Selected Cargo Preview
          if (_selectedCargo != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x660F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 52,
                      height: 52,
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      child: _selectedCargo!.imageAsset != null
                          ? Image.asset(
                              _selectedCargo!.imageAsset!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.inventory_2_rounded,
                              color: AppColors.primaryGold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCargo!.name,
                          style: GoogleFonts.cairo(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                        ),
                        Text(
                          _selectedCargo!.category,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSubtle
                                : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _selectedCargo!.weight,
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '|  ${_selectedCargo!.quantity}',
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 11.5,
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
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => setState(() => _selectedCargo = null),
                    tooltip: 'إزالة',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Add New Cargo bar button
          OutlinedButton.icon(
            onPressed: widget.onAddNewCargo,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              AppStrings.addNewCargoBtn,
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              foregroundColor: AppColors.primaryGold,
              side: const BorderSide(color: AppColors.primaryGold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD 3: متطلبات النقل ---
  Widget _buildRequirementsCard(bool isDark) {
    return _buildCardContainer(
      title: AppStrings.transportRequirementsTitle,
      stepNumber: 3,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Vehicle Type (Right in RTL)
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _vehicleType,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                  decoration: InputDecoration(
                    labelText: AppStrings.vehicleTypeLabel,
                    prefixIcon: const Icon(Icons.local_shipping_outlined, size: 18),
                  ),
                  items: _vehicleTypes.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _vehicleType = val);
                  },
                ),
              ),
              const SizedBox(width: 10),

              // Loading Date (Left in RTL)
              Expanded(
                child: TextFormField(
                  controller: _loadingDateController,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                  decoration: InputDecoration(
                    labelText: AppStrings.loadingDateLabel,
                    prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Loading Time
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _loadingTime,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                  decoration: InputDecoration(
                    labelText: AppStrings.loadingTimeLabel,
                    prefixIcon: const Icon(Icons.access_time_rounded, size: 18),
                  ),
                  items: _loadingTimes.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _loadingTime = val);
                  },
                ),
              ),
              const SizedBox(width: 10),

              // Flexibility Pills
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.scheduleFlexibilityLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFlexPill(
                            label: AppStrings.flexExact,
                            flex: ScheduleFlexibility.exact,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 4),
                          _buildFlexPill(
                            label: AppStrings.flexPlusMinus6,
                            flex: ScheduleFlexibility.plusMinus6Hours,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 4),
                          _buildFlexPill(
                            label: AppStrings.flexPlusMinus12,
                            flex: ScheduleFlexibility.plusMinus12Hours,
                            isDark: isDark,
                          ),
                        ],
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

  Widget _buildFlexPill({
    required String label,
    required ScheduleFlexibility flex,
    required bool isDark,
  }) {
    final isSelected = _flexibility == flex;
    return InkWell(
      onTap: () => setState(() => _flexibility = flex),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : (isDark ? const Color(0x660F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.black
                : (isDark ? AppColors.textWhite : AppColors.textMainLight),
          ),
        ),
      ),
    );
  }

  // --- CARD 4: الميزانية المتوقعة للنقل ---
  Widget _buildBudgetCard(bool isDark) {
    return _buildCardContainer(
      title: AppStrings.expectedBudgetTitle,
      stepNumber: 4,
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              // Min Budget
              Expanded(
                child: TextFormField(
                  controller: _minBudgetController,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                  decoration: InputDecoration(
                    labelText: AppStrings.budgetMinLabel,
                    suffixText: AppStrings.yemeniRialUnit,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Max Budget
              Expanded(
                child: TextFormField(
                  controller: _maxBudgetController,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                  decoration: InputDecoration(
                    labelText: AppStrings.budgetMaxLabel,
                    suffixText: AppStrings.yemeniRialUnit,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Negotiable Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.primaryGold),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.budgetNegotiable,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isBudgetNegotiable,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primaryGold,
                onChanged: (val) => setState(() => _isBudgetNegotiable = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- CARD 5: نشر الطلب إلى ---
  Widget _buildPublishTargetCard(bool isDark) {
    return _buildCardContainer(
      title: AppStrings.publishOrderToTitle,
      stepNumber: 5,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4-Grid Target Selector
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.6,
            children: [
              _buildTargetItem(
                target: PublishTarget.allDrivers,
                label: AppStrings.targetAllDrivers,
                icon: Icons.groups_rounded,
                isDark: isDark,
              ),
              _buildTargetItem(
                target: PublishTarget.specificDriver,
                label: AppStrings.targetSpecificDriver,
                icon: Icons.badge_outlined,
                isDark: isDark,
              ),
              _buildTargetItem(
                target: PublishTarget.allOffices,
                label: AppStrings.targetAllOffices,
                icon: Icons.domain_rounded,
                isDark: isDark,
              ),
              _buildTargetItem(
                target: PublishTarget.specificOffice,
                label: AppStrings.targetSpecificOffice,
                icon: Icons.business_rounded,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Selected Driver Card
          if (_target == PublishTarget.specificDriver) ...[
            if (_selectedDriver != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x660F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.primaryGold, size: 26),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _selectedDriver!.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.textMainLight,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'موثق',
                                  style: GoogleFonts.cairo(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '🟢 ${_selectedDriver!.vehicleType} · ${_selectedDriver!.capacity} · ${AppStrings.onlineNow}',
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
                    TextButton(
                      onPressed: widget.onSelectDriver,
                      child: Text(
                        AppStrings.changeBtn,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: widget.onSelectDriver,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: Text(AppStrings.chooseDriverFromMap),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
            ],
          ],

          // Selected Office Card
          if (_target == PublishTarget.specificOffice) ...[
            if (_selectedOffice != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x660F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.business_rounded,
                          color: AppColors.primaryGold, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _selectedOffice!.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.textMainLight,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'موثق',
                                  style: GoogleFonts.cairo(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_selectedOffice!.city} · ${_selectedOffice!.services}',
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
                    TextButton(
                      onPressed: widget.onSelectOffice,
                      child: Text(
                        AppStrings.changeBtn,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: widget.onSelectOffice,
                icon: const Icon(Icons.business_rounded, size: 18),
                label: Text(AppStrings.chooseOfficeBtn),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTargetItem({
    required PublishTarget target,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _target == target;
    return InkWell(
      onTap: () => setState(() => _target = target),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0x33F59E0B) : const Color(0xFFFEF3C7))
              : (isDark ? const Color(0x660F172A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.borderLight),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.primaryGold
                  : (isDark ? AppColors.textSubtle : AppColors.textMutedLight),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryGold
                      : (isDark ? AppColors.textWhite : AppColors.textMainLight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CARD 6: معلومات إضافية ---
  Widget _buildNotesCard(bool isDark) {
    return _buildCardContainer(
      title: AppStrings.additionalInfoTitle,
      stepNumber: 6,
      isDark: isDark,
      child: TextFormField(
        controller: _notesController,
        maxLines: 3,
        style: GoogleFonts.cairo(
          fontSize: 12.5,
          color: isDark ? AppColors.textWhite : AppColors.textMainLight,
        ),
        decoration: InputDecoration(
          hintText: AppStrings.orderNotesHint,
        ),
      ),
    );
  }

  // --- CARD 7: معلومات التواصل ---
  Widget _buildContactCard(bool isDark) {
    return _buildCardContainer(
      title: AppStrings.contactInfoTitle,
      stepNumber: 7,
      isDark: isDark,
      child: Row(
        children: [
          // Preferred Method
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.preferredContactLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildContactPill(
                      label: AppStrings.contactWhatsapp,
                      method: ContactMethod.whatsapp,
                      icon: Icons.chat_bubble_outline_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    _buildContactPill(
                      label: AppStrings.contactCall,
                      method: ContactMethod.call,
                      icon: Icons.phone_outlined,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Phone
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              ),
              decoration: InputDecoration(
                labelText: AppStrings.contactPhoneLabel,
                prefixIcon: const Icon(Icons.phone_outlined, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactPill({
    required String label,
    required ContactMethod method,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _contactMethod == method;
    return InkWell(
      onTap: () => setState(() => _contactMethod = method),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0x332563EB) : const Color(0xFFDBEAFE))
              : (isDark ? const Color(0x660F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.borderLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : (isDark ? AppColors.textSubtle : AppColors.textMutedLight),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : (isDark ? AppColors.textWhite : AppColors.textMainLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
