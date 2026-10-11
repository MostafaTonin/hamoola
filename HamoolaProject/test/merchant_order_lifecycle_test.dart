import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/transport_order_draft.dart';
import 'package:flutter_application/features/merchant/presentation/screens/driver_profile_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_create_order_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/select_office_screen.dart';

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

  group('MerchantCreateOrderScreen Tests', () {
    testWidgets('renders all 7 cards and responds to back action', (tester) async {
      bool backTapped = false;

      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          MerchantCreateOrderScreen(
            onBack: () => backTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text(AppStrings.createOrderTitle), findsOneWidget);
      expect(find.text(AppStrings.createOrderSubtitle), findsOneWidget);

      // Verify Cards
      expect(find.text(AppStrings.orderLocationsTitle), findsOneWidget);
      expect(find.text(AppStrings.requestedCargoTitle), findsOneWidget);
      expect(find.text(AppStrings.transportRequirementsTitle), findsOneWidget);
      expect(find.text(AppStrings.expectedBudgetTitle), findsOneWidget);
      expect(find.text(AppStrings.publishOrderToTitle), findsOneWidget);
      expect(find.text(AppStrings.additionalInfoTitle), findsOneWidget);
      expect(find.text(AppStrings.contactInfoTitle), findsOneWidget);

      // Verify Back action
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backTapped, isTrue);
    });

    testWidgets('submits order, opens review modal, and triggers callback on confirm',
        (tester) async {
      TransportOrderDraft? submittedDraft;

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          MerchantCreateOrderScreen(
            onSubmitOrder: (draft) => submittedDraft = draft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Publish button
      final publishBtn = find.text(AppStrings.submitTransportOrderBtn);
      expect(publishBtn, findsOneWidget);
      await tester.ensureVisible(publishBtn);
      await tester.tap(publishBtn);
      await tester.pumpAndSettle();

      // Review Modal Sheet should be visible
      expect(find.text(AppStrings.reviewOrderTitle), findsOneWidget);
      expect(find.text(AppStrings.confirmPublishBtn), findsWidgets);

      // Tap confirm in modal sheet
      await tester.tap(find.text(AppStrings.confirmPublishBtn).last);
      await tester.pumpAndSettle();

      // Verify submitted draft
      expect(submittedDraft, isNotNull);
      expect(submittedDraft!.originCity, equals('صنعاء'));
      expect(submittedDraft!.destCity, equals('عدن'));

      // Success modal should now be shown
      expect(find.text(AppStrings.orderPublishedSuccessTitle), findsOneWidget);
    });

    testWidgets(
        'opens map picker for origin location, selects landmark, and populates detailed address',
        (tester) async {
      TransportOrderDraft? submittedDraft;

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          MerchantCreateOrderScreen(
            onSubmitOrder: (draft) => submittedDraft = draft,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 'تحديد من الخريطة' buttons are present
      final pickMapButtons = find.text('تحديد من الخريطة');
      expect(pickMapButtons, findsWidgets);

      // Tap first map picker button (for Origin Location)
      await tester.tap(pickMapButtons.first);
      await tester.pumpAndSettle();

      // Verify Map Location Picker Modal is displayed
      expect(find.text('تحديد موقع التحميل من الخريطة'), findsOneWidget);

      // Tap confirm button in modal sheet
      final confirmLocationBtn = find.textContaining('تأكيد هذا الموقع');
      expect(confirmLocationBtn, findsOneWidget);
      await tester.tap(confirmLocationBtn);
      await tester.pumpAndSettle();

      // Modal closed, verify origin address field contains city/location
      expect(find.textContaining('صنعاء'), findsWidgets);

      // Type detailed landmark address into origin text field
      final originDetailInput = find.byType(TextField).first;
      await tester.enterText(
          originDetailInput, 'صنعاء — شارع الستين الجنوبي، مخازن الأمل رقم 4');
      await tester.pumpAndSettle();

      // Submit the order
      final publishBtn = find.text(AppStrings.submitTransportOrderBtn);
      await tester.ensureVisible(publishBtn);
      await tester.tap(publishBtn);
      await tester.pumpAndSettle();

      // Confirm in Review modal
      await tester.tap(find.text(AppStrings.confirmPublishBtn).last);
      await tester.pumpAndSettle();

      // Verify submitted draft contains the detailed address
      expect(submittedDraft, isNotNull);
      expect(submittedDraft!.originAddressDetail, contains('مخازن الأمل'));
    });
  });

  group('SelectOfficeScreen Tests', () {
    testWidgets('renders office list, filters by search, and triggers onOfficeSelected',
        (tester) async {
      TransportOffice? selectedOffice;
      bool backTapped = false;

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          SelectOfficeScreen(
            onBack: () => backTapped = true,
            onOfficeSelected: (off) => selectedOffice = off,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Search
      expect(find.text(AppStrings.selectOfficeTitle), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify default offices in list
      expect(find.text('مكتب الأمان للنقل الثقيل'), findsOneWidget);
      expect(find.text('شركة النجم السريع لخدمات النقل'), findsOneWidget);

      // Test Select button on first card
      final selectBtn = find.text(AppStrings.selectOfficeConfirmBtn).first;
      await tester.tap(selectBtn);
      expect(selectedOffice?.name, equals('مكتب الأمان للنقل الثقيل'));

      // Test Back button
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backTapped, isTrue);
    });

    testWidgets('toggles between list view and map view', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const SelectOfficeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Map view
      final mapToggle = find.text(AppStrings.officeMapViewBtn);
      await tester.tap(mapToggle);
      await tester.pumpAndSettle();

      // Office pins should exist in map view
      expect(find.text('الأمان للنقل الثقيل'), findsOneWidget);

      // Switch back to List view
      final listToggle = find.text(AppStrings.officeListViewBtn);
      await tester.tap(listToggle);
      await tester.pumpAndSettle();
      expect(find.text('مكتب الأمان للنقل الثقيل'), findsOneWidget);
    });
  });

  group('DriverProfileScreen Tests', () {
    testWidgets('renders driver identity, stats, vehicle specs, and actions', (tester) async {
      bool directOrderTapped = false;
      String? messagedPhone;
      bool backTapped = false;

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          DriverProfileScreen(
            onBack: () => backTapped = true,
            onDirectOrder: (drv) => directOrderTapped = true,
            onMessage: (phone) => messagedPhone = phone,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Driver Identity
      expect(find.text('أحمد عبدالله'), findsOneWidget);
      expect(find.text('متاح الآن'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);

      // Verify Stats from Image 1
      expect(find.text('رحلة مكتملة'), findsOneWidget);
      expect(find.text('في المنصة'), findsOneWidget);
      expect(find.text('الحمولة القصوى'), findsOneWidget);
      expect(find.text('نوع المركبة'), findsOneWidget);

      // Verify Sections from Image 1
      expect(find.text('نبذة عني'), findsOneWidget);
      expect(find.text('معلومات المركبة'), findsOneWidget);
      expect(find.text('مرسيدس أكتروس'), findsOneWidget);
      expect(find.text('أنواع الحمولات المنقولة'), findsOneWidget);
      expect(find.text('مناطق الخدمة'), findsOneWidget);
      expect(find.text('تقييمات العملاء'), findsOneWidget);

      // Tap Direct Order CTA ("طلب نقل")
      final directOrderBtn = find.text('طلب نقل');
      await tester.tap(directOrderBtn);
      expect(directOrderTapped, isTrue);

      // Tap Message CTA ("مراسلة")
      final messageBtn = find.text('مراسلة');
      await tester.tap(messageBtn);
      expect(messagedPhone, isNotNull);

      // Tap Back Button
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backTapped, isTrue);
    });
  });
}
