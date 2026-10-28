import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/otp_verify_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthSimulationStore.instance.resetToDemo();
  });

  Widget wrapWidget(Widget child, {Size size = const Size(1080, 2400)}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    );
  }

  group('Prompt 01 - Auth Simulation & Store Tests', () {
    test('1. تسجيل الدخول بحساب عميل صحيح', () {
      final res = AuthSimulationStore.instance.login(
        role: 'عميل',
        phone: '770123456',
        password: 'password123',
      );
      expect(res.isSuccess, isTrue);
      expect(res.user?.role, AuthUserRole.client);
      expect(res.user?.verificationStatus, AccountVerificationStatus.unverified);
    });

    test('2. تسجيل الدخول بحساب سائق صحيح', () {
      final res = AuthSimulationStore.instance.login(
        role: 'سائق',
        phone: '772345678',
        password: 'password123',
      );
      expect(res.isSuccess, isTrue);
      expect(res.user?.role, AuthUserRole.driver);
    });

    test('3. تسجيل الدخول بحساب تاجر صحيح', () {
      final res = AuthSimulationStore.instance.login(
        role: 'تاجر',
        phone: '771234567',
        password: 'password123',
      );
      expect(res.isSuccess, isTrue);
      expect(res.user?.role, AuthUserRole.merchant);
    });

    test('4. تسجيل الدخول بحساب مكتب نقل صحيح', () {
      final res = AuthSimulationStore.instance.login(
        role: 'مكتب نقل',
        phone: '774567890',
        password: 'password123',
      );
      expect(res.isSuccess, isTrue);
      expect(res.user?.role, AuthUserRole.office);
    });

    test('5. محاولة تسجيل الدخول بنوع حساب لا يطابق الحساب (role mismatch)', () {
      // Trying to log into Client account (770123456) using 'تاجر' role
      final res = AuthSimulationStore.instance.login(
        role: 'تاجر',
        phone: '770123456',
        password: 'password123',
      );
      expect(res.isSuccess, isFalse);
      expect(res.errorMessage, contains('لا يتطابق'));
    });

    test('6. محاولة تسجيل الدخول ببيانات خاطئة', () {
      // Wrong password
      final wrongPass = AuthSimulationStore.instance.login(
        role: 'عميل',
        phone: '770123456',
        password: 'wrong_password_999',
      );
      expect(wrongPass.isSuccess, isFalse);
      expect(wrongPass.errorMessage, contains('كلمة المرور غير صحيحة'));

      // Non-existent phone
      final nonExistent = AuthSimulationStore.instance.login(
        role: 'عميل',
        phone: '779999999',
        password: 'password123',
      );
      expect(nonExistent.isSuccess, isFalse);
      expect(nonExistent.errorMessage, contains('لا يوجد حساب'));
    });

    test('9 & 10. إنشاء حساب عميل وسائق وتاجر ومكتب نقل وتأكيد حالة unverified', () {
      // Client
      final clientRes = AuthSimulationStore.instance.register(
        role: AuthUserRole.client,
        fullName: 'ماجد أحمد العمري',
        phone: '770999001',
        password: 'password123',
      );
      expect(clientRes.isSuccess, isTrue);
      expect(clientRes.user?.role, AuthUserRole.client);
      expect(clientRes.user?.verificationStatus, AccountVerificationStatus.unverified);
      expect(clientRes.user?.isPhoneVerified, isFalse);

      // Driver
      final driverRes = AuthSimulationStore.instance.register(
        role: AuthUserRole.driver,
        fullName: 'طارق السائق',
        phone: '770999002',
        password: 'password123',
      );
      expect(driverRes.isSuccess, isTrue);
      expect(driverRes.user?.verificationStatus, AccountVerificationStatus.unverified);

      // Merchant
      final merchantRes = AuthSimulationStore.instance.register(
        role: AuthUserRole.merchant,
        fullName: 'شركة النور',
        phone: '770999003',
        password: 'password123',
      );
      expect(merchantRes.isSuccess, isTrue);
      expect(merchantRes.user?.verificationStatus, AccountVerificationStatus.unverified);

      // Office
      final officeRes = AuthSimulationStore.instance.register(
        role: AuthUserRole.office,
        fullName: 'مكتب الأمل للنقل',
        phone: '770999004',
        password: 'password123',
      );
      expect(officeRes.isSuccess, isTrue);
      expect(officeRes.user?.verificationStatus, AccountVerificationStatus.unverified);
    });

    test('12. منع تكرار التسجيل بنفس رقم الهاتف', () {
      // 770123456 is already a registered demo user
      expect(AuthSimulationStore.instance.isPhoneRegistered('770123456'), isTrue);

      final dupRes = AuthSimulationStore.instance.register(
        role: AuthUserRole.client,
        fullName: 'مستخدم مكرر',
        phone: '770123456',
        password: 'password123',
      );
      expect(dupRes.isSuccess, isFalse);
      expect(dupRes.errorMessage, contains('مسجل بالفعل'));
    });

    test('14 & 15. التحقق من رقم الهاتف عبر OTP لا يغيّر حالة التوثيق إلى verified', () {
      // Register new user
      final regRes = AuthSimulationStore.instance.register(
        role: AuthUserRole.client,
        fullName: 'سمير خلدون',
        phone: '770888999',
        password: 'password123',
      );
      expect(regRes.isSuccess, isTrue);

      // Verify OTP
      final verified = AuthSimulationStore.instance.verifyOtp('770888999', '123456');
      expect(verified, isTrue);

      final user = AuthSimulationStore.instance.getUserByPhone('770888999');
      expect(user?.isPhoneVerified, isTrue);
      // Strict requirement: KYC status remains unverified!
      expect(user?.verificationStatus, AccountVerificationStatus.unverified);
    });
  });

  group('Prompt 01 - LoginScreen UI & Behavioral Tests', () {
    testWidgets('7 & 16. LoginScreen renders Hamula branding, 4 roles, and shortcuts', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool tollFreeTapped = false;
      bool servicePointsTapped = false;
      bool customerSupportTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          LoginScreen(
            onTollFree: () => tollFreeTapped = true,
            onServicePoints: () => servicePointsTapped = true,
            onCustomerSupport: () => customerSupportTapped = true,
          ),
        ),
      );
      await tester.pump();

      // Brand Header
      expect(find.text('حمولة'), findsOneWidget);
      expect(find.text('HAMULA'), findsOneWidget);
      expect(find.text('مرحباً بعودتك'), findsOneWidget);

      // Demo accounts quick chip
      expect(find.text('حسابات تجريبية'), findsOneWidget);

      // 4 Roles
      expect(find.text('عميل'), findsOneWidget);
      expect(find.text('سائق'), findsOneWidget);
      expect(find.text('تاجر'), findsOneWidget);
      expect(find.text('مكتب نقل'), findsOneWidget);

      // Shortcuts
      expect(find.text('الرقم المجاني'), findsOneWidget);
      expect(find.text('نقاط الخدمة'), findsOneWidget);
      expect(find.text('خدمة العملاء'), findsOneWidget);

      await tester.ensureVisible(find.text('الرقم المجاني'));
      await tester.tap(find.text('الرقم المجاني'));
      expect(tollFreeTapped, isTrue);

      await tester.ensureVisible(find.text('نقاط الخدمة'));
      await tester.tap(find.text('نقاط الخدمة'));
      expect(servicePointsTapped, isTrue);

      await tester.ensureVisible(find.text('خدمة العملاء'));
      await tester.tap(find.text('خدمة العملاء'));
      expect(customerSupportTapped, isTrue);
    });

    testWidgets('5. Login role mismatch shows inline error message', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool loginSubmitted = false;

      await tester.pumpWidget(
        wrapWidget(
          LoginScreen(
            onSubmitLogin: (r, p, pass, off) => loginSubmitted = true,
          ),
        ),
      );
      await tester.pump();

      // Select 'عميل' role by default. Enter Driver's phone 772345678
      final phoneFinder = find.byType(TextFormField).first;
      final passFinder = find.byType(TextFormField).last;

      await tester.enterText(phoneFinder, '772345678');
      await tester.enterText(passFinder, 'password123');

      final submitBtn = find.widgetWithText(ElevatedButton, 'تسجيل الدخول');
      await tester.tap(submitBtn);
      await tester.pump(const Duration(milliseconds: 250));

      expect(loginSubmitted, isFalse);
      // Error is displayed
      expect(find.textContaining('لا يتطابق'), findsWidgets);
    });
  });

  group('Prompt 01 - RegisterScreen UI & Behavioral Tests', () {
    testWidgets('7 & 8. RegisterScreen displays Hamula brand logo, welcome subtitle, and all 4 roles including عميل', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const RegisterScreen()));
      await tester.pump();

      // Brand Logo & Welcome
      expect(find.text('حمولة'), findsOneWidget);
      expect(find.text('HAMULA'), findsOneWidget);
      expect(find.text('إنشاء حساب جديد'), findsOneWidget);
      expect(find.text('انضم إلى مجتمع حمولة للنقل'), findsOneWidget);

      // All 4 Roles
      expect(find.text('عميل'), findsOneWidget);
      expect(find.text('سائق'), findsOneWidget);
      expect(find.text('تاجر'), findsOneWidget);
      expect(find.text('مكتب نقل'), findsOneWidget);
    });

    testWidgets('11. RegisterScreen validates missing fields, mismatched passwords, and terms', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool submitted = false;

      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (r, n, p, pass) => submitted = true,
          ),
        ),
      );
      await tester.pump();

      final fields = find.byType(TextFormField);
      for (int i = 0; i < 4; i++) {
        await tester.enterText(fields.at(i), '');
      }
      await tester.pump();

      final submitBtn = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(submitted, isFalse);
      expect(find.text(AppStrings.nameRequiredError), findsOneWidget);
      expect(find.text(AppStrings.phoneRequiredError), findsOneWidget);
      expect(find.text(AppStrings.passwordRequiredError), findsNWidgets(2));
      expect(find.text(AppStrings.termsRequiredError), findsOneWidget);

      // Fill in mismatched passwords
      await tester.enterText(fields.at(0), 'خالد مسعود');
      await tester.enterText(fields.at(1), '778899001');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'mismatch456');

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text(AppStrings.passwordMismatchError), findsOneWidget);
      expect(submitted, isFalse);
    });

    testWidgets('9 & 12. RegisterScreen creates client account and rejects duplicate phone', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      HamulaUserRole? regRole;
      String? regPhone;

      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (role, name, phone, pass) {
              regRole = role;
              regPhone = phone;
            },
          ),
        ),
      );
      await tester.pump();

      // Ensure 'عميل' is selected
      await tester.tap(find.text('عميل'));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'سامي باوزير');
      // Use existing demo phone (770123456) to test duplicate prevention
      await tester.enterText(fields.at(1), '770123456');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      // Agree to terms
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final submitBtn = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      // Duplicate blocked
      expect(find.textContaining('مسجل مسبقاً'), findsWidgets);
      expect(regRole, isNull);

      // Now enter fresh phone
      await tester.enterText(fields.at(1), '779911223');
      await tester.tap(submitBtn);
      await tester.pump();

      expect(regRole, HamulaUserRole.client);
      expect(regPhone, '779911223');

      // Verify stored in simulation store
      final savedUser = AuthSimulationStore.instance.getUserByPhone('779911223');
      expect(savedUser, isNotNull);
      expect(savedUser?.name, 'سامي باوزير');
      expect(savedUser?.verificationStatus, AccountVerificationStatus.unverified);
    });
  });

  group('Prompt 01 - OtpVerifyScreen Tests', () {
    testWidgets('13 & 14. OtpVerifyScreen displays phone and role, and verifies successfully', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool verifiedCalled = false;

      await tester.pumpWidget(
        wrapWidget(
          OtpVerifyScreen(
            phoneNumber: '779911223',
            userRole: 'عميل',
            userName: 'سامي باوزير',
            onVerified: () => verifiedCalled = true,
          ),
        ),
      );
      await tester.pump();

      // Displays masked phone and role
      expect(find.textContaining('***'), findsOneWidget);
      expect(find.text('نوع الحساب: عميل'), findsOneWidget);

      // Enter 6 OTP digits ('123456')
      const code = '123456';
      final textFields = find.byType(TextField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), code[i]);
      }
      await tester.pump(const Duration(milliseconds: 700));

      expect(verifiedCalled, isTrue);
    });

    testWidgets('17. Small device responsiveness: renders without overflow', (tester) async {
      // Small screen: 360 x 640 dp
      tester.view.physicalSize = const Size(360 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const LoginScreen()));
      await tester.pump();

      expect(find.text('حمولة'), findsOneWidget);
      expect(find.text('تسجيل الدخول'), findsWidgets);

      await tester.pumpWidget(wrapWidget(const RegisterScreen()));
      await tester.pump();

      expect(find.text('إنشاء حساب جديد'), findsOneWidget);
      expect(find.text(AppStrings.registerSubmit), findsOneWidget);
    });
  });
}
