import 'package:flutter/material.dart';

import 'cargo_bid_opportunity.dart';
import '../../../merchant/domain/models/merchant_simulation_store.dart';

/// Milestone definition for driver trip execution
class DriverTripMilestone {
  final int stageNumber;
  final String title;
  final String description;
  final String actionButtonLabel;
  final String confirmationPrompt;
  final bool isConfirmationRequired;

  const DriverTripMilestone({
    required this.stageNumber,
    required this.title,
    required this.description,
    required this.actionButtonLabel,
    required this.confirmationPrompt,
    this.isConfirmationRequired = false,
  });

  static const List<DriverTripMilestone> allMilestones = [
    DriverTripMilestone(
      stageNumber: 1,
      title: 'قبول الطلب وتأكيد الدفع',
      description: 'تم توثيق الاتفاق مع التاجر وتأمين المقابل المالي عبر المنصة.',
      actionButtonLabel: 'بدء الاستعداد والتوجه للتحميل',
      confirmationPrompt: 'هل أنت مستعد للانطلاق إلى موقع التحميل الآن؟',
    ),
    DriverTripMilestone(
      stageNumber: 2,
      title: 'التوجه إلى موقع التحميل',
      description: 'الشاحنة في طريقها إلى مستودع التاجر لاستلام الحمولة.',
      actionButtonLabel: 'تأكيد الوصول لموقع التحميل',
      confirmationPrompt: 'هل وصلت فعلياً إلى بوابة مستودع التحميل؟',
    ),
    DriverTripMilestone(
      stageNumber: 3,
      title: 'الوصول إلى موقع التحميل',
      description: 'وصلت الشاحنة إلى الموقع وبانتظار بدء التحميل والتستيف.',
      actionButtonLabel: 'بدء عملية التحميل والتستيف',
      confirmationPrompt: 'هل بدأ عمال المستودع في تحميل البضاعة على الشاحنة؟',
    ),
    DriverTripMilestone(
      stageNumber: 4,
      title: 'عملية التحميل والتستيف',
      description: 'جاري تحميل وتثبيت الحمولات والتأكد من أجهزة التبريد والأربطة.',
      actionButtonLabel: 'تأكيد استلام الحمولة وبدء النقل',
      confirmationPrompt: 'تأكيد: هل تم فحص الحمولة واستلام البوليصة وجاهز للانطلاق؟',
      isConfirmationRequired: true,
    ),
    DriverTripMilestone(
      stageNumber: 5,
      title: 'انطلاق الرحلة وبدء النقل',
      description: 'تم استلام الشحنة رسمياً وبدأت الرحلة على الطريق السريع.',
      actionButtonLabel: 'متابعة السير عبر نقاط الطريق',
      confirmationPrompt: 'هل تريد تحديث نقطة العبور الحالية للشاحنة؟',
    ),
    DriverTripMilestone(
      stageNumber: 6,
      title: 'متابعة الرحلة (في الطريق)',
      description: 'الشاحنة تعبر ممر النقل السريع نحو مدينة التسليم.',
      actionButtonLabel: 'تأكيد الوصول إلى موقع التسليم',
      confirmationPrompt: 'تأكيد: هل وصلت الشاحنة إلى رصيف التسليم النهائي؟',
      isConfirmationRequired: true,
    ),
    DriverTripMilestone(
      stageNumber: 7,
      title: 'الوصول إلى موقع التسليم',
      description: 'وصلت الشاحنة إلى مستودع العميل وبدأت معاينة الطرود.',
      actionButtonLabel: 'تأكيد تسليم الشحنة للعميل',
      confirmationPrompt: 'هل تم تفريغ الشحنة بالكامل وتوقيع سند الاستلام؟',
      isConfirmationRequired: true,
    ),
    DriverTripMilestone(
      stageNumber: 8,
      title: 'تأكيد التسليم بنجاح',
      description: 'تم تسليم الشحنة وفحصها وتوقيع الاستلام من المستلم.',
      actionButtonLabel: 'إغلاق الرحلة وتحصيل الأرباح',
      confirmationPrompt: 'هل تود إنهاء الرحلة رسميًا وإيداع الأجر في محفظتك؟',
      isConfirmationRequired: true,
    ),
    DriverTripMilestone(
      stageNumber: 9,
      title: 'اكتملت الرحلة وتمت التسوية',
      description: 'تم إغلاق الرحلة وإيداع المستحقات في محفظتك بنجاح.',
      actionButtonLabel: 'عرض إيصال التسوية',
      confirmationPrompt: '',
    ),
  ];

