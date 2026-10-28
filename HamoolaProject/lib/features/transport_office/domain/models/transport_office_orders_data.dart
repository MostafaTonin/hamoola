import '../../../driver/domain/models/cargo_bid_opportunity.dart';
import '../../../merchant/domain/models/merchant_order.dart';

/// The two primary roles/tabs for Transport Office orders
enum TransportOfficeOrderRole {
  provider, // كمقدم خدمة: طلبات وعروض النقل
  requester, // كطالب خدمة: طلباتي للبحث عن سائق
}

/// Horizontal filter chips for "كمقدم خدمة"
enum OfficeProviderFilter {
  all('الكل'),
  available('متاحة'),
  myBids('عروضي'),
  assigned('مسندة للمكتب'),
  inProgress('قيد التنفيذ'),
  completed('مكتملة');

  final String label;
  const OfficeProviderFilter(this.label);
}

/// Horizontal filter chips for "كطالب خدمة"
enum OfficeRequesterFilter {
  all('الكل'),
  waitingDriver('بانتظار سائق'),
  assignedDriver('تم إسناد سائق'),
  inProgress('قيد التنفيذ'),
  completed('مكتملة'),
  cancelled('ملغاة');

  final String label;
  const OfficeRequesterFilter(this.label);
}

/// Represents an order viewed by the Transport Office as a Service Provider
class OfficeProviderOrder {
  final String id;
  final String title;
  final String imageAsset;
  final String originCity;
  final String destinationCity;
  final String? originArea;
  final String? destinationArea;
  final int distanceKm;
  final double weightTons;
  final int priceYmr;
  final bool isPrivate;
  final OfficeProviderFilter category;
  final int? bidAmount;
  final String? bidStatus; // 'pending', 'accepted', 'rejected'
  final DateTime? createdAt;
  final String? notes;

  const OfficeProviderOrder({
    required this.id,
    required this.title,
    required this.imageAsset,
    required this.originCity,
    required this.destinationCity,
    this.originArea,
    this.destinationArea,
    required this.distanceKm,
    required this.weightTons,
    required this.priceYmr,
    required this.isPrivate,
    required this.category,
    this.bidAmount,
    this.bidStatus,
    this.createdAt,
    this.notes,
  });

