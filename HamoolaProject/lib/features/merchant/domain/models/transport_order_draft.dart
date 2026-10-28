import 'cargo_card_item.dart';

/// Models representing transport order creation, driver profile, and office selection.

enum PublishTarget {
  allDrivers,
  specificDriver,
  allOffices,
  specificOffice,
}

enum ContactMethod {
  whatsapp,
  call,
}

enum ScheduleFlexibility {
  exact,
  plusMinus6Hours,
  plusMinus12Hours,
}

class DriverProfile {
  final String id;
  final String name;
  final String profession;
  final double rating;
  final int reviewsCount;
  final bool isVerified;
  final bool isOnline;
  final String city;
  final String distance;
  final String vehicleType;
  final String vehicleModel;
  final String capacity;
  final String plateNumber;
  final String vehicleYear;
  final String vehicleCondition;
  final String vehicleBoxType;
  final int completedTrips;
  final String onTimeRate;
  final int yearsExperience;
  final String yearsOnPlatform;
  final String phone;
  final String avatarAsset;
  final String heroTruckAsset;
  final String bio;
  final String serviceRoutes;
  final List<String> supportedCargoTypes;
  final String selectedCargoType;
  final String latestReviewer;
  final String latestReviewDate;
  final String latestReviewText;
  final double latestReviewRating;

  const DriverProfile({
    required this.id,
    required this.name,
    this.profession = 'سائق نقل بري',
    this.rating = 4.8,
    this.reviewsCount = 127,
    this.isVerified = true,
    this.isOnline = true,
    this.city = 'صنعاء، اليمن',
    this.distance = 'على بعد 12 كم',
    this.vehicleType = 'شاحنة',
    this.vehicleModel = 'مرسيدس أكتروس',
    this.capacity = '20 طن',
    this.plateNumber = '1234 - صنعاء',
    this.vehicleYear = '2020',
    this.vehicleCondition = 'جيدة جداً',
    this.vehicleBoxType = 'مغلقة',
    this.completedTrips = 200,
    this.onTimeRate = '98%',
    this.yearsExperience = 9,
    this.yearsOnPlatform = '3 سنوات',
    this.phone = '771234567',
    this.avatarAsset = 'assets/images/driver_ahmed_avatar.jpg',
    this.heroTruckAsset = 'assets/images/driver_hero_actros.jpg',
    this.bio =
        'سائق محترف في مجال النقل البري بين مدن اليمن، أحرص على الالتزام بالمواعيد وسلامة البضائع، ولدي خبرة في نقل مواد البناء والمواد الغذائية. مرحباً بالتعامل مع الجميع.',
    this.serviceRoutes = 'صنعاء ↔ عدن • وجميع المحافظات',
    this.supportedCargoTypes = const [
      'مواد بناء',
      'إسمنت',
      'حديد تسليح',
      'مواد غذائية',
      'أخرى',
    ],
    this.selectedCargoType = 'مواد بناء',
    this.latestReviewer = 'شركة البناء الحديث',
    this.latestReviewDate = '12 مارس 2024',
    this.latestReviewText =
        'سائق ممتاز جداً. التزم بالموعد وكان حريصاً على سلامة البضائع. أنصح بالتعامل معه.',
    this.latestReviewRating = 5.0,
  });

  static const DriverProfile demoDriver = DriverProfile(
    id: 'DRV-101',
    name: 'أحمد عبدالله',
    profession: 'سائق نقل بري',
    rating: 4.8,
    reviewsCount: 127,
    isVerified: true,
    isOnline: true,
    city: 'صنعاء، اليمن',
    distance: 'على بعد 12 كم',
    vehicleType: 'شاحنة',
    vehicleModel: 'مرسيدس أكتروس',
    capacity: '20 طن',
    plateNumber: '1234 - صنعاء',
    vehicleYear: '2020',
    vehicleCondition: 'جيدة جداً',
    vehicleBoxType: 'مغلقة',
    completedTrips: 200,
    onTimeRate: '98%',
    yearsExperience: 9,
    yearsOnPlatform: '3 سنوات',
    phone: '771234567',
    avatarAsset: 'assets/images/driver_ahmed_avatar.jpg',
    heroTruckAsset: 'assets/images/driver_hero_actros.jpg',
    bio:
        'سائق محترف في مجال النقل البري بين مدن اليمن، أحرص على الالتزام بالمواعيد وسلامة البضائع، ولدي خبرة في نقل مواد البناء والمواد الغذائية. مرحباً بالتعامل مع الجميع.',
    serviceRoutes: 'صنعاء ↔ عدن • وجميع المحافظات',
    supportedCargoTypes: [
      'مواد بناء',
      'إسمنت',
      'حديد تسليح',
      'مواد غذائية',
      'أخرى',
    ],
    selectedCargoType: 'مواد بناء',
    latestReviewer: 'شركة البناء الحديث',
    latestReviewDate: '12 مارس 2024',
    latestReviewText:
        'سائق ممتاز جداً. التزم بالموعد وكان حريصاً على سلامة البضائع. أنصح بالتعامل معه.',
    latestReviewRating: 5.0,
  );