  static DriverTripMilestone forStage(int stage) {
    return allMilestones.firstWhere(
      (m) => m.stageNumber == stage,
      orElse: () => allMilestones.first,
    );
  }
}

/// Model representing a driver trip with complete execution lifecycle
class DriverTrip {
  final String id;
  final String orderId;
  final String cargoTitle;
  final String merchantName;
  final String merchantPhone;
  final String originCity;
  final String destinationCity;
  final int distanceKm;
  final int payoutYmr;
  final String currentCheckpoint;
  final int stage; // 1 to 9
  final bool isCompleted;
  final bool isCancelled;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String cargoDetails;
  final double weightTons;
  final String truckType;
  final String pickupLocation;
  final String dropoffLocation;
  final String loadingWindow;
  final String notes;

  const DriverTrip({
    required this.id,
    required this.orderId,
    required this.cargoTitle,
    required this.merchantName,
    required this.merchantPhone,
    required this.originCity,
    required this.destinationCity,
    required this.distanceKm,
    required this.payoutYmr,
    required this.currentCheckpoint,
    required this.stage,
    this.isCompleted = false,
    this.isCancelled = false,
    required this.createdAt,
    this.completedAt,
    required this.cargoDetails,
    required this.weightTons,
    required this.truckType,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.loadingWindow,
    required this.notes,
  });

  DriverTrip copyWith({
    String? id,
    String? orderId,
    String? cargoTitle,
    String? merchantName,
    String? merchantPhone,
    String? originCity,
    String? destinationCity,
    int? distanceKm,
    int? payoutYmr,
    String? currentCheckpoint,
    int? stage,
    bool? isCompleted,
    bool? isCancelled,
    DateTime? createdAt,
    DateTime? completedAt,
    String? cargoDetails,
    double? weightTons,
    String? truckType,
    String? pickupLocation,
    String? dropoffLocation,
    String? loadingWindow,
    String? notes,
  }) {
    return DriverTrip(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      cargoTitle: cargoTitle ?? this.cargoTitle,
      merchantName: merchantName ?? this.merchantName,
      merchantPhone: merchantPhone ?? this.merchantPhone,
      originCity: originCity ?? this.originCity,
      destinationCity: destinationCity ?? this.destinationCity,
      distanceKm: distanceKm ?? this.distanceKm,
      payoutYmr: payoutYmr ?? this.payoutYmr,
      currentCheckpoint: currentCheckpoint ?? this.currentCheckpoint,
      stage: stage ?? this.stage,
      isCompleted: isCompleted ?? this.isCompleted,
      isCancelled: isCancelled ?? this.isCancelled,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      cargoDetails: cargoDetails ?? this.cargoDetails,
      weightTons: weightTons ?? this.weightTons,
      truckType: truckType ?? this.truckType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      loadingWindow: loadingWindow ?? this.loadingWindow,
      notes: notes ?? this.notes,
    );
  }

  String get stageTitle => DriverTripMilestone.forStage(stage).title;
  String get stageDescription => DriverTripMilestone.forStage(stage).description;

  double get progressRatio {
    if (isCompleted) return 1.0;
    return (stage.clamp(1, 9) - 1) / 8.0;
  }

  String get routeLabel => '$originCity ← $destinationCity';

  DriverActiveTrip toActiveTrip() {
    return DriverActiveTrip(
      tripId: id,
      cargoTitle: cargoTitle,
      merchantName: merchantName,
      merchantPhone: merchantPhone,
      originCity: originCity,
      destinationCity: destinationCity,
      currentCheckpoint: currentCheckpoint,
      progressRatio: progressRatio,
      payoutYmr: payoutYmr,
      estimatedArrival: stage >= 7 ? 'وصلت للشحنة' : 'ساعتان و 15 دقيقة',
      currentStatusText: stageTitle,
    );
  }
}

