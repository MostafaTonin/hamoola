import 'package:flutter/material.dart';

/// Role of the Transport Office in the trip
enum OfficeTripRole {
  /// كمقدم خدمة: الرحلات التي يقدم المكتب خدمة النقل فيها للعميل
  provider('كمقدم خدمة'),

  /// كطالب خدمة: الطلبات والرحلات التي ينشئها المكتب بحثاً عن سائق/ناقل
  seeker('كطالب خدمة');

  final String label;
  const OfficeTripRole(this.label);
}

/// Status of the trip
enum OfficeTripStatus {
  /// بانتظار البدء (أسندت للمكتب ولم تبدأ بعد)
  pendingStart('بانتظار البدء'),

  /// قيد التنفيذ (بدأت الشاحنة الرحلة)
  inProgress('قيد التنفيذ'),

  /// مكتملة (تم التسليم بنجاح)
  completed('مكتملة'),

  /// ملغاة
  cancelled('ملغاة');

  final String label;
  const OfficeTripStatus(this.label);
}

/// Horizontal filter for "كمقدم خدمة"
enum OfficeTripFilter {
  all('الكل'),
  pendingStart('بانتظار البدء'),
  inProgress('قيد التنفيذ'),
  completed('مكتملة'),
  cancelled('ملغاة');

  final String label;
  const OfficeTripFilter(this.label);
}

/// Milestone in the trip's timeline
class OfficeTripMilestone {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final bool isCompleted;

  const OfficeTripMilestone({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    this.isCompleted = true,
  });

  OfficeTripMilestone copyWith({
    String? title,
    String? description,
    DateTime? timestamp,
    IconData? icon,
    bool? isCompleted,
  }) {
    return OfficeTripMilestone(
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      icon: icon ?? this.icon,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Driver details attached to a trip
class OfficeTripDriver {
  final String id;
  final String name;
  final String phone;
  final String avatarAsset;
  final String vehiclePlate;

  const OfficeTripDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatarAsset,
    required this.vehiclePlate,
  });
}

/// Client rating for completed trips
class OfficeTripRating {
  final double stars;
  final String? comment;
  final DateTime date;

  const OfficeTripRating({
    required this.stars,
    this.comment,
    required this.date,
  });
}

/// Model representing a Trip for the Transport Office
class OfficeTrip {
  final String id; // e.g. R-1042
  final OfficeTripRole role;
  final OfficeTripStatus status;

  // Origin & Destination
  final String originCity;
  final String originCountry;
  final String? originArea;
  final String destinationCity;
  final String destinationCountry;
  final String? destinationArea;

  // Distance & Metrics
  final int distanceKm;
  final int estimatedDurationHours;
  final int? remainingDistanceKm;

  // Client Details
  final String clientName;
  final String clientCompany;
  final String clientPhone;

  // Truck & Cargo Specs
  final String cargoTitle;
  final String truckType; // e.g. 'شاحنة سطحة', 'شاحنة قلابة'
  final double weightTons; // e.g. 20.0

  // Assigned Driver (optional if not yet assigned)
  final OfficeTripDriver? driver;

  // Financials
  final int agreedPriceSar; // المبلغ المتفق عليه بالريال السعودي

  // Timestamps
  final DateTime scheduledDate;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  // Rating (if completed)
  final OfficeTripRating? rating;

  // Milestones
  final List<OfficeTripMilestone> milestones;

  const OfficeTrip({
    required this.id,
    required this.role,
    required this.status,
    required this.originCity,
    required this.originCountry,
    this.originArea,
    required this.destinationCity,
    required this.destinationCountry,
    this.destinationArea,
    required this.distanceKm,
    required this.estimatedDurationHours,
    this.remainingDistanceKm,
    required this.clientName,
    required this.clientCompany,
    required this.clientPhone,
    required this.cargoTitle,
    required this.truckType,
    required this.weightTons,
    this.driver,
    required this.agreedPriceSar,
    required this.scheduledDate,
    this.actualStartTime,
    this.actualEndTime,
    this.cancelledAt,
    this.cancellationReason,
    this.rating,
    required this.milestones,
  });

  /// Formatted route string: e.g. "صنعاء، اليمن ← الرياض، السعودية"
  String get formattedRoute {
    final from = originCountry.isNotEmpty && originCountry != destinationCountry
        ? '$originCity، $originCountry'
        : originCity;
    final to = destinationCountry.isNotEmpty && originCountry != destinationCountry
        ? '$destinationCity، $destinationCountry'
        : destinationCity;
    return '$from ← $to';
  }

  /// Whether the scheduled start time is in the past (overdue without start)
  bool get isOverdue {
    if (status != OfficeTripStatus.pendingStart) return false;
    return DateTime.now().isAfter(scheduledDate);
  }

  /// Whether the scheduled start time is today/near (within 6 hours)
  bool get isApproaching {
    if (status != OfficeTripStatus.pendingStart) return false;
    final diff = scheduledDate.difference(DateTime.now());
    return diff.inHours >= 0 && diff.inHours <= 6;
  }

