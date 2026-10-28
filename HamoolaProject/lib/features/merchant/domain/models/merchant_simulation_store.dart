import 'package:flutter/material.dart';

import 'cargo_card_item.dart';
import 'driver_offer.dart';
import 'merchant_order.dart';
import 'wallet_models.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../transport_office/domain/models/office_bid.dart';

export '../../../transport_office/domain/models/office_bid.dart';

/// Central In-Memory Simulation Store for the Merchant Experience.
/// Manages reactive state across Cargos, Orders, Offers, Wallet, and Trip Tracking.
/// Zero backend required — pure reactive local state.
class MerchantSimulationStore extends ChangeNotifier {
  static final MerchantSimulationStore instance =
      MerchantSimulationStore._internal();

  factory MerchantSimulationStore() => instance;

  MerchantSimulationStore._internal() {
    _initialize();
  }

  // --- In-Memory State ---
  late List<CargoCardItem> _cargos;
  late List<MerchantOrder> _orders;
  late Map<String, List<DriverOffer>> _orderOffers;
  late double _walletBalance;
  late double _pendingBalance;
  late List<MerchantTransaction> _transactions;
  late Map<AuthUserRole, RoleWalletState> _roleWallets;
  late Map<String, int> _tripStageIndexes;
  late List<OfficeBid> _officeBids;
  late Map<String, ProviderSettlementRecord> _providerSettlements;
  late Map<String, TripRatingRecord> _orderRatings;

