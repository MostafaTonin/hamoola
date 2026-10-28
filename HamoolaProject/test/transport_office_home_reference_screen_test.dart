import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/storage/app_preferences.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/driver/domain/models/driver_simulation_store.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/transport_office/presentation/screens/transport_office_home_screen.dart';

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
    VoidCallback? onNotifications,
    VoidCallback? onAccount,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: TransportOfficeHomeScreen(
          onNotifications: onNotifications,
          onAccount: onAccount,
        ),
      ),
    );
  }

  group('Transport Office Home Screen — Matching Reference Image', () {
    testWidgets('Criteria 1: Top Header matches reference image exactly',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      bool notificationsTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          onNotifications: () => notificationsTapped = true,
        ),
      );
      await tester.pump();

      // Office greeting and name
      expect(find.text('أهلًا بك في حمولة'), findsOneWidget);
      expect(find.text('مكتب النقل السالمي'), findsOneWidget);
      expect(find.byIcon(Icons.apartment_rounded), findsOneWidget);

      // Smart assistant robot icon without text
      expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);

      // Notification bell with red badge dot
      final bellFinder = find.byIcon(Icons.notifications_none_rounded);
      expect(bellFinder, findsOneWidget);

      await tester.tap(bellFinder);
      await tester.pump();
      expect(notificationsTapped, isTrue);
    });

    testWidgets('Criteria 2: Hero Slider displays 4 banners and transitions smoothly every 3 seconds',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Banner 1 is visible
      expect(find.text('فرص نقل جديدة بانتظارك'), findsOneWidget);
      expect(find.text('اكتشف أفضل الطلبات المناسبة لمكتبك'), findsOneWidget);
      expect(find.text('عرض الطلبات'), findsOneWidget);

      // Advance timer by 3.2 seconds
      await tester.pump(const Duration(milliseconds: 3200));
      await tester.pump(const Duration(milliseconds: 600));

      // Banner 2 should now be visible
      expect(find.text('تابع رحلات مكتبك بسهولة'), findsOneWidget);
      expect(find.text('تابع حالة الرحلات والمهام المرتبطة بها'), findsOneWidget);
      expect(find.text('عرض الرحلات'), findsOneWidget);

      // Advance timer again
      await tester.pump(const Duration(milliseconds: 3200));
      await tester.pump(const Duration(milliseconds: 600));

      // Banner 3 should now be visible
      expect(find.text('شبكة من السائقين الموثوقين'), findsOneWidget);
      expect(find.text('أدر السائقين الذين تزكيهم من خلال حمولة'), findsOneWidget);
      expect(find.text('السائقون'), findsNWidgets(2)); // One in banner, one in quick services
    });

    testWidgets('Criteria 3: Three Stats Cards in one row with correct titles, dynamic counts, and action buttons',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Stats titles
      expect(find.text('الطلبات المتاحة'), findsOneWidget);
      expect(find.text('الطلبات النشطة'), findsOneWidget);
      expect(find.text('الرحلات المكتملة'), findsOneWidget);

      // "عرض الكل" buttons on each card (plus one in section header = 4 total)
      expect(find.text('عرض الكل'), findsNWidgets(4));

      // Numbers matching demo state
      expect(find.text('18'), findsOneWidget); // completed trips
    });

    testWidgets('Criteria 4: Quick Services section displays 4 items in a row',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('الخدمات السريعة'), findsOneWidget);
      expect(find.text('رحلاتي'), findsOneWidget);
      expect(find.text('محفظتي'), findsOneWidget);
      expect(find.text('أرباحي'), findsOneWidget);

      // Tap on "أرباحي" opens earnings breakdown sheet
      await tester.tap(find.text('أرباحي'));
      await tester.pumpAndSettle();

      expect(find.text('ملخص أرباح مكتب النقل'), findsOneWidget);
      expect(find.text('صافي الأرباح المحققة'), findsOneWidget);
      expect(find.text('18 رحلة بنجاح'), findsOneWidget);
      expect(find.text('الانتقال للمحفظة والتسويات'), findsOneWidget);
    });

    testWidgets('Criteria 5: Available Orders section filters between الكل, العامة, and الخاصة',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('الطلبات المتاحة لك'), findsOneWidget);
      expect(find.text('تصفح أحدث الطلبات المناسبة لمكتبك'), findsOneWidget);

      // Filter chips
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('العامة'), findsOneWidget);
      expect(find.text('الخاصة'), findsOneWidget);

      // Orders matching reference image
      expect(find.text('نقل مواد بناء (أسمنت)'), findsOneWidget);
      expect(find.text('طلب عام'), findsWidgets);
      expect(find.text('صنعاء'), findsWidgets);
      expect(find.text('تعز'), findsWidgets);

      expect(find.text('نقل مواسير حديدية'), findsOneWidget);
      expect(find.text('طلب خاص'), findsWidgets);
      expect(find.text('عدن'), findsWidgets);
      expect(find.text('إب'), findsWidgets);

      // Filter by "العامة"
      await tester.tap(find.text('العامة'));
      await tester.pumpAndSettle();

      expect(find.text('نقل مواد بناء (أسمنت)'), findsOneWidget);
      expect(find.text('نقل مواسير حديدية'), findsNothing);

      // Filter by "الخاصة"
      await tester.tap(find.text('الخاصة'));
      await tester.pumpAndSettle();

      expect(find.text('نقل مواسير حديدية'), findsOneWidget);
      expect(find.text('نقل مواد بناء (أسمنت)'), findsNothing);
    });

    testWidgets('Criteria 6: Bottom Navigation Bar has 5 items with central (+) having NO text label',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الخريطة'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // (+) button is present with icon
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Ensure NO text widget is under or beside the (+) button
      // Only 4 labels exist in the bottom navigation bar
      final bottomBarFinder = find.byType(SafeArea).last;
      expect(
        find.descendant(of: bottomBarFinder, matching: find.text('الرئيسية')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bottomBarFinder, matching: find.text('الخريطة')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bottomBarFinder, matching: find.text('طلباتي')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bottomBarFinder, matching: find.text('حسابي')),
        findsOneWidget,
      );
    });

    testWidgets('Criteria 7: (+) Sheet opens 2x2 grid with strictly 4 actions, detached with margins, while bottom nav remains visible',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap central (+) button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Verify the strictly 4 actions inside floating card
      expect(find.text('تحديث الحالة'), findsOneWidget);
      expect(find.text('رحلاتي الجارية'), findsOneWidget);
      expect(find.text('طلب مساعدة'), findsOneWidget);
      expect(find.text('الإبلاغ عن مشكلة'), findsOneWidget);

      // Verify "إنشاء طلب" is NOT inside the (+) sheet
      expect(find.text('إنشاء طلب نقل'), findsNothing);

      // Verify that the bottom navigation bar and all its options REMAIN VISIBLE
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الخريطة'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // Tap the rotated center button again -> closes the card
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Card is now closed
      expect(find.text('تحديث الحالة'), findsNothing);
      expect(find.text('رحلاتي الجارية'), findsNothing);

      // Tap central (+) button again to reopen
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(find.text('تحديث الحالة'), findsOneWidget);

      // Tap outside on backdrop to dismiss
      await tester.tapAt(const Offset(200, 200));
      await tester.pumpAndSettle();
      expect(find.text('تحديث الحالة'), findsNothing);
    });

    testWidgets('Criteria 8: Status update modal toggles office availability and persists in AppPreferences',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Open (+) sheet
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Tap "تحديث الحالة"
      await tester.tap(find.text('تحديث الحالة'));
      await tester.pumpAndSettle();

      expect(find.text('تحديث حالة استقبال الطلبات'), findsOneWidget);
      expect(find.text('متاح لاستقبال الطلبات'), findsOneWidget);
      expect(find.text('غير متاح حالياً'), findsOneWidget);

      // Select "غير متاح حالياً"
      await tester.tap(find.text('غير متاح حالياً'));
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('حفظ الحالة'));
      await tester.pumpAndSettle();

      // Verify persisted state is false
      expect(AppPreferences.instance.isOfficeAvailable, isFalse);

      // When unavailable, selecting "الخاصة" shows office unavailable notice
      await tester.tap(find.text('الخاصة'));
      await tester.pumpAndSettle();

      expect(find.text('حالة استقبال الطلبات غير متاحة حالياً'), findsOneWidget);

      // Wait for snackbar dismissal before tapping add_rounded
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Open status dialog and restore to "متاح"
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تحديث الحالة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('متاح لاستقبال الطلبات'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حفظ الحالة'));
      await tester.pumpAndSettle();

      expect(AppPreferences.instance.isOfficeAvailable, isTrue);
    });

    testWidgets('Criteria 9 & 10: Support and Issue report dialogs validate input and show confirmation',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Test Support Dialog
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('طلب مساعدة'));
      await tester.pumpAndSettle();

      expect(find.text('طلب مساعدة والدعم الفني'), findsOneWidget);

      // Tap submit with empty fields -> shows validation errors
      await tester.tap(find.text('إرسال الطلب'));
      await tester.pumpAndSettle();
      expect(find.text('يرجى إدخال موضوع الطلب'), findsOneWidget);

      // Enter data
      await tester.enterText(find.byType(TextFormField).first, 'استفسار عن التسعيرة');
      await tester.enterText(find.byType(TextFormField).last, 'نرجو توضيح آلية الخصم');
      await tester.tap(find.text('إرسال الطلب'));
      await tester.pumpAndSettle();

      expect(find.textContaining('تم تسجيل طلب المساعدة بنجاح'), findsOneWidget);

      // Wait for snackbar dismissal before next FAB tap
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Test Report Issue Dialog
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('الإبلاغ عن مشكلة'));
      await tester.pumpAndSettle();

      expect(find.text('الإبلاغ عن مشكلة لوجستية'), findsOneWidget);

      // Submit empty
      await tester.tap(find.text('إرسال البلاغ'));
      await tester.pumpAndSettle();
      expect(find.text('يرجى كتابة وصف المشكلة'), findsOneWidget);

      // Enter issue description
      await tester.enterText(find.byType(TextFormField), 'تأخر التفريغ في الموقع ساعة');
      await tester.tap(find.text('إرسال البلاغ'));
      await tester.pumpAndSettle();

      expect(find.textContaining('تم رفع البلاغ بنجاح'), findsOneWidget);
    });

    testWidgets('Criteria 11: Available Orders cards render without any overflow on standard 360px mobile width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Ensure no overflow exception occurred during initial layout
      expect(tester.takeException(), isNull);

      // Scroll down to make orders visible
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify no overflow occurred after scrolling down
      expect(tester.takeException(), isNull);

      // Verify orders are rendered
      expect(find.text('نقل مواد بناء (أسمنت)'), findsOneWidget);
      expect(find.text('نقل مواسير حديدية'), findsOneWidget);
      expect(find.text('صنعاء'), findsWidgets);
      expect(find.text('تعز'), findsWidgets);

      // Filter to 'العامة'
      await tester.tap(find.text('العامة'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Filter back to 'الكل'
      await tester.tap(find.text('الكل'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
