import 'package:flutter/material.dart';

/// Status of a merchant freight order
enum MerchantOrderStatus {
  draft,
  pendingDriver,
  pendingOffice,
  assignedDriver,
  inTransit,
  completed,
}

/// Domain model representing a merchant's freight order
class MerchantOrder {
  final String id;
  final String cargoName;
  final String originCity;
  final String destinationCity;
  final MerchantOrderStatus status;
  final int offersCount;
  final String? driverName;
  final String timeAgo;
  final IconData iconData;
  final String? vehicleType;
  final String? broadcastScope;
  final String? notes;
  final double? expectedPrice;
  final double? minBudget;
  final double? maxBudget;
  final double? agreedFare;
  final String? directStatus; // null, 'pending', 'accepted', 'rejected'
  final bool isPaid;
  final bool isClosed;
  final DateTime? closedAt;
  final String? targetProviderPhone;
  final String? targetProviderId;

  const MerchantOrder({
    required this.id,
    required this.cargoName,
    required this.originCity,
    required this.destinationCity,
    required this.status,
    this.offersCount = 0,
    this.driverName,
    required this.timeAgo,
    this.iconData = Icons.inventory_2_outlined,
    this.vehicleType,
    this.broadcastScope,
    this.notes,
    this.expectedPrice,
    this.minBudget,
    this.maxBudget,
    this.agreedFare,
    this.directStatus,
    this.isPaid = false,
    this.isClosed = false,
    this.closedAt,
    this.targetProviderPhone,
    this.targetProviderId,
  });

  String get orderNumber => id;
  String get cargoTitle => cargoName;
  double? get budget => expectedPrice ?? maxBudget ?? minBudget;
  double get weightTons => 25.0;
  String? get assignedDriverName => driverName;
  String? get assignedDriverPhone => targetProviderPhone;
  double? get directFee => agreedFare ?? expectedPrice ?? maxBudget;

  bool get isDirectOrder =>
      broadcastScope == 'driver' || broadcastScope == 'office';

  bool get isContactRevealed => isPaid;

  String get maskedTargetPhone {
    if (isContactRevealed) {
      return targetProviderPhone ?? '+967 771 234 567';
    }
    return '+967 77*** ***';
  }

  bool get isEditable =>
      status == MerchantOrderStatus.draft ||
      status == MerchantOrderStatus.pendingDriver ||
      status == MerchantOrderStatus.pendingOffice;

  String get statusLabel {
    if (status == MerchantOrderStatus.draft) {
      return 'مسودة';
    }
    if (isDirectOrder) {
      if (status == MerchantOrderStatus.assignedDriver) {
        return 'مسند للجهة المنفذة';
      }
      if (directStatus == 'accepted') {
        return 'تم قبول الطلب (بانتظار الدفع)';
      }
      if (directStatus == 'rejected') {
        return 'تم اعتذار الجهة';
      }
      if (directStatus == 'pending') {
        return 'بانتظار قبول الجهة';
      }
    }
    switch (status) {
      case MerchantOrderStatus.draft:
        return 'مسودة';
      case MerchantOrderStatus.pendingDriver:
        return 'بانتظار اختيار سائق';
      case MerchantOrderStatus.pendingOffice:
        return 'بانتظار مكتب';
      case MerchantOrderStatus.assignedDriver:
        return 'مسند للسائق';
      case MerchantOrderStatus.inTransit:
        return 'قيد النقل';
      case MerchantOrderStatus.completed:
        return 'مكتمل';
    }
  }