  void _initialize() {
    _cargos = List.from(CargoCardItem.demoCargos);
    _orders = List.from(MerchantOrder.demoOrders);
    _orderOffers = {
      'REQ-1024': List.from(DriverOffer.demoOffers),
    };
    _walletBalance = MerchantWalletData.demoWallet.balance;
    _pendingBalance = MerchantWalletData.demoWallet.pendingBalance;
    _transactions = List.from(MerchantWalletData.demoWallet.transactions);

    _roleWallets = {
      AuthUserRole.merchant: RoleWalletState(
        balance: _walletBalance,
        pendingBalance: _pendingBalance,
        totalWithdrawn: 0.0,
        totalPaid: 35000.0,
        transactions: _transactions,
      ),
      AuthUserRole.client: RoleWalletState(
        balance: 15000.0,
        pendingBalance: 0.0,
        totalWithdrawn: 0.0,
        totalPaid: 8000.0,
        transactions: [
          const MerchantTransaction(
            id: 'TXN-CL-101',
            type: TransactionType.deposit,
            title: 'شحن رصيد — محفظة جيب',
            date: 'أمس، 02:30 م',
            amount: 15000.0,
            status: TransactionStatus.completed,
            statusLabel: 'مكتملة',
            wallet: 'محفظة جيب',
            ref: 'REF-CL-101',
          ),
          const MerchantTransaction(
            id: 'TXN-CL-100',
            type: TransactionType.payment,
            title: 'دفع نقل أثاث منزلي (#REQ-502)',
            date: 'قبل يومين، 11:15 ص',
            amount: -8000.0,
            status: TransactionStatus.completed,
            statusLabel: 'مكتملة',
            wallet: 'المحفظة الداخلية',
            ref: 'REQ-502',
          ),
        ],
      ),
      AuthUserRole.office: RoleWalletState(
        balance: 185000.0,
        pendingBalance: 25000.0,
        totalWithdrawn: 60000.0,
        totalPaid: 120000.0,
        transactions: [
          const MerchantTransaction(
            id: 'TXN-OF-201',
            type: TransactionType.deposit,
            title: 'شحن رصيد تشغيلي — البنك الأهلي',
            date: 'اليوم، 09:15 ص',
            amount: 25000.0,
            status: TransactionStatus.pending,
            statusLabel: 'قيد المراجعة',
            wallet: 'البنك الأهلي',
            ref: 'REF-OF-201',
          ),
          const MerchantTransaction(
            id: 'TXN-OF-200',
            type: TransactionType.deposit,
            title: 'عمولة وساطة رحلات (شحنة مواد بناء)',
            date: 'أمس، 05:40 م',
            amount: 45000.0,
            status: TransactionStatus.completed,
            statusLabel: 'مكتملة',
            wallet: 'المحفظة الداخلية',
            ref: 'TRIP-9901',
          ),
        ],
      ),
      AuthUserRole.driver: RoleWalletState(
        balance: 25000.0,
        pendingBalance: 5000.0,
        totalWithdrawn: 40000.0,
        totalPaid: 0.0,
        transactions: [
          const MerchantTransaction(
            id: 'TXN-DR-1042',
            type: TransactionType.payment,
            title: 'مستحقات رحلة',
            date: '12 أكتوبر 2026 • 10:30 ص',
            amount: 8000.0,
            status: TransactionStatus.completed,
            statusLabel: 'متاحة للسحب',
            wallet: 'المحفظة الداخلية',
            ref: 'رحلة #HM-1042',
          ),
          const MerchantTransaction(
            id: 'TXN-DR-WD204',
            type: TransactionType.withdrawal,
            title: 'طلب سحب',
            date: '11 أكتوبر 2026 • 04:15 م',
            amount: -5000.0,
            status: TransactionStatus.pending,
            statusLabel: 'قيد المعالجة',
            wallet: 'حساب بنكي معتمد',
            ref: 'عملية #WD-204',
          ),
          const MerchantTransaction(
            id: 'TXN-DR-1038',
            type: TransactionType.payment,
            title: 'مستحقات رحلة',
            date: '10 أكتوبر 2026 • 09:20 ص',
            amount: 4500.0,
            status: TransactionStatus.completed,
            statusLabel: 'مكتملة',
            wallet: 'المحفظة الداخلية',
            ref: 'رحلة #HM-1038',
          ),
          const MerchantTransaction(
            id: 'TXN-DR-WD203',
            type: TransactionType.withdrawal,
            title: 'طلب سحب',
            date: '8 أكتوبر 2026 • 11:48 ص',
            amount: -3200.0,
            status: TransactionStatus.completed,
            statusLabel: 'مكتملة',
            wallet: 'حساب بنكي معتمد',
            ref: 'عملية #WD-203',
          ),
          const MerchantTransaction(
            id: 'TXN-DR-1029',
            type: TransactionType.payment,
            title: 'مستحقات رحلة',
            date: '5 أكتوبر 2026 • 03:10 م',
            amount: 6750.0,
            status: TransactionStatus.completed,
            statusLabel: 'مكتملة',
            wallet: 'المحفظة الداخلية',
            ref: 'رحلة #HM-1029',
          ),
        ],
      ),
    };

    _tripStageIndexes = {
      'REQ-1023': 6, // In transit (Stage 6)
      'REQ-1024': 0, // Pending agreement & payment (Stage 0)
    };
    _officeBids = [];
    _providerSettlements = {
      'REQ-1023': ProviderSettlementRecord(
        orderId: 'REQ-1023',
        providerName: 'كابتن أحمد صالح النجار',
        requesterPaidAmount: 395000.0,
        providerDueAmount: 380000.0,
        platformFee: 15000.0,
        status: ProviderSettlementStatus.pendingCompletion,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    };
    _orderRatings = {};
  }

  void resetToDemo() {
    _initialize();
    notifyListeners();
  }

  void resetToInitialState() => resetToDemo();

  // ===========================================================================
  // CARGOS MANAGEMENT (حمولاتي)
  // ===========================================================================
  List<CargoCardItem> get cargos => List.unmodifiable(_cargos);

  CargoCardItem? getCargoById(String id) {
    try {
      return _cargos.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isCargoLinkedToActiveOrder(String cargoId) {
    final cargo = getCargoById(cargoId);
    if (cargo == null) return false;
    for (final orderId in cargo.linkedOrderIds) {
      final order = getOrderById(orderId);
      if (order != null &&
          order.status != MerchantOrderStatus.completed) {
        return true;
      }
    }
    return false;
  }

  void addCargo(CargoCardItem cargo) {
    _cargos.insert(0, cargo);
    notifyListeners();
  }

  void updateCargo(CargoCardItem updated) {
    final idx = _cargos.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      _cargos[idx] = updated;
      notifyListeners();
    }
  }

  /// Deletes cargo only if not linked to an active order. Returns false if blocked.
  bool deleteCargo(String cargoId) {
    if (isCargoLinkedToActiveOrder(cargoId)) {
      return false;
    }
    _cargos.removeWhere((c) => c.id == cargoId);
    notifyListeners();
    return true;
  }

  // ===========================================================================
  // ORDERS MANAGEMENT (طلباتي)
  // ===========================================================================
  List<MerchantOrder> get orders => List.unmodifiable(_orders);

  MerchantOrder? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  String generateNextOrderId() {
    int maxNum = 1024;
    for (final o in _orders) {
      final parts = o.id.split('-');
      if (parts.length == 2) {
        final n = int.tryParse(parts[1]);
        if (n != null && n > maxNum) maxNum = n;
      }
    }
    return 'REQ-${maxNum + 1}';
  }

  List<MerchantOrder> get drafts =>
      _orders.where((o) => o.status == MerchantOrderStatus.draft).toList();

  /// Saves a draft transport order without any balance check or deductions
  MerchantOrder saveDraft({
    String cargoName = 'مسودة طلب',
    required String originCity,
    required String destinationCity,
    String? originAddressDetail,
    String? destAddressDetail,
    String? vehicleType,
    String? loadingDate,
    String? loadingTime,
    String? flexibility,
    double? minBudget,
    double? maxBudget,
    double? expectedPrice,
    String? notes,
  }) {
    final orderId = generateNextOrderId();
    final draftOrder = MerchantOrder(
      id: orderId,
      cargoName: cargoName,
      originCity: originCity,
      destinationCity: destinationCity,
      status: MerchantOrderStatus.draft,
      offersCount: 0,
      timeAgo: 'الآن',
      iconData: Icons.assignment_outlined,
      vehicleType: vehicleType,
      notes: notes,
      minBudget: minBudget,
      maxBudget: maxBudget,
      expectedPrice: expectedPrice ?? minBudget,
    );
    _orders.insert(0, draftOrder);
    notifyListeners();
    return draftOrder;
  }

  /// Creates a draft transport order (saved in drafts, not published, no offers)
  MerchantOrder createDraftOrder({
    CargoCardItem? cargo,
    required String originCity,
    required String destinationCity,
    String? originAddressDetail,
    String? destAddressDetail,
    String? vehicleType,
    String? loadingDate,
    String? loadingTime,
    String? flexibility,
    String? minBudget,
    String? maxBudget,
    double? expectedPrice,
    String? notes,
  }) {
    final orderId = generateNextOrderId();
    final minVal = minBudget != null
        ? double.tryParse(minBudget.replaceAll(',', ''))
        : null;
    final maxVal = maxBudget != null
        ? double.tryParse(maxBudget.replaceAll(',', ''))
        : null;

    final draftOrder = MerchantOrder(
      id: orderId,
      cargoName: cargo?.name ?? 'مسودة طلب',
      originCity: originCity,
      destinationCity: destinationCity,
      status: MerchantOrderStatus.draft,
      offersCount: 0,
      timeAgo: 'الآن',
      iconData: cargo?.categoryIcon ?? Icons.assignment_outlined,
      vehicleType: vehicleType,
      notes: notes,
      minBudget: minVal,
      maxBudget: maxVal,
      expectedPrice: expectedPrice ?? minVal,
    );
    _orders.insert(0, draftOrder);
    notifyListeners();
    return draftOrder;
  }

  /// Publishes a transport order directly without cargo dependency
  MerchantOrder publishOrder({
    required String cargoName,
    required String originCity,
    required String destinationCity,
    required String broadcastScope, // 'all_drivers', 'driver', 'all_offices', 'office'
    double? minBudget,
    double? maxBudget,
    String? vehicleType,
    String? notes,
    String? targetProviderId,
    String? targetProviderPhone,
    String? driverName,
  }) {
    final orderId = generateNextOrderId();
    final isDirect = broadcastScope == 'driver' || broadcastScope == 'office';

    final newOrder = MerchantOrder(
      id: orderId,
      cargoName: cargoName,
      originCity: originCity,
      destinationCity: destinationCity,
      status: broadcastScope == 'all_offices' || broadcastScope == 'office'
          ? MerchantOrderStatus.pendingOffice
          : MerchantOrderStatus.pendingDriver,
      offersCount: isDirect ? 0 : 3,
      driverName: driverName,
      timeAgo: 'الآن',
      iconData: Icons.local_shipping_outlined,
      vehicleType: vehicleType,
      broadcastScope: broadcastScope,
      notes: notes,
      expectedPrice: minBudget,
      minBudget: minBudget,
      maxBudget: maxBudget,
      directStatus: isDirect ? 'pending' : null,
      targetProviderId: targetProviderId,
      targetProviderPhone: targetProviderPhone,
    );

    _orders.insert(0, newOrder);

    if (isDirect) {
      _orderOffers[orderId] = [];
    } else {
      _orderOffers[orderId] = [
        DriverOffer(
          id: 'OFF-${DateTime.now().millisecondsSinceEpoch % 1000}',
          orderId: orderId,
          driverId: 'DRV-201',
          driverName: 'كابتن أحمد السالمي',
          rating: 4.8,
          tripsCount: 140,
          vehicleName: vehicleType ?? 'دينا تبريد 10 طن — إيسوزو NPR',
          vehiclePlate: '$originCity 12-4521',
          price: (minBudget != null && minBudget > 0) ? minBudget : 380000,
          pickupTimeText: 'اليوم خلال ساعتين',
          deliveryTimeText: 'غداً صباحاً',
          isVerified: true,
          isBestPrice: true,
          notes: 'جاهز فوراً مع جميع أحزمة التثبيت والمظلات الواقية.',
          driverPhone: '+967 775 112 345',
        ),
        DriverOffer(
          id: 'OFF-${(DateTime.now().millisecondsSinceEpoch + 1) % 1000}',
          orderId: orderId,
          driverId: 'DRV-202',
          driverName: 'كابتن علي الحارثي',
          rating: 5.0,
          tripsCount: 220,
          vehicleName: 'سطحة تريلا هيدروليك 32 طن — مرسيدس أكتروس',
          vehiclePlate: '$originCity 18-9923',
          price: (minBudget != null && minBudget > 0) ? minBudget + 30000 : 410000,
          pickupTimeText: 'اليوم 4:00 عصراً',
          deliveryTimeText: 'غداً 10:00 صباحاً',
          isVerified: true,
          isHighestRated: true,
          notes: 'تأمين كامل على البضاعة ومتابعة بنظام التتبع المباشر لحظة بلحظة.',
          driverPhone: '+967 771 990 882',
        ),
        DriverOffer(
          id: 'OFF-${(DateTime.now().millisecondsSinceEpoch + 2) % 1000}',
          orderId: orderId,
          driverId: 'DRV-203',
          driverName: 'كابتن محمد الشهري',
          rating: 4.8,
          tripsCount: 94,
          vehicleName: 'شاحنة صندوق مقفل 25 طن — فولفو FH',
          vehiclePlate: '$originCity 09-3120',
          price: (minBudget != null && minBudget > 0) ? minBudget + 15000 : 395000,
          pickupTimeText: 'خلال ساعة واحدة',
          deliveryTimeText: 'غداً فجراً',
          isVerified: true,
          isFastest: true,
          notes: 'متواجد على مقربة من موقع التحميل وجاهز للبدء فوراً.',
          driverPhone: '+967 773 400 191',
        ),
      ];
    }

    _tripStageIndexes[orderId] = 0;
    notifyListeners();
    return newOrder;
  }

  /// Creates and publishes a new transport order
  MerchantOrder createOrder({
    required CargoCardItem cargo,
    required String originCity,
    required String destinationCity,
    required String broadcastScope, // 'all_drivers', 'driver', 'all_offices', 'office'
    String? targetDriverName,
    String? targetDriverPhone,
    String? targetOfficeName,
    double? expectedPrice,
    double? minBudget,
    double? maxBudget,
    String? notes,
    String? vehicleType,
  }) {
    final orderId = generateNextOrderId();
    final isDirect = broadcastScope == 'driver' || broadcastScope == 'office';

    final newOrder = MerchantOrder(
      id: orderId,
      cargoName: cargo.name,
      originCity: originCity,
      destinationCity: destinationCity,
      status: broadcastScope == 'all_offices' || broadcastScope == 'office'
          ? MerchantOrderStatus.pendingOffice
          : MerchantOrderStatus.pendingDriver,
      offersCount: isDirect ? 0 : 3,
      driverName: targetDriverName ?? targetOfficeName,
      timeAgo: 'الآن',
      iconData: cargo.categoryIcon,
      vehicleType: vehicleType,
      broadcastScope: broadcastScope,
      notes: notes,
      expectedPrice: expectedPrice,
      minBudget: minBudget,
      maxBudget: maxBudget,
      directStatus: isDirect ? 'pending' : null,
      targetProviderPhone: targetDriverPhone,
    );

    _orders.insert(0, newOrder);

    // Link cargo to this new order
    final updatedCargo = cargo.copyWith(
      linkedOrderIds: [...cargo.linkedOrderIds, orderId],
      status: isDirect ? 'بانتظار قبول الجهة' : 'بانتظار العروض',
    );
    updateCargo(updatedCargo);

    if (isDirect) {
      // Direct request to specific driver or office: strictly NO bidding/offers loop
      _orderOffers[orderId] = [];
    } else {
      // Public broadcast to all drivers or all offices: receives independent bids
      _orderOffers[orderId] = [
        DriverOffer(
          id: 'OFF-${DateTime.now().millisecondsSinceEpoch % 1000}',
          orderId: orderId,
          driverId: 'DRV-201',
          driverName: 'كابتن أحمد السالمي',
          rating: 4.8,
          tripsCount: 140,
          vehicleName: vehicleType ?? 'دينا تبريد 10 طن — إيسوزو NPR',
          vehiclePlate: '$originCity 12-4521',
          price: (expectedPrice != null && expectedPrice > 0)
              ? expectedPrice
              : 380000,
          pickupTimeText: 'اليوم خلال ساعتين',
          deliveryTimeText: 'غداً صباحاً',
          isVerified: true,
          isBestPrice: true,
          notes: 'جاهز فوراً مع جميع أحزمة التثبيت والمظلات الواقية.',
          driverPhone: '+967 775 112 345',
        ),
        DriverOffer(
          id: 'OFF-${(DateTime.now().millisecondsSinceEpoch + 1) % 1000}',
          orderId: orderId,
          driverId: 'DRV-202',
          driverName: 'كابتن علي الحارثي',
          rating: 5.0,
          tripsCount: 220,
          vehicleName: 'سطحة تريلا هيدروليك 32 طن — مرسيدس أكتروس',
          vehiclePlate: '$originCity 18-9923',
          price: (expectedPrice != null && expectedPrice > 0)
              ? expectedPrice + 30000
              : 410000,
          pickupTimeText: 'اليوم 4:00 عصراً',
          deliveryTimeText: 'غداً 10:00 صباحاً',
          isVerified: true,
          isHighestRated: true,
          notes: 'تأمين كامل على البضاعة ومتابعة بنظام التتبع المباشر لحظة بلحظة.',
          driverPhone: '+967 771 990 882',
        ),
        DriverOffer(
          id: 'OFF-${(DateTime.now().millisecondsSinceEpoch + 2) % 1000}',
          orderId: orderId,
          driverId: 'DRV-203',
          driverName: 'كابتن محمد الشهري',
          rating: 4.8,
          tripsCount: 94,
          vehicleName: 'شاحنة صندوق مقفل 25 طن — فولفو FH',
          vehiclePlate: '$originCity 09-3120',
          price: (expectedPrice != null && expectedPrice > 0)
              ? expectedPrice + 15000
              : 395000,
          pickupTimeText: 'خلال ساعة واحدة',
          deliveryTimeText: 'غداً فجراً',
          isVerified: true,
          isFastest: true,
          notes: 'متواجد على مقربة من موقع التحميل وجاهز للبدء فوراً.',
          driverPhone: '+967 773 400 191',
        ),
      ];
    }

    _tripStageIndexes[orderId] = 0;
    notifyListeners();
    return newOrder;
  }

  /// Accepts a direct request (by targeted driver or targeted office)
  bool acceptDirectOrder(
    String orderId, {
    double? agreedPrice,
    String? providerName,
    String? providerPhone,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return false;
    final current = _orders[idx];
    if (!current.isDirectOrder) return false;

    final finalFare = agreedPrice ??
        current.expectedPrice ??
        current.maxBudget ??
        current.minBudget ??
        350000.0;

    _orders[idx] = current.copyWith(
      directStatus: 'accepted',
      agreedFare: finalFare,
      driverName: providerName ?? current.driverName,
      targetProviderPhone:
          providerPhone ?? current.targetProviderPhone ?? '+967 771 234 567',
    );
    notifyListeners();
    return true;
  }

  /// Rejects a direct request (by targeted driver or targeted office)
  /// Crucial rule: Does NOT automatically re-assign to anyone else.
  bool rejectDirectOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return false;
    final current = _orders[idx];
    if (!current.isDirectOrder) return false;

    _orders[idx] = current.copyWith(
      directStatus: 'rejected',
    );
    notifyListeners();
    return true;
  }

  void updateOrderStatus(
    String orderId,
    MerchantOrderStatus newStatus, {
    String? driverName,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final current = _orders[idx];
      _orders[idx] = current.copyWith(
        status: newStatus,
        driverName: driverName ?? current.driverName,
        timeAgo: 'محدث الآن',
      );
      notifyListeners();
    }
  }

  void updateOrder(MerchantOrder updated) {
    final idx = _orders.indexWhere((o) => o.id == updated.id);
    if (idx != -1) {
      _orders[idx] = updated;
      notifyListeners();
    }
  }

  bool deleteOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders.removeAt(idx);
      _orderOffers.remove(orderId);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ===========================================================================
  // OFFERS MANAGEMENT (مراجعة العروض)
  // ===========================================================================
  List<DriverOffer> getOffersForOrder(String orderId) {
    return _orderOffers[orderId] ?? const [];
  }

  void rejectOffer(String orderId, String offerId) {
    if (_orderOffers.containsKey(orderId)) {
      _orderOffers[orderId]!.removeWhere((o) => o.id == offerId);
      // Update order offersCount
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        final current = _orders[idx];
        _orders[idx] = MerchantOrder(
          id: current.id,
          cargoName: current.cargoName,
          originCity: current.originCity,
          destinationCity: current.destinationCity,
          status: current.status,
          offersCount: _orderOffers[orderId]!.length,
          driverName: current.driverName,
          timeAgo: current.timeAgo,
          iconData: current.iconData,
        );
      }
      notifyListeners();
    }
  }

  /// Accepts a driver or transport office quote/offer for a public broadcast order,
  /// establishing binding agreement and assigning the provider.
  bool acceptQuote(String orderId, DriverOffer offer) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return false;
    _orders[idx] = _orders[idx].copyWith(
      status: MerchantOrderStatus.assignedDriver,
      agreedFare: offer.price,
      driverName: offer.driverName,
      targetProviderPhone: offer.driverPhone,
    );
    notifyListeners();
    return true;
  }