/// Bid placed by driver on an open marketplace cargo
class DriverBidItem {
  final String id;
  final String cargoId;
  final String cargoTitle;
  final String originCity;
  final String destinationCity;
  final int distanceKm;
  final int bidAmount;
  final int targetBudget;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime submittedAt;
  final String cargoType;
  final bool isPrivate;
  final String truckType;
  final String currencyCode; // 'YER', 'SAR', 'USD'
  final String? notes;

  const DriverBidItem({
    required this.id,
    required this.cargoId,
    required this.cargoTitle,
    required this.originCity,
    required this.destinationCity,
    required this.distanceKm,
    required this.bidAmount,
    required this.targetBudget,
    required this.status,
    required this.submittedAt,
    required this.cargoType,
    this.isPrivate = false,
    required this.truckType,
    this.currencyCode = 'YER',
    this.notes,
  });

  String get currencyLabel {
    switch (currencyCode) {
      case 'SAR':
        return 'ريال سعودي';
      case 'USD':
        return 'دولار أمريكي';
      case 'YER':
      default:
        return 'ريال يمني';
    }
  }

  String get currencySymbol {
    switch (currencyCode) {
      case 'SAR':
        return 'ر.س';
      case 'USD':
        return '\$';
      case 'YER':
      default:
        return 'ر.ي';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
      default:
        return 'قيد الانتظار';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'accepted':
        return const Color(0xFF16A34A);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'pending':
      default:
        return const Color(0xFF2563EB);
    }
  }
}

/// Direct transport request sent exclusively to the driver
class DriverDirectRequestItem {
  final String id;
  final String cargoTitle;
  final String merchantName;
  final String merchantPhone;
  final String originCity;
  final String destinationCity;
  final int offeredFare;
  final String status; // 'pending', 'accepted', 'declined'
  final String loadingWindow;
  final String truckType;
  final String notes;
  final DateTime receivedAt;

  const DriverDirectRequestItem({
    required this.id,
    required this.cargoTitle,
    required this.merchantName,
    required this.merchantPhone,
    required this.originCity,
    required this.destinationCity,
    required this.offeredFare,
    required this.status,
    required this.loadingWindow,
    required this.truckType,
    required this.notes,
    required this.receivedAt,
  });

  DriverDirectRequestItem copyWith({
    String? status,
  }) {
    return DriverDirectRequestItem(
      id: id,
      cargoTitle: cargoTitle,
      merchantName: merchantName,
      merchantPhone: merchantPhone,
      originCity: originCity,
      destinationCity: destinationCity,
      offeredFare: offeredFare,
      status: status ?? this.status,
      loadingWindow: loadingWindow,
      truckType: truckType,
      notes: notes,
      receivedAt: receivedAt,
    );
  }
}

/// Central In-Memory Simulation Store for Driver State
/// Fully synchronized across Driver Home, Trips, Orders, and Cargo Map
class DriverSimulationStore extends ChangeNotifier {
  static final DriverSimulationStore instance = DriverSimulationStore._internal();
  factory DriverSimulationStore() => instance;

  DriverSimulationStore._internal() {
    resetToDemo();
  }

  late List<CargoBidOpportunity> _opportunities;
  late List<DriverBidItem> _bids;
  late List<DriverDirectRequestItem> _directRequests;
  DriverTrip? _activeTrip;
  late List<DriverTrip> _completedTrips;
  late List<DriverTrip> _upcomingTrips;

  // Getters
  List<CargoBidOpportunity> get opportunities => List.unmodifiable(_opportunities);
  List<DriverBidItem> get bids => List.unmodifiable(_bids);
  List<DriverDirectRequestItem> get directRequests => List.unmodifiable(_directRequests);
  DriverTrip? get activeTrip => _activeTrip;
  List<DriverTrip> get completedTrips => List.unmodifiable(_completedTrips);
  List<DriverTrip> get upcomingTrips => List.unmodifiable(_upcomingTrips);

