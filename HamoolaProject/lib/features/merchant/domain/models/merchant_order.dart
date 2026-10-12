import 'package:flutter/material.dart';

/// Status of a merchant freight order
enum MerchantOrderStatus {
  pendingDriver,
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
  });

  String get statusLabel {
    switch (status) {
      case MerchantOrderStatus.pendingDriver:
        return 'بانتظار اختيار سائق';
      case MerchantOrderStatus.assignedDriver:
        return 'مسند للسائق';
      case MerchantOrderStatus.inTransit:
        return 'قيد النقل';
      case MerchantOrderStatus.completed:
        return 'مكتمل';
    }
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
        ),
        const MerchantOrder(
          id: 'REQ-1023',
          cargoName: 'بضائع تجارية',
          originCity: 'تعز',
          destinationCity: 'صنعاء',
          status: MerchantOrderStatus.assignedDriver,
          driverName: 'كابتن أحمد النجار',
          timeAgo: 'أمس',
          iconData: Icons.local_shipping_outlined,
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