  OfficeTrip copyWith({
    String? id,
    OfficeTripRole? role,
    OfficeTripStatus? status,
    String? originCity,
    String? originCountry,
    String? originArea,
    String? destinationCity,
    String? destinationCountry,
    String? destinationArea,
    int? distanceKm,
    int? estimatedDurationHours,
    int? remainingDistanceKm,
    String? clientName,
    String? clientCompany,
    String? clientPhone,
    String? cargoTitle,
    String? truckType,
    double? weightTons,
    OfficeTripDriver? driver,
    int? agreedPriceSar,
    DateTime? scheduledDate,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    DateTime? cancelledAt,
    String? cancellationReason,
    OfficeTripRating? rating,
    List<OfficeTripMilestone>? milestones,
  }) {
    return OfficeTrip(
      id: id ?? this.id,
      role: role ?? this.role,
      status: status ?? this.status,
      originCity: originCity ?? this.originCity,
      originCountry: originCountry ?? this.originCountry,
      originArea: originArea ?? this.originArea,
      destinationCity: destinationCity ?? this.destinationCity,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      destinationArea: destinationArea ?? this.destinationArea,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationHours: estimatedDurationHours ?? this.estimatedDurationHours,
      remainingDistanceKm: remainingDistanceKm ?? this.remainingDistanceKm,
      clientName: clientName ?? this.clientName,
      clientCompany: clientCompany ?? this.clientCompany,
      clientPhone: clientPhone ?? this.clientPhone,
      cargoTitle: cargoTitle ?? this.cargoTitle,
      truckType: truckType ?? this.truckType,
      weightTons: weightTons ?? this.weightTons,
      driver: driver ?? this.driver,
      agreedPriceSar: agreedPriceSar ?? this.agreedPriceSar,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rating: rating ?? this.rating,
      milestones: milestones ?? this.milestones,
    );
  }
}

/// Notification item logged when trip status changes
class OfficeTripNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;

  const OfficeTripNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
  });
}

/// Store managing trips for the Transport Office
class TransportOfficeTripsStore extends ChangeNotifier {
  static final TransportOfficeTripsStore _instance = TransportOfficeTripsStore._internal();
  static TransportOfficeTripsStore get instance => _instance;

  TransportOfficeTripsStore._internal() {
    _initDefaultTrips();
  }

  final List<OfficeTrip> _trips = [];
  final List<OfficeTripNotification> _notifications = [];

  List<OfficeTrip> get allTrips => List.unmodifiable(_trips);
  List<OfficeTripNotification> get notifications => List.unmodifiable(_notifications);

  void resetToDefault() {
    _trips.clear();
    _notifications.clear();
    _initDefaultTrips();
    notifyListeners();
  }

  /// Initial seed dataset reflecting Yemen <-> Saudi cross-border, Yemen domestic, and Saudi routes
  void _initDefaultTrips() {
    _trips.addAll([
      // =======================================================================
      // 1. Pending Start Trips (بانتظار البدء)
      // =======================================================================
      // Yemen to Saudi Cross-border trip
      OfficeTrip(
        id: 'R-1042',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.pendingStart,
        originCity: 'صنعاء',
        originCountry: 'اليمن',
        originArea: 'شارع تعز الصناعي',
        destinationCity: 'الرياض',
        destinationCountry: 'السعودية',
        destinationArea: 'مستودعات السلي',
        distanceKm: 1380,
        estimatedDurationHours: 24,
        clientName: 'شركة البناء الحديثة',
        clientCompany: 'مؤسسة إعمار الخليج للتجارة',
        clientPhone: '0551234567',
        cargoTitle: 'مواد بناء وإكسسوارات ألمنيوم',
        truckType: 'شاحنة سطحة',
        weightTons: 20.0,
        driver: const OfficeTripDriver(
          id: 'DRV-101',
          name: 'أحمد السالم',
          phone: '0501234567',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ص ن ع 4521',
        ),
        agreedPriceSar: 6800,
        scheduledDate: DateTime(2026, 10, 15, 10, 0),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'تم إنشاء طلب الشحنة وتحديد مسار الرحلة.',
            timestamp: DateTime(2026, 10, 14, 9, 30),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'قبول العرض',
            description: 'تم قبول عرض مكتب النقل وتأكيد الاتفاق المالي.',
            timestamp: DateTime(2026, 10, 14, 11, 15),
            icon: Icons.check_circle_outline_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة',
            description: 'تم إسناد الرحلة وتعيين السائق أحمد السالم لتنفيذ النقل.',
            timestamp: DateTime(2026, 10, 14, 14, 0),
            icon: Icons.assignment_ind_rounded,
          ),
        ],
      ),

      // Saudi to Yemen Cross-border trip
      OfficeTrip(
        id: 'R-1045',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.pendingStart,
        originCity: 'جدة',
        originCountry: 'السعودية',
        originArea: 'ميناء جدة الإسلامي',
        destinationCity: 'تعز',
        destinationCountry: 'اليمن',
        destinationArea: 'منطقة الحوبان',
        distanceKm: 1240,
        estimatedDurationHours: 22,
        clientName: 'مؤسسة الطرق والتجارة',
        clientCompany: 'مؤسسة الطرق للمقاولات',
        clientPhone: '0509876543',
        cargoTitle: 'قطع غيار معدات ثقيلة ومولدات',
        truckType: 'شاحنة قلابة',
        weightTons: 25.0,
        driver: const OfficeTripDriver(
          id: 'DRV-103',
          name: 'سالم القحطاني',
          phone: '0503456789',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ج د ة 8832',
        ),
        agreedPriceSar: 7200,
        scheduledDate: DateTime(2026, 10, 16, 14, 0),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'تم حجز الشحنة من ميناء جدة.',
            timestamp: DateTime(2026, 10, 14, 8, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة للمكتب',
            description: 'تأكيد إسناد الحمولة للمكتب واستخراج تصاريح المنفذ.',
            timestamp: DateTime(2026, 10, 14, 16, 30),
            icon: Icons.assignment_turned_in_rounded,
          ),
        ],
      ),