  MerchantOrder copyWith({
    String? id,
    String? cargoName,
    String? originCity,
    String? destinationCity,
    MerchantOrderStatus? status,
    int? offersCount,
    String? driverName,
    String? timeAgo,
    IconData? iconData,
    String? vehicleType,
    String? broadcastScope,
    String? notes,
    double? expectedPrice,
    double? minBudget,
    double? maxBudget,
    double? agreedFare,
    String? directStatus,
    bool? isPaid,
    bool? isClosed,
    DateTime? closedAt,
    String? targetProviderPhone,
    String? targetProviderId,
  }) {
    return MerchantOrder(
      id: id ?? this.id,
      cargoName: cargoName ?? this.cargoName,
      originCity: originCity ?? this.originCity,
      destinationCity: destinationCity ?? this.destinationCity,
      status: status ?? this.status,
      offersCount: offersCount ?? this.offersCount,
      driverName: driverName ?? this.driverName,
      timeAgo: timeAgo ?? this.timeAgo,
      iconData: iconData ?? this.iconData,
      vehicleType: vehicleType ?? this.vehicleType,
      broadcastScope: broadcastScope ?? this.broadcastScope,
      notes: notes ?? this.notes,
      expectedPrice: expectedPrice ?? this.expectedPrice,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      agreedFare: agreedFare ?? this.agreedFare,
      directStatus: directStatus ?? this.directStatus,
      isPaid: isPaid ?? this.isPaid,
      isClosed: isClosed ?? this.isClosed,
      closedAt: closedAt ?? this.closedAt,
      targetProviderPhone: targetProviderPhone ?? this.targetProviderPhone,
      targetProviderId: targetProviderId ?? this.targetProviderId,
    );
  }

  /// Default demo orders from Hamoola prototype
  static List<MerchantOrder> get demoOrders => [
        const MerchantOrder(
          id: 'REQ-1024',
          cargoName: 'مواد غذائية',
          originCity: 'صنعاء',
          destinationCity: 'عدن',
          status: MerchantOrderStatus.pendingDriver,
          offersCount: 4,
          timeAgo: 'منذ ساعتين',
          iconData: Icons.all_inbox_rounded,
          vehicleType: 'دينا تبريد 10 طن',
          broadcastScope: 'all_drivers',
          notes: 'حمولة مواد غذائية تتطلب تبريد خفيف مع تفريغ في مستودعات المعلا.',
          expectedPrice: 380000,
        ),
        const MerchantOrder(
          id: 'REQ-1023',
          cargoName: 'بضائع تجارية',
          originCity: 'تعز',
          destinationCity: 'صنعاء',
          status: MerchantOrderStatus.assignedDriver,
          driverName: 'كابتن أحمد صالح النجار',
          timeAgo: 'أمس',
          iconData: Icons.local_shipping_outlined,
          vehicleType: 'شاحنة نقل عام 20 طن',
          broadcastScope: 'driver',
          notes: 'بضائع تجارية كراتين مغلفة ومحكمة الإغلاق.',
          expectedPrice: 320000,
          agreedFare: 380000.0,
          isPaid: true,
          targetProviderPhone: '+967 771 998 877',
        ),
        const MerchantOrder(
          id: 'REQ-1025',
          cargoName: 'حديد ومواد بناء وإنشاءات',
          originCity: 'الحديدة',
          destinationCity: 'صنعاء',
          status: MerchantOrderStatus.pendingOffice,
          offersCount: 0,
          timeAgo: 'منذ نصف ساعة',
          iconData: Icons.foundation_outlined,
          vehicleType: 'تريلا جوانب 35 طن',
          broadcastScope: 'all_offices',
          notes: 'حمولة حديد تسليح ومعدات بناء من ميناء الحديدة.',
          expectedPrice: 450000,
        ),
      ];
}

/// Domain model representing an urgent action requiring the merchant's attention
class MerchantAttentionItem {
  final String id;
  final String orderId;
  final String title;
  final String description;
  final String timeAgo;
  final bool isOffers;
  final String actionText;

  const MerchantAttentionItem({
    required this.id,
    required this.orderId,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.isOffers,
    required this.actionText,
  });

  /// Default demo attention items matching the prototype
  static List<MerchantAttentionItem> get demoItems => [
        const MerchantAttentionItem(
          id: 'ATT-001',
          orderId: 'REQ-1024',
          title: 'وصلت عروض جديدة',
          description: 'لديك 4 عروض جديدة على الطلب REQ-1024',
          timeAgo: 'منذ 25 دقيقة',
          isOffers: true,
          actionText: 'مراجعة العروض',
        ),
        const MerchantAttentionItem(
          id: 'ATT-002',
          orderId: 'REQ-1023',
          title: 'طلب عربون بانتظار موافقتك',
          description: 'السائق طلب عربوناً للرحلة على الطلب REQ-1023',
          timeAgo: 'منذ ساعتين',
          isOffers: false,
          actionText: 'مراجعة الطلب',
        ),
      ];
}
