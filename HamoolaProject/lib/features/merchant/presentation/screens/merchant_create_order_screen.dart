import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cargo_card_item.dart';
import '../../domain/models/merchant_order.dart';
import '../../domain/models/merchant_simulation_store.dart';
import '../../domain/models/transport_order_draft.dart';
import '../widgets/location_map_picker_sheet.dart';
import '../widgets/order_published_modal_sheet.dart';
import '../widgets/publish_target_modal_sheet.dart';
import 'merchant_create_cargo_screen.dart';
import 'merchant_add_balance_screen.dart';
import 'select_driver_screen.dart';
import 'select_office_screen.dart';

/// Screen representing the single continuous scrollable Transport Order Creation form
/// Strictly titled «إضافة طلب» matching the Hamoola application specifications and approved design.
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
  final CargoCardItem? initialCargo;

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
    this.initialCargo,
  });

  @override
  State<MerchantCreateOrderScreen> createState() =>
      _MerchantCreateOrderScreenState();
}

class _MerchantCreateOrderScreenState extends State<MerchantCreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Section 1: Locations
  String _originCity = 'صنعاء';
  String _destCity = 'الرياض';
  late final TextEditingController _originDetailAddressController;
  late final TextEditingController _destDetailAddressController;
  double? _originLat = 15.3694;
  double? _originLng = 44.1910;
  double? _destLat = 24.7136;
  double? _destLng = 46.6753;

  // Section 2: Cargo selection
  late List<CargoCardItem> _availableCargos;
  CargoCardItem? _selectedCargo;
  String? _cargoError;

  // Section 3: Requirements
  String _vehicleType = 'شاحنة';
  final _loadingDateController = TextEditingController(text: '2026/10/15');
  String _loadingTime = '08:00 صباحاً';
  ScheduleFlexibility _flexibility = ScheduleFlexibility.plusMinus6Hours;

  // Section 4: Budget
  final _minBudgetController = TextEditingController(text: '2,500');
  final _maxBudgetController = TextEditingController(text: '4,000');
  static const String _budgetCurrency = 'ريال سعودي';
  String? _budgetError;

  // Section 5: Notes (Optional, with 0/500 char limit & NO contact fields)
  final _notesController = TextEditingController();
  static const int _maxNotesLength = 500;

  // Validation feedback
  String? _generalValidationError;
  bool _isPublishing = false;

  static const List<String> _cities = [
    'صنعاء',
    'الرياض',
    'جدة',
    'الدمام',
    'عدن',
    'تعز',
    'الحديدة',
    'المكلا',
    'مأرب',
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
      text: 'الرياض — المدينة الصناعية الثانية، المستودع المركزي رقم 12',
    );

    final storeCargos = MerchantSimulationStore.instance.cargos;
    _availableCargos = List.from(
      storeCargos.isNotEmpty ? storeCargos : CargoCardItem.demoCargos,
    );

    if (widget.initialCargo != null) {
      final existingIndex = _availableCargos.indexWhere(
        (c) => c.id == widget.initialCargo!.id,
      );
      if (existingIndex >= 0) {
        _selectedCargo = _availableCargos[existingIndex];
      } else {
        _availableCargos.insert(0, widget.initialCargo!);
        _selectedCargo = widget.initialCargo;
      }
    } else {
      _selectedCargo = _availableCargos.isNotEmpty ? _availableCargos.first : null;
    }

    _notesController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _originDetailAddressController.dispose();
    _destDetailAddressController.dispose();
    _loadingDateController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Location Map Picker Sheet ---
  Future<void> _openLocationMapPicker(bool isOrigin) async {
    final result = await LocationMapPickerSheet.show(
      context,
      initialCity: isOrigin ? _originCity : _destCity,
      initialDetail: isOrigin
          ? _originDetailAddressController.text.trim()
          : _destDetailAddressController.text.trim(),
      isOrigin: isOrigin,
    );
    if (result != null && mounted) {
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

  // --- Full Route Map Modal ---
  void _openFullRouteMap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? AppColors.navyDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المسار الجغرافي الكامل للرحلة',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _RouteMapCanvasPainter(
                            originCity: _originCity,
                            destCity: _destCity,
                            isDark: isDark,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'نقطة الانطلاق',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: AppColors.textMutedLight,
                                    ),
                                  ),
                                  Text(
                                    _originCity,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Color(0xFF2563EB)),
                              Column(
                                children: [
                                  Text(
                                    'نقطة الوصول',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: AppColors.textMutedLight,
                                    ),
                                  ),
                                  Text(
                                    _destCity,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Add Cargo Flow (Preserves all entered data) ---
  Future<void> _openAddCargoFlow() async {
    final result = await Navigator.of(context).push<CargoCardItem>(
      MaterialPageRoute(
        builder: (_) => MerchantCreateCargoScreen(
          onBack: () => Navigator.of(context).pop(),
          onSubmitCargo: (cargo) {
            CargoCardItem.demoCargos.insert(0, cargo);
            Navigator.of(context).pop(cargo);
          },
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (!_availableCargos.any((c) => c.id == result.id)) {
          _availableCargos.insert(0, result);
        }
        _selectedCargo = result;
        _cargoError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة الحمولة بنجاح: ${result.name} وتم تحديدها للطلب'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // --- Validation ---
  bool _validateForm() {
    String? error;
    String? cargoErr;
    String? budgetErr;

    if (_selectedCargo == null) {
      cargoErr = 'يرجى اختيار الحمولة المطلوب نقلها أو إضافة حمولة جديدة.';
      error = cargoErr;
    }

    final minBudget = double.tryParse(_minBudgetController.text.replaceAll(',', ''));
    final maxBudget = double.tryParse(_maxBudgetController.text.replaceAll(',', ''));

    if (minBudget != null && maxBudget != null && minBudget > maxBudget) {
      budgetErr = 'الحد الأدنى للميزانية لا يمكن أن يتجاوز الحد الأعلى.';
      error = budgetErr;
    }

    setState(() {
      _cargoError = cargoErr;
      _budgetError = budgetErr;
      _generalValidationError = error;
    });

    return error == null;
  }

  // --- Button 1: Save Draft ---
  void _handleSaveDraft() {
    final minBudgetText = _minBudgetController.text.trim();
    final maxBudgetText = _maxBudgetController.text.trim();
    final double? budgetVal =
        double.tryParse(minBudgetText.replaceAll(',', ''));

    final draftOrder = MerchantSimulationStore.instance.createDraftOrder(
      cargo: _selectedCargo,
      originCity: _originCity,
      destinationCity: _destCity,
      originAddressDetail: _originDetailAddressController.text.trim(),
      destAddressDetail: _destDetailAddressController.text.trim(),
      vehicleType: _vehicleType,
      loadingDate: _loadingDateController.text.trim(),
      loadingTime: _loadingTime,
      flexibility: _flexibility.name,
      minBudget: minBudgetText,
      maxBudget: maxBudgetText,
      expectedPrice: budgetVal,
      notes: _notesController.text.trim(),
    );

    // Also notify listeners / insert into demo orders for immediate availability
    if (!MerchantOrder.demoOrders.any((o) => o.id == draftOrder.id)) {
      MerchantOrder.demoOrders.insert(0, draftOrder);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ مسودة الطلب بنجاح برقم: ${draftOrder.id} في شاشة طلباتي'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'عرض المسودات',
          onPressed: () => widget.onOrderPublishedOffers?.call(),
        ),
      ),
    );

    widget.onSubmitOrder?.call(
      TransportOrderDraft(
        originCity: _originCity,
        destCity: _destCity,
        originAddressDetail: _originDetailAddressController.text.trim(),
        destAddressDetail: _destDetailAddressController.text.trim(),
        originLatitude: _originLat,
        originLongitude: _originLng,
        destLatitude: _destLat,
        destLongitude: _destLng,
        cargo: _selectedCargo ??
            const CargoCardItem(
              id: 'DRAFT-CARGO',
              name: 'مسودة حمولة',
              category: 'بضائع عامة',
              weight: 'غير محدد',
              quantity: '1',
              handlingRequirement: 'عادي',
              status: 'مسودة',
            ),
        vehicleType: _vehicleType,
        loadingDate: _loadingDateController.text.trim(),
        loadingTime: _loadingTime,
        flexibility: _flexibility,
        minBudget: minBudgetText,
        maxBudget: maxBudgetText,
        isBudgetNegotiable: false,
        target: PublishTarget.allDrivers,
        notes: _notesController.text.trim(),
      ),
    );
  }

  // --- Button 2: Publish Order Flow ---
  Future<void> _handlePublishOrder() async {
    if (!_validateForm()) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    final double maxBudgetVal =
        double.tryParse(_maxBudgetController.text.replaceAll(',', '')) ??
        double.tryParse(_minBudgetController.text.replaceAll(',', '')) ??
        0.0;

    final store = MerchantSimulationStore.instance;
    if (store.walletBalance < maxBudgetVal) {
      await _showInsufficientBalanceModal(
        currentBalance: store.walletBalance,
        requiredAmount: maxBudgetVal,
      );
      return;
    }

    // Open Screen 3: Independent Publish Target Modal Sheet
    final targetOption = await PublishTargetModalSheet.show(context);
    if (targetOption == null || !mounted) return;

    switch (targetOption) {
      case PublishTarget.allDrivers:
        _executeOrderPublish(
          broadcastScope: 'all_drivers',
          targetDescription: 'جميع السائقين المعتمدين',
        );
        break;

      case PublishTarget.allOffices:
        _executeOrderPublish(
          broadcastScope: 'all_offices',
          targetDescription: 'جميع مكاتب النقل المعتمدة',
        );
        break;

      case PublishTarget.specificDriver:
        // Open Screen 4: Independent Select Driver Screen
        final selectedDriver = await Navigator.of(context).push<DriverProfile>(
          MaterialPageRoute(
            builder: (_) => SelectDriverScreen(
              onBack: () => Navigator.of(context).pop(),
              onDriverSelected: (drv) => Navigator.of(context).pop(drv),
            ),
          ),
        );

        if (selectedDriver != null && mounted) {
          _executeOrderPublish(
            broadcastScope: 'driver',
            targetDriver: selectedDriver,
            targetDescription: 'السائق: ${selectedDriver.name}',
          );
        }
        break;

      case PublishTarget.specificOffice:
        // Open Select Office Screen
        final selectedOffice = await Navigator.of(context).push<TransportOffice>(
          MaterialPageRoute(
            builder: (_) => SelectOfficeScreen(
              onBack: () => Navigator.of(context).pop(),
              onOfficeSelected: (off) => Navigator.of(context).pop(off),
            ),
          ),
        );

        if (selectedOffice != null && mounted) {
          _executeOrderPublish(
            broadcastScope: 'office',
            targetOffice: selectedOffice,
            targetDescription: 'مكتب: ${selectedOffice.name}',
          );
        }
        break;
    }
  }

  void _executeOrderPublish({
    required String broadcastScope,
    required String targetDescription,
    DriverProfile? targetDriver,
    TransportOffice? targetOffice,
  }) {
    if (_isPublishing) return;
    _isPublishing = true;

    final double minBudgetVal =
        double.tryParse(_minBudgetController.text.replaceAll(',', '')) ?? 0.0;
    final double maxBudgetVal =
        double.tryParse(_maxBudgetController.text.replaceAll(',', '')) ??
        minBudgetVal;

    final store = MerchantSimulationStore.instance;
    // Strict re-check before publishing to avoid stale data
    if (store.walletBalance < maxBudgetVal) {
      _isPublishing = false;
      _showInsufficientBalanceModal(
        currentBalance: store.walletBalance,
        requiredAmount: maxBudgetVal,
      );
      return;
    }

    final newOrder = store.createOrder(
      cargo: _selectedCargo!,
      originCity: _originCity,
      destinationCity: _destCity,
      broadcastScope: broadcastScope,
      targetDriverName: targetDriver?.name,
      targetDriverPhone: targetDriver?.phone,
      targetOfficeName: targetOffice?.name,
      vehicleType: _vehicleType,
      expectedPrice: minBudgetVal > 0 ? minBudgetVal : null,
      minBudget: minBudgetVal > 0 ? minBudgetVal : null,
      maxBudget: maxBudgetVal > 0 ? maxBudgetVal : null,
      notes: _notesController.text.trim(),
    );

    if (!MerchantOrder.demoOrders.any((o) => o.id == newOrder.id)) {
      MerchantOrder.demoOrders.insert(0, newOrder);
    }

    _isPublishing = false;

    widget.onSubmitOrder?.call(
      TransportOrderDraft(
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
        isBudgetNegotiable: false,
        target: broadcastScope == 'driver'
            ? PublishTarget.specificDriver
            : (broadcastScope == 'office'
                ? PublishTarget.specificOffice
                : (broadcastScope == 'all_offices'
                    ? PublishTarget.allOffices
                    : PublishTarget.allDrivers)),
        selectedDriver: targetDriver,
        selectedOffice: targetOffice,
        notes: _notesController.text.trim(),
      ),
    );

    OrderPublishedModalSheet.show(
      context,
      orderId: newOrder.id,
      routeSummary: '$_originCity ← $_destCity',
      targetDescription: targetDescription,
      onReturnHome: () => widget.onOrderPublishedHome?.call(),
      onViewOffers: () => widget.onOrderPublishedOffers?.call(),
    );
  }

  String _formatNumber(double amount) {
    final intVal = amount.toInt();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return intVal.toString().replaceAllMapped(reg, (match) => ',');
  }

  Future<bool> _showInsufficientBalanceModal({
    required double currentBalance,
    required double requiredAmount,
  }) async {
    final deficit = requiredAmount - currentBalance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFFEF4444),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رصيد المحفظة غير كافٍ لنشر الطلب',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'يجب أن يغطي رصيدك الحد الأعلى للميزانية المحددة',
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Financial Breakdown Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildBalanceRow('الرصيد الحالي في المحفظة:', '${_formatNumber(currentBalance)} ر.ي', isDark: isDark, isHighlight: false),
                      const SizedBox(height: 8),
                      _buildBalanceRow('الحد الأعلى للميزانية المطلوبة:', '${_formatNumber(requiredAmount)} ر.ي', isDark: isDark, isHighlight: false),
                      const Divider(height: 16),
                      _buildBalanceRow(
                        'المبلغ المطلوب إيداعه (الفرق):',
                        '${_formatNumber(deficit > 0 ? deficit : 0)} ر.ي',
                        isDark: isDark,
                        isHighlight: true,
                        highlightColor: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Button 1: Add Balance (Primary)
                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop(true);
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MerchantAddBalanceScreen(
                            onClose: () => Navigator.of(context).pop(),
                            onSuccessDone: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                    label: Text(
                      'إضافة رصيد للمحفظة الآن',
                      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Button 2: Save as Draft
                SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                      _handleSaveDraft();
                    },
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text(
                      'حفظ الطلب كمسودة والعودة لاحقاً',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.textWhite : const Color(0xFF334155),
                      side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Button 3: Return to edit
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    'العودة لتعديل بيانات الطلب والميزانية',
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSubtle : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  Widget _buildBalanceRow(
    String label,
    String value, {
    required bool isDark,
    required bool isHighlight,
    Color? highlightColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight
                ? (highlightColor ?? const Color(0xFFEF4444))
                : (isDark ? AppColors.textSubtle : const Color(0xFF64748B)),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: isHighlight ? 14 : 13,
            fontWeight: FontWeight.w800,
            color: isHighlight
                ? (highlightColor ?? const Color(0xFFEF4444))
                : (isDark ? AppColors.textWhite : const Color(0xFF0F172A)),
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
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Column(
                children: [
                  // 1. Strict Screen Header: «إضافة طلب»
                  _buildHeader(isDark),

                  // 2. Single Continuous Scrollable Form
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Inline Validation Banner
                            if (_generalValidationError != null) ...[
                              _buildValidationBanner(_generalValidationError!),
                              const SizedBox(height: 12),
                            ],

                            // Card 1: مواقع النقل
                            _buildLocationsCard(isDark),
                            const SizedBox(height: 14),

                            // Card 2: الحمولة المطلوب نقلها
                            _buildCargoCard(isDark),
                            const SizedBox(height: 14),

                            // Card 3: متطلبات النقل
                            _buildRequirementsCard(isDark),
                            const SizedBox(height: 14),

                            // Card 4: الميزانية المتوقعة (اختياري)
                            _buildBudgetCard(isDark),
                            const SizedBox(height: 14),

                            // Card 5: ملاحظات إضافية (اختياري)
                            _buildNotesCard(isDark),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Bottom Sticky Action Bar matching Image 2
                  _buildBottomActionButtons(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Strict Header ---
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
                  AppStrings.createOrderTitle, // Strict: «إضافة طلب»
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
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.note_add_rounded,
              color: AppColors.primaryGold,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationBanner(String message) {
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
              message,
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
    required String subtitle,
    required int stepNumber,
    required IconData icon,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '$stepNumber. $title',
                      style: GoogleFonts.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textSubtle
                                : AppColors.textMutedLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
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

  // =========================================================================
  // CARD 1: مواقع النقل
  // =========================================================================
  Widget _buildLocationsCard(bool isDark) {
    return _buildCardContainer(
      title: 'مواقع النقل',
      subtitle: 'حدد موقع التحميل والتسليم على الخريطة',
      stepNumber: 1,
      icon: Icons.location_on_rounded,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Origin Location Input
          _buildLocationInputField(
            label: 'موقع التحميل *',
            cityValue: _originCity,
            detailController: _originDetailAddressController,
            isOrigin: true,
            onCityChanged: (val) {
              if (val != null) setState(() => _originCity = val);
            },
            onPickMap: () => _openLocationMapPicker(true),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Destination Location Input
          _buildLocationInputField(
            label: 'موقع التسليم *',
            cityValue: _destCity,
            detailController: _destDetailAddressController,
            isOrigin: false,
            onCityChanged: (val) {
              if (val != null) setState(() => _destCity = val);
            },
            onPickMap: () => _openLocationMapPicker(false),
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Mini-Map Route Card matching Image 1
          _buildMiniRouteMap(isDark),
        ],
      ),
    );
  }

  Widget _buildLocationInputField({
    required String label,
    required String cityValue,
    required TextEditingController detailController,
    required bool isOrigin,
    required ValueChanged<String?> onCityChanged,
    required VoidCallback onPickMap,
    required bool isDark,
  }) {
    final dotColor = isOrigin ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x660F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onPickMap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location_rounded, size: 14, color: AppColors.primaryGold),
                      const SizedBox(width: 4),
                      Text(
                        'الخريطة',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : AppColors.borderLight,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: cityValue,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                      items: _cities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: onCityChanged,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : AppColors.borderLight,
                    ),
                  ),
                  child: TextField(
                    controller: detailController,
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
                      hintText: 'العنوان بالتفصيل أو المعلم...',
                      hintStyle: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRouteMap(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Visual Map Canvas with Route & Pins
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RouteMapCanvasPainter(
                      originCity: _originCity,
                      destCity: _destCity,
                      isDark: isDark,
                    ),
                  ),
                ),

                // Top-Left Button: عرض المسار بالكامل
                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _openFullRouteMap,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black : Colors.white)
                              .withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.borderLight.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fullscreen_rounded,
                                size: 14, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            Text(
                              'عرض المسار الكامل',
                              style: GoogleFonts.cairo(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textMainLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Distance & Duration Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Row(
              children: [
                // Right item: Distance
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.alt_route_rounded,
                            size: 14, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المسافة التقديرية',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.textSubtle
                                    : AppColors.textMutedLight,
                              ),
                            ),
                            Text(
                              _calculateEstimatedDistance(),
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textMainLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 1,
                  height: 28,
                  color: isDark ? Colors.white12 : AppColors.borderLight,
                ),

                // Left item: Duration
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.access_time_rounded,
                              size: 14, color: AppColors.primaryGold),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المدة التقديرية',
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.textSubtle
                                      : AppColors.textMutedLight,
                                ),
                              ),
                              Text(
                                _calculateEstimatedDuration(),
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.textMainLight,
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
          ),

          // Disclaimer Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x330284C7)
                  : const Color(0xFFEFF6FF),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : const Color(0xFFDBEAFE),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 13, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'المسافة والمدة تقديرية وقد تختلف حسب الظروف الفعلية للرحلة',
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D4ED8),
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

  String _calculateEstimatedDistance() {
    if (_originCity == _destCity) return '45 كم';
    if ((_originCity == 'صنعاء' && _destCity == 'الرياض') ||
        (_originCity == 'الرياض' && _destCity == 'صنعاء')) {
      return '1,850 كم';
    }
    if ((_originCity == 'صنعاء' && _destCity == 'عدن') ||
        (_originCity == 'عدن' && _destCity == 'صنعاء')) {
      return '365 كم';
    }
    return '1,120 كم';
  }

  String _calculateEstimatedDuration() {
    if (_originCity == _destCity) return 'حوالي ساعة ونصف';
    if ((_originCity == 'صنعاء' && _destCity == 'الرياض') ||
        (_originCity == 'الرياض' && _destCity == 'صنعاء')) {
      return 'حوالي 27 ساعة';
    }
    if ((_originCity == 'صنعاء' && _destCity == 'عدن') ||
        (_originCity == 'عدن' && _destCity == 'صنعاء')) {
      return 'حوالي 8 ساعات';
    }
    return 'حوالي 18 ساعة';
  }

  // =========================================================================
  // CARD 2: الحمولة المطلوب نقلها
  // =========================================================================
  Widget _buildCargoCard(bool isDark) {
    return _buildCardContainer(
      title: 'الحمولة المطلوب نقلها',
      subtitle: 'اختر حمولة من حمولاتك المسجلة أو أضف حمولة جديدة',
      stepNumber: 2,
      icon: Icons.inventory_2_rounded,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cargo Dropdown with (+) Add Cargo Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _cargoError != null
                              ? AppColors.error
                              : (isDark ? Colors.white12 : AppColors.borderLight),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CargoCardItem>(
                          isExpanded: true,
                          value: _selectedCargo,
                          hint: Text(
                            'اختر الحمولة',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSubtle
                                  : AppColors.textMutedLight,
                            ),
                          ),
                          dropdownColor:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                          items: _availableCargos.map((cargo) {
                            return DropdownMenuItem(
                              value: cargo,
                              child: Text('${cargo.name} — ${cargo.weight}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCargo = val;
                              _cargoError = null;
                            });
                          },
                        ),
                      ),
                    ),
                    if (_cargoError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _cargoError!,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Button (+) إضافة حمولة
              Tooltip(
                message: 'إضافة حمولة',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openAddCargoFlow,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: AppColors.primaryGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'إضافة حمولة',
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rich Preview of Selected Cargo
          if (_selectedCargo != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x660F172A) : const Color(0xFFF8FAFC),
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
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 56,
                      height: 56,
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      child: _selectedCargo!.imageAsset != null
                          ? Image.asset(
                              _selectedCargo!.imageAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.inventory_2_rounded,
                                color: AppColors.primaryGold,
                                size: 28,
                              ),
                            )
                          : const Icon(
                              Icons.inventory_2_rounded,
                              color: AppColors.primaryGold,
                              size: 28,
                            ),
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
                          '${_selectedCargo!.category} • ${_selectedCargo!.packagingType}',
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _selectedCargo!.weight,
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedCargo!.quantity,
                              style: GoogleFonts.ibmPlexSansArabic(
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
                ],
              ),
            ),
          ] else ...[
            // Empty State
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x330F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  style: BorderStyle.solid,
                  color: isDark ? Colors.white10 : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 28, color: AppColors.textMutedLight),
                  const SizedBox(height: 6),
                  Text(
                    'لم تقم بتحديد أي حمولة لهذا الطلب بعد',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // CARD 3: متطلبات النقل
  // =========================================================================
  Widget _buildRequirementsCard(bool isDark) {
    return _buildCardContainer(
      title: 'متطلبات النقل',
      subtitle: 'حدد نوع المركبة وموعد التحميل المناسب',
      stepNumber: 3,
      icon: Icons.local_shipping_rounded,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Vehicle Type Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نوع المركبة المطلوبة *',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white12 : AppColors.borderLight,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _vehicleType,
                          isExpanded: true,
                          dropdownColor:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                          items: _vehicleTypes.map((v) {
                            return DropdownMenuItem(value: v, child: Text(v));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _vehicleType = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Loading Date Picker Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ التحميل *',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white12 : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _loadingDateController,
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textMainLight,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 90)),
                              );
                              if (picked != null) {
                                setState(() {
                                  _loadingDateController.text =
                                      '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                            child: const Icon(Icons.calendar_today_rounded,
                                size: 16, color: Color(0xFF2563EB)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Loading Time & Flexibility Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preferred Time Dropdown
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وقت التحميل المفضل *',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white12 : AppColors.borderLight,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _loadingTime,
                          isExpanded: true,
                          dropdownColor:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textMainLight,
                          ),
                          items: _loadingTimes.map((t) {
                            return DropdownMenuItem(value: t, child: Text(t));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _loadingTime = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Schedule Flexibility Pills
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرونة وقت التحميل *',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFlexibilityChip(
                            label: 'دقيق في الوقت',
                            flex: ScheduleFlexibility.exact,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildFlexibilityChip(
                            label: '± 6 ساعات',
                            flex: ScheduleFlexibility.plusMinus6Hours,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildFlexibilityChip(
                            label: '± 12 ساعة',
                            flex: ScheduleFlexibility.plusMinus12Hours,
                            isDark: isDark,
                          ),
                        ),
                      ],
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

  Widget _buildFlexibilityChip({
    required String label,
    required ScheduleFlexibility flex,
    required bool isDark,
  }) {
    final isSelected = _flexibility == flex;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _flexibility = flex),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0x33F59E0B) : const Color(0xFFFEF3C7))
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryGold
                  : (isDark ? Colors.white10 : AppColors.borderLight),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? const Color(0xFFB45309)
                  : (isDark ? AppColors.textWhite : AppColors.textMainLight),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // CARD 4: الميزانية المتوقعة (اختياري)
  // =========================================================================
  Widget _buildBudgetCard(bool isDark) {
    return _buildCardContainer(
      title: 'الميزانية المتوقعة (اختياري)',
      subtitle: 'حدد نطاق الميزانية المتوقع لعرض الطلب',
      stepNumber: 4,
      icon: Icons.account_balance_wallet_rounded,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Min Budget
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الحد الأدنى المتوقع',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _budgetError != null
                              ? AppColors.error
                              : (isDark ? Colors.white12 : AppColors.borderLight),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minBudgetController,
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textMainLight,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _budgetCurrency,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
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
              ),
              const SizedBox(width: 10),

              // Max Budget
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الحد الأعلى المتوقع',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _budgetError != null
                              ? AppColors.error
                              : (isDark ? Colors.white12 : AppColors.borderLight),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _maxBudgetController,
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textMainLight,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _budgetCurrency,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
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
              ),
            ],
          ),

          if (_budgetError != null) ...[
            const SizedBox(height: 6),
            Text(
              _budgetError!,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],

          const SizedBox(height: 10),
          // Info Note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x330284C7) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 15, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الميزانية المتوقعة تساعد في الحصول على عروض مناسبة، والسعر النهائي سيكون ضمن العروض المقدمة من السائقين أو مكاتب النقل.',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      height: 1.45,
                      color: const Color(0xFF1E40AF),
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

  // =========================================================================
  // CARD 5: ملاحظات إضافية (اختياري)
  // =========================================================================
  Widget _buildNotesCard(bool isDark) {
    final currentLength = _notesController.text.length;

    return _buildCardContainer(
      title: 'ملاحظات إضافية (اختياري)',
      subtitle: 'أضف أي متطلبات أو تعليمات خاصة بالنقل',
      stepNumber: 5,
      icon: Icons.edit_note_rounded,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  maxLength: _maxNotesLength,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    color: isDark ? AppColors.textWhite : AppColors.textMainLight,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText:
                        'مثال: يرجى التأكد من سلامة التغليف، واستخدام رافعة عند التحميل...',
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$currentLength/$_maxNotesLength',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 10.5,
                      color: currentLength >= _maxNotesLength
                          ? AppColors.error
                          : (isDark ? AppColors.textSubtle : AppColors.textMutedLight),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Blue Notice Box matching Image 2
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x331E40AF) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFBFDBFE),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_rounded,
                        size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(
                      'ملاحظات مهمة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildBulletPoint('سيتم نشر الطلب على الجهات التي تختارها لاحقاً.'),
                _buildBulletPoint(
                    'لن يتم التواصل مع السائق أو مكاتب النقل إلا بعد الدفع وتأكيد الإسناد.'),
                _buildBulletPoint(
                    'يمكنك متابعة الطلب والعروض من خلال شاشة طلباتي.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF2563EB), fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 11,
                height: 1.4,
                color: const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // BOTTOM ACTION BUTTONS: حفظ الطلب (Draft) + نشر الطلب (Publish)
  // =========================================================================
  Widget _buildBottomActionButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderLight,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Button 1 (Right in RTL): حفظ الطلب (Dark button with subtitle)
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleSaveDraft,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFF334155),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_border_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حفظ الطلب',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'سيتم حفظ الطلب في طلباتي',
                              style: GoogleFonts.cairo(
                                fontSize: 9.0,
                                color: const Color(0xFF94A3B8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Button 2 (Left in RTL): نشر الطلب (White / Primary outlined button matching Image 2)
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handlePublishOrder,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.send_rounded,
                          color: Color(0xFF2563EB), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نشر الطلب',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2563EB),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'اختر الجهة التي تريد نشر الطلب لها',
                              style: GoogleFonts.cairo(
                                fontSize: 9.0,
                                color: isDark
                                    ? AppColors.textSubtle
                                    : AppColors.textMutedLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Canvas Painter rendering real geographical territory, Arabian peninsula outline & route polyline
class _RouteMapCanvasPainter extends CustomPainter {
  final String originCity;
  final String destCity;
  final bool isDark;

  _RouteMapCanvasPainter({
    required this.originCity,
    required this.destCity,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Water Background (Red Sea / Arabian Gulf)
    final waterPaint = Paint()
      ..color = isDark ? const Color(0xFF0C192C) : const Color(0xFFE0F2FE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), waterPaint);

    // 2. Arabian Peninsula Landmass Outline
    final landPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7)
      ..style = PaintingStyle.fill;

    final landPath = Path();
    // Simplified coastal outline resembling the Arabian peninsula / Red sea & Gulf
    landPath.moveTo(size.width * 0.15, size.height);
    landPath.lineTo(size.width * 0.35, size.height * 0.70); // Yemen coast
    landPath.lineTo(size.width * 0.45, size.height * 0.45); // Red Sea coast
    landPath.lineTo(size.width * 0.55, size.height * 0.15); // Hejaz
    landPath.lineTo(size.width * 0.85, 0); // North
    landPath.lineTo(size.width, 0);
    landPath.lineTo(size.width, size.height);
    landPath.close();

    canvas.drawPath(landPath, landPaint);

    // Grid lines for geospatial feel
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Origin & Destination Positions
    // In geography: Sana'a is south (lower), Riyadh is north-east (higher)
    final originPos = Offset(size.width * 0.38, size.height * 0.78);
    final destPos = Offset(size.width * 0.68, size.height * 0.32);

    // 4. Curved Polyline Route
    final routePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path();
    routePath.moveTo(originPos.dx, originPos.dy);
    // Realistic curve through highways
    routePath.cubicTo(
      originPos.dx + (destPos.dx - originPos.dx) * 0.25,
      originPos.dy - 10,
      originPos.dx + (destPos.dx - originPos.dx) * 0.60,
      destPos.dy + 25,
      destPos.dx,
      destPos.dy,
    );

    canvas.drawPath(routePath, routePaint);

    // Route Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.25)
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, glowPaint);

    // 5. Origin Marker (Green with halo)
    final greenHalo = Paint()
      ..color = AppColors.success.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(originPos, 10, greenHalo);

    final greenPin = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.fill;
    canvas.drawCircle(originPos, 5, greenPin);

    // 6. Destination Marker (Red pin with halo)
    final redHalo = Paint()
      ..color = AppColors.error.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(destPos, 12, redHalo);

    final redPin = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;
    canvas.drawCircle(destPos, 6, redPin);

    // 7. Text labels for Origin and Dest
    final originTextPainter = TextPainter(
      text: TextSpan(
        text: originCity,
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          backgroundColor:
              (isDark ? Colors.black : Colors.white).withValues(alpha: 0.75),
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    originTextPainter.paint(
      canvas,
      Offset(originPos.dx - (originTextPainter.width / 2), originPos.dy + 12),
    );

    final destTextPainter = TextPainter(
      text: TextSpan(
        text: destCity,
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          backgroundColor:
              (isDark ? Colors.black : Colors.white).withValues(alpha: 0.75),
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    destTextPainter.paint(
      canvas,
      Offset(destPos.dx - (destTextPainter.width / 2), destPos.dy - 22),
    );
  }

  @override
  bool shouldRepaint(covariant _RouteMapCanvasPainter oldDelegate) {
    return oldDelegate.originCity != originCity ||
        oldDelegate.destCity != destCity ||
        oldDelegate.isDark != isDark;
  }
}