  OfficeProviderOrder copyWith({
    String? id,
    String? title,
    String? imageAsset,
    String? originCity,
    String? destinationCity,
    String? originArea,
    String? destinationArea,
    int? distanceKm,
    double? weightTons,
    int? priceYmr,
    bool? isPrivate,
    OfficeProviderFilter? category,
    int? bidAmount,
    String? bidStatus,
    DateTime? createdAt,
    String? notes,
  }) {
    return OfficeProviderOrder(
      id: id ?? this.id,
      title: title ?? this.title,
      imageAsset: imageAsset ?? this.imageAsset,
      originCity: originCity ?? this.originCity,
      destinationCity: destinationCity ?? this.destinationCity,
      originArea: originArea ?? this.originArea,
      destinationArea: destinationArea ?? this.destinationArea,
      distanceKm: distanceKm ?? this.distanceKm,
      weightTons: weightTons ?? this.weightTons,
      priceYmr: priceYmr ?? this.priceYmr,
      isPrivate: isPrivate ?? this.isPrivate,
      category: category ?? this.category,
      bidAmount: bidAmount ?? this.bidAmount,
      bidStatus: bidStatus ?? this.bidStatus,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  /// Converts to CargoBidOpportunity for compatibility with existing driver details & bidding flows
  CargoBidOpportunity toCargoOpportunity() {
    return CargoBidOpportunity(
      id: id,
      title: title,
      merchantName: isPrivate ? 'طلب خاص موجه لمكتبك' : 'تاجر معتمد في حمولة',
      merchantRating: 4.9,
      originCity: originCity,
      destinationCity: destinationCity,
      pickupArea: originArea ?? originCity,
      dropoffArea: destinationArea ?? destinationCity,
      distanceKm: distanceKm,
      durationHours: (distanceKm / 60.0).clamp(1.5, 12.0),
      weightTons: weightTons,
      requiredTruckType: 'شاحنة نقل بضائع',
      urgencyLabel: isPrivate ? 'طلب خاص موجه لمكتبك' : 'متاح للتقديم',
      isUrgent: false,
      targetBudgetYmr: priceYmr,
      offersCount: category == OfficeProviderFilter.myBids ? 2 : 1,
      loadingWindow: 'خلال 24 ساعة',
      paymentTerms: 'دفع مؤمن عبر محفظة حمولة',
      isInsuranceRequired: true,
      notes: notes ?? 'الحمولة جاهزة في الموقع. يرجى التأكد من توفر الوثائق المطلوبة والالتزام بموعد التحميل.',
      isPrivate: isPrivate,
      imageAsset: imageAsset,
      galleryImages: [imageAsset],
    );
  }

  /// Realistic demo orders matching the reference image under "كمقدم خدمة"
  static List<OfficeProviderOrder> get demoOrders => [
        const OfficeProviderOrder(
          id: 'REQ-2401',
          title: 'نقل مواد بناء (أسمنت)',
          imageAsset: 'assets/images/cement_sacks_pallet.jpg',
          originCity: 'صنعاء',
          destinationCity: 'تعز',
          originArea: 'صنعاء - الحصبة',
          destinationArea: 'تعز - الحوبان',
          distanceKm: 92,
          weightTons: 12.0,
          priceYmr: 55000,
          isPrivate: false,
          category: OfficeProviderFilter.available,
          notes: 'حمولة أكياس أسمنت معبأة ومثبتة على طبالي خشبية جاهزة للنقل.',
        ),
        const OfficeProviderOrder(
          id: 'REQ-2398',
          title: 'نقل مواسير حديدية',
          imageAsset: 'assets/images/steel_pipes_cargo.jpg',
          originCity: 'عدن',
          destinationCity: 'إب',
          originArea: 'عدن - ميناء المعلا',
          destinationArea: 'إب - المنطقة الصناعية',
          distanceKm: 280,
          weightTons: 20.0,
          priceYmr: 75000,
          isPrivate: true,
          category: OfficeProviderFilter.available,
          notes: 'مواسير حديد مجلفن دائرية مربوطة ومحكمة التستيف وجاهزة للنقل.',
        ),
        const OfficeProviderOrder(
          id: 'REQ-2395',
          title: 'نقل منتجات زراعية',
          imageAsset: 'assets/images/client_hero_crops.jpg',
          originCity: 'صنعاء',
          destinationCity: 'الحديدة',
          originArea: 'صنعاء - سوق ذهبان',
          destinationArea: 'الحديدة - الميناء',
          distanceKm: 226,
          weightTons: 10.0,
          priceYmr: 45000,
          isPrivate: false,
          category: OfficeProviderFilter.available,
          notes: 'صناديق خضار وفواكه طازجة تتطلب تهوية جيدة وتفريغ فوري.',
        ),
        const OfficeProviderOrder(
          id: 'REQ-2390',
          title: 'نقل مواد غذائية',
          imageAsset: 'assets/images/cargo_ref_2.jpg',
          originCity: 'تعز',
          destinationCity: 'صنعاء',
          originArea: 'تعز - شارع جمال',
          destinationArea: 'صنعاء - باب اليمن',
          distanceKm: 180,
          weightTons: 8.0,
          priceYmr: 38000,
          isPrivate: true,
          category: OfficeProviderFilter.available,
          notes: 'كراتين مواد غذائية ومعلبات محكمة الإغلاق ونظيفة.',
        ),
        const OfficeProviderOrder(
          id: 'REQ-2380',
          title: 'حديد تسليح ومعدات بناء',
          imageAsset: 'assets/images/cargo_rebar.png',
          originCity: 'الحديدة',
          destinationCity: 'صنعاء',
          distanceKm: 226,
          weightTons: 24.0,
          priceYmr: 380000,
          isPrivate: false,
          category: OfficeProviderFilter.assigned,
          notes: 'تم إسناد الطلب للمكتب، وبانتظار بدء حركة الشاحنة.',
        ),
        const OfficeProviderOrder(
          id: 'REQ-2375',
          title: 'بضائع تجارية وكراتين شحن',
          imageAsset: 'assets/images/hamula_intercity_cargo.jpg',
          originCity: 'عدن',
          destinationCity: 'صنعاء',
          distanceKm: 360,
          weightTons: 18.0,
          priceYmr: 320000,
          isPrivate: false,
          category: OfficeProviderFilter.inProgress,
          notes: 'الرحلة قيد التنفيذ حالياً، تم تجاوز نقيل يسلح.',
        ),
        const OfficeProviderOrder(
          id: 'REQ-2350',
          title: 'معدات طاقة شمسية وبطاريات',
          imageAsset: 'assets/images/hamula_port_cargo.jpg',
          originCity: 'المكلا',
          destinationCity: 'مأرب',
          distanceKm: 490,
          weightTons: 12.0,
          priceYmr: 620000,
          isPrivate: false,
          category: OfficeProviderFilter.completed,
          notes: 'تم تسليم الحمولة بنجاح وإيداع المستحقات في محفظة المكتب.',
        ),
      ];
}

/// Represents an order created by the Transport Office as a Service Requester
class OfficeRequesterOrder {
  final String id;
  final String title;
  final String imageAsset;
  final String originCity;
  final String destinationCity;
  final String? originArea;
  final String? destinationArea;
  final String dateStr;
  final double weightTons;
  final int distanceKm;
  final int priceYmr;
  final OfficeRequesterFilter status;
  final String? driverName;
  final String? driverPhone;
  final String? tripId;
  final String? notes;

  const OfficeRequesterOrder({
    required this.id,
    required this.title,
    required this.imageAsset,
    required this.originCity,
    required this.destinationCity,
    this.originArea,
    this.destinationArea,
    required this.dateStr,
    required this.weightTons,
    required this.distanceKm,
    required this.priceYmr,
    required this.status,
    this.driverName,
    this.driverPhone,
    this.tripId,
    this.notes,
  });

  OfficeRequesterOrder copyWith({
    String? id,
    String? title,
    String? imageAsset,
    String? originCity,
    String? destinationCity,
    String? originArea,
    String? destinationArea,
    String? dateStr,
    double? weightTons,
    int? distanceKm,
    int? priceYmr,
    OfficeRequesterFilter? status,
    String? driverName,
    String? driverPhone,
    String? tripId,
    String? notes,
  }) {
    return OfficeRequesterOrder(
      id: id ?? this.id,
      title: title ?? this.title,
      imageAsset: imageAsset ?? this.imageAsset,
      originCity: originCity ?? this.originCity,
      destinationCity: destinationCity ?? this.destinationCity,
      originArea: originArea ?? this.originArea,
      destinationArea: destinationArea ?? this.destinationArea,
      dateStr: dateStr ?? this.dateStr,
      weightTons: weightTons ?? this.weightTons,
      distanceKm: distanceKm ?? this.distanceKm,
      priceYmr: priceYmr ?? this.priceYmr,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      tripId: tripId ?? this.tripId,
      notes: notes ?? this.notes,
    );
  }

  /// Converts to MerchantOrder for compatibility with existing merchant details dialog & assignment flows
  MerchantOrder toMerchantOrder() {
    MerchantOrderStatus orderStatus;
    switch (status) {
      case OfficeRequesterFilter.waitingDriver:
        orderStatus = MerchantOrderStatus.pendingDriver;
        break;
      case OfficeRequesterFilter.assignedDriver:
        orderStatus = MerchantOrderStatus.assignedDriver;
        break;
      case OfficeRequesterFilter.inProgress:
        orderStatus = MerchantOrderStatus.inTransit;
        break;
      case OfficeRequesterFilter.completed:
        orderStatus = MerchantOrderStatus.completed;
        break;
      case OfficeRequesterFilter.cancelled:
        orderStatus = MerchantOrderStatus.draft;
        break;
      case OfficeRequesterFilter.all:
        orderStatus = MerchantOrderStatus.pendingDriver;
        break;
    }

    return MerchantOrder(
      id: id,
      cargoName: title,
      originCity: originCity,
      destinationCity: destinationCity,
      status: orderStatus,
      driverName: driverName,
      timeAgo: dateStr,
      expectedPrice: priceYmr.toDouble(),
      agreedFare: priceYmr.toDouble(),
      notes: notes ?? 'طلب نقل صادر من مكتب النقل.',
      targetProviderPhone: driverPhone,
      isPaid: status == OfficeRequesterFilter.inProgress ||
          status == OfficeRequesterFilter.completed,
      isClosed: status == OfficeRequesterFilter.cancelled,
    );
  }

  /// Realistic demo orders matching the reference image under "كطالب خدمة"
  static List<OfficeRequesterOrder> get demoOrders => [
        const OfficeRequesterOrder(
          id: 'REQ-2410',
          title: 'نقل رمل وبحص',
          imageAsset: 'assets/images/sand_gravel_cargo.jpg',
          originCity: 'صنعاء',
          destinationCity: 'تعز',
          originArea: 'صنعاء - المطار',
          destinationArea: 'تعز - بير باشا',
          dateStr: '15 مايو 2024',
          weightTons: 92.0,
          distanceKm: 92,
          priceYmr: 65000,
          status: OfficeRequesterFilter.waitingDriver,
          notes: 'شحنة رمل مغسول وبحص بناء، يلزم شاحنة قلاب حمولة ثقيلة.',
        ),
        const OfficeRequesterOrder(
          id: 'REQ-2408',
          title: 'نقل أسمنت',
          imageAsset: 'assets/images/cement_sacks_pallet.jpg',
          originCity: 'عدن',
          destinationCity: 'إب',
          originArea: 'عدن - الميناء',
          destinationArea: 'إب - الدائري',
          dateStr: '10 مايو 2024',
          weightTons: 20.0,
          distanceKm: 280,
          priceYmr: 75000,
          status: OfficeRequesterFilter.assignedDriver,
          driverName: 'كابتن عصام الحبيشي',
          driverPhone: '+967 771 889 900',
          notes: 'تم إسناد الشحنة للسائق وبانتظار موعد التحميل.',
        ),
        const OfficeRequesterOrder(
          id: 'REQ-2405',
          title: 'نقل منتجات زراعية',
          imageAsset: 'assets/images/client_hero_crops.jpg',
          originCity: 'الحديدة',
          destinationCity: 'صنعاء',
          originArea: 'الحديدة - كيلو 16',
          destinationArea: 'صنعاء - سوق شميلة',
          dateStr: '10 مايو 2024',
          weightTons: 12.0,
          distanceKm: 226,
          priceYmr: 50000,
          status: OfficeRequesterFilter.inProgress,
          driverName: 'كابتن أحمد صالح النجار',
          driverPhone: '+967 771 998 877',
          tripId: 'TRIP-OFFICE-2405',
          notes: 'الرحلة على الطريق السريع، تم تأكيد نقطة العبور بمناخة.',
        ),
        const OfficeRequesterOrder(
          id: 'REQ-2400',
          title: 'نقل مواسير',
          imageAsset: 'assets/images/steel_pipes_cargo.jpg',
          originCity: 'تعز',
          destinationCity: 'عدن',
          originArea: 'تعز - مصانع الحوبان',
          destinationArea: 'عدن - المنصورة',
          dateStr: '5 مايو 2024',
          weightTons: 18.0,
          distanceKm: 180,
          priceYmr: 58000,
          status: OfficeRequesterFilter.completed,
          driverName: 'كابتن ياسر عبده القاضي',
          driverPhone: '+967 770 456 123',
          notes: 'اكتملت عملية التسليم والتفريغ، وتم توقيع سند الاستلام.',
        ),
        const OfficeRequesterOrder(
          id: 'REQ-2385',
          title: 'نقل أثاث ومكتبيات',
          imageAsset: 'assets/images/hamula_furniture_trucks.jpg',
          originCity: 'صنعاء',
          destinationCity: 'عدن',
          originArea: 'صنعاء - حدة',
          destinationArea: 'عدن - خور مكسر',
          dateStr: '1 مايو 2024',
          weightTons: 6.0,
          distanceKm: 360,
          priceYmr: 42000,
          status: OfficeRequesterFilter.cancelled,
          notes: 'تم إلغاء الطلب من قبل المكتب لتغير خطة النقل.',
        ),
      ];
}
