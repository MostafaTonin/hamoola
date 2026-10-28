import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/auth/presentation/screens/identity_verification_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthSimulationStore.instance.resetToDemo();
  });

  Widget wrapWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    );
  }

  group('Prompt 02 — Client Identity Verification Suite', () {
    // 1 & 2: فتح شاشة التوثيق بحساب مصطفى وظهور البيانات الافتراضية
    testWidgets('1 & 2. Open KYC with Mustafa demo account and verify all defaults', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mustafa = AuthSimulationStore.instance.users.firstWhere((u) => u.id == 'USR-CLIENT-01');
      AuthSimulationStore.instance.setCurrentUser(mustafa);

      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            userId: mustafa.id,
            userName: mustafa.name,
            userPhone: mustafa.phone,
            userRole: mustafa.role.label,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and titles matching user screenshots
      expect(find.text('بيانات الهوية'), findsOneWidget);
      expect(find.text('الصورة الشخصية'), findsOneWidget);
      expect(find.text('توثيق الهوية • حساب مواطن'), findsOneWidget);
      expect(find.text('توثيق الهوية'), findsOneWidget);
      expect(find.text('اختياري'), findsOneWidget);

      // Verify specific Section 3 demo data
      expect(find.text('مصطفى صالح طنين'), findsOneWidget);
      expect(find.text('بطاقة شخصية'), findsOneWidget);
      expect(find.text('يمني'), findsOneWidget);
      expect(find.text('TEST-YE-100245'), findsOneWidget);
      expect(find.text('الأحوال المدنية — بيانات تجريبية'), findsOneWidget);
      expect(find.text('2022-03-15'), findsOneWidget);
      expect(find.text('2032-03-14'), findsOneWidget);
      expect(find.text('صنعاء'), findsOneWidget);
      expect(find.text('1998-05-12'), findsOneWidget);

      // Verify action buttons
      expect(find.text('توثيق الحساب'), findsOneWidget);
      expect(find.text('تخطي الآن'), findsOneWidget);

      // Verify no family card option exists in ID types
      expect(find.text('بطاقة عائلية'), findsNothing);
    });

    // 3 & 9: تعديل حقل ثم العودة إلى الشاشة والتأكد من حفظ القيمة
    testWidgets('3 & 9. Edit field, navigate back, and verify persistence on return', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mustafa = AuthSimulationStore.instance.users.firstWhere((u) => u.id == 'USR-CLIENT-01');
      AuthSimulationStore.instance.setCurrentUser(mustafa);

      bool backCalled = false;
      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            userId: mustafa.id,
            userName: mustafa.name,
            onBack: () => backCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Modify Issue Place
      final issuePlaceFinder = find.widgetWithText(TextFormField, 'الأحوال المدنية — بيانات تجريبية');
      expect(issuePlaceFinder, findsOneWidget);
      await tester.enterText(issuePlaceFinder, 'صنعاء — فرع السبعين المحدث');
      await tester.pump();

      // Tap back button (which saves draft)
      final backButton = find.byIcon(Icons.arrow_forward_ios_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      expect(backCalled, isTrue);

      // Re-mount screen and ensure modified field was retained
      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            userId: mustafa.id,
            userName: mustafa.name,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('صنعاء — فرع السبعين المحدث'), findsOneWidget);
    });

    // 4: التحقق من عمل معاينات الصور واستبدالها وحذفها
    testWidgets('4. Verify photo preview cards, deletion, and replacement', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        wrapWidget(
          const IdentityVerificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify photo section cards
      expect(find.text('رفع صور وثيقة الهوية'), findsOneWidget);
      expect(find.text('صورة الهوية من الأمام'), findsOneWidget);
      expect(find.text('صورة الهوية من الخلف'), findsOneWidget);
      expect(find.text('صورة سيلفي مع الهوية'), findsOneWidget);

      // Find delete buttons ('close' icons)
      final deleteButtons = find.byIcon(Icons.close_rounded);
      expect(deleteButtons, findsWidgets);

      // Tap the first delete button (delete front photo)
      await tester.ensureVisible(deleteButtons.first);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Now tap change photo on the front card
      final changeButtons = find.text('تغيير الصورة');
      expect(changeButtons, findsWidgets);
      await tester.tap(changeButtons.first);
      await tester.pumpAndSettle();

      // Bottom sheet opens
      expect(find.text('اختيار مصدر الصورة'), findsOneWidget);
      expect(find.text('التقاط بالكاميرا الآن'), findsOneWidget);
      expect(find.text('اختيار من ألبوم الصور'), findsOneWidget);

      // Select camera option
      await tester.tap(find.text('التقاط بالكاميرا الآن'));
      await tester.pumpAndSettle();

      // SnackBar confirmation
      expect(find.text('تم تحديث الصورة بنجاح'), findsOneWidget);
    });

    // 5: محاولة إرسال التوثيق مع نقص حقل إلزامي
    testWidgets('5. Block submission if mandatory field is missing and display error', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mustafa = AuthSimulationStore.instance.users.firstWhere((u) => u.id == 'USR-CLIENT-01');
      AuthSimulationStore.instance.setCurrentUser(mustafa);

      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            userId: mustafa.id,
            userName: mustafa.name,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Clear full name
      final nameFinder = find.widgetWithText(TextFormField, 'مصطفى صالح طنين');
      await tester.enterText(nameFinder, '');
      await tester.pump();

      // Attempt submit
      final submitBtn = find.widgetWithText(ElevatedButton, 'توثيق الحساب');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Expect validation error
      expect(find.text('يرجى إدخال الاسم الكامل.'), findsOneWidget);

      // Status in store remains unverified
      final refreshed = AuthSimulationStore.instance.getUserById('USR-CLIENT-01');
      expect(refreshed?.verificationStatus, AccountVerificationStatus.unverified);
    });

    // 6 & 7: إرسال طلب توثيق صحيح ومنع التكرار والانتقال إلى pending_review
    testWidgets('6 & 7. Valid submission transitions to pending_review and prevents duplicate submits', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mustafa = AuthSimulationStore.instance.users.firstWhere((u) => u.id == 'USR-CLIENT-01');
      AuthSimulationStore.instance.setCurrentUser(mustafa);
      bool verificationCompleted = false;

      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            userId: mustafa.id,
            userName: mustafa.name,
            onVerificationComplete: (val) => verificationCompleted = val,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final submitBtn = find.widgetWithText(ElevatedButton, 'توثيق الحساب');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      // Double tap test
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Feedback Dialog
      expect(find.text('تم إرسال طلب التوثيق بنجاح ✓'), findsOneWidget);
      expect(find.text('متابعة إلى الرئيسية'), findsOneWidget);

      // Click to continue
      await tester.tap(find.text('متابعة إلى الرئيسية'));
      await tester.pumpAndSettle();
      expect(verificationCompleted, isTrue);

      // Status MUST be pendingReview, NOT verified!
      final refreshed = AuthSimulationStore.instance.getUserById('USR-CLIENT-01');
      expect(refreshed?.verificationStatus, AccountVerificationStatus.pendingReview);
      expect(refreshed?.identityData?.idNumber, 'TEST-YE-100245');
    });

    // 8: تخطي التوثيق والوصول إلى الرئيسية بحالة unverified
    testWidgets('8. Skip action retains account with unverified status', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mustafa = AuthSimulationStore.instance.users.firstWhere((u) => u.id == 'USR-CLIENT-01');
      AuthSimulationStore.instance.setCurrentUser(mustafa);
      bool skipCalled = false;

      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            userId: mustafa.id,
            userName: mustafa.name,
            onSkip: () => skipCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final skipBtn = find.text('تخطي الآن');
      await tester.ensureVisible(skipBtn);
      await tester.tap(skipBtn);
      await tester.pumpAndSettle();

      expect(skipCalled, isTrue);
      final refreshed = AuthSimulationStore.instance.getUserById('USR-CLIENT-01');
      expect(refreshed?.verificationStatus, AccountVerificationStatus.unverified);
    });

    // 10 & 11: التأكد من عدم الخلط بين التحقق من الهاتف واعتماد الهوية وعدم منح verified تلقائياً
    testWidgets('10 & 11. Phone verified client does not automatically gain verified KYC', (tester) async {
      final user = AuthSimulationStore.instance.getUserById('USR-CLIENT-01');
      expect(user?.isPhoneVerified, isTrue);
      // KYC is NOT verified just because phone is verified
      expect(user?.verificationStatus, isNot(AccountVerificationStatus.verified));
      expect(user?.verificationStatus, AccountVerificationStatus.unverified);

      // Submitting KYC moves to pendingReview, still NOT verified
      AuthSimulationStore.instance.submitClientVerification(
        userId: 'USR-CLIENT-01',
        identityData: ClientIdentityData(
          fullName: 'مصطفى صالح طنين',
          idNumber: 'TEST-YE-100245',
          issuePlace: 'الأحوال المدنية — بيانات تجريبية',
          issueDate: '2022-03-15',
          birthPlace: 'صنعاء',
          birthDate: '1998-05-12',
          submittedAt: DateTime(2026, 10, 14),
        ),
      );

      final submittedUser = AuthSimulationStore.instance.getUserById('USR-CLIENT-01');
      expect(submittedUser?.verificationStatus, AccountVerificationStatus.pendingReview);
      expect(submittedUser?.verificationStatus, isNot(AccountVerificationStatus.verified));

      // Only administrative simulation approval can make it verified
      AuthSimulationStore.instance.simulateApproveClientVerification('USR-CLIENT-01');
      final approvedUser = AuthSimulationStore.instance.getUserById('USR-CLIENT-01');
      expect(approvedUser?.verificationStatus, AccountVerificationStatus.verified);
    });

    // 12: التأكد من أن بيانات العميل لا تظهر في حساب آخر (عزل الحسابات)
    testWidgets('12. User identity data is strictly isolated per account ID', (tester) async {
      final client1 = AuthSimulationStore.instance.getUserById('USR-CLIENT-01');
      final client2 = AuthSimulationStore.instance.getUserById('USR-CLIENT-02');
      final driver = AuthSimulationStore.instance.getUserById('USR-DRIVER-01');

      expect(client1?.name, 'مصطفى صالح طنين');
      expect(client2?.name, contains('سالم صالح الكندي'));
      expect(driver?.name, contains('كابتن أحمد السالمي'));

      // Save custom identity for Client 1
      AuthSimulationStore.instance.saveClientIdentityDraft(
        userId: 'USR-CLIENT-01',
        identityData: ClientIdentityData(
          fullName: 'مصطفى صالح طنين الخاص',
          idNumber: 'TEST-YE-UNIQUE-101',
          issuePlace: 'صنعاء',
          issueDate: '2022-03-15',
          birthPlace: 'صنعاء',
          birthDate: '1998-05-12',
          submittedAt: DateTime.now(),
        ),
      );

      final c1 = AuthSimulationStore.instance.getUserById('USR-CLIENT-01');
      final c2 = AuthSimulationStore.instance.getUserById('USR-CLIENT-02');

      expect(c1?.identityData?.idNumber, 'TEST-YE-UNIQUE-101');
      expect(c2?.identityData?.idNumber, isNot('TEST-YE-UNIQUE-101'));
    });
  });
}