  // ===========================================================================
  // DRIVER & TRANSPORT OFFICE OPERATIONS (عمليات السائقين ومكاتب النقل)
  // ===========================================================================
  /// Returns orders that are available for a truck driver to view and submit bids on,
  /// or direct orders targeted specifically to this driver. Excludes drafts and assigned orders.
  List<MerchantOrder> getAvailableOrdersForDriver([String? driverIdentifier]) {
    return _orders.where((o) {
      if (o.status == MerchantOrderStatus.draft ||
          o.status == MerchantOrderStatus.assignedDriver ||
          o.status == MerchantOrderStatus.completed ||
          o.status == MerchantOrderStatus.inTransit) {
        return false;
      }
      // If direct order targeted to driver:
      if (o.isDirectOrder) {
        if (o.broadcastScope != 'driver') return false;
        if (driverIdentifier != null &&
            o.targetProviderId != null &&
            o.targetProviderId != driverIdentifier) {
          return false;
        }
        return true;
      }
      // Public broadcast targeted to all drivers
      return o.broadcastScope == 'all_drivers';
    }).toList();
  }

  /// Returns orders that are available for a transport office to view and submit bids on,
  /// or direct orders targeted specifically to this office. Excludes drafts and assigned orders.
  List<MerchantOrder> getAvailableOrdersForOffice([String? officeIdentifier]) {
    return _orders.where((o) {
      if (o.status == MerchantOrderStatus.draft ||
          o.status == MerchantOrderStatus.assignedDriver ||
          o.status == MerchantOrderStatus.completed ||
          o.status == MerchantOrderStatus.inTransit) {
        return false;
      }
      // If direct order targeted to office:
      if (o.isDirectOrder) {
        if (o.broadcastScope != 'office') return false;
        if (officeIdentifier != null &&
            o.targetProviderId != null &&
            o.targetProviderId != officeIdentifier) {
          return false;
        }
        return true;
      }
      // Public broadcast targeted to all offices
      return o.broadcastScope == 'all_offices';
    }).toList();
  }

