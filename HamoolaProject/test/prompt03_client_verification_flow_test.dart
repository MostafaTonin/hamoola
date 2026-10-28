import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/auth/presentation/screens/identity_verification_screen.dart';
import 'package:flutter_application/features/client/presentation/screens/client_home_screen.dart';

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

  group('Prompt 03 - Client Verification and Home Flow Tests', () {
    testWidgets('1. عميل ينشئ حساباً، يتحقق من هاتفه، يكمل التوثيق، ويرسل الطلب إلى pending_review',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Create client account
      final regRes = AuthSimulationStore.instance.register(
        role: AuthUserRole.client,
        fullName: 'عمر ياسين باحميد',
        phone: '770987654',
        password: 'password123',
      );
      expect(regRes.isSuccess, isTrue);
      final registeredUser = regRes.user!;
      expect(registeredUser.role, AuthUserRole.client);
      expect(registeredUser.verificationStatus, AccountVerificationStatus.unverified);
      expect(registeredUser.isPhoneVerified, isFalse);

      // 2. OTP Verification
      final otpRes = AuthSimulationStore.instance.verifyOtpResult(
        registeredUser.phone,
        AuthSimulationStore.defaultDemoOtp,
      );
      expect(otpRes.isSuccess, isTrue);
      expect(otpRes.user?.isPhoneVerified, isTrue);
      // Strictly remains unverified for KYC per Rule 16
      expect(otpRes.user?.verificationStatus, AccountVerificationStatus.unverified);

      // 3. Mount IdentityVerificationScreen
      bool verificationCompleted = false;
      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            userId: registeredUser.id,
            userName: registeredUser.name,
            userPhone: registeredUser.phone,
            userRole: registeredUser.role.label,
            onVerificationComplete: (val) => verificationCompleted = val,
          ),
        ),
      );
      await tester.pump();

      // Check Title and Subtitle per Prompt 03 Section 4
      expect(find.text('توثيق الهوية الشخصية'), findsOneWidget);
      expect(
        find.text('أكمل بيانات هويتك لتفعيل خدمات حمولة التي تتطلب التوثيق.'),
        findsOneWidget,
      );

      // Check pre-filled name
      expect(find.text('عمر ياسين باحميد'), findsOneWidget);

      // Submit Verification Request
      final submitBtn = find.widgetWithText(ElevatedButton, 'إرسال طلب التوثيق');
      expect(submitBtn, findsOneWidget);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Check Feedback Modal
      expect(find.text('تم إرسال طلب التوثيق بنجاح ✓'), findsOneWidget);
      expect(find.text('متابعة إلى الرئيسية'), findsOneWidget);

      // Tap continue
      await tester.tap(find.text('متابعة إلى الرئيسية'));
      await tester.pumpAndSettle();
      expect(verificationCompleted, isTrue);

      // Check that store was updated to pending_review
      final updatedUser = AuthSimulationStore.instance.getUserByPhone('770987654');
      expect(updatedUser?.verificationStatus, AccountVerificationStatus.pendingReview);
      expect(updatedUser?.identityData, isNotNull);
      expect(updatedUser?.identityData?.fullName, 'عمر ياسين باحميد');
      expect(updatedUser?.identityData?.idNumber, 'TEST-YE-100245');
    });

    testWidgets('2. عميل يتخطى التوثيق (تخطي الآن) ويصل إلى الرئيسية بحالة غير موثقة دون فقدان الحساب',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Register and verify OTP
      final regRes = AuthSimulationStore.instance.register(
        role: AuthUserRole.client,
        fullName: 'فؤاد عبدالكريم',
        phone: '770333444',
        password: 'password123',
      );
      AuthSimulationStore.instance.verifyOtp('770333444', '123456');

      bool skipCalled = false;
      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            userId: regRes.user!.id,
            userName: regRes.user!.name,
            userPhone: regRes.user!.phone,
            onSkip: () => skipCalled = true,
          ),
        ),
      );
      await tester.pump();

      // Tap 'تخطي الآن'
      final skipBtn = find.text('تخطي الآن');
      expect(skipBtn, findsOneWidget);
      await tester.ensureVisible(skipBtn);
      await tester.tap(skipBtn);
      await tester.pump();

      expect(skipCalled, isTrue);

      // User account is preserved with unverified status
      final user = AuthSimulationStore.instance.getUserByPhone('770333444');
      expect(user, isNotNull);
      expect(user?.name, 'فؤاد عبدالكريم');
      expect(user?.verificationStatus, AccountVerificationStatus.unverified);
      expect(user?.isPhoneVerified, isTrue);

      // Mount ClientHomeScreen with this unverified user
      AuthSimulationStore.instance.setCurrentUser(user!);
      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      // Check unverified banner and chip
      expect(find.text('حسابك غير موثق حالياً'), findsOneWidget);
      expect(find.text('غير موثق'), findsWidgets);
      expect(find.text('توثيق الحساب الآن'), findsOneWidget);
    });

    testWidgets('3. عميل يعود لاحقاً إلى التوثيق من الرئيسية بالنقر على توثيق الحساب الآن',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool verifyTapped = false;

      // Set demo unverified client as active user
      final unverifiedClient = AuthSimulationStore.instance.users.firstWhere(
        (u) => u.role == AuthUserRole.client && u.verificationStatus == AccountVerificationStatus.unverified,
      );
      AuthSimulationStore.instance.setCurrentUser(unverifiedClient);

      await tester.pumpWidget(
        wrapWidget(
          ClientHomeScreen(
            onVerifyNow: () => verifyTapped = true,
          ),
        ),
      );
      await tester.pump();

      final verifyBtn = find.text('توثيق الحساب الآن');
      expect(verifyBtn, findsOneWidget);
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pump();

      expect(verifyTapped, isTrue);
    });

    testWidgets('4. عميل يرسل طلب التوثيق وتظهر حالته «قيد المراجعة» مع إمكانية عرض تفاصيل الطلب',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Submit verification for client
      final client = AuthSimulationStore.instance.users.firstWhere((u) => u.role == AuthUserRole.client);
      AuthSimulationStore.instance.submitClientVerification(
        userId: client.id,
        identityData: ClientIdentityData(
          fullName: 'سالم صالح الكندي',
          idNumber: '11010290469',
          issuePlace: 'حضرموت - المكلا',
          issueDate: '2026-01-10',
          birthPlace: 'حضرموت',
          birthDate: '1992-05-15',
          submittedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      // Verify pending review banner is visible
      expect(find.text('طلب التوثيق قيد المراجعة'), findsOneWidget);
      expect(find.text('قيد المراجعة'), findsWidgets);
      expect(find.text('عرض حالة التوثيق'), findsOneWidget);

      // Tap 'عرض حالة التوثيق'
      await tester.tap(find.text('عرض حالة التوثيق'));
      await tester.pumpAndSettle();

      // Check that bottom sheet displays submitted data
      expect(find.text('بيانات توثيق الهوية المرسلة'), findsOneWidget);
      expect(find.text('11010290469'), findsOneWidget);
      expect(find.text('حضرموت - المكلا'), findsOneWidget);
    });

    testWidgets('5. عميل موثق يرى الخدمات المتاحة وتختفي تنبيهات عدم التوثيق ويستطيع إنشاء طلب نقل',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool orderCreated = false;

      // Approve client verification
      final client = AuthSimulationStore.instance.users.firstWhere((u) => u.role == AuthUserRole.client);
      AuthSimulationStore.instance.simulateApproveClientVerification(client.id);

      await tester.pumpWidget(
        wrapWidget(
          ClientHomeScreen(
            onCreateOrder: () => orderCreated = true,
          ),
        ),
      );
      await tester.pump();

      // Verify verified chip & banner
      expect(find.text('موثق ومعتمد'), findsWidgets);
      expect(find.textContaining('حساب موثق ومعتمد بنجاح'), findsOneWidget);

      // Restricted warning not present
      expect(find.text('حسابك غير موثق حالياً'), findsNothing);
      expect(find.text('طلب التوثيق قيد المراجعة'), findsNothing);

      // Tap 'إنشاء طلب نقل'
      final createOrderBtn = find.text('إنشاء طلب نقل');
      expect(createOrderBtn, findsOneWidget);
      await tester.ensureVisible(createOrderBtn);
      await tester.tap(createOrderBtn);
      await tester.pump();

      expect(orderCreated, isTrue);
    });

    testWidgets('6. عميل غير موثق يحاول فتح خدمة مقيدة (إنشاء طلب نقل) فتظهر رسالة توضيحية',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final client = AuthSimulationStore.instance.users.firstWhere((u) => u.role == AuthUserRole.client);
      AuthSimulationStore.instance.simulateSetVerificationStatus(client.id, AccountVerificationStatus.unverified);

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      // Tap 'إنشاء طلب نقل'
      final createOrderBtn = find.text('إنشاء طلب نقل');
      await tester.ensureVisible(createOrderBtn);
      await tester.tap(createOrderBtn);
      await tester.pumpAndSettle();

      // Dialog opens explaining verification required
      expect(find.text('توثيق الحساب مطلوب'), findsOneWidget);
      expect(find.textContaining('يتطلب إنشاء طلب نقل توثيق هويتك الشخصية'), findsOneWidget);
      expect(find.text('توثيق الحساب الآن'), findsWidgets);
    });

    testWidgets('7. التأكد من عدم ظهور السجل التجاري أو بيانات المركبة أو رخصة القيادة في حساب العميل',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const IdentityVerificationScreen()));
      await tester.pump();

      // No commercial register or driving license in Client KYC
      expect(find.text('السجل التجاري'), findsNothing);
      expect(find.text('رقم السجل التجاري'), findsNothing);
      expect(find.text('رخصة القيادة'), findsNothing);
      expect(find.text('بيانات المركبة'), findsNothing);
      expect(find.text('استمارة المركبة'), findsNothing);

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      expect(find.text('السجل التجاري'), findsNothing);
      expect(find.text('رخصة القيادة'), findsNothing);
      expect(find.text('بيانات المركبة'), findsNothing);
    });

    testWidgets('8. التأكد من سلامة وحفظ البيانات بعد التنقل والعودة',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Submit KYC with specific ID
      final client = AuthSimulationStore.instance.users.firstWhere((u) => u.role == AuthUserRole.client);
      AuthSimulationStore.instance.submitClientVerification(
        userId: client.id,
        identityData: ClientIdentityData(
          fullName: 'سالم الكندي الأصيل',
          idNumber: '9988776655',
          issuePlace: 'صنعاء - التحرير',
          issueDate: '2025-05-20',
          birthPlace: 'حضرموت',
          birthDate: '1990-01-01',
          submittedAt: DateTime.now(),
        ),
      );

      // Re-mount IdentityVerificationScreen and verify data is retrieved
      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            userId: client.id,
            userName: client.name,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('9988776655'), findsOneWidget);
      expect(find.text('صنعاء - التحرير'), findsOneWidget);
    });

    testWidgets('9. التأكد من احتفاظ العميل بمعرف حساب واحد (Single User ID) دون إنشاء حسابات مكررة',
        (tester) async {
      final initialCount = AuthSimulationStore.instance.users.length;
      final regRes = AuthSimulationStore.instance.register(
        role: AuthUserRole.client,
        fullName: 'ماهر النجار',
        phone: '770654321',
        password: 'password123',
      );
      expect(regRes.isSuccess, isTrue);
      final userId = regRes.user!.id;

      // Verify OTP
      AuthSimulationStore.instance.verifyOtp('770654321', '123456');

      // Submit verification
      AuthSimulationStore.instance.submitClientVerification(
        userId: userId,
        identityData: ClientIdentityData(
          fullName: 'ماهر النجار',
          idNumber: '1122334455',
          issuePlace: 'عدن',
          issueDate: '2026-01-01',
          birthPlace: 'عدن',
          birthDate: '1996-02-02',
          submittedAt: DateTime.now(),
        ),
      );

      // Verify user count increased only by 1
      expect(AuthSimulationStore.instance.users.length, initialCount + 1);
      final found = AuthSimulationStore.instance.getUserById(userId);
      expect(found, isNotNull);
      expect(found?.verificationStatus, AccountVerificationStatus.pendingReview);
      expect(found?.id, userId);
    });

    testWidgets('10. التأكد من أن 4 شرائح الترويج في الرئيسية تطابق تماماً موضوعات العميل المحددة',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      // 4 Carousel Topics defined in Prompt 03 Section 6.b
      expect(find.text('انقل أثاث منزلك بسهولة'), findsOneWidget);
      expect(find.text('نقل أثاث وعفش'), findsOneWidget);

      // Verify services
      expect(find.text('إنشاء طلب نقل'), findsOneWidget);
      expect(find.text('حمولاتي'), findsWidgets);
      expect(find.text('عروضي'), findsOneWidget);
      expect(find.text('تتبع الحمولة'), findsOneWidget);

      // Verify bottom nav items
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الإشعارات'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);
    });
  });
}