  int get completedTripsCount => _completedTrips.length;
  int get activeOrdersCount =>
      _bids.where((b) => b.status == 'pending').length +
      _directRequests.where((d) => d.status == 'pending').length;
  int get availableOpportunitiesCount => _opportunities.length;

  void resetToDemo() {
    _opportunities = List.from(CargoBidOpportunity.demoOpportunities);

    // Initial demo bids submitted by the driver (matching "عروضي النشطة 3")
    _bids = [
      DriverBidItem(
        id: 'BID-701',
        cargoId: 'CRG-101',
        cargoTitle: 'أسمنت مكيس (25 طن)',
        originCity: 'الدمام',
        destinationCity: 'الرياض',
        distanceKm: 312,
        bidAmount: 5000,
        targetBudget: 5200,
        status: 'pending',
        submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
        cargoType: 'مواد بناء',
        truckType: 'شاحنة نقل ثقيل',
      ),
      DriverBidItem(
        id: 'BID-702',
        cargoId: 'CRG-103',
        cargoTitle: 'حديد ومواد بناء (28 طن)',
        originCity: 'الجبيل',
        destinationCity: 'الهفوف',
        distanceKm: 190,
        bidAmount: 2850,
        targetBudget: 2900,
        status: 'pending',
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        cargoType: 'حديد ومقاولات',
        truckType: 'قاطرة تريلا سطحة',
      ),
      DriverBidItem(
        id: 'BID-703',
        cargoId: 'CRG-9021',
        cargoTitle: 'شحنة خضار وفواكه مبردة (24 طن)',
        originCity: 'الحديدة - الميناء',
        destinationCity: 'صنعاء - سوق ذهبان',
        distanceKm: 226,
        bidAmount: 375000,
        targetBudget: 380000,
        status: 'pending',
        submittedAt: DateTime.now().subtract(const Duration(hours: 7)),
        cargoType: 'مواد غذائية مبردة',
        truckType: 'قاطرة براد',
      ),
    ];

    // Initial private request directed to driver
    _directRequests = [
      DriverDirectRequestItem(
        id: 'REQ-PRIV-01',
        cargoTitle: 'خضار وفواكه طازجة (16 طن)',
        merchantName: 'مزارع القصيم الخضراء',
        merchantPhone: '+967 770 112 233',
        originCity: 'القصيم',
        destinationCity: 'الرياض',
        offeredFare: 3800,
        status: 'pending',
        loadingWindow: 'اليوم: 03:00 م - 06:00 م',
        truckType: 'دينا براد',
        notes: 'صناديق خضار وفواكه طازجة متجهة لسوق الجملة المركزي.',
        receivedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    // Ongoing active trip matching the reference image: TRP-4091
    _activeTrip = DriverTrip(
      id: 'TRP-4091',
      orderId: 'REQ-1023',
      cargoTitle: 'أدوية ومستلزمات طبية مبردة (12 طن)',
      merchantName: 'مستودع الأمل الدوائي المركزي',
      merchantPhone: '+967 771 234 567',
      originCity: 'صنعاء',
      destinationCity: 'تعز',
      distanceKm: 256,
      payoutYmr: 340000,
      currentCheckpoint: 'نقيل سمارة - الكيلو 92',
      stage: 6, // In transit (matches reference: في الطريق إلى نقطة التسليم)
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      cargoDetails: 'صناديق أدوية ومحاليل وريدية مبردة بحرارة ثابتة 4 درجات مئوية.',
      weightTons: 12.0,
      truckType: 'قاطرة براد',
      pickupLocation: 'صنعاء — شارع الستين الجنوبي، مستودعات الأدوية',
      dropoffLocation: 'تعز — شارع جمال، المستودع الإقليمي',
      loadingWindow: 'اليوم: 06:00 ص',
      notes: 'الحمولة حساسة للحرارة، يلزم المحافظة على التبريد دون انقطاع.',
    );

    // Upcoming accepted trips ready to begin
    _upcomingTrips = [
      DriverTrip(
        id: 'TRP-4092',
        orderId: 'REQ-1027',
        cargoTitle: 'أجهزة ومعدات كهرومنزلية (8 طن)',
        merchantName: 'شركة النور للإلكترونيات',
        merchantPhone: '+967 772 889 900',
        originCity: 'عدن',
        destinationCity: 'لحج',
        distanceKm: 45,
        payoutYmr: 120000,
        currentCheckpoint: 'بانتظار انطلاق الرحلة',
        stage: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        cargoDetails: 'شاشات وغسالات كراتين أصلية مغلفة.',
        weightTons: 8.0,
        truckType: 'دينا صندوق مغلق',
        pickupLocation: 'عدن — ميناء المعلا',
        dropoffLocation: 'لحج — الحوطة السوق العام',
        loadingWindow: 'غداً: 08:00 ص',
        notes: 'الحمولة مؤمن عليها بالكامل.',
      ),
    ];

    // Exactly 18 completed trips matching the reference badge "الرحلات المكتملة 18"
    _completedTrips = List.generate(18, (index) {
      final tripNumber = 4090 - index;
      final cities = [
        ['صنعاء', 'الحديدة'],
        ['عدن', 'تعز'],
        ['المكلا', 'مأرب'],
        ['ذمار', 'إب'],
        ['الدمام', 'الرياض'],
        ['الجبيل', 'الهفوف'],
      ];
      final pair = cities[index % cities.length];
      final cargos = [
        'مواد غذائية معلبة (20 طن)',
        'حديد تسليح وأنابيب (25 طن)',
        'أسمنت ومواد بناء (30 طن)',
        'أدوات صحية وسيراميك (15 طن)',
        'زيوت نباتية ومعلبات (18 طن)',
      ];
      final cargo = cargos[index % cargos.length];

      return DriverTrip(
        id: 'TRP-$tripNumber',
        orderId: 'ORD-HIST-$tripNumber',
        cargoTitle: cargo,
        merchantName: 'شركة النقل الوطنية الموحدة',
        merchantPhone: '+967 771 000 000',
        originCity: pair[0],
        destinationCity: pair[1],
        distanceKm: 180 + (index * 15),
        payoutYmr: 280000 + (index * 12000),
        currentCheckpoint: 'تم التسليم بنجاح',
        stage: 9,
        isCompleted: true,
        createdAt: DateTime.now().subtract(Duration(days: index + 2)),
        completedAt: DateTime.now().subtract(Duration(days: index + 1)),
        cargoDetails: 'تم تسليم الحمولة بالكامل بحالة ممتازة وبدون ملاحظات.',
        weightTons: 20.0,
        truckType: 'شاحنة نقل ثقيل',
        pickupLocation: '${pair[0]} — المستودع الرئيسي',
        dropoffLocation: '${pair[1]} — المركز اللوجستي',
        loadingWindow: 'مكتمل',
        notes: 'تم استلام وتوثيق سند التسليم والتوقيع الإلكتروني.',
      );
    });

    notifyListeners();
  }

  /// Advances the active trip to the next milestone stage
  bool advanceActiveTripStage() {
    if (_activeTrip == null) return false;
    final current = _activeTrip!.stage;
    if (current >= 8) {
      // Transition to completed
      return completeActiveTrip();
    }

    final next = current + 1;
    String newCheckpoint = _activeTrip!.currentCheckpoint;
    if (next == 2) {
      newCheckpoint = 'في الطريق إلى موقع التحميل';
    } else if (next == 3) {
      newCheckpoint = 'وصلت إلى بوابة التحميل';
    } else if (next == 4) {
      newCheckpoint = 'جاري التحميل والتستيف';
    } else if (next == 5) {
      newCheckpoint = 'انطلاق الرحلة على الطريق السريع';
    } else if (next == 6) {
      newCheckpoint = 'نقيل سمارة - الكيلو 92';
    } else if (next == 7) {
      newCheckpoint = 'وصلت إلى رصيف التسليم';
    } else if (next == 8) {
      newCheckpoint = 'تم تسليم الشحنة للعميل بنجاح';
    }

    _activeTrip = _activeTrip!.copyWith(
      stage: next,
      currentCheckpoint: newCheckpoint,
    );

    // Sync with MerchantSimulationStore if linked
    MerchantSimulationStore.instance.advanceTripStage(_activeTrip!.orderId);

    notifyListeners();
    return true;
  }

  /// Confirms delivery at destination
  bool confirmActiveTripDelivery() {
    if (_activeTrip == null || _activeTrip!.stage < 7) return false;
    _activeTrip = _activeTrip!.copyWith(
      stage: 8,
      currentCheckpoint: 'تم تسليم الشحنة للعميل بنجاح',
    );
    MerchantSimulationStore.instance.confirmDelivery(_activeTrip!.orderId);
    notifyListeners();
    return true;
  }

  /// Completes and closes the trip
  bool completeActiveTrip() {
    if (_activeTrip == null) return false;
    final finishedTrip = _activeTrip!.copyWith(
      stage: 9,
      isCompleted: true,
      completedAt: DateTime.now(),
      currentCheckpoint: 'تمت التسوية وإغلاق الرحلة',
    );

    _completedTrips.insert(0, finishedTrip);
    _activeTrip = null;

    // Advance any upcoming trip to active if available
    if (_upcomingTrips.isNotEmpty) {
      _activeTrip = _upcomingTrips.removeAt(0).copyWith(stage: 2);
    }

    notifyListeners();
    return true;
  }

  final Set<String> _favoriteCargoIds = {};

  // Favorites
  bool isFavorite(String cargoId) => _favoriteCargoIds.contains(cargoId);
  void toggleFavorite(String cargoId) {
    if (_favoriteCargoIds.contains(cargoId)) {
      _favoriteCargoIds.remove(cargoId);
    } else {
      _favoriteCargoIds.add(cargoId);
    }
    notifyListeners();
  }

  // Duplicate bid check
  bool hasBidOnCargo(String cargoId) =>
      _bids.any((b) => b.cargoId == cargoId && b.status != 'rejected');

  DriverBidItem? getBidForCargo(String cargoId) {
    for (final b in _bids) {
      if (b.cargoId == cargoId && b.status != 'rejected') return b;
    }
    return null;
  }

  CargoBidOpportunity? findOpportunityById(String id) {
    for (final opp in _opportunities) {
      if (opp.id == id) return opp;
    }
    return null;
  }

  /// Submits a new bid on a cargo opportunity
  bool submitBid({
    required CargoBidOpportunity cargo,
    required int amount,
    String currencyCode = 'YER',
    String? notes,
  }) {
    if (hasBidOnCargo(cargo.id)) {
      return false;
    }

    final newBid = DriverBidItem(
      id: 'BID-${DateTime.now().millisecondsSinceEpoch % 10000}',
      cargoId: cargo.id,
      cargoTitle: cargo.title,
      originCity: cargo.originCity,
      destinationCity: cargo.destinationCity,
      distanceKm: cargo.distanceKm,
      bidAmount: amount,
      targetBudget: cargo.targetBudgetYmr,
      status: 'pending',
      submittedAt: DateTime.now(),
      cargoType: cargo.requiredTruckType,
      truckType: cargo.requiredTruckType,
      currencyCode: currencyCode,
      notes: notes,
    );

    _bids.insert(0, newBid);
    notifyListeners();
    return true;
  }

  /// Accepts a direct private transport request
  void acceptDirectRequest(String id) {
    final index = _directRequests.indexWhere((d) => d.id == id);
    if (index != -1) {
      _directRequests[index] = _directRequests[index].copyWith(status: 'accepted');
      notifyListeners();
    }
  }

  /// Declines a direct private transport request
  void declineDirectRequest(String id) {
    final index = _directRequests.indexWhere((d) => d.id == id);
    if (index != -1) {
      _directRequests[index] = _directRequests[index].copyWith(status: 'declined');
      notifyListeners();
    }
  }
}
