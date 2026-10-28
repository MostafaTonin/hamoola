import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_home_screen.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_orders_screen.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_trips_screen.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_trip_tracking_screen.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_cargo_map_screen.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_available_orders_screen.dart';
import 'package:flutter_application/features/driver/domain/models/driver_simulation_store.dart';

void main() {
  setUp(() {
    DriverSimulationStore.instance.resetToDemo();
  });

  group('Driver Home Screen & Slider Tests', () {
    testWidgets('Verification phrase is removed from driver home screen when verified', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: DriverHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Requirement 3: Ensure phrase is completely removed
      expect(find.text('معتمد حساب موثق ومؤهل لتقديم عروض الأسعار'), findsNothing);
      expect(find.text('معتمد ✓'), findsNothing);
    });

    testWidgets('Hero banner displays single banner at a time and rotates through slides', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: DriverHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Slide 1 visible initially
      expect(find.text('فرص نقل جديدة بانتظارك'), findsOneWidget);
      expect(find.text('اكتشف أفضل الطلبات المناسبة لناقلتك'), findsOneWidget);
      expect(find.text('عرض الطلبات'), findsOneWidget);

      // Other slides should not be visible in single banner mode
      expect(find.text('تابع رحلاتك بسهولة'), findsNothing);
      expect(find.text('تابع مستحقاتك'), findsNothing);

      // Advance by 3 seconds
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Slide 2 is now visible
      expect(find.text('شبكة واسعة من السائقين'), findsOneWidget);
      expect(find.text('استعرض فرص النقل المتاحة لناقلتك'), findsOneWidget);
      expect(find.text('استكشف الطلبات'), findsOneWidget);

      // Advance by 3 seconds again
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Slide 3 is now visible
      expect(find.text('تابع رحلاتك بسهولة'), findsOneWidget);
      expect(find.text('راجع حالة رحلاتك والمهام المرتبطة بها'), findsOneWidget);
      expect(find.text('رحلاتي'), findsWidgets);

      // Advance by 3 seconds again
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Slide 4 is now visible
      expect(find.text('تابع مستحقاتك'), findsOneWidget);
      expect(find.text('راجع رصيدك وحركة أرباحك'), findsOneWidget);
      expect(find.text('محفظتي'), findsWidgets);
    });

    testWidgets('Active trip card shows current ongoing trip and opens tracking', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: DriverHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('رحلة جارية الآن'), findsOneWidget);
      expect(find.text('TRP-4091'), findsOneWidget);
      expect(find.text('أدوية ومستلزمات طبية مبردة (12 طن)'), findsOneWidget);

      final trackTripBtn = find.text('متابعة الرحلة').first;
      expect(trackTripBtn, findsOneWidget);
      await tester.tap(trackTripBtn);
      await tester.pumpAndSettle();

      // Should open DriverTripTrackingScreen
      expect(find.text('مراحل تنفيذ الرحلة'), findsOneWidget);
      expect(find.text('مسار الرحلة ونقاط العبور'), findsOneWidget);
    });

    testWidgets('Statistics cards navigate to correct views with filters', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: DriverHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'الرحلات المكتملة' stat card
      final completedCard = find.text('الرحلات المكتملة').first;
      await tester.tap(completedCard);
      await tester.pumpAndSettle();

      // Should open DriverTripsScreen with 'المكتملة' tab selected
      expect(find.text('رحلاتي'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'المكتملة'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
      await tester.pumpAndSettle();

      // Tap 'الطلبات النشطة' stat card
      final activeCard = find.text('الطلبات النشطة').first;
      await tester.tap(activeCard);
      await tester.pumpAndSettle();

      // Should open DriverOrdersScreen with active bids
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'عروضي النشطة'), findsOneWidget);
    });
  });

  group('Driver Dedicated Screens Acceptance Tests', () {
    testWidgets('DriverOrdersScreen displays bids, direct requests, and filters', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: DriverOrdersScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('عروضي النشطة'), findsOneWidget);
      expect(find.text('طلبات خاصة'), findsOneWidget);

      // Switch to 'طلبات خاصة'
      await tester.tap(find.widgetWithText(ChoiceChip, 'طلبات خاصة'));
      await tester.pumpAndSettle();

      expect(find.text('طلب خاص موجه لك'), findsOneWidget);
      expect(find.text('خضار وفواكه طازجة (16 طن)'), findsOneWidget);
      expect(find.text('قبول'), findsOneWidget);
      expect(find.text('اعتذار'), findsOneWidget);

      // Switch to 'عروضي النشطة'
      await tester.tap(find.widgetWithText(ChoiceChip, 'عروضي النشطة'));
      await tester.pumpAndSettle();

      expect(find.text('BID-701'), findsOneWidget);
      expect(find.text('أسمنت مكيس (25 طن)'), findsOneWidget);
    });

    testWidgets('DriverTripsScreen displays active and completed trips with correct buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: DriverTripsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('رحلاتي'), findsOneWidget);

      // Active tab: shows active trip with 'متابعة الرحلة' button
      expect(find.text('TRP-4091'), findsOneWidget);
      expect(find.text('متابعة الرحلة'), findsOneWidget);

      // Switch to 'المكتملة'
      await tester.tap(find.widgetWithText(ChoiceChip, 'المكتملة'));
      await tester.pumpAndSettle();

      // Completed tab: shows completed trips with 'عرض التفاصيل', NEVER 'متابعة الرحلة'
      expect(find.text('TRP-4090'), findsOneWidget);
      expect(find.text('عرض التفاصيل'), findsWidgets);
      expect(find.text('متابعة الرحلة'), findsNothing);
    });

    testWidgets('DriverTripTrackingScreen renders 9 milestones, details, and advances stages', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: DriverTripTrackingScreen(tripId: 'TRP-4091'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('متابعة الرحلة'), findsOneWidget);
      expect(find.text('TRP-4091'), findsOneWidget);
      expect(find.text('أدوية ومستلزمات طبية مبردة (12 طن)'), findsWidgets);
      expect(find.textContaining('صنعاء'), findsWidgets);
      expect(find.textContaining('تعز'), findsWidgets);
      expect(find.text('مستودع الأمل الدوائي المركزي'), findsOneWidget);

      // Next action button for stage 6 (in transit)
      expect(find.text('الخطوة التالية المطلوبة منك:'), findsOneWidget);
      expect(find.text('تأكيد الوصول إلى موقع التسليم'), findsOneWidget);

      // Tap action button (triggers confirmation dialog)
      await tester.tap(find.text('تأكيد الوصول إلى موقع التسليم'));
      await tester.pumpAndSettle();

      expect(find.text('تأكيد الخطوة'), findsOneWidget);
      expect(find.text('تأكيد والمتابعة'), findsOneWidget);

      // Confirm step
      await tester.tap(find.text('تأكيد والمتابعة'));
      await tester.pumpAndSettle();

      // State is now stage 7 (arrived at destination)
      expect(find.text('المرحلة 7 من 9'), findsOneWidget);
      expect(find.text('تأكيد تسليم الشحنة للعميل'), findsOneWidget);
    });

    testWidgets('DriverCargoMapScreen renders map and filter chips', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: DriverCargoMapScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('خريطة الحمولات'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('العامة'), findsOneWidget);
      expect(find.text('الخاصة'), findsOneWidget);
      expect(find.text('مطابق لشاحنتي'), findsOneWidget);
      expect(find.text('تحميل فوري'), findsOneWidget);
    });

    testWidgets('DriverAvailableOrdersScreen renders full list of marketplace opportunities', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: DriverAvailableOrdersScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سوق الحمولات المتاحة'), findsOneWidget);
      expect(find.text('أسمنت'), findsWidgets);
      expect(find.text('خضار وفواكه'), findsWidgets);
      expect(find.text('حديد ومواد بناء'), findsWidgets);
      expect(find.text('تقديم عرض سعر'), findsWidgets);
    });
  });
}
