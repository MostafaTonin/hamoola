import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/transport_order_draft.dart';
import 'package:flutter_application/features/merchant/presentation/screens/driver_profile_screen.dart';
import 'package:flutter_application/features/transport_office/domain/models/transport_office_drivers_store.dart';
import 'package:flutter_application/features/transport_office/presentation/screens/transport_office_drivers_screen.dart';
import 'package:flutter_application/features/transport_office/presentation/screens/transport_office_endorse_search_screen.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    TransportOfficeDriversStore.instance.resetToDefault();
  });

  tearDown(() {
    TransportOfficeDriversStore.instance.resetToDefault();
  });

  Widget createTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  void setPhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Transport Office Drivers & Endorsement Acceptance Tests', () {
    testWidgets('Criteria 1: Drivers screen loads only currently endorsed drivers with matching header',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeDriversScreen()));
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('السائقون'), findsOneWidget);
      expect(find.text('السائقون الذين يزكّيهم مكتبك حاليًا'), findsOneWidget);
      expect(find.byIcon(Icons.group_rounded), findsWidgets);

      // Verify home greeting and robot elements are ABSENT
      expect(find.text('أهلًا بك في حمولة'), findsNothing);
      expect(find.byIcon(Icons.smart_toy_rounded), findsNothing);
      expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);

      // Verify "+ تزكية سائق" button
      expect(find.text('تزكية سائق'), findsOneWidget);

      // Verify the 4 endorsed drivers matching Image 1
      expect(find.text('أحمد محمد'), findsOneWidget);
      expect(find.text('محمد عبدالله'), findsOneWidget);
      expect(find.text('سالم علي'), findsOneWidget);
      expect(find.text('خالد صالح'), findsOneWidget);

      // Account numbers & cities
      expect(find.text('رقم الحساب: 10482'), findsOneWidget);
      expect(find.text('صنعاء'), findsOneWidget);
      expect(find.text('رقم الحساب: 10735'), findsOneWidget);
      expect(find.text('تعز'), findsOneWidget);

      // Endorsement badge is strictly "مزكّى" with green checkmark
      expect(find.text('مزكّى'), findsNWidgets(4));
      expect(find.text('مزكّى من المكتب'), findsNothing);
      expect(find.text('مزكّى بالفعل'), findsNothing);
    });

    testWidgets('Criteria 2: Real-time search in Drivers screen filters endorsed drivers',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeDriversScreen()));
      await tester.pumpAndSettle();

      // Search for "سالم"
      await tester.enterText(find.byType(TextField), 'سالم');
      await tester.pumpAndSettle();

      expect(find.text('سالم علي'), findsOneWidget);
      expect(find.text('أحمد محمد'), findsNothing);
      expect(find.text('محمد عبدالله'), findsNothing);

      // Search by account number "10482"
      await tester.enterText(find.byType(TextField), '10482');
      await tester.pumpAndSettle();

      expect(find.text('أحمد محمد'), findsOneWidget);
      expect(find.text('سالم علي'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(find.text('أحمد محمد'), findsOneWidget);
      expect(find.text('محمد عبدالله'), findsOneWidget);
      expect(find.text('سالم علي'), findsOneWidget);
      expect(find.text('خالد صالح'), findsOneWidget);
    });

    testWidgets('Criteria 3: Cancel endorsement removes driver and sends in-app notification',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeDriversScreen()));
      await tester.pumpAndSettle();

      // Tap 3-dots on the first driver "أحمد محمد"
      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pumpAndSettle();

      // Verify popup menu options
      expect(find.text('عرض ملف السائق'), findsOneWidget);
      expect(find.text('إلغاء التزكية'), findsOneWidget);

      // Tap "إلغاء التزكية"
      await tester.tap(find.text('إلغاء التزكية'));
      await tester.pumpAndSettle();

      // Verify Cancel Confirmation Modal (Image 6)
      expect(find.text('إلغاء تزكية السائق'), findsOneWidget);
      expect(find.textContaining('هل أنت متأكد من رغبتك في إلغاء تزكية السائق أحمد محمد؟'), findsOneWidget);
      expect(
        find.textContaining('ستُزال تزكية مكتبك من الملف، وسيصله إشعار بذلك'),
        findsOneWidget,
      );
      expect(find.text('تأكيد الإلغاء'), findsOneWidget);
      expect(find.text('تراجع'), findsOneWidget);

      // Tap "تأكيد الإلغاء"
      await tester.tap(find.text('تأكيد الإلغاء'));
      await tester.pumpAndSettle();

      // Ahmad is now removed from active endorsed drivers list
      expect(find.text('أحمد محمد'), findsNothing);
      expect(find.text('محمد عبدالله'), findsOneWidget);
      expect(find.text('سالم علي'), findsOneWidget);
      expect(find.text('خالد صالح'), findsOneWidget);

      // Verify notification logged
      final notifications = TransportOfficeDriversStore.instance.notifications;
      expect(notifications.any((n) => n.title.contains('إلغاء تزكية')), isTrue);
    });

    testWidgets('Criteria 4: Endorse Search screen shows matching drivers and handles search text',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeEndorseSearchScreen()));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('تزكية سائق'), findsOneWidget);
      expect(find.text('ابحث عن سائق مسجّل في حمولة'), findsOneWidget);

      // Search for "ناصر"
      await tester.enterText(find.byType(TextField), 'ناصر');
      await tester.pumpAndSettle();

      // Matching registered drivers
      expect(find.text('ناصر حسين'), findsOneWidget);
      expect(find.text('ناصر محمد'), findsOneWidget);
      expect(find.text('ناصر علي'), findsOneWidget);
      expect(find.text('ناصر صالح'), findsOneWidget);

      // Non-endorsed drivers have "+ تزكية" button
      expect(find.text('تزكية'), findsWidgets);
    });

    testWidgets('Criteria 5: Endorsement flow updates driver status to مزكى and shows success banner',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeEndorseSearchScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '12567');
      await tester.pumpAndSettle();

      expect(find.text('ناصر حسين'), findsOneWidget);
      expect(find.text('رقم الحساب: 12567'), findsOneWidget);

      // Tap "تزكية" button
      await tester.tap(find.text('تزكية'));
      await tester.pumpAndSettle();

      // Verify Endorsement Confirmation Dialog (Image 3)
      expect(find.text('تزكية السائق'), findsOneWidget);
      expect(find.textContaining('هل أنت متأكد من رغبتك في تزكية السائق ناصر حسين؟'), findsOneWidget);
      expect(find.text('تأكيد التزكية'), findsOneWidget);
      expect(find.text('تراجع'), findsOneWidget);

      // Tap "تأكيد التزكية"
      await tester.tap(find.text('تأكيد التزكية'));
      await tester.pumpAndSettle();

      // Verify Success Banner (Image 4)
      expect(find.text('تمت التزكية بنجاح'), findsOneWidget);
      expect(find.text('تمت إضافة ناصر حسين إلى قائمة السائقين لديك.'), findsOneWidget);

      // Nasser Hussein's action button is now replaced by green badge "مزكّى"
      expect(find.text('مزكّى'), findsOneWidget);

      // In store, Nasser Hussein is now endorsed
      expect(
        TransportOfficeDriversStore.instance.endorsedDrivers.any((d) => d.name == 'ناصر حسين'),
        isTrue,
      );

      // Verify in-app notification sent to driver
      final notifications = TransportOfficeDriversStore.instance.notifications;
      expect(notifications.any((n) => n.title.contains('تزكية جديدة')), isTrue);
    });

    testWidgets('Criteria 6: Re-endorsement flow for previously cancelled driver',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      // 1. Cancel endorsement for أحمد محمد in store
      await TransportOfficeDriversStore.instance.cancelEndorsement('DRV-101');

      // 2. Open Endorse Search Screen and search for "10482"
      await tester.pumpWidget(createTestApp(const TransportOfficeEndorseSearchScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '10482');
      await tester.pumpAndSettle();

      expect(find.text('أحمد محمد'), findsOneWidget);
      // Button shows "إعادة التزكية"
      expect(find.text('إعادة التزكية'), findsOneWidget);

      // Tap "إعادة التزكية"
      await tester.tap(find.text('إعادة التزكية'));
      await tester.pumpAndSettle();

      // Confirm re-endorsement
      expect(find.text('إعادة تزكية السائق'), findsOneWidget);
      await tester.tap(find.text('تأكيد إعادة التزكية'));
      await tester.pumpAndSettle();

      // Now re-endorsed
      expect(find.text('مزكّى'), findsOneWidget);
      expect(
        TransportOfficeDriversStore.instance.endorsedDrivers.any((d) => d.name == 'أحمد محمد'),
        isTrue,
      );
    });

    testWidgets('Criteria 7: Section التزكيات in DriverProfileScreen updates accurately',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const driverProfile = DriverProfile(
        id: 'DRV-101',
        name: 'أحمد محمد',
        city: 'صنعاء',
        phone: '771234567',
      );

      await tester.pumpWidget(createTestApp(const DriverProfileScreen(driver: driverProfile)));
      await tester.pumpAndSettle();

      // Verify Section Title "التزكيات"
      expect(find.text('التزكيات'), findsOneWidget);
      expect(find.text('مكتب النور للنقل السريع'), findsOneWidget);

      // Cancel endorsement in store
      await TransportOfficeDriversStore.instance.cancelEndorsement('DRV-101');
      await tester.pumpAndSettle();

      // "مكتب النور للنقل السريع" is removed from driver's profile
      expect(find.text('مكتب النور للنقل السريع'), findsNothing);
    });

    testWidgets('Criteria 8: Bottom Navigation Bar renders with 5 items and rotating (+) FAB',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeDriversScreen()));
      await tester.pumpAndSettle();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الخريطة'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // Tap central (+) FAB
      await tester.tap(find.byIcon(Icons.add_rounded).last);
      await tester.pumpAndSettle();

      // Quick action sheet opened
      expect(find.text('تحديث الحالة'), findsOneWidget);
      expect(find.text('رحلاتي الجارية'), findsOneWidget);
      expect(find.text('طلب مساعدة'), findsOneWidget);
      expect(find.text('الإبلاغ عن مشكلة'), findsOneWidget);
    });

    testWidgets('Criteria 9: Renders cleanly on compact 360px mobile width without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp(const TransportOfficeDriversScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Test Search Screen on compact 360px as well
      await tester.pumpWidget(createTestApp(const TransportOfficeEndorseSearchScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
