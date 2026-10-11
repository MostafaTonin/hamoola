import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/presentation/screens/identity_verification_screen.dart';
import 'package:flutter_application/features/onboarding/presentation/screens/onboarding_3_screen.dart';

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

  group('Onboarding3Screen Visual & Functional Tests (Image 1)', () {
    testWidgets('renders hero content, badge, title, and buttons accurately',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool startTapped = false;
      bool skipTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          Onboarding3Screen(
            onStartNow: () => startTapped = true,
            onSkip: () => skipTapped = true,
          ),
        ),
      );
      await tester.pump();

      // Verify Screen Elements matching Image 1
      expect(find.text('تخطي'), findsOneWidget);
      expect(find.text('انطلاق ووصول موثوق'), findsOneWidget);
      expect(find.text('ابدأ رحلتك مع حمولة'), findsOneWidget);
      expect(find.text('أنشئ حسابك وابدأ في نقل حمولاتك بسهولة.'), findsOneWidget);
      expect(find.text('ابدأ الآن'), findsOneWidget);

      // Tap 'ابدأ الآن'
      await tester.tap(find.text('ابدأ الآن'));
      expect(startTapped, isTrue);

      // Tap 'تخطي'
      await tester.tap(find.text('تخطي'));
      expect(skipTapped, isTrue);
    });
  });

  group('IdentityVerificationScreen Tests (Images 3, 4, 5)', () {
    testWidgets('renders identity verification form, cards, scanner modal, and simulates verification',
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
          IdentityVerificationScreen(
            onBack: () => backTapped = true,
            onVerificationComplete: (val) => verificationCompleted = val,
          ),
        ),
      );
      await tester.pump();

      // Check header back button tap
      await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
      expect(backTapped, isTrue);

      // Check header and titles
      expect(find.text('بيانات الهوية'), findsOneWidget);
      expect(find.text('الصورة الشخصية'), findsOneWidget);
      expect(find.text('توثيق الهوية • حساب مواطن'), findsOneWidget);
      expect(find.text('توثيق الهوية'), findsOneWidget);
      expect(find.text('اختياري'), findsOneWidget);

      // Check prepopulated values matching user screenshot
      expect(find.text('11010290469'), findsOneWidget);
      expect(find.text('حجة'), findsOneWidget);
      expect(find.text('2026-4-5'), findsOneWidget);
      expect(find.text('2036-4-4'), findsOneWidget);
      expect(find.text('حجة - مبين - الجبر'), findsOneWidget);
      expect(find.text('1995-08-12'), findsOneWidget);

      // Check document upload labels
      expect(find.text('رفع صور وثيقة الهوية'), findsOneWidget);
      expect(find.text('صورة الهوية من الأمام'), findsOneWidget);
      expect(find.text('صورة الهوية من الخلف'), findsOneWidget);
      expect(find.text('صورة سيلفي مع الهوية'), findsWidgets);

      // Check Action Buttons
      expect(find.text('توثيق الحساب'), findsOneWidget);
      expect(find.text('تخطي الآن'), findsOneWidget);

      // Open Smart Scanner Modal
      final scannerButton = find.byTooltip('مسح ذكي للبطاقة عبر الكاميرا');
      expect(scannerButton, findsOneWidget);
      await tester.ensureVisible(scannerButton);
      await tester.tap(scannerButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check scanner modal UI
      expect(find.text('مسح بطاقة الهوية الذكي'), findsOneWidget);
      expect(find.text('مسح البطاقة الذكية الآن'), findsOneWidget);

      // Tap simulate scan in modal
      await tester.tap(find.text('مسح البطاقة الذكية الآن'));
      await tester.pump(const Duration(milliseconds: 400));

      // Tap 'توثيق الحساب' and confirm completion dialog
      final verifyButton = find.widgetWithText(ElevatedButton, 'توثيق الحساب');
      await tester.ensureVisible(verifyButton);
      await tester.tap(verifyButton);
      await tester.pump(); // Start simulated loading
      await tester.pump(const Duration(milliseconds: 900)); // Finish loading
      await tester.pumpAndSettle();

      // Verify success dialog appears
      expect(find.text('تم توثيق الحساب بنجاح ✓'), findsOneWidget);
      expect(find.text('متابعة إلى الرئيسية'), findsOneWidget);

      // Tap confirm in modal
      await tester.tap(find.text('متابعة إلى الرئيسية'));
      await tester.pumpAndSettle();

      expect(verificationCompleted, isTrue);
    });

    testWidgets('triggers skip button properly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool skipTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            onSkip: () => skipTapped = true,
          ),
        ),
      );
      await tester.pump();

      final skipButton = find.text('تخطي الآن');
      await tester.ensureVisible(skipButton);
      await tester.tap(skipButton);
      expect(skipTapped, isTrue);
    });
  });
}
