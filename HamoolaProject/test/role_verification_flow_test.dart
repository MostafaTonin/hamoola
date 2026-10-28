import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_license_verification_screen.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_vehicle_verification_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/commercial_verification_screen.dart';

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

  group('CommercialVerificationScreen Tests (Images 1 & 2)', () {
    testWidgets(
        'renders merchant enterprise data, commercial register fields, 4 documents and completes verification',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool backTapped = false;
      bool verificationCompleted = false;

      await tester.pumpWidget(
        wrapWidget(
          CommercialVerificationScreen(
            role: 'تاجر',
            onBack: () => backTapped = true,
            onVerificationComplete: (val) => verificationCompleted = val,
          ),
        ),
      );
      await tester.pump();

      // Check header and status pill
      expect(find.text('بيانات التاجر'), findsOneWidget);
      expect(find.text('بيانات النشاط التجاري والسجل التجاري'), findsOneWidget);

      // Check pre-populated fields matching Image 2
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is EditableText &&
              (w.controller.text == 'مؤسسة النور للتجارة العامة' ||
                  w.controller.text == 'مؤسسة الأمل للتجارة العامة والاستيراد'),
        ),
        findsOneWidget,
      );
      expect(find.text('تجارة جملة وتجزئة'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is EditableText &&
              (w.controller.text == '1234567890' ||
                  w.controller.text == 'CR-1048293'),
        ),
        findsOneWidget,
      );
      expect(find.text('وزارة الصناعة والتجارة - مكتب الأمانة'), findsOneWidget);
      expect(find.text('2021-08-10'), findsOneWidget);
      expect(find.text('2026-08-09'), findsOneWidget);
      expect(find.text('صنعاء - شارع الستين الجنوبي - عمارة الأمل'), findsOneWidget);

      // Check documents section matching Image 2
      expect(find.text('مستندات التوثيق والاعتماد'), findsOneWidget);
      expect(find.text('صورة الهوية من الأمام'), findsOneWidget);
      expect(find.text('صورة الهوية من الخلف'), findsOneWidget);
      expect(find.text('صورة شخصية مع الهوية'), findsOneWidget);
      expect(find.text('صورة السجل التجاري'), findsOneWidget);

      // Check back button tap
      await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
      expect(backTapped, isTrue);

      // Tap 'توثيق الحساب' and confirm dialog
      final submitBtn = find.widgetWithText(ElevatedButton, 'توثيق الحساب');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Check verified completion dialog
      expect(find.text('تم توثيق السجل التجاري بنجاح ✓'), findsOneWidget);
      expect(find.text('متابعة إلى الرئيسية'), findsOneWidget);

      await tester.tap(find.text('متابعة إلى الرئيسية'));
      await tester.pumpAndSettle();

      expect(verificationCompleted, isTrue);
    });

    testWidgets('adapts title for office role and triggers skip', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool skipTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          CommercialVerificationScreen(
            role: 'مكتب نقل',
            onSkip: () => skipTapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('بيانات مكتب النقل'), findsOneWidget);
      expect(find.text('مكتب الأمانة لنقل البضائع والمهمات'), findsOneWidget);

      final skipBtn = find.text('تخطي الآن');
      await tester.ensureVisible(skipBtn);
      await tester.tap(skipBtn);
      expect(skipTapped, isTrue);
    });
  });

  group('DriverLicenseVerificationScreen Tests (Images 3 & 4)', () {
    testWidgets('renders license form, photo cards, and triggers continue to vehicle',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool backTapped = false;
      bool nextTapped = false;
      bool skipTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          DriverLicenseVerificationScreen(
            onBack: () => backTapped = true,
            onNext: () => nextTapped = true,
            onSkip: () => skipTapped = true,
          ),
        ),
      );
      await tester.pump();

      // Check header and pill matching Image 3
      expect(find.text('بيانات السائق والرخصة'), findsOneWidget);
      expect(find.text('بيانات رخصة القيادة'), findsOneWidget);

      // Check fields matching Image 3
      expect(find.text('DL-942851'), findsOneWidget);
      expect(find.text('نقل ثقيل (شاحنات وقاطرات)'), findsOneWidget);
      expect(find.text('الإدارة العامة للمرور - تعز'), findsOneWidget);
      expect(find.text('2021-09-15'), findsOneWidget);
      expect(find.text('2026-09-14'), findsOneWidget);

      // Check photo cards matching Image 4
      expect(find.text('صور رخصة القيادة'), findsOneWidget);
      expect(find.text('صورة الرخصة (الأمام)'), findsOneWidget);
      expect(find.text('صورة الرخصة (الخلف)'), findsOneWidget);

      // Check back tap
      await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
      expect(backTapped, isTrue);

      // Tap 'متابعة إلى بيانات المركبة'
      final nextBtn = find.widgetWithText(ElevatedButton, 'متابعة إلى بيانات المركبة');
      await tester.ensureVisible(nextBtn);
      await tester.tap(nextBtn);
      expect(nextTapped, isTrue);

      // Tap 'تخطي الآن'
      final skipBtn = find.text('تخطي الآن');
      await tester.ensureVisible(skipBtn);
      await tester.tap(skipBtn);
      expect(skipTapped, isTrue);
    });
  });

  group('DriverVehicleVerificationScreen Tests (Image 5)', () {
    testWidgets('renders vehicle specifications, documents, and completes verification',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool backTapped = false;
      bool skipTapped = false;
      bool verificationCompleted = false;

      await tester.pumpWidget(
        wrapWidget(
          DriverVehicleVerificationScreen(
            onBack: () => backTapped = true,
            onSkip: () => skipTapped = true,
            onVerificationComplete: (val) => verificationCompleted = val,
          ),
        ),
      );
      await tester.pump();

      // Check header and pill matching Image 5
      expect(find.text('بيانات مركبتك'), findsOneWidget);
      expect(find.text('بيانات المركبة الأساسية'), findsOneWidget);

      // Check fields matching Image 5 & latest screenshots
      expect(find.text('شاحنة نقل'), findsOneWidget);
      expect(find.text('نقل ثقيل'), findsOneWidget);
      expect(find.text('مرسيدس'), findsOneWidget);
      expect(find.text('أكتروس'), findsOneWidget);
      expect(find.text('2023'), findsOneWidget);
      expect(find.text('7198 د ح ي'), findsOneWidget);
      expect(find.text('أبيض'), findsOneWidget);

      // Check capabilities section and fields
      expect(find.text('قدرات المركبة'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('طن'), findsOneWidget);
      expect(find.text('صندوق مغلق'), findsOneWidget);
      expect(find.text('65 م³'), findsOneWidget);

      // Check 4 photo cards
      expect(find.text('صور المركبة'), findsOneWidget);
      expect(find.text('صورة المركبة من الأمام'), findsOneWidget);
      expect(find.text('صورة المركبة من الخلف'), findsOneWidget);
      expect(find.text('صورة جانبية للمركبة'), findsOneWidget);
      expect(find.text('صورة لوحة المركبة'), findsOneWidget);

      // Check back tap
      await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
      expect(backTapped, isTrue);

      // Tap 'توثيق الحساب' and confirm dialog
      final submitBtn = find.widgetWithText(ElevatedButton, 'توثيق الحساب');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Check verified completion dialog
      expect(find.text('تم توثيق بيانات السائق والمركبة بنجاح ✓'), findsOneWidget);
      expect(find.text('متابعة إلى الرئيسية'), findsOneWidget);

      await tester.tap(find.text('متابعة إلى الرئيسية'));
      await tester.pumpAndSettle();

      expect(verificationCompleted, isTrue);

      // Verify skip button tap
      final skipBtn = find.text('تخطي الآن');
      await tester.ensureVisible(skipBtn);
      await tester.tap(skipBtn);
      expect(skipTapped, isTrue);
    });
  });
}
