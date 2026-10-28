import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_home_screen.dart';

void main() {
  Widget createDriverApp({
    VoidCallback? onNotifications,
    VoidCallback? onSwitchToMerchant,
    VoidCallback? onWallet,
    VoidCallback? onSupport,
    VoidCallback? onLogout,
    ValueChanged<String>? onTripDetails,
    VoidCallback? onVerifyLicense,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: DriverHomeScreen(
          onNotifications: onNotifications,
          onSwitchToMerchant: onSwitchToMerchant,
          onWallet: onWallet,
          onSupport: onSupport,
          onLogout: onLogout,
          onTripDetails: onTripDetails,
          onVerifyLicense: onVerifyLicense,
        ),
      ),
    );
  }

  group('Hamula Driver Home Screen Prototype Tests', () {
    testWidgets('Renders all required sections per reference design', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createDriverApp());
      await tester.pumpAndSettle();

      // 1. Header: logo, greeting, subtitle, avatar, notification bell (3)
      expect(find.text('حمولة'), findsOneWidget);
      expect(find.textContaining('أهلاً، أحمد'), findsOneWidget);
      expect(find.text('سائق في منصة حمولة'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Bell badge

      // 2. Availability status card: online state
      expect(find.text('متاح الآن'), findsOneWidget);
      expect(find.text('متاح لاستقبال الطلبات'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      // 3. Conditional Active Trip Card (TRP-4091)
      expect(find.text('رحلة جارية الآن'), findsOneWidget);
      expect(find.text('TRP-4091'), findsOneWidget);
      expect(find.text('متابعة الرحلة'), findsOneWidget);

      // 4. Hero Banner
      expect(find.text('فرص نقل جديدة بانتظارك'), findsOneWidget);
      expect(find.text('اكتشف أفضل الطلبات المناسبة لناقلتك'), findsOneWidget);
      expect(find.text('عرض الطلبات'), findsOneWidget);

      // 5. 3 Statistics Cards
      expect(find.text('الطلبات المتاحة'), findsWidgets);
      expect(find.text('الطلبات النشطة'), findsOneWidget);
      expect(find.text('الرحلات المكتملة'), findsOneWidget);

      // 6. Quick Services (4 items)
      expect(find.text('رحلاتي'), findsOneWidget);
      expect(find.text('خريطة الحمولات'), findsOneWidget);
      expect(find.text('محفظتي'), findsWidgets);
      expect(find.text('أرباحي'), findsOneWidget);

      // 7. Available Orders Section & Filter Chips
      expect(find.text('الطلبات المتاحة لك'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('العامة'), findsOneWidget);
      expect(find.text('الخاصة'), findsOneWidget);

      // 8. Bottom Navigation Bar items
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الخريطة'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);
    });

    testWidgets('Availability toggle hides new available orders while preserving active trip', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createDriverApp());
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Initially online -> orders are visible
      expect(find.text('عرض التفاصيل'), findsWidgets);

      // Toggle to offline
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Status text changes immediately
      expect(find.text('غير متاح'), findsOneWidget);
      expect(find.text('غير متاح لاستقبال الطلبات'), findsOneWidget);
      expect(find.text('أنت غير متاح حالياً لاستقبال الطلبات'), findsOneWidget);

      // Active trip remains visible and fully accessible even when offline
      expect(find.text('رحلة جارية الآن'), findsOneWidget);
      expect(find.text('متابعة الرحلة'), findsOneWidget);

      // Toggle back to online
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.text('متاح الآن'), findsOneWidget);
      expect(find.text('عرض التفاصيل'), findsWidgets);
    });

    testWidgets('Quick Actions (+) opens dark navy quadrant card with 4 specific actions and (x) button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createDriverApp());
      await tester.pumpAndSettle();

      // Find center (+) button in bottom navigation
      final plusBtn = find.byIcon(Icons.add_rounded);
      expect(plusBtn, findsOneWidget);

      // Tap (+) to open Quick Actions modal
      await tester.tap(plusBtn);
      await tester.pumpAndSettle();

      // The icon should now be transformed to (x)
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // 4 Quadrant actions are visible
      expect(find.text('تحديث الحالة'), findsOneWidget);
      expect(find.text('الطلبات المتاحة'), findsWidgets);
      expect(find.text('طلب مساعدة'), findsOneWidget);
      expect(find.text('الإبلاغ عن مشكلة'), findsOneWidget);

      // Tap (x) to close the modal
      final closeBtn = find.byIcon(Icons.close_rounded);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      // Quick actions closed, icon restored to (+)
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('Quick Actions quadrant options open interactive dialogs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createDriverApp());
      await tester.pumpAndSettle();

      // 1. Open (+) and tap "الإبلاغ عن مشكلة"
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      final reportIssueOption = find.text('الإبلاغ عن مشكلة');
      expect(reportIssueOption, findsOneWidget);
      await tester.tap(reportIssueOption);
      await tester.pumpAndSettle();

      // Dialog for reporting an issue is displayed
      expect(find.text('نوع المشكلة'), findsOneWidget);
      expect(find.text('إرسال البلاغ'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      // 2. Open (+) and tap "طلب مساعدة"
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      final requestHelpOption = find.text('طلب مساعدة');
      expect(requestHelpOption, findsOneWidget);
      await tester.tap(requestHelpOption);
      await tester.pumpAndSettle();

      // Dialog for help request is displayed
      expect(find.text('مركز المساعدة والدعم'), findsOneWidget);
      expect(find.text('الأسئلة الشائعة للسائقين'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('الأسئلة الشائعة للسائقين'));
      await tester.pumpAndSettle();

      // 3. Open (+) and tap "تحديث الحالة"
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      final updateStatusOption = find.text('تحديث الحالة');
      expect(updateStatusOption, findsOneWidget);
      await tester.tap(updateStatusOption);
      await tester.pumpAndSettle();

      // Dialog for status update is displayed
      expect(find.text('تحديث حالة التوفر'), findsOneWidget);
      expect(find.text('متاح الآن لاستقبال الطلبات'), findsOneWidget);
      expect(find.text('غير متاح حالياً (استراحة)'), findsOneWidget);

      // Confirm and close modal
      await tester.tap(find.text('تأكيد وحفظ الحالة'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
    });

    testWidgets('Hero banner "عرض الطلبات" scrolls down to available orders section', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createDriverApp());
      await tester.pumpAndSettle();

      final viewOrdersBtn = find.text('عرض الطلبات');
      expect(viewOrdersBtn, findsOneWidget);

      await tester.tap(viewOrdersBtn);
      await tester.pumpAndSettle();

      // Available orders section header is visible
      expect(find.text('الطلبات المتاحة لك'), findsOneWidget);
    });
  });
}
