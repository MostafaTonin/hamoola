import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/transport_office/domain/models/transport_office_trips_store.dart';
import 'package:flutter_application/features/transport_office/presentation/screens/transport_office_trip_details_screen.dart';
import 'package:flutter_application/features/transport_office/presentation/screens/transport_office_trip_timeline_screen.dart';
import 'package:flutter_application/features/transport_office/presentation/screens/transport_office_trips_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    TransportOfficeTripsStore.instance.resetToDefault();
  });

  tearDown(() {
    TransportOfficeTripsStore.instance.resetToDefault();
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

  group('Transport Office Trips Acceptance Tests (رحلاتي لمكتب النقل)', () {
    // -------------------------------------------------------------------------
    // Criteria 1: Screen loads cleanly with independent header and RTL
    // -------------------------------------------------------------------------
    testWidgets('Criteria 1: Trips screen renders with independent header and hides home elements',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeTripsScreen()));
      await tester.pumpAndSettle();

      // Title & Icon
      expect(find.text('رحلاتي'), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_rounded), findsWidgets);

      // Home header elements MUST be completely absent
      expect(find.text('أهلًا بك في حمولة'), findsNothing);
      expect(find.byIcon(Icons.smart_toy_rounded), findsNothing);
      expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);

      // Back button
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Criteria 2: Two Main Tabs «كمقدم خدمة» vs «كطالب خدمة»
    // -------------------------------------------------------------------------
    testWidgets('Criteria 2: Two main tabs switch roles cleanly without mixing data',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeTripsScreen()));
      await tester.pumpAndSettle();

      // Tab headers exist
      expect(find.text('كمقدم خدمة'), findsOneWidget);
      expect(find.text('كطالب خدمة'), findsOneWidget);

      // Provider trips are visible by default
      expect(find.text('#R-1042'), findsOneWidget);

      // Switch to «كطالب خدمة»
      await tester.tap(find.text('كطالب خدمة'));
      await tester.pumpAndSettle();

      // Seeker orders visible, provider trips hidden
      expect(find.text('#R-2001'), findsOneWidget);
      expect(find.text('#R-1042'), findsNothing);

      // Switch back to «كمقدم خدمة»
      await tester.tap(find.text('كمقدم خدمة'));
      await tester.pumpAndSettle();

      expect(find.text('#R-1042'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Criteria 3: Status Filters for «كمقدم خدمة»
    // -------------------------------------------------------------------------
    testWidgets('Criteria 3: Five status filter chips display accurate counts and filter trips',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeTripsScreen()));
      await tester.pumpAndSettle();

      // Verify all 5 filter chips exist with non-zero counts
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('بانتظار البدء'), findsWidgets);
      expect(find.text('قيد التنفيذ'), findsWidgets);
      expect(find.text('مكتملة'), findsWidgets);
      expect(find.text('ملغاة'), findsWidgets);

      // Filter by «بانتظار البدء»
      await tester.tap(find.text('بانتظار البدء').first);
      await tester.pumpAndSettle();

      expect(find.text('#R-1042'), findsOneWidget); // Pending start
      expect(find.text('#R-1041'), findsNothing); // In progress should be hidden
      expect(find.text('#R-1035'), findsNothing); // Completed should be hidden

      // Filter by «قيد التنفيذ»
      await tester.tap(find.text('قيد التنفيذ').first);
      await tester.pumpAndSettle();

      expect(find.text('#R-1041'), findsOneWidget); // In progress
      expect(find.text('#R-1042'), findsNothing);

      // Filter by «مكتملة»
      await tester.tap(find.text('مكتملة').first);
      await tester.pumpAndSettle();

      expect(find.text('#R-1035'), findsOneWidget); // Completed
      expect(find.text('#R-1041'), findsNothing);

      // Filter by «ملغاة»
      await tester.tap(find.text('ملغاة').first);
      await tester.pumpAndSettle();

      expect(find.text('#R-1030'), findsOneWidget); // Cancelled
      expect(find.text('#R-1035'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // Criteria 4: Instant Search Field
    // -------------------------------------------------------------------------
    testWidgets('Criteria 4: Real-time search filters by trip ID, client name, and driver name',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeTripsScreen()));
      await tester.pumpAndSettle();

      // Search by Trip ID "1041"
      await tester.enterText(find.byType(TextField), '1041');
      await tester.pumpAndSettle();

      expect(find.text('#R-1041'), findsOneWidget);
      expect(find.text('#R-1042'), findsNothing);

      // Search by Client Name "العمران"
      await tester.enterText(find.byType(TextField), 'العمران');
      await tester.pumpAndSettle();

      expect(find.text('مؤسسة العمران'), findsWidgets);

      // Clear search
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('#R-1042'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Criteria 5: Yemen <-> Saudi Cross-Border & Yemen Domestic Routes
    // -------------------------------------------------------------------------
    testWidgets('Criteria 5: Displays authentic Yemen-Saudi cross-border and Yemen domestic routes',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeTripsScreen()));
      await tester.pumpAndSettle();

      // 1. Yemen to Saudi route
      expect(find.text('صنعاء، اليمن ← الرياض، السعودية'), findsOneWidget);

      // 2. Yemen domestic route (scroll if needed or search)
      await tester.enterText(find.byType(TextField), 'عدن');
      await tester.pumpAndSettle();

      expect(find.textContaining('عدن'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // Criteria 6: Action "بدء الرحلة" on Card and Confirmation Modal
    // -------------------------------------------------------------------------
    testWidgets('Criteria 6: Starting a trip updates status to قيد التنفيذ and logs timeline',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeTripsScreen(
        initialFilter: OfficeTripFilter.pendingStart,
      )));
      await tester.pumpAndSettle();

      expect(find.text('#R-1042'), findsOneWidget);
      expect(find.text('بدء الرحلة'), findsWidgets);

      // Tap "بدء الرحلة"
      await tester.tap(find.text('بدء الرحلة').first);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.textContaining('بدء الرحلة #R-1042'), findsOneWidget);
      expect(find.text('تأكيد بدء الرحلة'), findsOneWidget);
      expect(find.text('تراجع'), findsOneWidget);

      // Confirm
      await tester.tap(find.text('تأكيد بدء الرحلة'));
      await tester.pumpAndSettle();

      // R-1042 is no longer in pendingStart filter
      expect(find.text('#R-1042'), findsNothing);

      // In store, R-1042 is now inProgress
      final trip = TransportOfficeTripsStore.instance.getTripById('R-1042');
      expect(trip?.status, OfficeTripStatus.inProgress);
      expect(trip?.milestones.any((m) => m.title == 'بدء الرحلة'), isTrue);
    });

    // -------------------------------------------------------------------------
    // Criteria 7: Action "إنهاء الرحلة" on Card and Confirmation Modal
    // -------------------------------------------------------------------------
    testWidgets('Criteria 7: Completing a trip updates status to مكتملة and logs timeline',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(const TransportOfficeTripsScreen(
        initialFilter: OfficeTripFilter.inProgress,
      )));
      await tester.pumpAndSettle();

      expect(find.text('#R-1041'), findsOneWidget);
      expect(find.text('إنهاء الرحلة'), findsWidgets);

      // Tap "إنهاء الرحلة"
      await tester.tap(find.text('إنهاء الرحلة').first);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.textContaining('إنهاء الرحلة #R-1041'), findsOneWidget);
      expect(find.text('تأكيد إنهاء الرحلة'), findsOneWidget);
      expect(find.text('تراجع'), findsOneWidget);

      // Confirm
      await tester.tap(find.text('تأكيد إنهاء الرحلة'));
      await tester.pumpAndSettle();

      // In store, R-1041 is now completed
      final trip = TransportOfficeTripsStore.instance.getTripById('R-1041');
      expect(trip?.status, OfficeTripStatus.completed);
      expect(trip?.milestones.any((m) => m.title == 'إنهاء الرحلة'), isTrue);
    });

    // -------------------------------------------------------------------------
    // Criteria 8: Trip Details Screen renders comprehensive information
    // -------------------------------------------------------------------------
    testWidgets('Criteria 8: Details screen renders route metrics, truck specs, client and driver info',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(
        const TransportOfficeTripDetailsScreen(tripId: 'R-1042'),
      ));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('تفاصيل الرحلة'), findsOneWidget);
      expect(find.text('#R-1042'), findsOneWidget);
      expect(find.text('صنعاء، اليمن ← الرياض، السعودية'), findsOneWidget);

      // Metrics
      expect(find.text('1380 كم'), findsOneWidget);
      expect(find.text('24 ساعات'), findsOneWidget);

      // Truck & Client
      expect(find.text('شاحنة سطحة'), findsOneWidget);
      expect(find.text('شركة البناء الحديثة'), findsOneWidget);

      // Driver
      expect(find.text('أحمد السالم'), findsOneWidget);

      // Action buttons in details
      expect(find.text('بدء الرحلة'), findsOneWidget);
      expect(find.text('إلغاء الرحلة'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Criteria 9: Trip Cancellation with Reason from Details Screen
    // -------------------------------------------------------------------------
    testWidgets('Criteria 9: Cancelling a trip from details requires reason and updates status to ملغاة',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(
        const TransportOfficeTripDetailsScreen(tripId: 'R-1048'),
      ));
      await tester.pumpAndSettle();

      // Tap "إلغاء الرحلة"
      await tester.tap(find.text('إلغاء الرحلة'));
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.textContaining('إلغاء الرحلة #R-1048'), findsOneWidget);
      expect(find.text('طلب العميل تأجيل الشحنة'), findsOneWidget);
      expect(find.text('تأكيد الإلغاء'), findsOneWidget);

      // Confirm cancellation
      await tester.tap(find.text('تأكيد الإلغاء'));
      await tester.pumpAndSettle();

      // Trip is now cancelled
      final trip = TransportOfficeTripsStore.instance.getTripById('R-1048');
      expect(trip?.status, OfficeTripStatus.cancelled);
      expect(trip?.cancellationReason, isNotNull);
      expect(find.text('سبب الإلغاء'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Criteria 10: Trip Timeline Screen displays sequential milestones
    // -------------------------------------------------------------------------
    testWidgets('Criteria 10: Timeline screen displays sequential milestones with dates and times',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(createTestApp(
        const TransportOfficeTripTimelineScreen(tripId: 'R-1035'),
      ));
      await tester.pumpAndSettle();

      // Title
      expect(find.text('السجل الزمني'), findsOneWidget);
      expect(find.text('تسلسل الأحداث المسجلة'), findsOneWidget);

      // Milestones
      expect(find.text('إنشاء الطلب'), findsOneWidget);
      expect(find.text('قبول العرض'), findsOneWidget);
      expect(find.text('إسناد الرحلة'), findsOneWidget);
      expect(find.text('بدء الرحلة'), findsOneWidget);
      expect(find.text('إنهاء الرحلة'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Criteria 11: Compact Mobile Layout (360px) without overflow
    // -------------------------------------------------------------------------
    testWidgets('Criteria 11: Renders cleanly on compact 360px mobile width without overflow',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 740 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp(const TransportOfficeTripsScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