  List<MerchantOrder> getAvailableOrdersForOffices([String? officeIdentifier]) =>
      getAvailableOrdersForOffice(officeIdentifier);

  /// Returns orders specifically assigned to this transport office
  List<MerchantOrder> getAssignedOrdersForOffice(String identifier) {
    return _orders.where((o) {
      final isAssigned = o.status == MerchantOrderStatus.assignedDriver ||
          o.status == MerchantOrderStatus.inTransit ||
          o.status == MerchantOrderStatus.completed;
      if (!isAssigned) return false;
      return o.driverName == identifier ||
          (o.driverName != null && o.driverName!.contains(identifier)) ||
          _officeBids.any((b) =>
              b.orderId == o.id &&
              (b.officeUserId == identifier || b.officeName.contains(identifier)) &&
              b.isAccepted);
    }).toList();
  }

  /// Returns all bids submitted by a transport office across all orders
  List<OfficeBid> getOfficeBids(String identifier) {
    return _officeBids.where((b) =>
      b.officeUserId == identifier ||
      b.officeName == identifier ||
      b.officeName.contains(identifier)
    ).toList();
  }

  /// Checks if office has already submitted a bid for an order
  bool hasOfficeSubmittedBid(String orderId, String identifier) {
    return _officeBids.any(
      (b) =>
          b.orderId == orderId &&
          (b.officeUserId == identifier || b.officeName.contains(identifier)),
    ) ||
    (_orderOffers[orderId]?.any(
            (o) => o.driverName.contains(identifier) || o.driverId == identifier) ??
        false);
  }

