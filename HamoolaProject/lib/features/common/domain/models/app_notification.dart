import 'package:flutter/material.dart';

enum NotificationCategory {
  bids,
  tracking,
  finance,
  system,
}

/// Domain model representing an in-app notification.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final String timeAgo;
  final bool isRead;
  final String? targetRoute;
  final String? routeArgument;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.timeAgo,
    this.isRead = false,
    this.targetRoute,
    this.routeArgument,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationCategory? category,
    String? timeAgo,
    bool? isRead,
    String? targetRoute,
    String? routeArgument,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      timeAgo: timeAgo ?? this.timeAgo,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute ?? this.targetRoute,
      routeArgument: routeArgument ?? this.routeArgument,
    );
  }

  IconData get iconData {
    switch (category) {
      case NotificationCategory.bids:
        return Icons.local_offer_rounded;
      case NotificationCategory.tracking:
        return Icons.local_shipping_rounded;
      case NotificationCategory.finance:
        return Icons.account_balance_wallet_rounded;
      case NotificationCategory.system:
        return Icons.verified_user_rounded;
    }
  }

  Color get iconColor {
    switch (category) {
      case NotificationCategory.bids:
        return const Color(0xFFF59E0B);
      case NotificationCategory.tracking:
        return const Color(0xFF10B981);
      case NotificationCategory.finance:
        return const Color(0xFF3B82F6);
      case NotificationCategory.system:
        return const Color(0xFF8B5CF6);
    }
  }

  Color get iconBgColor {
    switch (category) {
      case NotificationCategory.bids:
        return const Color(0x2EF59E0B);
      case NotificationCategory.tracking:
        return const Color(0x2E10B981);
      case NotificationCategory.finance:
        return const Color(0x2E3B82F6);
      case NotificationCategory.system:
        return const Color(0x2E8B5CF6);
    }
  }

  /// Default demo notifications matching Hamula's live status
  static List<AppNotification> get demoNotifications => const [
        AppNotification(
          id: 'NTF-101',
          title: 'عرض سعر جديد على الشحنة REQ-1024',
          body: 'قدّم كابتن سالم العولقي عرض سعر بقيمة 420,000 ر.ي لنقل المواد الغذائية إلى عدن.',
          category: NotificationCategory.bids,
          timeAgo: 'منذ 10 دقائق',
          isRead: false,
          targetRoute: '/merchant/offers-review',
          routeArgument: 'REQ-1024',
        ),
        AppNotification(
          id: 'NTF-102',
          title: 'الشاحنة وصلت إلى نقطة التحميل',
          body: 'وصل كابتن أحمد النجار إلى مستودع التحميل في صنعاء وجاري فحص وربط البضاعة.',
          category: NotificationCategory.tracking,
          timeAgo: 'منذ 35 دقيقة',
          isRead: false,
          targetRoute: '/merchant/trip-tracking',
          routeArgument: 'REQ-1023',
        ),
        AppNotification(
          id: 'NTF-103',
          title: 'عرض منافس جديد: وفر 40,000 ر.ي',
          body: 'قدّم كابتن عادل باوزير عرضاً سريعاً بقيمة 410,000 ر.ي مع جاهزية للتحميل خلال ساعة.',
          category: NotificationCategory.bids,
          timeAgo: 'منذ ساعة',
          isRead: false,
          targetRoute: '/merchant/offers-review',
          routeArgument: 'REQ-1024',
        ),
        AppNotification(
          id: 'NTF-104',
          title: 'تأكيد إضافة رصيد للمحفظة',
          body: 'تم استلام وتأكيد إيداع 500,000 ر.ي في محفظتك عبر بنك الكريمي بنجاح.',
          category: NotificationCategory.finance,
          timeAgo: 'منذ ساعتين',
          isRead: true,
          targetRoute: '/merchant/wallet',
        ),
        AppNotification(
          id: 'NTF-105',
          title: 'تنبيه مستشعر درجة حرارة الحاوية',
          body: 'درجة حرارة الحاوية مستقرة عند 4°C ومطابقة لمعايير نقل البضائع المبردة.',
          category: NotificationCategory.tracking,
          timeAgo: 'منذ 4 ساعات',
          isRead: true,
          targetRoute: '/merchant/trip-tracking',
        ),
        AppNotification(
          id: 'NTF-106',
          title: 'تم اعتماد وتوثيق منشأتك رسمياً',
          body: 'تمت مطابقة السجل التجاري والترخيص وأصبح حسابك موثقاً بالكامل في حمولة.',
          category: NotificationCategory.system,
          timeAgo: 'أمس',
          isRead: true,
          targetRoute: '/merchant/verification',
        ),
      ];
}
