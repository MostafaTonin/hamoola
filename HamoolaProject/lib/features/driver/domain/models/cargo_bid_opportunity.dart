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
  final bool isPrivate;
  final String? imageAsset;
  final String? pickupArea;
  final String? dropoffArea;
  final String? cargoCategory;
  final String? cargoSubCategory;
  final String? packagingType;
  final String? loadingMethod;
  final String? truckRequirements;
  final String? additionalDetails;
  final List<String>? galleryImages;
  final List<String>? terms;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final bool isExpiredOrClosed;

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
    this.isPrivate = false,
    this.imageAsset,
    this.pickupArea,
    this.dropoffArea,
    this.cargoCategory,
    this.cargoSubCategory,
    this.packagingType,
    this.loadingMethod,
    this.truckRequirements,
    this.additionalDetails,
    this.galleryImages,
    this.terms,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.isExpiredOrClosed = false,
  });

  String get pickupLocationDisplay => pickupArea ?? originCity;
  String get dropoffLocationDisplay => dropoffArea ?? destinationCity;
  String get packagingDisplay => packagingType ?? 'أكياس';
  String get loadingMethodDisplay => loadingMethod ?? 'من الموقع';
  String get truckRequirementsDisplay => truckRequirements ?? requiredTruckType;
  String get cargoCategoryDisplay => cargoCategory ?? 'مواد بناء';
  String get cargoSubCategoryDisplay => cargoSubCategory ?? 'أسمنت';
  String get weightDisplay =>
      '${weightTons % 1 == 0 ? weightTons.toInt() : weightTons} طن';
  String get additionalDetailsDisplay =>
      additionalDetails ?? (notes.isNotEmpty ? notes : 'الحمولة جاهزة في الموقع. يرجى التأكد من توفر الوثائق المطلوبة والالتزام بموعد التحميل.');

  List<String> get imagesList {
    if (galleryImages != null && galleryImages!.isNotEmpty) {
      return galleryImages!;
    }
    if (imageAsset != null && imageAsset!.isNotEmpty) {
      return [imageAsset!];
    }
    return const ['assets/images/cargo_ref_1.jpg'];
  }

  List<String> get termsList {
    if (terms != null && terms!.isNotEmpty) {
      return terms!;
    }
    return const [
      'الالتزام بموعد التحميل والتسليم.',
      'الحفاظ على سلامة الحمولة.',
      'أي تكاليف إضافية يجب أن تكون واضحة في العرض.',
    ];
  }

  /// Realistic demo opportunities matching the reference image and diverse routes
  static const List<CargoBidOpportunity> demoOpportunities = [
    CargoBidOpportunity(
      id: 'REQ-4091',
      title: 'نقل مواد بناء (أسمنت)',
      merchantName: 'شركة الأسمنت الوطنية',
      merchantRating: 4.9,
      originCity: 'صنعاء',
      destinationCity: 'تعز',
      pickupArea: 'صنعاء - منطقة الحصبة',
      dropoffArea: 'تعز - منطقة الحوبان',
      distanceKm: 92,
      durationHours: 2.0,
      weightTons: 12.0,
      requiredTruckType: 'شاحنة طن (مغلقة أو مفتوحة)',
      urgencyLabel: 'متاح للتقديم',
      isUrgent: false,
      targetBudgetYmr: 55000,
      offersCount: 3,
      loadingWindow: '2025/05/20',
      paymentTerms: 'دفع مؤمن عبر محفظة حمولة',
      isInsuranceRequired: true,
      notes: 'الحمولة جاهزة في الموقع. يرجى التأكد من توفر الوثائق المطلوبة والالتزام بموعد التحميل.',
      isPrivate: false,
      imageAsset: 'assets/images/cement_sacks_pallet.jpg',
      galleryImages: [
        'assets/images/cement_sacks_pallet.jpg',
        'assets/images/cargo_ref_2.jpg',
        'assets/images/cargo_ref_3.jpg',
      ],
      cargoCategory: 'مواد بناء',
      cargoSubCategory: 'أسمنت',
      packagingType: 'أكياس',
      loadingMethod: 'من الموقع',
      truckRequirements: 'شاحنة طن (مغلقة أو مفتوحة)',
      additionalDetails: 'الحمولة جاهزة في الموقع. يرجى التأكد من توفر الوثائق المطلوبة والالتزام بموعد التحميل.',
      terms: [
        'الالتزام بموعد التحميل والتسليم.',
        'الحفاظ على سلامة الحمولة.',
        'أي تكاليف إضافية يجب أن تكون واضحة في العرض.',
      ],
      pickupLat: 15.3900,
      pickupLng: 44.1950,
      dropoffLat: 13.5850,
      dropoffLng: 44.0300,
    ),
    CargoBidOpportunity(
      id: 'REQ-4092',
      title: 'نقل مواسير حديدية',
      merchantName: 'مؤسسة السعيد للمقاولات والمواسير',
      merchantRating: 4.8,
      originCity: 'عدن',
      destinationCity: 'إب',
      pickupArea: 'عدن - ميناء المعلا',
      dropoffArea: 'إب - المنطقة الصناعية',
      distanceKm: 280,
      durationHours: 5.0,
      weightTons: 20.0,
      requiredTruckType: 'قاطرة تريلا سطحة',
      urgencyLabel: 'طلب خاص موجه لمكتبك',
      isUrgent: false,
      targetBudgetYmr: 75000,
      offersCount: 1,
      loadingWindow: '2025/05/22',
      paymentTerms: 'دفع مؤمن عبر محفظة حمولة',
      isInsuranceRequired: true,
      notes: 'مواسير حديد مجلفن دائرية مربوطة ومحكمة التستيف وجاهزة للنقل.',
      isPrivate: true,
      imageAsset: 'assets/images/steel_pipes_cargo.jpg',
      galleryImages: [
        'assets/images/steel_pipes_cargo.jpg',
      ],
      cargoCategory: 'حديد ومواد بناء',
      cargoSubCategory: 'مواسير حديدية',
      packagingType: 'ربطات صناعية',
      loadingMethod: 'رافعة شوكية',
      truckRequirements: 'قاطرة تريلا سطحة',
      additionalDetails: 'مواسير حديد مجلفن دائرية مربوطة ومحكمة التستيف وجاهزة للنقل.',
      terms: [
        'الالتزام بموعد التحميل والتسليم.',
        'الحفاظ على سلامة الحمولة.',
      ],
      pickupLat: 12.7980,
      pickupLng: 45.0180,
      dropoffLat: 13.9667,
      dropoffLng: 44.1667,
    ),
    CargoBidOpportunity(
      id: 'CRG-101',
      title: 'أسمنت',
      merchantName: 'شركة الأسمنت الوطنية',
      merchantRating: 4.9,
      originCity: 'الدمام',
      destinationCity: 'الرياض',
      pickupArea: 'الدمام - الميناء',
      dropoffArea: 'الرياض - السلي',
      distanceKm: 312,
      durationHours: 4.0,
      weightTons: 25.0,
      requiredTruckType: 'شاحنة نقل ثقيل',
      urgencyLabel: 'تحميل فوري اليوم',
      isUrgent: true,
      targetBudgetYmr: 5200,
      offersCount: 2,
      loadingWindow: 'اليوم: 08:00 ص - 12:00 م',
      paymentTerms: 'دفع مؤمن عبر محفظة حمولة',
      isInsuranceRequired: true,
      notes: 'أكياس أسمنت معبأة ومثبتة على طبالي خشبية جاهزة للتحميل.',
      isPrivate: false,
      imageAsset: 'assets/images/cargo_ref_1.jpg',
      galleryImages: [
        'assets/images/cargo_ref_1.jpg',
        'assets/images/cargo_ref_2.jpg',
      ],
      cargoSubCategory: 'مواد بناء',
      packagingType: 'أكياس',
      loadingMethod: 'من الموقع',
      truckRequirements: 'شاحنة نقل ثقيل',
    ),
    CargoBidOpportunity(
      id: 'CRG-102',
      title: 'خضار وفواكه',
      merchantName: 'مزارع القصيم الخضراء',
      merchantRating: 5.0,
      originCity: 'القصيم',
      destinationCity: 'الرياض',
      distanceKm: 360,
      durationHours: 4.5,
      weightTons: 16.0,
      requiredTruckType: 'دينا براد',
      temperatureSpec: '4°C تبريد',
      urgencyLabel: 'طلب خاص موجه لك',
      isUrgent: true,
      targetBudgetYmr: 3800,
      offersCount: 1,
      loadingWindow: 'اليوم: 03:00 م - 06:00 م',
      paymentTerms: 'دفع كامل عند الاستلام',
      isInsuranceRequired: false,
      notes: 'صناديق خضار وفواكه طازجة متجهة لسوق الجملة المركزي.',
      isPrivate: true,
      imageAsset: 'assets/images/cargo_ref_2.jpg',
    ),
    CargoBidOpportunity(
      id: 'CRG-103',
      title: 'حديد ومواد بناء',
      merchantName: 'مؤسسة اليمامة للتجارة والمقاولات',
      merchantRating: 4.8,
      originCity: 'الجبيل',
      destinationCity: 'الهفوف',
      distanceKm: 190,
      durationHours: 2.8,
      weightTons: 28.0,
      requiredTruckType: 'قاطرة تريلا سطحة',
      urgencyLabel: 'غداً صباحاً',
      isUrgent: false,
      targetBudgetYmr: 2900,
      offersCount: 3,
      loadingWindow: 'غداً: 07:00 ص',
      paymentTerms: 'تحويل بنكي فوري عند إصدار البوليصة',
      isInsuranceRequired: true,
      notes: 'حديد تسليح ولفائف سلك مع رافعة جاهزة للتنزيل.',
      isPrivate: false,
      imageAsset: 'assets/images/cargo_rebar.png',
    ),
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