  /// Submits an independent, binding price bid on an order from a transport office.
  OfficeBid submitOfficeBid({
    required String orderId,
    AuthUser? officeUser,
    String? officeName,
    String? officeId,
    double? price,
    double? offeredPrice,
    String? vehicleType,
    String? pickupTime,
    String? deliveryTime,
    String? deliveryDuration,
    String? notes,
    bool hasInsurance = true,
    bool hasGpsTracking = true,
    String phone = '+967 774 567 890',
  }) {
    final finalPrice = offeredPrice ?? price ?? 0.0;
    final finalOfficeName =
        officeUser?.officeData?.officeName ?? officeName ?? officeUser?.name ?? 'مكتب نقل';
    final finalOfficeId = officeUser?.id ?? officeId ?? 'OFFICE-01';
    final finalDuration = deliveryDuration ?? deliveryTime ?? '24-48 ساعة';

    final bidId = 'BID-${DateTime.now().millisecondsSinceEpoch}';
    final newBid = OfficeBid(
      id: bidId,
      orderId: orderId,
      officeUserId: finalOfficeId,
      officeName: finalOfficeName,
      offeredPrice: finalPrice,
      deliveryDuration: finalDuration,
      notes: notes ?? 'عرض سعر رسمي وملزم من $finalOfficeName',
      createdAt: DateTime.now(),
    );
    _officeBids.insert(0, newBid);

    // Also insert as DriverOffer in _orderOffers so merchant review screens see it
    final driverOffer = DriverOffer(
      id: bidId,
      orderId: orderId,
      driverId: finalOfficeId,
      driverName: finalOfficeName,
      rating: 4.9,
      tripsCount: 156,
      vehicleName: vehicleType ?? 'شاحنة نقل ثقيل',
      vehiclePlate: 'صنعاء 18-5021',
      price: finalPrice,
      currency: 'ر.ي',
      pickupTimeText: pickupTime ?? 'خلال 24 ساعة',
      deliveryTimeText: finalDuration,
      isVerified: true,
      notes: notes ?? 'عرض نقل بري رسمي مقدم من $finalOfficeName مع أسطول حديث وتأمين شامل.',
      hasInsurance: hasInsurance,
      hasGpsTracking: hasGpsTracking,
      driverPhone: phone,
    );

    if (!_orderOffers.containsKey(orderId)) {
      _orderOffers[orderId] = [];
    }
    _orderOffers[orderId]!.insert(0, driverOffer);

    // Update offersCount on the order
    final orderIdx = _orders.indexWhere((o) => o.id == orderId);
    if (orderIdx != -1) {
      _orders[orderIdx] = _orders[orderIdx].copyWith(
        offersCount: _orderOffers[orderId]!.length,
      );
    }

    notifyListeners();
    return newBid;
  }

