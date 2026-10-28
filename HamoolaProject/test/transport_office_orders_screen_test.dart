import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/storage/app_preferences.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/driver/domain/models/driver_simulation_store.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/transport_office/presentation/screens/transport_office_orders_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    await AppPreferences.instance.resetForTesting();
    await AppPreferences.instance.setOfficeAvailable(true);
    AuthSimulationStore.instance.resetToInitialState();
    DriverSimulationStore.instance.resetToDemo();
    MerchantSimulationStore.instance.resetToInitialState();
  });

  void setPhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget createTestWidget({
    VoidCallback? onBack,
    String? initialTab,
    ValueChanged<String>? onOrderDetails,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: TransportOfficeOrdersScreen(
          onBack: onBack,
          initialTab: initialTab,
          onOrderDetails: onOrderDetails,
        ),
      ),
    );
  }

  group('Transport Office Orders Screen — Comprehensive Acceptance Tests', () {
    testWidgets('Criteria 1 & 2: Both primary tabs exist and switch filters and orders',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Screen Header
      expect(find.text('طلباتي'), findsWidgets);
      expect(find.text('إدارة طلبات مكتب النقل'), findsOneWidget);

      // Both primary tabs exist
      expect(find.text('كمقدم خدمة'), findsOneWidget);
      expect(find.text('طلبات وعروض النقل'), findsOneWidget);
      expect(find.text('كطالب خدمة'), findsOneWidget);
      expect(find.text('طلباتي للبحث عن سائق'), findsOneWidget);

      // By default, "كمقدم خدمة" is active with its specific filter chips:
      // الكل, متاحة, عروضي, مسندة للمكتب, قيد التنفيذ, مكتملة
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('متاحة'), findsOneWidget);
      expect(find.text('عروضي'), findsOneWidget);
      expect(find.text('مسندة للمكتب'), findsOneWidget);
      expect(find.text('قيد التنفيذ'), findsOneWidget);
      expect(find.text('مكتملة'), findsOneWidget);

      // Provider cards visible matching reference image:
      expect(find.text('نقل مواد بناء (أسمنت)'), findsOneWidget);
      expect(find.text('رقم الطلب: REQ-2401'), findsOneWidget);
      expect(find.text('طلب عام'), findsWidgets);
      expect(find.text('55000 ريال'), findsOneWidget);

      // Switch to "كطالب خدمة"
      await tester.tap(find.text('كطالب خدمة'));
      await tester.pumpAndSettle();

      // Filter chips should now be:
      // الكل, بانتظار سائق, تم إسناد سائق, قيد التنفيذ, مكتملة, ملغاة
      expect(find.text('بانتظار سائق'), findsWidgets);
      expect(find.text('تم إسناد سائق'), findsWidgets);
      expect(find.text('ملغاة'), findsWidgets);

      // Requester cards visible matching reference image:
      expect(find.text('نقل رمل وبحص'), findsOneWidget);
      expect(find.text('رقم الطلب: REQ-2410'), findsOneWidget);
      expect(find.text('نقل أسمنت'), findsOneWidget);
      expect(find.text('رقم الطلب: REQ-2408'), findsOneWidget);
    });

    testWidgets('Criteria 3 & 4: Filter chips update orders list immediately',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // In Provider role: Tap "متاحة"
      await tester.tap(find.text('متاحة'));
      await tester.pumpAndSettle();

      expect(find.text('نقل مواد بناء (أسمنت)'), findsOneWidget);
      expect(find.text('نقل مواسير حديدية'), findsOneWidget);

      // Switch to "مسندة للمكتب"
      await tester.tap(find.text('مسندة للمكتب'));
      await tester.pumpAndSettle();

      expect(find.text('حديد تسليح ومعدات بناء'), findsOneWidget);
      expect(find.text('رقم الطلب: REQ-2380'), findsOneWidget);

      // Switch to "كطالب خدمة"
      await tester.tap(find.text('كطالب خدمة'));
      await tester.pumpAndSettle();

      // Tap "تم إسناد سائق"
      await tester.tap(find.text('تم إسناد سائق').first);
      await tester.pumpAndSettle();

      expect(find.text('نقل أسمنت'), findsOneWidget);
      expect(find.text('رقم الطلب: REQ-2408'), findsOneWidget);
      expect(find.text('نقل رمل وبحص'), findsNothing);

      // Tap "ملغاة"
      await tester.tap(find.text('ملغاة'));
      await tester.pumpAndSettle();

      expect(find.text('نقل أثاث ومكتبيات'), findsOneWidget);
      expect(find.text('رقم الطلب: REQ-2385'), findsOneWidget);
    });

    testWidgets('Criteria 5: Search filters current list in real-time',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Search by order ID
      await tester.enterText(searchField, 'REQ-2398');
      await tester.pumpAndSettle();

      expect(find.text('نقل مواسير حديدية'), findsOneWidget);
      expect(find.text('نقل مواد بناء (أسمنت)'), findsNothing);

      // Search by cargo title
      await tester.enterText(searchField, 'زراعية');
      await tester.pumpAndSettle();

      expect(find.text('نقل منتجات زراعية'), findsOneWidget);
      expect(find.text('نقل مواسير حديدية'), findsNothing);

      // Non-matching search shows empty search state
      await tester.enterText(searchField, 'غير_موجود');
      await tester.pumpAndSettle();

      expect(find.text('لا توجد نتائج مطابقة لبحثك'), findsOneWidget);
      expect(find.text('مسح البحث والعودة'), findsOneWidget);

      // Clear search
      await tester.tap(find.text('مسح البحث والعودة'));
      await tester.pumpAndSettle();

      expect(find.text('نقل مواد بناء (أسمنت)'), findsOneWidget);
    });

    testWidgets('Criteria 6 & 7: Action buttons match role and status correctly',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // In Provider role: Available order has "عرض التفاصيل" and "تقديم عرض"
      expect(find.text('عرض التفاصيل'), findsWidgets);
      expect(find.text('تقديم عرض'), findsWidgets);

      // Switch to Requester role
      await tester.tap(find.text('كطالب خدمة'));
      await tester.pumpAndSettle();

      // Card 1 "بانتظار سائق" has only "عرض التفاصيل"
      // Card 2 "تم إسناد سائق" has "التواصل مع السائق"
      expect(find.text('التواصل مع السائق'), findsOneWidget);

      // Tap "التواصل مع السائق" -> opens contact sheet
      await tester.tap(find.text('التواصل مع السائق'));
      await tester.pumpAndSettle();

      expect(find.text('كابتن عصام الحبيشي'), findsOneWidget);
      expect(find.text('+967 771 889 900'), findsOneWidget);
      expect(find.text('اتصال هاتفي مباشر'), findsOneWidget);
      expect(find.text('محادثة فورية عبر حمولة'), findsOneWidget);

      // Close bottom sheet
      await tester.tap(find.text('اتصال هاتفي مباشر'));
      await tester.pumpAndSettle();

      // Card 3 "قيد التنفيذ" has "تتبع الرحلة"
      expect(find.text('تتبع الرحلة'), findsOneWidget);
    });

    testWidgets('Criteria 8: Order details callback receives correct order id',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      String? selectedOrderId;
      await tester.pumpWidget(
        createTestWidget(
          onOrderDetails: (id) => selectedOrderId = id,
        ),
      );
      await tester.pump();

      // Tap "عرض التفاصيل" on first provider order
      await tester.tap(find.text('عرض التفاصيل').first);
      await tester.pumpAndSettle();

      expect(selectedOrderId, 'REQ-2401');
    });

    testWidgets('Criteria 9: Bottom Navigation Bar highlights طلباتي and handles (+) quick actions',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Verify bottom nav items
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الخريطة'), findsOneWidget);
      expect(find.text('طلباتي'), findsWidgets);
      expect(find.text('حسابي'), findsOneWidget);

      // Tap center (+) FAB
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Quick actions card appears
      expect(find.text('تحديث الحالة'), findsOneWidget);
      expect(find.text('رحلاتي الجارية'), findsOneWidget);
      expect(find.text('طلب مساعدة'), findsOneWidget);
      expect(find.text('الإبلاغ عن مشكلة'), findsOneWidget);
    });

    testWidgets('Criteria 10: Renders without overflow on compact 360px mobile width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(tester.takeException(), isNull);

      // Switch to requester tab on compact screen
      await tester.tap(find.text('كطالب خدمة'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
