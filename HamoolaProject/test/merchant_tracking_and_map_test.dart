import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/tracking_models.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_map_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_trip_tracking_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget wrapWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      home: child,
    );
  }

  group('MerchantMapScreen Tests', () {
    testWidgets('renders map screen header, search, chips, and markers',
        (tester) async {
      bool backTapped = false;
      AvailableTruckMarker? viewedTruck;

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          MerchantMapScreen(
            onBack: () => backTapped = true,
            onViewDriverProfile: (truck) => viewedTruck = truck,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text(AppStrings.merchantMapTitle), findsOneWidget);

      // Verify Search hint
      expect(find.text(AppStrings.searchDriversHint), findsOneWidget);

      // Verify Category Chips
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text(AppStrings.categoryTrucks), findsOneWidget);
      expect(find.text(AppStrings.categoryTrailers), findsOneWidget);

      // Verify Back Button
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backTapped, isTrue);

      // Verify tapping a Category Chip filters
      await tester.tap(find.text(AppStrings.categoryTrucks));
      await tester.pumpAndSettle();

      // Verify tapping a Truck Pin marker reveals Driver Summary Card
      final pinIcons = find.byIcon(Icons.local_shipping_rounded);
      if (pinIcons.evaluate().isNotEmpty) {
        await tester.tap(pinIcons.first);
        await tester.pumpAndSettle();

        // Check if Driver Summary Card appeared
        expect(find.text('موثق ✓'), findsOneWidget);
        expect(find.text(AppStrings.directOrderForDriver), findsOneWidget);
        expect(find.text(AppStrings.viewOfficeProfileBtn), findsOneWidget);

        // Tap View Profile
        await tester.tap(find.text(AppStrings.viewOfficeProfileBtn));
        await tester.pumpAndSettle();
        expect(viewedTruck, isNotNull);

        // Tap Close Button on Summary Card
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.text('موثق ✓'), findsNothing);
      }
    });

    testWidgets('tapping locate button triggers current location snackbar',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const MerchantMapScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap locate button
      final locateFinder = find.byTooltip(AppStrings.currentLocateTooltip);
      expect(locateFinder, findsOneWidget);
      await tester.tap(locateFinder);
      await tester.pumpAndSettle();

      expect(find.text('تم تحديد موقعك الحالي: صنعاء، اليمن'), findsOneWidget);
    });

    testWidgets('opens DriverFilterModal, selects filter criteria, and applies',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const MerchantMapScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap filter icon button in search bar
      final filterBtn = find.byTooltip('تصفية السائقين');
      expect(filterBtn, findsOneWidget);
      await tester.tap(filterBtn);
      await tester.pumpAndSettle();

      // Verify DriverFilterModal is displayed (Image 1)
      expect(find.text('تصفية السائقين'), findsOneWidget);
      expect(find.text('نوع المركبة'), findsOneWidget);
      expect(find.text('حالة السائق'), findsOneWidget);
      expect(find.text('المحافظة'), findsOneWidget);
      expect(find.text('تطبيق الفلتر'), findsOneWidget);
      expect(find.text('إعادة تعيين'), findsOneWidget);

      // Tap category chip 'قاطرات' inside the modal
      await tester.tap(find.text('قاطرات').first);
      await tester.pumpAndSettle();

      // Tap 'تطبيق الفلتر'
      await tester.tap(find.text('تطبيق الفلتر'));
      await tester.pumpAndSettle();

      // Modal closed, filter applied
      expect(find.text('تصفية السائقين'), findsNothing);
    });

    testWidgets('opens DriverSearchModal, searches, and selects location & driver',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const MerchantMapScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap search field
      await tester.tap(find.text(AppStrings.searchDriversHint));
      await tester.pumpAndSettle();

      // Verify DriverSearchModal is displayed (Image 2)
      expect(find.text('البحث'), findsOneWidget);
      expect(find.textContaining('الكل'), findsWidgets);
      expect(find.textContaining('السائقون'), findsWidgets);
      expect(find.textContaining('المدن والمناطق'), findsWidgets);
      expect(find.textContaining('المحافظات'), findsWidgets);
      expect(find.text('عرض جميع النتائج على الخريطة'), findsOneWidget);

      // Verify driver item 'أحمد عبدالله' and tap
      final driverItem = find.text('أحمد عبدالله');
      expect(driverItem, findsOneWidget);
      await tester.tap(driverItem);
      await tester.pumpAndSettle();

      // Modal closed and driver selected on map
      expect(find.text('البحث'), findsNothing);
      expect(find.text('موثق ✓'), findsOneWidget);
    });
  });

  group('MerchantTripTrackingScreen Tests', () {
    testWidgets(
        'renders live tracking header, driver card, and floating controls',
        (tester) async {
      bool backTapped = false;
      bool emergencyTapped = false;
      String? calledPhone;

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          MerchantTripTrackingScreen(
            onBack: () => backTapped = true,
            onEmergencyCall: () => emergencyTapped = true,
            onCallDriver: (p) => calledPhone = p,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text(AppStrings.liveTripTrackingTitle), findsOneWidget);
      expect(find.textContaining('REQ-1023'), findsOneWidget);

      // Verify Floating Emergency Control
      final emergencyBtn = find.byTooltip(AppStrings.emergencyContactTooltip);
      expect(emergencyBtn, findsOneWidget);
      await tester.tap(emergencyBtn);
      expect(emergencyTapped, isTrue);

      // Verify Driver Compact Card
      expect(find.text('كابتن أحمد صالح النجار'), findsOneWidget);
      final callDriverBtn = find.byTooltip(AppStrings.callDriver);
      expect(callDriverBtn, findsOneWidget);
      await tester.tap(callDriverBtn);
      expect(calledPhone, isNotNull);

      // Verify Back action
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backTapped, isTrue);
    });

    testWidgets('expands bottom sheet, tests simulation stepper and sensors',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const MerchantTripTrackingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'تفاصيل' to expand the sheet
      final detailsBtn = find.text('تفاصيل');
      expect(detailsBtn, findsOneWidget);
      await tester.tap(detailsBtn);
      await tester.pumpAndSettle();

      // Now expanded: Stepper and Sensors should be visible
      expect(find.text(AppStrings.simulationControlTitle), findsOneWidget);
      expect(find.text(AppStrings.simulationStep1), findsOneWidget);
      expect(find.text(AppStrings.simulationStep2), findsOneWidget);
      expect(find.text(AppStrings.simulationStep3), findsOneWidget);
      expect(find.text(AppStrings.simulationStep4), findsOneWidget);

      // Verify Sensors Card
      expect(find.text(AppStrings.cargoSensorTitle), findsOneWidget);

      // Tap Step 4 (وصول) in prototype simulation stepper
      await tester.tap(find.text(AppStrings.simulationStep4));
      await tester.pumpAndSettle();

      // Progress should now be 100% and status updated
      expect(find.text('تم وصول الشاحنة إلى وجهة التسليم بنجاح'),
          findsOneWidget);
      expect(find.textContaining('100%'), findsWidgets);

      // Tap Step 1 (تحرك)
      await tester.tap(find.text(AppStrings.simulationStep1));
      await tester.pumpAndSettle();
      expect(find.text('الشاحنة في طريقها إلى موقع التحميل'),
          findsOneWidget);
      expect(find.textContaining('15%'), findsOneWidget);
    });

    testWidgets(
        'renders live telemetry HUD, toggles simulation play/pause, and changes speed',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const MerchantTripTrackingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Telemetry HUD is present on screen
      expect(find.textContaining('كم/س'), findsOneWidget);
      expect(find.text('▶ تشغيل المحاكاة الحية'), findsWidgets);
      expect(find.text('1x'), findsOneWidget);
      expect(find.text('2x'), findsOneWidget);
      expect(find.text('5x'), findsOneWidget);

      // Tap speed multiplier chip 2x
      await tester.tap(find.text('2x'));
      await tester.pumpAndSettle();

      // Tap speed multiplier chip 5x
      await tester.tap(find.text('5x'));
      await tester.pumpAndSettle();

      // Toggle Play
      await tester.tap(find.text('▶ تشغيل المحاكاة الحية').first);
      await tester.pump(const Duration(milliseconds: 100));

      // Now simulation is running, button should show 'إيقاف مؤقت'
      expect(find.text('إيقاف مؤقت'), findsWidgets);

      // Toggle Pause
      await tester.tap(find.text('إيقاف مؤقت').first);
      await tester.pumpAndSettle();

      // Now paused, button returns to '▶ تشغيل المحاكاة الحية'
      expect(find.text('▶ تشغيل المحاكاة الحية'), findsWidgets);

      // Tap Reset button
      final refreshBtn = find.byTooltip('إعادة الرحلة من البداية');
      expect(refreshBtn, findsOneWidget);
      await tester.tap(refreshBtn);
      await tester.pumpAndSettle();

      // Reset state verification
      expect(find.textContaining('0%'), findsWidgets);
    });
  });
}