  void simulateAcceptOfficeBid(String orderId, String identifier) {
    final bidIdx = _officeBids.indexWhere(
      (b) =>
          b.orderId == orderId &&
          (b.officeUserId == identifier || b.officeName.contains(identifier)),
    );
    String officeName = 'مكتب الأمانة لنقل البضائع والمهمات';
    if (bidIdx != -1) {
      _officeBids[bidIdx] = _officeBids[bidIdx].copyWith(isAccepted: true);
      officeName = _officeBids[bidIdx].officeName;
    }

    updateOrderStatus(
      orderId,
      MerchantOrderStatus.assignedDriver,
      driverName: officeName,
    );
    notifyListeners();
  }

  // ===========================================================================
  // WALLET & PAYMENT MANAGEMENT (المحفظة والدفع)
  // ===========================================================================
  RoleWalletState getWalletForRole(AuthUserRole role) {
    return _roleWallets[role] ??
        RoleWalletState(
          balance: 0.0,
          pendingBalance: 0.0,
          transactions: [],
        );
  }

  double getBalanceForRole(AuthUserRole role) =>
      _roleWallets[role]?.balance ?? 0.0;

  double getPendingBalanceForRole(AuthUserRole role) =>
      _roleWallets[role]?.pendingBalance ?? 0.0;

  double getTotalWithdrawnForRole(AuthUserRole role) =>
      _roleWallets[role]?.totalWithdrawn ?? 0.0;

  double getTotalPaidForRole(AuthUserRole role) =>
      _roleWallets[role]?.totalPaid ?? 0.0;

  List<MerchantTransaction> getTransactionsForRole(AuthUserRole role) =>
      List.unmodifiable(_roleWallets[role]?.transactions ?? []);

  double get walletBalance => getBalanceForRole(AuthUserRole.merchant);
  set walletBalance(double value) {
    _walletBalance = value;
    _roleWallets[AuthUserRole.merchant]?.balance = value;
    notifyListeners();
  }

  void addBalance(double amount) {
    _walletBalance += amount;
    _roleWallets[AuthUserRole.merchant]?.balance += amount;
    notifyListeners();
  }

  /// Alias for topping up / depositing into wallet
  void depositToWallet(double amount) => addBalance(amount);

  bool canPublishOrder(double maxBudget) => _walletBalance >= maxBudget;

  double get pendingBalance => getPendingBalanceForRole(AuthUserRole.merchant);
  List<MerchantTransaction> get transactions =>
      getTransactionsForRole(AuthUserRole.merchant);

  bool canPay(double amount) => _walletBalance >= amount;

  /// Submits a deposit request for a specific user role.
  /// Enforces that drivers cannot submit deposit requests.
  void addDepositRequestForRole({
    required AuthUserRole role,
    required double amount,
    required String walletName,
    required String ref,
    String? sender,
  }) {
    if (role == AuthUserRole.driver) {
      throw UnsupportedError('السائق لا يملك صلاحية إضافة الرصيد');
    }

    final wallet = _roleWallets[role];
    if (wallet == null) return;

    final txnId = 'TXN-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final newTxn = MerchantTransaction(
      id: txnId,
      type: TransactionType.deposit,
      title: 'شحن رصيد — $walletName',
      date: 'الآن',
      amount: amount,
      status: TransactionStatus.pending,
      statusLabel: 'قيد المراجعة',
      wallet: walletName,
      ref: ref,
    );

    wallet.transactions.insert(0, newTxn);
    wallet.pendingBalance += amount;

    if (role == AuthUserRole.merchant) {
      _walletBalance = wallet.balance;
      _pendingBalance = wallet.pendingBalance;
      _transactions = wallet.transactions;
    }

