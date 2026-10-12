/// Domain model representing a competitive transport offer submitted by a truck driver.
class DriverOffer {
  final String id;
  final String orderId;
  final String driverId;
  final String driverName;
  final double rating;
  final int tripsCount;
  final String vehicleName;
  final String vehiclePlate;
  final double price;
  final String currency;
  final String pickupTimeText;
  final String deliveryTimeText;
  final bool isVerified;
  final bool isBestPrice;
  final bool isHighestRated;
  final bool isFastest;
  final String notes;
  final bool hasInsurance;
  final bool hasGpsTracking;
  final String driverPhone;

  const DriverOffer({
    required this.id,
    required this.orderId,
    required this.driverId,
    required this.driverName,
    required this.rating,
    required this.tripsCount,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.price,
    this.currency = 'ر.ي',
    required this.pickupTimeText,
    required this.deliveryTimeText,
    this.isVerified = true,
    this.isBestPrice = false,
    this.isHighestRated = false,
    this.isFastest = false,
    required this.notes,
    this.hasInsurance = true,
    this.hasGpsTracking = true,
    this.driverPhone = '+967 771 234 567',
  });

  /// Formatted price with commas (e.g. 420,000)
  String get formattedPrice {
    final intPrice = price.toInt();
    final str = intPrice.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (match) => ',');
  }

  /// Demo offers submitted for cargo REQ-1024
  static List<DriverOffer> get demoOffers => const [
        DriverOffer(
          id: 'OFF-301',
          orderId: 'REQ-1024',
          driverId: 'DRV-101',
          driverName: 'كابتن سالم العولقي',
          rating: 4.9,
          tripsCount: 184,
          vehicleName: 'قاطرة مسطحة 30 طن — مان TGX',
          vehiclePlate: 'صنعاء 14-8832',
          price: 420000,
          pickupTimeText: 'اليوم 2:30 ظهراً',
          deliveryTimeText: 'غداً 8:00 صباحاً',
          isVerified: true,
          isBestPrice: true,
          isHighestRated: false,
          isFastest: false,
          notes: 'جاهز للتحميل فوراً ولدي مظلات وأحزمة تثبيت مشددة للبضاعة.',
          hasInsurance: true,
          hasGpsTracking: true,
          driverPhone: '+967 771 450 123',
        ),
        DriverOffer(
          id: 'OFF-302',
          orderId: 'REQ-1024',
          driverId: 'DRV-102',
          driverName: 'كابتن نبيل الحاشدي',
          rating: 5.0,
          tripsCount: 312,
          vehicleName: 'شاحنة صندوق مقفل 28 طن — مرسيدس أكتروس',
          vehiclePlate: 'صنعاء 22-9401',
          price: 440000,
          pickupTimeText: 'اليوم 4:00 عصراً',
          deliveryTimeText: 'غداً 11:00 صباحاً',
          isVerified: true,
          isBestPrice: false,
          isHighestRated: true,
          isFastest: false,
          notes: 'صندوق معزول ومغلق بالكامل يحمي المواد الغذائية من أي حرارة أو غبار.',
          hasInsurance: true,
          hasGpsTracking: true,
          driverPhone: '+967 773 992 018',
        ),
        DriverOffer(
          id: 'OFF-303',
          orderId: 'REQ-1024',
          driverId: 'DRV-103',
          driverName: 'كابتن عادل باوزير',
          rating: 4.8,
          tripsCount: 96,
          vehicleName: 'دينا شاص طويل 15 طن — إيسوزو FVR',
          vehiclePlate: 'عدن 05-3319',
          price: 410000,
          pickupTimeText: 'خلال ساعة واحدة',
          deliveryTimeText: 'فجر الغد 5:30 ص',
          isVerified: true,
          isBestPrice: false,
          isHighestRated: false,
          isFastest: true,
          notes: 'متواجد حالياً في منطقة التحميل بصنعاء وجاهز للانطلاق المباشر.',
          hasInsurance: true,
          hasGpsTracking: true,
          driverPhone: '+967 777 810 542',
        ),
        DriverOffer(
          id: 'OFF-304',
          orderId: 'REQ-1024',
          driverId: 'DRV-104',
          driverName: 'كابتن مروان العدني',
          rating: 4.7,
          tripsCount: 65,
          vehicleName: 'شاحنة جوانب شبك 25 طن — رينو K',
          vehiclePlate: 'عدن 11-7054',
          price: 450000,
          pickupTimeText: 'اليوم 6:00 مساءً',
          deliveryTimeText: 'غداً 2:00 ظهراً',
          isVerified: false,
          isBestPrice: false,
          isHighestRated: false,
          isFastest: false,
          notes: 'السعر يشمل عمال التحميل والتفريغ عند الوصول.',
          hasInsurance: false,
          hasGpsTracking: true,
          driverPhone: '+967 734 661 290',
        ),
      ];
}