  static const List<DriverProfile> demoDrivers = [
    DriverProfile(
      id: 'DRV-201',
      name: 'أحمد القحطاني',
      profession: 'سائق نقل ثقيل معتمد',
      rating: 4.8,
      reviewsCount: 120,
      isVerified: true,
      isOnline: true,
      city: 'صنعاء',
      distance: '5 كم',
      vehicleType: 'شاحنة',
      vehicleModel: 'مرسيدس أكتروس',
      capacity: '25 طن',
      phone: '771234567',
    ),
    DriverProfile(
      id: 'DRV-202',
      name: 'محمد العتيبي',
      profession: 'سائق قاطرات معتمد',
      rating: 4.6,
      reviewsCount: 95,
      isVerified: true,
      isOnline: true,
      city: 'صنعاء',
      distance: '12 كم',
      vehicleType: 'قاطرة',
      vehicleModel: 'فولفو FH',
      capacity: '30 طن',
      phone: '772345678',
    ),
    DriverProfile(
      id: 'DRV-203',
      name: 'خالد الشهري',
      profession: 'سائق دينا وشاحنات خفيفة',
      rating: 4.5,
      reviewsCount: 78,
      isVerified: true,
      isOnline: false, // مشغول حالياً!
      city: 'صنعاء',
      distance: '18 كم',
      vehicleType: 'دينا',
      vehicleModel: 'إيسوزو NPR',
      capacity: '6 طن',
      phone: '773456789',
    ),
    DriverProfile(
      id: 'DRV-204',
      name: 'سالم الدوسري',
      profession: 'سائق شاحنات مبردة',
      rating: 4.4,
      reviewsCount: 64,
      isVerified: true,
      isOnline: true,
      city: 'عدن',
      distance: '22 كم',
      vehicleType: 'شاحنة تبريد',
      vehicleModel: 'مان TGM',
      capacity: '18 طن',
      phone: '774567890',
    ),
    demoDriver,
  ];
}

class TransportOffice {
  final String id;
  final String name;
  final String city;
  final String services;
  final double rating;
  final int reviewsCount;
  final bool isVerified;
  final String phone;
  final int fleetCount;
  final String address;

  const TransportOffice({
    required this.id,
    required this.name,
    required this.city,
    required this.services,
    this.rating = 4.9,
    this.reviewsCount = 84,
    this.isVerified = true,
    this.phone = '770001122',
    this.fleetCount = 45,
    this.address = 'شارع الستين الجنوبي، صنعاء',
  });

  static const List<TransportOffice> demoOffices = [
    TransportOffice(
      id: 'OFF-01',
      name: 'مكتب الأمان للنقل الثقيل',
      city: 'صنعاء',
      services: 'نقل ثقيل · بين المحافظات · قواطر وشاحنات',
      rating: 4.9,
      reviewsCount: 142,
      isVerified: true,
      phone: '777112233',
      fleetCount: 52,
      address: 'صنعاء — جولة عصر، جوار مستودعات التجارة',
    ),
    TransportOffice(
      id: 'OFF-02',
      name: 'شركة النجم السريع لخدمات النقل',
      city: 'عدن',
      services: 'بضائع الموانئ · حاويات · تبريد وحفظ',
      rating: 4.8,
      reviewsCount: 96,
      isVerified: true,
      phone: '733221100',
      fleetCount: 38,
      address: 'عدن — مديرية المعلا، قرب رصيف الحاويات',
    ),
    TransportOffice(
      id: 'OFF-03',
      name: 'مكتب سبأ لنقل البضائع والمعدات',
      city: 'مأرب',
      services: 'معدات نفطية · مواد بناء · قلابات وصهاريج',
      rating: 4.7,
      reviewsCount: 68,
      isVerified: true,
      phone: '711889900',
      fleetCount: 29,
      address: 'مأرب — الشارع العام، المجمع الحكومي',
    ),
    TransportOffice(
      id: 'OFF-04',
      name: 'مؤسسة الساحل الغربي للشحن البري',
      city: 'الحديدة',
      services: 'استيراد وتصدير · مواد غذائية · حاويات',
      rating: 4.85,
      reviewsCount: 110,
      isVerified: true,
      phone: '775544332',
      fleetCount: 44,
      address: 'الحديدة — شارع الميناء، خط جيزان',
    ),
  ];
}

class TransportOrderDraft {
  final String originCity;
  final String destCity;
  final String originAddressDetail;
  final String destAddressDetail;
  final double? originLatitude;
  final double? originLongitude;
  final double? destLatitude;
  final double? destLongitude;
  final CargoCardItem cargo;
  final String vehicleType;
  final String loadingDate;
  final String loadingTime;
  final ScheduleFlexibility flexibility;
  final String minBudget;
  final String maxBudget;
  final bool isBudgetNegotiable;
  final PublishTarget target;
  final DriverProfile? selectedDriver;
  final TransportOffice? selectedOffice;
  final String notes;
  final ContactMethod contactMethod;
  final String phone;

  const TransportOrderDraft({
    required this.originCity,
    required this.destCity,
    this.originAddressDetail = '',
    this.destAddressDetail = '',
    this.originLatitude,
    this.originLongitude,
    this.destLatitude,
    this.destLongitude,
    required this.cargo,
    required this.vehicleType,
    required this.loadingDate,
    required this.loadingTime,
    required this.flexibility,
    required this.minBudget,
    required this.maxBudget,
    required this.isBudgetNegotiable,
    required this.target,
    this.selectedDriver,
    this.selectedOffice,
    this.notes = '',
    this.contactMethod = ContactMethod.whatsapp,
    this.phone = '',
  });
}
