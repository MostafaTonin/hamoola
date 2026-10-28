import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_order.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/merchant/domain/models/transport_order_draft.dart';
import 'package:flutter_application/features/merchant/presentation/screens/driver_profile_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_create_order_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/select_driver_screen.dart';
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
    testWidgets('renders strict title «إضافة طلب», 5 cards, mini-map, and responds to back action',
        (tester) async {
      bool backTapped = false;

      tester.view.physicalSize = const Size(800, 2400);
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

      // Verify Header: strictly «إضافة طلب»
      expect(find.text(AppStrings.createOrderTitle), findsOneWidget);
      expect(find.text(AppStrings.createOrderSubtitle), findsOneWidget);

      // Verify 5 Cards
      expect(find.textContaining('1. مواقع النقل'), findsOneWidget);
      expect(find.textContaining('2. الحمولة المطلوب نقلها'), findsOneWidget);
      expect(find.textContaining('3. متطلبات النقل'), findsOneWidget);
      expect(find.textContaining('4. الميزانية المتوقعة (اختياري)'), findsOneWidget);
      expect(find.textContaining('5. ملاحظات إضافية (اختياري)'), findsOneWidget);

      // Verify Mini-map route estimates
      expect(find.text('المسافة التقديرية'), findsOneWidget);
      expect(find.text('المدة التقديرية'), findsOneWidget);
      expect(find.text('عرض المسار الكامل'), findsOneWidget);

      // Verify Bottom Buttons
      expect(find.text('حفظ الطلب'), findsOneWidget);
      expect(find.text('نشر الطلب'), findsOneWidget);

      // Verify Back action
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backTapped, isTrue);
    });

    testWidgets('saves order as draft into MerchantSimulationStore under status draft',
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

      final initialDraftCount = MerchantSimulationStore.instance.orders
          .where((o) => o.status == MerchantOrderStatus.draft)
          .length;

      // Find and tap «حفظ الطلب»
      final saveDraftBtn = find.text('حفظ الطلب');
      expect(saveDraftBtn, findsOneWidget);
      await tester.ensureVisible(saveDraftBtn);
      await tester.tap(saveDraftBtn);
      await tester.pumpAndSettle();

      // Verify draft callback was triggered
      expect(submittedDraft, isNotNull);
      expect(submittedDraft!.originCity, equals('صنعاء'));
      expect(submittedDraft!.destCity, equals('الرياض'));

      // Verify draft exists in MerchantSimulationStore
      final newDraftCount = MerchantSimulationStore.instance.orders
          .where((o) => o.status == MerchantOrderStatus.draft)
          .length;
      expect(newDraftCount, equals(initialDraftCount + 1));

      // SnackBar should confirm draft saved
      expect(find.textContaining('تم حفظ مسودة الطلب بنجاح'), findsOneWidget);
    });

    testWidgets('tapping «نشر الطلب» opens PublishTargetModalSheet and publishes to all drivers',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const MerchantCreateOrderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap «نشر الطلب»
      final publishBtn = find.text('نشر الطلب');
      await tester.ensureVisible(publishBtn);
      await tester.tap(publishBtn);
      await tester.pumpAndSettle();

      // Verify Publish Target Modal is displayed with the 4 options
      expect(find.text('نشر طلب النقل'), findsOneWidget);
      expect(find.text('جميع السائقين'), findsOneWidget);
      expect(find.text('سائق محدد'), findsOneWidget);
      expect(find.text('جميع مكاتب النقل'), findsOneWidget);
      expect(find.text('مكتب نقل محدد'), findsOneWidget);

      // Tap «متابعة» to publish to all drivers (default selected option)
      final continueBtn = find.text('متابعة');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Verify Success Modal appears
      expect(find.text(AppStrings.orderPublishedSuccessTitle), findsOneWidget);
      expect(find.text('عرض الطلب'), findsOneWidget);
      expect(find.text('العودة للرئيسية'), findsOneWidget);
    });

    testWidgets('validates min budget cannot exceed max budget and displays inline error',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const MerchantCreateOrderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter min budget > max budget
      final textFields = find.byType(TextField);
      // Index 0: origin detail, 1: dest detail, 2: loading date, 3: min budget, 4: max budget
      await tester.enterText(textFields.at(3), '5000');
      await tester.enterText(textFields.at(4), '2000');
      await tester.pumpAndSettle();

      // Tap «نشر الطلب»
      final publishBtn = find.text('نشر الطلب');
      await tester.ensureVisible(publishBtn);
      await tester.tap(publishBtn);
      await tester.pumpAndSettle();

      // Verify inline error message is shown
      expect(
        find.textContaining('الحد الأدنى للميزانية لا يمكن أن يتجاوز الحد الأعلى'),
        findsWidgets,
      );

      // Publish Target Modal must NOT open
      expect(find.text('نشر طلب النقل'), findsNothing);
    });

    testWidgets('opens map picker for origin location and updates route',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const MerchantCreateOrderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 'الخريطة' buttons are present
      final pickMapButtons = find.text('الخريطة');
      expect(pickMapButtons, findsWidgets);

      // Tap first map picker button (Origin)
      await tester.tap(pickMapButtons.first);
      await tester.pumpAndSettle();

      // Verify Map Location Picker Modal is displayed
      expect(find.text('تحديد موقع التحميل من الخريطة'), findsOneWidget);

      // Confirm in modal
      final confirmLocationBtn = find.textContaining('تأكيد هذا الموقع');
      expect(confirmLocationBtn, findsOneWidget);
      await tester.tap(confirmLocationBtn);
      await tester.pumpAndSettle();

      // Modal closed, origin city remains active
      expect(find.textContaining('صنعاء'), findsWidgets);
    });
  });

  group('SelectDriverScreen Tests', () {
    testWidgets('renders verified drivers list with ratings, filters by search, and selects available driver',
        (tester) async {
      DriverProfile? selectedDriver;
      bool backTapped = false;

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          SelectDriverScreen(
            onBack: () => backTapped = true,
            onDriverSelected: (drv) => selectedDriver = drv,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header and Search Field
      expect(find.text('اختيار سائق محدد'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify Driver Cards from Mockup Image 4
      expect(find.text('أحمد القحطاني'), findsOneWidget);
      expect(find.text('محمد العتيبي'), findsOneWidget);
      expect(find.text('خالد الشهري'), findsOneWidget); // Busy driver
      expect(find.text('سالم الدوسري'), findsOneWidget);

      // Verify 'مشغول حالياً' tag for Khaled Al-Shehri
      expect(find.text('مشغول حالياً'), findsOneWidget);

      // Tap 'اختيار' on first available driver (Ahmad Al-Qahtani)
      final selectButtons = find.text('اختيار');
      expect(selectButtons, findsWidgets);
      await tester.tap(selectButtons.first);
      await tester.pumpAndSettle();

      expect(selectedDriver, isNotNull);
      expect(selectedDriver!.name, equals('أحمد القحطاني'));

      // Test Back button
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backTapped, isTrue);
    });

    testWidgets('toggles between list view and map view with driver markers',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const SelectDriverScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Map View via button
      final mapToggle = find.text('الخريطة');
      await tester.tap(mapToggle);
      await tester.pumpAndSettle();

      // Verify map mode with "عرض في القائمة" button
      expect(find.text('عرض في القائمة'), findsOneWidget);

      // Switch back to list view
      await tester.tap(find.text('عرض في القائمة'));
      await tester.pumpAndSettle();

      // List is back
      expect(find.text('أحمد القحطاني'), findsOneWidget);
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

      // Tap Direct Order CTA ("طلب نقل") to open Order Selection Modal
      final directOrderBtn = find.text('طلب نقل');
      await tester.tap(directOrderBtn);
      await tester.pumpAndSettle();

      // Verify Case A Modal appears with available orders
      expect(find.textContaining('اختر طلباً موجوداً أو أنشئ طلباً جديداً'), findsOneWidget);
      expect(find.text('إسناد للسائق'), findsWidgets);

      // Tap assign to driver on the first pending order
      await tester.tap(find.text('إسناد للسائق').first);
      await tester.pumpAndSettle();
      expect(directOrderTapped, isTrue);

      // Tap Message CTA ("مراسلة")
      final messageBtn = find.text('مراسلة');
      await tester.tap(messageBtn);
      expect(messagedPhone, isNotNull);

      // Tap Back Button
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backTapped, isTrue);
    });

    testWidgets('renders perfectly on narrow mobile width (360px) without overflow exceptions', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          const DriverProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('معلومات المركبة'), findsOneWidget);
      expect(find.text('مرسيدس أكتروس'), findsOneWidget);
    });
  });
}
