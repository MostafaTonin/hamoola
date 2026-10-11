/// Represents a cargo transport request available in the marketplace for drivers to bid on.
class CargoBidOpportunity {
  final String id;
  final String title;
  final String merchantName;
  final double merchantRating;
  final String originCity;
  final String destinationCity;
  final int distanceKm;
  final double durationHours;
  final double weightTons;
  final String requiredTruckType;
  final String? temperatureSpec;
  final String urgencyLabel;
  final bool isUrgent;
  final int targetBudgetYmr;
  final int offersCount;
  final String loadingWindow;
  final String paymentTerms;
  final bool isInsuranceRequired;
  final String notes;

  const CargoBidOpportunity({
    required this.id,
    required this.title,
    required this.merchantName,
    required this.merchantRating,
    required this.originCity,
    required this.destinationCity,
    required this.distanceKm,
    required this.durationHours,
    required this.weightTons,
    required this.requiredTruckType,
    this.temperatureSpec,
    required this.urgencyLabel,
    required this.isUrgent,
    required this.targetBudgetYmr,
    required this.offersCount,
    required this.loadingWindow,
    required this.paymentTerms,
    required this.isInsuranceRequired,
    required this.notes,
  });

  /// Realistic demo opportunities matching diverse truck types and routes in Yemen
  static const List<CargoBidOpportunity> demoOpportunities = [
    CargoBidOpportunity(
      id: 'CRG-9021',
      title: 'شحنة خضار وفواكه مبردة (موز وتفاح)',
      merchantName: 'شركة تهامة للتبريد والتجارة',
      merchantRating: 4.8,
      originCity: 'الحديدة - الميناء',
      destinationCity: 'صنعاء - سوق ذهبان',
      distanceKm: 226,
      durationHours: 5.5,
      weightTons: 24.0,
      requiredTruckType: 'قاطرة براد',
      temperatureSpec: '-18°C تبريد',
      urgencyLabel: 'تحميل فوري اليوم',
      isUrgent: true,
      targetBudgetYmr: 380000,
      offersCount: 3,
      loadingWindow: 'اليوم: 02:00 م - 05:00 م',
      paymentTerms: '50% عند التحميل + 50% تسليم فوري',
      isInsuranceRequired: true,
      notes: 'يلزم تشغيل التبريد المسبق للحاوية لساعتين قبل موعد التحميل.',
    ),
    CargoBidOpportunity(
      id: 'CRG-8842',
      title: 'حديد تسليح 12 ملم ولفائف سلك',
      merchantName: 'مؤسسة الوحدة لمواد البناء',
      merchantRating: 4.9,
      originCity: 'عدن - ميناء المعلا',
      destinationCity: 'تعز - منطقة الحوبان',
      distanceKm: 180,
      durationHours: 4.5,
      weightTons: 32.0,
      requiredTruckType: 'قاطرة تريلا سطحة',
      urgencyLabel: 'غداً صباحاً',
      isUrgent: false,
      targetBudgetYmr: 460000,
      offersCount: 1,
      loadingWindow: 'غداً: 07:00 ص - 10:00 ص',
      paymentTerms: 'دفع كامل مقدماً عبر محفظة حمولة',
      isInsuranceRequired: true,
      notes: 'أحزمة ربط ثقيلة متوفرة مع الرافعة في موقع التحميل والتفريغ.',
    ),
    CargoBidOpportunity(
      id: 'CRG-7715',
      title: 'كراتين زيوت نباتية ومعلبات غذائية',
      merchantName: 'مجموعة هائل سعيد التجارية',
      merchantRating: 5.0,
      originCity: 'الحديدة - المصانع',
      destinationCity: 'ذمار - السوق المركزي',
      distanceKm: 275,
      durationHours: 6.0,
      weightTons: 18.0,
      requiredTruckType: 'دينا جامبو مغلقة',
      urgencyLabel: 'تحميل فوري',
      isUrgent: true,
      targetBudgetYmr: 290000,
      offersCount: 4,
      loadingWindow: 'اليوم: 04:00 م - 07:00 م',
      paymentTerms: 'إيداع فوري بالمحفظة عند إصدار البوليصة',
      isInsuranceRequired: false,
      notes: 'بضاعة نظيفة محملة على طبالي خشبية جاهزة للتحميل بالرافعة الشوكية.',
    ),
    CargoBidOpportunity(
      id: 'CRG-6603',
      title: 'أدوات صحية وسيراميك وأنابيب',
      merchantName: 'شركة السعيد للتجارة والمقاولات',
      merchantRating: 4.7,
      originCity: 'صنعاء - بني مطر',
      destinationCity: 'إب - مفرق جبلة',
      distanceKm: 195,
      durationHours: 4.8,
      weightTons: 15.0,
      requiredTruckType: 'دينا صندوق شبك',
      urgencyLabel: 'بعد غد',
      isUrgent: false,
      targetBudgetYmr: 240000,
      offersCount: 2,
      loadingWindow: 'الأربعاء: 08:00 ص',
      paymentTerms: 'شيك مضمون أو تحويل بنكي فوري',
      isInsuranceRequired: false,
      notes: 'التسليم مباشرة في مستودع المشتري مع توفير عمال تفريغ.',
    ),
    CargoBidOpportunity(
      id: 'CRG-5519',
      title: 'معدات طاقة شمسية وبطاريات جل',
      merchantName: 'مؤسسة الأفق للطاقة المتجددة',
      merchantRating: 4.9,
      originCity: 'المكلا - الميناء',
      destinationCity: 'مأرب - المدينة',
      distanceKm: 490,
      durationHours: 9.0,
      weightTons: 12.0,
      requiredTruckType: 'دينا جامبو مغلقة',
      urgencyLabel: 'شحنة ذات قيمة عالية',
      isUrgent: true,
      targetBudgetYmr: 620000,
      offersCount: 5,
      loadingWindow: 'اليوم قبل 06:00 م',
      paymentTerms: 'دفع مؤمن 100% عبر حمولة إسكرو',
      isInsuranceRequired: true,
      notes: 'بضاعة حساسة ضد الاهتزاز، يلزم تأمين معتمد وتتبع GPS مستمر.',
    ),
  ];
}

/// Represents the active transit state of a driver's ongoing trip.
class DriverActiveTrip {
  final String tripId;
  final String cargoTitle;
  final String merchantName;
  final String merchantPhone;
  final String originCity;
  final String destinationCity;
  final String currentCheckpoint;
  final double progressRatio;
  final int payoutYmr;
  final String estimatedArrival;
  final String currentStatusText;

  const DriverActiveTrip({
    required this.tripId,
    required this.cargoTitle,
    required this.merchantName,
    required this.merchantPhone,
    required this.originCity,
    required this.destinationCity,
    required this.currentCheckpoint,
    required this.progressRatio,
    required this.payoutYmr,
    required this.estimatedArrival,
    required this.currentStatusText,
  });

  static const DriverActiveTrip demoActiveTrip = DriverActiveTrip(
    tripId: 'TRP-4091',
    cargoTitle: 'أدوية ومستلزمات طبية مبردة (12 طن)',
    merchantName: 'مستودع الأمل الدوائي المركزي',
    merchantPhone: '+967 771 234 567',
    originCity: 'صنعاء',
    destinationCity: 'تعز',
    currentCheckpoint: 'نقيل سمارة - الكيلو 92',
    progressRatio: 0.65,
    payoutYmr: 340000,
    estimatedArrival: 'ساعتان و 15 دقيقة',
    currentStatusText: 'في الطريق إلى نقطة التسليم',
  );
}