    notifyListeners();
  }

  /// Submits a deposit request via local wallet, initially marked as 'pending'
  void addDepositRequest({
    required double amount,
    required String walletName,
    required String ref,
  }) {
    addDepositRequestForRole(
      role: AuthUserRole.merchant,
      amount: amount,
      walletName: walletName,
      ref: ref,
    );
  }

  /// Submits a driver withdrawal request to bank account.
  /// Deducts amount from available balance, adds to pending / total withdrawn,
  /// and creates a withdrawal transaction with 'قيد المعالجة' status.
  bool requestDriverWithdrawal({
    required double amount,
    required String bankName,
    required String accountNumber,
  }) {
    final wallet = _roleWallets[AuthUserRole.driver];
    if (wallet == null) return false;
    if (amount <= 0 || amount > wallet.balance) return false;

    wallet.balance -= amount;
    wallet.totalWithdrawn += amount;

    final refNum = 'WD-${100 + (DateTime.now().millisecondsSinceEpoch % 900)}';
    final txn = MerchantTransaction(
      id: 'TXN-DR-$refNum',
      type: TransactionType.withdrawal,
      title: 'طلب سحب',
      date: 'الآن',
      amount: -amount,
      status: TransactionStatus.pending,
      statusLabel: 'قيد المعالجة',
      wallet: '$bankName ($accountNumber)',
      ref: 'عملية #$refNum',
    );
    wallet.transactions.insert(0, txn);
    notifyListeners();
    return true;
  }

  /// Unified withdrawal request for Driver or Transport Office.
  /// Deducts amount from available balance, adds to totalWithdrawn,
  /// and creates a pending withdrawal transaction with status 'قيد المراجعة'.
  String? requestWithdrawalForRole({
    required AuthUserRole role,
    required double amount,
    required String methodType, // 'subscriber' or 'pos'
    required String recipientIdentifier, // Phone or Point number
    required String recipientName, // Full name or Commercial name
  }) {
    if (role != AuthUserRole.driver && role != AuthUserRole.office) {
      return null;
    }

    final wallet = _roleWallets[role];
    if (wallet == null) return null;
    if (amount <= 0 || amount > wallet.balance) return null;

    wallet.balance -= amount;
    wallet.totalWithdrawn += amount;

    final refNum = 'WD-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}';
    final isSubscriber = methodType == 'subscriber';
    final title = isSubscriber ? 'سحب - تحويل لمشترك' : 'سحب - دفع مشتريات';
    final walletDetail = isSubscriber
        ? 'تحويل لمشترك: $recipientIdentifier ($recipientName)'
        : 'نقطة بيع: $recipientIdentifier ($recipientName)';

    final txn = MerchantTransaction(
      id: 'TXN-$refNum',
      type: TransactionType.withdrawal,
      title: title,
      date: 'الآن',
      amount: -amount,
      status: TransactionStatus.pending,
      statusLabel: 'قيد المراجعة',
      wallet: walletDetail,
      ref: 'طلب سحب #$refNum',
    );
    wallet.transactions.insert(0, txn);
    notifyListeners();
    return refNum;
  }

  /// Simulates immediate approval of pending deposit for a specific role
  void simulateApproveDepositForRole(AuthUserRole role, String transactionId) {
    final wallet = _roleWallets[role];
    if (wallet == null) return;

    final idx = wallet.transactions.indexWhere((t) => t.id == transactionId);
    if (idx != -1) {
      final t = wallet.transactions[idx];
      if (t.status == TransactionStatus.pending) {
        wallet.transactions[idx] = MerchantTransaction(
          id: t.id,
          type: t.type,
          title: t.title,
          date: 'معتمدة الآن',
          amount: t.amount,
          status: TransactionStatus.completed,
          statusLabel: 'مكتملة',
          wallet: t.wallet,
          ref: t.ref,
        );
        wallet.pendingBalance -= t.amount;
        if (wallet.pendingBalance < 0) wallet.pendingBalance = 0;
        wallet.balance += t.amount;

        if (role == AuthUserRole.merchant) {
          _walletBalance = wallet.balance;
          _pendingBalance = wallet.pendingBalance;
          _transactions = wallet.transactions;
        }

        notifyListeners();
      }
    }
  }

  /// Approves the latest pending deposit for a specific role
  bool simulateApproveLatestDepositForRole(AuthUserRole role) {
    final wallet = _roleWallets[role];
    if (wallet == null) return false;

    final pendingIdx =
        wallet.transactions.indexWhere((t) => t.status == TransactionStatus.pending);
    if (pendingIdx != -1) {
      simulateApproveDepositForRole(role, wallet.transactions[pendingIdx].id);
      return true;
    }
    return false;
  }

  /// Simulates immediate approval of pending deposit
  void simulateApproveDeposit(String transactionId) {
    simulateApproveDepositForRole(AuthUserRole.merchant, transactionId);
  }

  /// Approves the latest pending deposit for convenient 1-tap simulation
  bool simulateApproveLatestDeposit() {
    return simulateApproveLatestDepositForRole(AuthUserRole.merchant);
  }

  /// Deducts fare from wallet, creates payment transaction, updates order status,
  /// reveals contact information and initiates trip tracking.
  /// Prevents duplicate payments on the same order.
  bool payForOrder(
    String orderId,
    double? amount, {
    String? driverName,
    String? routeDescription,
    String? driverPhone,
    bool? throwOnError,
  }) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1 && _orders[idx].isPaid) {
      // Prevent duplicate payment
      return false;
    }

    final order = idx != -1 ? _orders[idx] : null;
    final paymentAmount = amount ??
        ((order?.agreedFare != null)
            ? (order!.agreedFare! + 15000.0)
            : (order?.expectedPrice != null)
                ? (order!.expectedPrice! + 15000.0)
                : (order?.maxBudget ?? 0.0));

    if (!canPay(paymentAmount)) {
      if (throwOnError ?? (amount != null)) {
        throw Exception('رصيد المحفظة غير كافٍ لإتمام عملية الدفع');
      }
      return false;
    }

    _walletBalance -= paymentAmount;

    final paymentTxn = MerchantTransaction(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      type: TransactionType.payment,
      title: 'دفع أجرة نقل (طلب #$orderId)',
      date: 'الآن',
      amount: -paymentAmount,
      status: TransactionStatus.completed,
      statusLabel: 'مكتملة',
      wallet: 'المحفظة الداخلية',
      ref: orderId,
    );

    _transactions.insert(0, paymentTxn);

    final assignedDriverName = driverName ??
        (idx != -1 ? _orders[idx].driverName : null) ??
        'الجهة المنفذة المعتمدة';

    if (idx != -1) {
      final current = _orders[idx];
      _orders[idx] = current.copyWith(
        status: MerchantOrderStatus.assignedDriver,
        driverName: assignedDriverName,
        isPaid: true,
        agreedFare: current.agreedFare ??
            (paymentAmount > 15000 ? paymentAmount - 15000 : paymentAmount),
        targetProviderPhone: driverPhone ?? current.targetProviderPhone,
      );
    } else {
      updateOrderStatus(
        orderId,
        MerchantOrderStatus.assignedDriver,
        driverName: assignedDriverName,
      );
    }

    // Initialize provider financial settlement record (Section 6)
    const platformFee = 15000.0;
    final netProvider =
        paymentAmount > platformFee ? paymentAmount - platformFee : paymentAmount;
    _providerSettlements[orderId] = ProviderSettlementRecord(
      orderId: orderId,
      providerName: assignedDriverName,
      requesterPaidAmount: paymentAmount,
      providerDueAmount: netProvider,
      platformFee: platformFee,
      status: ProviderSettlementStatus.pendingCompletion,
      createdAt: DateTime.now(),
    );

    // Stage 1: تم تأكيد الاتفاق والدفع (Trip execution begins ONLY after successful payment)
    _tripStageIndexes[orderId] = 1;
    notifyListeners();
    return true;
  }

  // ===========================================================================
  // TRIP EXECUTION & TRACKING (المراحل التسع للرحلة وتتبعها وإغلاقها وتقييمها)
  // ===========================================================================
  int getTripStageIndex(String orderId) {
    final order = getOrderById(orderId);
    if (order != null && !order.isPaid) return 0;
    return _tripStageIndexes[orderId] ?? 0;
  }

  int getTripCurrentStage(String orderId) => getTripStageIndex(orderId);

  bool canAdvanceTripStage(String orderId) {
    final order = getOrderById(orderId);
    if (order == null || !order.isPaid) return false;
    final current = getTripStageIndex(orderId);
    return current >= 1 && current < 7;
  }

  bool advanceTripStage(String orderId) {
    final current = getTripStageIndex(orderId);
    if (current == 0) {
      // Cannot start or advance trip before payment!
      return false;
    }
    if (current >= 7) {
      // Reached delivery point (stage 7). Needs confirmDelivery to reach stage 8
      return false;
    }

    final nextStage = current + 1;
    _tripStageIndexes[orderId] = nextStage;
    if (nextStage >= 5 && nextStage <= 6) {
      updateOrderStatus(orderId, MerchantOrderStatus.inTransit);
    }
    notifyListeners();
    return true;
  }

  /// Confirms cargo delivery (Stage 8)
  /// Strictly requires stage >= 7 (truck must have arrived at delivery location).
  bool confirmDelivery(String orderId) {
    final order = getOrderById(orderId);
    if (order == null || !order.isPaid) return false;
    final current = getTripStageIndex(orderId);
    if (current < 7) {
      // Delivery cannot be confirmed before arriving at destination!
      return false;
    }

    _tripStageIndexes[orderId] = 8;
    notifyListeners();
    return true;
  }

  /// Closes the trip (Stage 9)
  /// Strictly requires delivery confirmation (stage == 8).
  /// Releases provider financial settlement (pendingCompletion -> settled).
  /// Idempotent: repeated clicks do not double-close or cause duplicate side effects.
  bool closeTrip(String orderId) {
    final order = getOrderById(orderId);
    if (order == null || !order.isPaid) return false;
    final current = getTripStageIndex(orderId);

    // Idempotent: if already closed, return true safely
    if (current == 9 || order.isClosed) {
      return true;
    }

    // Must have confirmed delivery first
    if (current < 8) {
      return false;
    }

    _tripStageIndexes[orderId] = 9;

    // Update order status to completed and set isClosed & closedAt
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(
        status: MerchantOrderStatus.completed,
        isClosed: true,
        closedAt: DateTime.now(),
      );
    }

    // Settle provider entitlement (Section 6)
    if (_providerSettlements.containsKey(orderId)) {
      final s = _providerSettlements[orderId]!;
      if (s.status == ProviderSettlementStatus.pendingCompletion) {
        _providerSettlements[orderId] = s.copyWith(
          status: ProviderSettlementStatus.settled,
          settledAt: DateTime.now(),
        );
      }
    }

    notifyListeners();
    return true;
  }

  void resetTripStage(String orderId) {
    _tripStageIndexes[orderId] = 0;
    notifyListeners();
  }

  // ===========================================================================
  // PROVIDER SETTLEMENT & RATINGS (التسوية المالية والتقييم)
  // ===========================================================================
  ProviderSettlementRecord? getSettlementForOrder(String orderId) {
    return _providerSettlements[orderId];
  }

  ProviderSettlementRecord? getProviderSettlement(String orderId) =>
      getSettlementForOrder(orderId);

  bool hasOrderBeenRated(String orderId) {
    return _orderRatings.containsKey(orderId);
  }

  bool hasOrderRating(String orderId) => hasOrderBeenRated(orderId);

  TripRatingRecord? getRatingForOrder(String orderId) {
    return _orderRatings[orderId];
  }

  TripRatingRecord? getOrderRating(String orderId) =>
      getRatingForOrder(orderId);

  int getTripStage(String orderId) => getTripStageIndex(orderId);

  /// Submits rating for the trip (Section 12)
  /// Enabled ONLY after trip closure (Stage 9).
  /// Strictly prevents duplicate ratings for the same order.
  bool submitTripRating(
    String orderId,
    double rating, {
    String comment = '',
  }) {
    final order = getOrderById(orderId);
    if (order == null || !order.isPaid) return false;
    final current = getTripStageIndex(orderId);
    if (current < 9) {
      // Cannot rate before trip closure!
      return false;
    }
    if (hasOrderBeenRated(orderId)) {
      // Prevent duplicate rating
      return false;
    }

    _orderRatings[orderId] = TripRatingRecord(
      orderId: orderId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    notifyListeners();
    return true;
  }
}