      // Domestic Yemen Trip
      OfficeTrip(
        id: 'R-1048',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.pendingStart,
        originCity: 'صنعاء',
        originCountry: 'اليمن',
        originArea: 'جولة آية',
        destinationCity: 'عدن',
        destinationCountry: 'اليمن',
        destinationArea: 'المنطقة الحرة، المعلا',
        distanceKm: 380,
        estimatedDurationHours: 8,
        clientName: 'شركة البناء الحديثة',
        clientCompany: 'شركة سبأ الدولية للتوزيع',
        clientPhone: '0551122334',
        cargoTitle: 'مواد غذائية مجففة وتمور',
        truckType: 'شاحنة دينا مغلقة',
        weightTons: 12.0,
        driver: const OfficeTripDriver(
          id: 'DRV-104',
          name: 'خالد صالح',
          phone: '0507788990',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ع د ن 1204',
        ),
        agreedPriceSar: 2800,
        scheduledDate: DateTime(2026, 10, 15, 16, 0),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'طلب نقل بضائع مجففة عبر خط صنعاء - عدن.',
            timestamp: DateTime(2026, 10, 14, 12, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة',
            description: 'تم إسناد الرحلة للمكتب.',
            timestamp: DateTime(2026, 10, 14, 15, 0),
            icon: Icons.assignment_ind_rounded,
          ),
        ],
      ),

      // Saudi Domestic Trip
      OfficeTrip(
        id: 'R-1049',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.pendingStart,
        originCity: 'الرياض',
        originCountry: 'السعودية',
        destinationCity: 'الدمام',
        destinationCountry: 'السعودية',
        distanceKm: 420,
        estimatedDurationHours: 4,
        clientName: 'شركة البناء الحديثة',
        clientCompany: 'شركة اليمامة للخرسانة',
        clientPhone: '0559988776',
        cargoTitle: 'أكياس أسمنت معبأة ومنصات نقالة',
        truckType: 'شاحنة سطحة',
        weightTons: 24.0,
        driver: const OfficeTripDriver(
          id: 'DRV-102',
          name: 'محمد العتيبي',
          phone: '0509876543',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ر ي ض 6512',
        ),
        agreedPriceSar: 3400,
        scheduledDate: DateTime(2026, 10, 15, 11, 30),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'تم إنشاء الطلب لنقل أسمنت.',
            timestamp: DateTime(2026, 10, 14, 14, 20),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة',
            description: 'تم إسناد الرحلة وتأكيد جاهزية الشاحنة.',
            timestamp: DateTime(2026, 10, 14, 18, 0),
            icon: Icons.assignment_ind_rounded,
          ),
        ],
      ),

      // =======================================================================
      // 2. In Progress Trips (قيد التنفيذ)
      // =======================================================================
      // Yemen to Saudi In-Progress
      OfficeTrip(
        id: 'R-1041',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.inProgress,
        originCity: 'تعز',
        originCountry: 'اليمن',
        destinationCity: 'جدة',
        destinationCountry: 'السعودية',
        distanceKm: 1240,
        estimatedDurationHours: 20,
        remainingDistanceKm: 340,
        clientName: 'مؤسسة العمران',
        clientCompany: 'مجموعة العمران الاستثمارية',
        clientPhone: '0501112233',
        cargoTitle: 'منتجات زراعية وخضار مبردة',
        truckType: 'شاحنة ثلاجة مبردة',
        weightTons: 22.0,
        driver: const OfficeTripDriver(
          id: 'DRV-102',
          name: 'محمد العتيبي',
          phone: '0509876543',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ت ع ز 9901',
        ),
        agreedPriceSar: 7800,
        scheduledDate: DateTime(2026, 10, 14, 8, 30),
        actualStartTime: DateTime(2026, 10, 14, 8, 30),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'تم إنشاء طلب شحنة تبريد من تعز.',
            timestamp: DateTime(2026, 10, 13, 10, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'قبول العرض',
            description: 'تم قبول عرض النقل المبرد وتوثيق العقد.',
            timestamp: DateTime(2026, 10, 13, 12, 30),
            icon: Icons.check_circle_outline_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة',
            description: 'تم إسناد الرحلة إلى السائق محمد العتيبي.',
            timestamp: DateTime(2026, 10, 13, 16, 0),
            icon: Icons.assignment_ind_rounded,
          ),
          OfficeTripMilestone(
            title: 'بدء الرحلة',
            description: 'تم تحميل الشاحنة وانطلاق الرحلة عبر منفذ الوديعة.',
            timestamp: DateTime(2026, 10, 14, 8, 30),
            icon: Icons.local_shipping_rounded,
          ),
        ],
      ),

      // Saudi Domestic In-Progress
      OfficeTrip(
        id: 'R-1039',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.inProgress,
        originCity: 'الرياض',
        originCountry: 'السعودية',
        destinationCity: 'القصيم',
        destinationCountry: 'السعودية',
        distanceKm: 330,
        estimatedDurationHours: 3,
        remainingDistanceKm: 110,
        clientName: 'شركة الإنشاءات',
        clientCompany: 'شركة البناء والتعمير الحديثة',
        clientPhone: '0504445566',
        cargoTitle: 'قضبان حديد تسليح وهياكل معدنية',
        truckType: 'شاحنة سطحة',
        weightTons: 28.0,
        driver: const OfficeTripDriver(
          id: 'DRV-105',
          name: 'خالد العنزي',
          phone: '0508889911',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ق ص م 7120',
        ),
        agreedPriceSar: 3100,
        scheduledDate: DateTime(2026, 10, 14, 11, 0),
        actualStartTime: DateTime(2026, 10, 14, 11, 0),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'طلب نقل حديد تسليح.',
            timestamp: DateTime(2026, 10, 13, 15, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة',
            description: 'تم إسناد الرحلة للسائق خالد العنزي.',
            timestamp: DateTime(2026, 10, 14, 9, 0),
            icon: Icons.assignment_ind_rounded,
          ),
          OfficeTripMilestone(
            title: 'بدء الرحلة',
            description: 'تم بدء الرحلة والشاحنة على طريق الرياض القصيم السريع.',
            timestamp: DateTime(2026, 10, 14, 11, 0),
            icon: Icons.local_shipping_rounded,
          ),
        ],
      ),

      // Yemen Domestic In-Progress
      OfficeTrip(
        id: 'R-1036',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.inProgress,
        originCity: 'الحديدة',
        originCountry: 'اليمن',
        destinationCity: 'إب',
        destinationCountry: 'اليمن',
        distanceKm: 210,
        estimatedDurationHours: 5,
        remainingDistanceKm: 75,
        clientName: 'شركة البناء الحديثة',
        clientCompany: 'شركة المحيط للاستيراد والتوزيع',
        clientPhone: '0557766554',
        cargoTitle: 'زيوت نباتية ومواد تموينية أساسية',
        truckType: 'شاحنة صهريج معزول',
        weightTons: 18.0,
        driver: const OfficeTripDriver(
          id: 'DRV-106',
          name: 'ناصر علي',
          phone: '0502233445',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ح د د 3410',
        ),
        agreedPriceSar: 2400,
        scheduledDate: DateTime(2026, 10, 14, 7, 0),
        actualStartTime: DateTime(2026, 10, 14, 7, 15),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'نقل مواد تموينية من ميناء الحديدة إلى إب.',
            timestamp: DateTime(2026, 10, 13, 18, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة',
            description: 'تم إسناد الشاحنة والسائق.',
            timestamp: DateTime(2026, 10, 13, 21, 0),
            icon: Icons.assignment_ind_rounded,
          ),
          OfficeTripMilestone(
            title: 'بدء الرحلة',
            description: 'انطلقت الشاحنة وتجاوزت نقطة كيلو 16 باتجاه العدين.',
            timestamp: DateTime(2026, 10, 14, 7, 15),
            icon: Icons.local_shipping_rounded,
          ),
        ],
      ),

      // =======================================================================
      // 3. Completed Trips (مكتملة)
      // =======================================================================
      // Yemen to Saudi Completed
      OfficeTrip(
        id: 'R-1035',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.completed,
        originCity: 'عدن',
        originCountry: 'اليمن',
        destinationCity: 'الدمام',
        destinationCountry: 'السعودية',
        distanceKm: 1680,
        estimatedDurationHours: 28,
        clientName: 'شركة الجزيرة',
        clientCompany: 'شركة الجزيرة للاستيراد والتصدير',
        clientPhone: '0502223334',
        cargoTitle: 'بضائع ومنتجات بحرية معلبة',
        truckType: 'شاحنة ثلاجة',
        weightTons: 20.0,
        driver: const OfficeTripDriver(
          id: 'DRV-107',
          name: 'ماجد الحربي',
          phone: '0505678901',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ع د ن 5412',
        ),
        agreedPriceSar: 8900,
        scheduledDate: DateTime(2026, 10, 10, 10, 0),
        actualStartTime: DateTime(2026, 10, 10, 10, 30),
        actualEndTime: DateTime(2026, 10, 12, 17, 0),
        rating: OfficeTripRating(
          stars: 4.8,
          comment: 'خدمة ممتازة، التزام بالمواعيد ومتابعة مستمرة للشاحنة طوال خط السير الدولي.',
          date: DateTime(2026, 10, 12),
        ),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'تم تسجيل الشحنة بميناء عدن.',
            timestamp: DateTime(2026, 10, 9, 14, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'قبول العرض',
            description: 'تم قبول عرض مكتب النقل الدولي.',
            timestamp: DateTime(2026, 10, 9, 16, 0),
            icon: Icons.check_circle_outline_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة',
            description: 'تم إسناد الرحلة إلى الكابتن ماجد الحربي.',
            timestamp: DateTime(2026, 10, 9, 19, 0),
            icon: Icons.assignment_ind_rounded,
          ),
          OfficeTripMilestone(
            title: 'بدء الرحلة',
            description: 'تم بدء الرحلة من عدن باتجاه منفذ الوديعة.',
            timestamp: DateTime(2026, 10, 10, 10, 30),
            icon: Icons.local_shipping_rounded,
          ),
          OfficeTripMilestone(
            title: 'إنهاء الرحلة',
            description: 'تم تسليم الشحنة في ميناء الملك عبد العزيز بالدمام وتوقيع السند.',
            timestamp: DateTime(2026, 10, 12, 17, 0),
            icon: Icons.task_alt_rounded,
          ),
        ],
      ),

      // Saudi to Yemen Completed
      OfficeTrip(
        id: 'R-1032',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.completed,
        originCity: 'الرياض',
        originCountry: 'السعودية',
        destinationCity: 'صنعاء',
        destinationCountry: 'اليمن',
        distanceKm: 1380,
        estimatedDurationHours: 24,
        clientName: 'مؤسسة النماء',
        clientCompany: 'مؤسسة النماء الدولية للمقاولات',
        clientPhone: '0506667778',
        cargoTitle: 'مستلزمات وأنابيب شبكات مياه وبنية تحتية',
        truckType: 'شاحنة قلابة ثقيلة',
        weightTons: 26.0,
        driver: const OfficeTripDriver(
          id: 'DRV-108',
          name: 'عبدالله الشهري',
          phone: '0507890123',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ر ي ض 8192',
        ),
        agreedPriceSar: 7400,
        scheduledDate: DateTime(2026, 10, 8, 9, 0),
        actualStartTime: DateTime(2026, 10, 8, 9, 30),
        actualEndTime: DateTime(2026, 10, 10, 18, 30),
        rating: OfficeTripRating(
          stars: 5.0,
          comment: 'تم استلام الأنابيب بحالة ممتازة وبدون أي تلفيات. تعامل احترافي للغاية.',
          date: DateTime(2026, 10, 10),
        ),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'تم إنشاء الطلب لنقل أنابيب وبنية تحتية إلى صنعاء.',
            timestamp: DateTime(2026, 10, 7, 11, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة',
            description: 'تم إسناد الرحلة إلى الكابتن عبدالله الشهري.',
            timestamp: DateTime(2026, 10, 7, 15, 0),
            icon: Icons.assignment_ind_rounded,
          ),
          OfficeTripMilestone(
            title: 'بدء الرحلة',
            description: 'انطلقت الشاحنة من مستودعات الرياض جنوباً.',
            timestamp: DateTime(2026, 10, 8, 9, 30),
            icon: Icons.local_shipping_rounded,
          ),
          OfficeTripMilestone(
            title: 'إنهاء الرحلة',
            description: 'تم تفريغ الشحنة في صنعاء وتوثيق سند التسليم بنجاح.',
            timestamp: DateTime(2026, 10, 10, 18, 30),
            icon: Icons.task_alt_rounded,
          ),
        ],
      ),

      // Saudi Domestic Completed
      OfficeTrip(
        id: 'R-1031',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.completed,
        originCity: 'جدة',
        originCountry: 'السعودية',
        destinationCity: 'الطائف',
        destinationCountry: 'السعودية',
        distanceKm: 170,
        estimatedDurationHours: 2,
        clientName: 'شركة البناء الحديثة',
        clientCompany: 'شركة الغربية للإنشاء',
        clientPhone: '0553344556',
        cargoTitle: 'بلاط ورخام سيراميك',
        truckType: 'شاحنة سطحة',
        weightTons: 16.0,
        driver: const OfficeTripDriver(
          id: 'DRV-109',
          name: 'سالم علي',
          phone: '0501199223',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ج د ة 4410',
        ),
        agreedPriceSar: 1800,
        scheduledDate: DateTime(2026, 10, 7, 8, 0),
        actualStartTime: DateTime(2026, 10, 7, 8, 15),
        actualEndTime: DateTime(2026, 10, 7, 11, 45),
        rating: OfficeTripRating(
          stars: 4.7,
          comment: 'سرعة في التوصيل واهتمام بالغ بالبضاعة.',
          date: DateTime(2026, 10, 7),
        ),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'تم تسجيل الطلب لنقل رخام.',
            timestamp: DateTime(2026, 10, 6, 16, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'بدء الرحلة',
            description: 'انطلقت الشاحنة عبر طريق الهدا.',
            timestamp: DateTime(2026, 10, 7, 8, 15),
            icon: Icons.local_shipping_rounded,
          ),
          OfficeTripMilestone(
            title: 'إنهاء الرحلة',
            description: 'تم التسليم بنجاح.',
            timestamp: DateTime(2026, 10, 7, 11, 45),
            icon: Icons.task_alt_rounded,
          ),
        ],
      ),

      // Yemen Domestic Completed
      OfficeTrip(
        id: 'R-1028',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.completed,
        originCity: 'صنعاء',
        originCountry: 'اليمن',
        destinationCity: 'تعز',
        destinationCountry: 'اليمن',
        distanceKm: 256,
        estimatedDurationHours: 6,
        clientName: 'مؤسسة العمران',
        clientCompany: 'مؤسسة النصر للتجارة العامة',
        clientPhone: '0505566778',
        cargoTitle: 'أدوية ومستلزمات طبية مبردة',
        truckType: 'شاحنة دينا ثلاجة',
        weightTons: 8.0,
        driver: const OfficeTripDriver(
          id: 'DRV-110',
          name: 'خالد صالح',
          phone: '0507788990',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ص ن ع 9021',
        ),
        agreedPriceSar: 2600,
        scheduledDate: DateTime(2026, 10, 5, 6, 0),
        actualStartTime: DateTime(2026, 10, 5, 6, 30),
        actualEndTime: DateTime(2026, 10, 5, 13, 0),
        rating: OfficeTripRating(
          stars: 4.9,
          comment: 'درجات حرارة التبريد كانت مضبوطة بدقة والتسليم تم قبل الموعد.',
          date: DateTime(2026, 10, 5),
        ),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'تم تسجيل شحنة أدوية مبردة.',
            timestamp: DateTime(2026, 10, 4, 14, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'بدء الرحلة',
            description: 'تم الانطلاق من مستودع الأدوية بصنعاء.',
            timestamp: DateTime(2026, 10, 5, 6, 30),
            icon: Icons.local_shipping_rounded,
          ),
          OfficeTripMilestone(
            title: 'إنهاء الرحلة',
            description: 'تم تسليم الأدوية لمستشفى تعز العام وتوقيع سند المطابقة.',
            timestamp: DateTime(2026, 10, 5, 13, 0),
            icon: Icons.task_alt_rounded,
          ),
        ],
      ),

      // =======================================================================
      // 4. Cancelled Trips (ملغاة)
      // =======================================================================
      OfficeTrip(
        id: 'R-1030',
        role: OfficeTripRole.provider,
        status: OfficeTripStatus.cancelled,
        originCity: 'أبها',
        originCountry: 'السعودية',
        destinationCity: 'خميس مشيط',
        destinationCountry: 'السعودية',
        distanceKm: 35,
        estimatedDurationHours: 1,
        clientName: 'شركة السلام',
        clientCompany: 'شركة السلام للمقاولات العامة',
        clientPhone: '0507778889',
        cargoTitle: 'ألواح خشب وحديد تسليح خفيف',
        truckType: 'شاحنة سطحة',
        weightTons: 15.0,
        driver: const OfficeTripDriver(
          id: 'DRV-103',
          name: 'سعود القحطاني',
          phone: '0503456789',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'أ ب ه 2309',
        ),
        agreedPriceSar: 1200,
        scheduledDate: DateTime(2026, 10, 8, 10, 0),
        cancelledAt: DateTime(2026, 10, 8, 9, 15),
        cancellationReason: 'إلغاء من قبل العميل نظراً لتأجيل موعد استلام الموقع',
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'تم إنشاء طلب نقل خشب وحديد.',
            timestamp: DateTime(2026, 10, 7, 14, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'قبول العرض',
            description: 'تم قبول عرض النقل.',
            timestamp: DateTime(2026, 10, 7, 16, 30),
            icon: Icons.check_circle_outline_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة',
            description: 'تم إسناد الرحلة إلى السائق سعود القحطاني.',
            timestamp: DateTime(2026, 10, 7, 18, 0),
            icon: Icons.assignment_ind_rounded,
          ),
          OfficeTripMilestone(
            title: 'إلغاء الرحلة',
            description: 'تم إلغاء الرحلة: إلغاء من قبل العميل نظراً لتأجيل موعد استلام الموقع.',
            timestamp: DateTime(2026, 10, 8, 9, 15),
            icon: Icons.cancel_outlined,
          ),
        ],
      ),

      // =======================================================================
      // 5. Seeker Role Trips (كطالب خدمة - 2 sample orders)
      // =======================================================================
      OfficeTrip(
        id: 'R-2001',
        role: OfficeTripRole.seeker,
        status: OfficeTripStatus.pendingStart,
        originCity: 'صنعاء',
        originCountry: 'اليمن',
        destinationCity: 'الرياض',
        destinationCountry: 'السعودية',
        distanceKm: 1380,
        estimatedDurationHours: 24,
        clientName: 'مكتب النور للنقل السريع (مكتبي)',
        clientCompany: 'مكتب النور للنقل',
        clientPhone: '0550000000',
        cargoTitle: 'حمولة إضافية لعميل المكتب - كراتين أجهزة',
        truckType: 'شاحنة تريلا ستارة',
        weightTons: 25.0,
        driver: null, // Still seeking a driver
        agreedPriceSar: 6200,
        scheduledDate: DateTime(2026, 10, 18, 12, 0),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'قام مكتبك بإنشاء طلب بحث عن سائق لتغطية رحلة عميل.',
            timestamp: DateTime(2026, 10, 14, 16, 0),
            icon: Icons.note_add_rounded,
          ),
        ],
      ),
      OfficeTrip(
        id: 'R-2002',
        role: OfficeTripRole.seeker,
        status: OfficeTripStatus.inProgress,
        originCity: 'الرياض',
        originCountry: 'السعودية',
        destinationCity: 'جدة',
        destinationCountry: 'السعودية',
        distanceKm: 950,
        estimatedDurationHours: 10,
        remainingDistanceKm: 420,
        clientName: 'مكتب النور للنقل السريع (مكتبي)',
        clientCompany: 'مكتب النور للنقل',
        clientPhone: '0550000000',
        cargoTitle: 'معدات اتصالات وكابلات فايبر',
        truckType: 'شاحنة سطحة',
        weightTons: 18.0,
        driver: const OfficeTripDriver(
          id: 'DRV-111',
          name: 'عمر باوزير',
          phone: '0504433221',
          avatarAsset: 'assets/images/merchant_hero_truck_banner.jpg',
          vehiclePlate: 'ر ي ض 1980',
        ),
        agreedPriceSar: 4200,
        scheduledDate: DateTime(2026, 10, 14, 6, 0),
        actualStartTime: DateTime(2026, 10, 14, 6, 30),
        milestones: [
          OfficeTripMilestone(
            title: 'إنشاء الطلب',
            description: 'طلب بحث عن سائق معتمد.',
            timestamp: DateTime(2026, 10, 13, 11, 0),
            icon: Icons.note_add_rounded,
          ),
          OfficeTripMilestone(
            title: 'إسناد الرحلة للسائق',
            description: 'تم قبول طلب السائق عمر باوزير وتكليفه بالحمولة.',
            timestamp: DateTime(2026, 10, 13, 17, 0),
            icon: Icons.assignment_ind_rounded,
          ),
          OfficeTripMilestone(
            title: 'بدء الرحلة',
            description: 'السائق بدأ الرحلة باتجاه جدة.',
            timestamp: DateTime(2026, 10, 14, 6, 30),
            icon: Icons.local_shipping_rounded,
          ),
        ],
      ),
    ]);
  }

  // ===========================================================================
  // Filter & Search Queries
  // ===========================================================================

  /// Returns trips matching role, filter, and search text
  List<OfficeTrip> getFilteredTrips({
    required OfficeTripRole role,
    required OfficeTripFilter filter,
    String query = '',
  }) {
    final cleanQuery = query.trim().toLowerCase();

    // 1. Role filter
    var list = _trips.where((t) => t.role == role).toList();

    // 2. Status filter
    switch (filter) {
      case OfficeTripFilter.all:
        break;
      case OfficeTripFilter.pendingStart:
        list = list.where((t) => t.status == OfficeTripStatus.pendingStart).toList();
        break;
      case OfficeTripFilter.inProgress:
        list = list.where((t) => t.status == OfficeTripStatus.inProgress).toList();
        break;
      case OfficeTripFilter.completed:
        list = list.where((t) => t.status == OfficeTripStatus.completed).toList();
        break;
      case OfficeTripFilter.cancelled:
        list = list.where((t) => t.status == OfficeTripStatus.cancelled).toList();
        break;
    }

    // 3. Search query (trip id, client name, driver name, route cities)
    if (cleanQuery.isNotEmpty) {
      list = list.where((t) {
        final matchesId = t.id.toLowerCase().contains(cleanQuery);
        final matchesClient = t.clientName.toLowerCase().contains(cleanQuery) ||
            t.clientCompany.toLowerCase().contains(cleanQuery);
        final matchesDriver = t.driver != null &&
            t.driver!.name.toLowerCase().contains(cleanQuery);
        final matchesOrigin = t.originCity.toLowerCase().contains(cleanQuery);
        final matchesDest = t.destinationCity.toLowerCase().contains(cleanQuery);
        return matchesId || matchesClient || matchesDriver || matchesOrigin || matchesDest;
      }).toList();
    }

    // 4. Sort order:
    // In "الكل": Active first (inProgress, then pendingStart), then completed, then cancelled
    // Within each group: chronological ordering
    list.sort((a, b) {
      final priorityA = _statusSortPriority(a.status);
      final priorityB = _statusSortPriority(b.status);
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      // If same status, sort chronologically:
      if (a.status == OfficeTripStatus.pendingStart) {
        // Nearest scheduled date first
        return a.scheduledDate.compareTo(b.scheduledDate);
      } else if (a.status == OfficeTripStatus.inProgress) {
        // Most recently started first
        final tA = a.actualStartTime ?? a.scheduledDate;
        final tB = b.actualStartTime ?? b.scheduledDate;
        return tB.compareTo(tA);
      } else if (a.status == OfficeTripStatus.completed) {
        // Most recently completed first
        final tA = a.actualEndTime ?? a.scheduledDate;
        final tB = b.actualEndTime ?? b.scheduledDate;
        return tB.compareTo(tA);
      } else {
        // Most recently cancelled first
        final tA = a.cancelledAt ?? a.scheduledDate;
        final tB = b.cancelledAt ?? b.scheduledDate;
        return tB.compareTo(tA);
      }
    });

    return list;
  }

  int _statusSortPriority(OfficeTripStatus status) {
    switch (status) {
      case OfficeTripStatus.inProgress:
        return 1;
      case OfficeTripStatus.pendingStart:
        return 2;
      case OfficeTripStatus.completed:
        return 3;
      case OfficeTripStatus.cancelled:
        return 4;
    }
  }

  /// Get accurate trip counts for each filter under the given role
  Map<OfficeTripFilter, int> getCounts(OfficeTripRole role) {
    final roleTrips = _trips.where((t) => t.role == role).toList();
    return {
      OfficeTripFilter.all: roleTrips.length,
      OfficeTripFilter.pendingStart:
          roleTrips.where((t) => t.status == OfficeTripStatus.pendingStart).length,
      OfficeTripFilter.inProgress:
          roleTrips.where((t) => t.status == OfficeTripStatus.inProgress).length,
      OfficeTripFilter.completed:
          roleTrips.where((t) => t.status == OfficeTripStatus.completed).length,
      OfficeTripFilter.cancelled:
          roleTrips.where((t) => t.status == OfficeTripStatus.cancelled).length,
    };
  }

  /// Find single trip by ID
  OfficeTrip? getTripById(String id) {
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // ===========================================================================
  // State Mutations (بدء الرحلة، إنهاء الرحلة، إلغاء الرحلة)
  // ===========================================================================

  /// Start a trip (بانتظار البدء -> قيد التنفيذ)
  Future<bool> startTrip(String tripId) async {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index == -1) return false;

    final trip = _trips[index];
    if (trip.status != OfficeTripStatus.pendingStart) return false;

    final now = DateTime.now();
    final updatedMilestones = List<OfficeTripMilestone>.from(trip.milestones)
      ..add(
        OfficeTripMilestone(
          title: 'بدء الرحلة',
          description: 'تم بدء الرحلة رسمياً من قبل مكتب النقل وانطلاق الشاحنة.',
          timestamp: now,
          icon: Icons.local_shipping_rounded,
        ),
      );

    _trips[index] = trip.copyWith(
      status: OfficeTripStatus.inProgress,
      actualStartTime: now,
      remainingDistanceKm: trip.distanceKm,
      milestones: updatedMilestones,
    );

    _logNotification(
      title: 'بدء الرحلة ${trip.id}',
      message: 'تم بدء الرحلة من ${trip.originCity} إلى ${trip.destinationCity} بنجاح.',
    );

    notifyListeners();
    return true;
  }

  /// Complete a trip (قيد التنفيذ -> مكتملة)
  Future<bool> completeTrip(String tripId) async {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index == -1) return false;

    final trip = _trips[index];
    if (trip.status != OfficeTripStatus.inProgress) return false;

    final now = DateTime.now();
    final updatedMilestones = List<OfficeTripMilestone>.from(trip.milestones)
      ..add(
        OfficeTripMilestone(
          title: 'إنهاء الرحلة',
          description: 'تم إنهاء الرحلة بنجاح وتأكيد تسليم البضاعة للعميل.',
          timestamp: now,
          icon: Icons.task_alt_rounded,
        ),
      );

    _trips[index] = trip.copyWith(
      status: OfficeTripStatus.completed,
      actualEndTime: now,
      remainingDistanceKm: 0,
      milestones: updatedMilestones,
    );

    _logNotification(
      title: 'اكتمال الرحلة ${trip.id}',
      message: 'تم تسليم الشحنة في ${trip.destinationCity} وإنهاء الرحلة بنجاح.',
    );

    notifyListeners();
    return true;
  }

  /// Cancel a trip (with reason and logging)
  Future<bool> cancelTrip(String tripId, String reason) async {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index == -1) return false;

    final trip = _trips[index];
    // Cannot cancel completed trips
    if (trip.status == OfficeTripStatus.completed ||
        trip.status == OfficeTripStatus.cancelled) {
      return false;
    }

    final now = DateTime.now();
    final updatedMilestones = List<OfficeTripMilestone>.from(trip.milestones)
      ..add(
        OfficeTripMilestone(
          title: 'إلغاء الرحلة',
          description: 'تم إلغاء الرحلة: $reason',
          timestamp: now,
          icon: Icons.cancel_outlined,
        ),
      );

    _trips[index] = trip.copyWith(
      status: OfficeTripStatus.cancelled,
      cancelledAt: now,
      cancellationReason: reason,
      milestones: updatedMilestones,
    );

    _logNotification(
      title: 'إلغاء الرحلة ${trip.id}',
      message: 'تم إلغاء الرحلة إلى ${trip.destinationCity}. السبب: $reason',
    );

    notifyListeners();
    return true;
  }

  void _logNotification({required String title, required String message}) {
    _notifications.insert(
      0,
      OfficeTripNotification(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
  }
}
