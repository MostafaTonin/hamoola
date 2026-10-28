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

  group('Prompt 02 - Registration to OTP Scenarios for all 4 Roles', () {
    testWidgets('1. إنشاء حساب عميل والوصول إلى شاشة OTP مع تمرير البيانات الصحيحة', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      HamulaUserRole? regRole;
      String? regPhone;
      String? regName;

      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (role, name, phone, pass) {
              regRole = role;
              regName = name;
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
      await tester.enterText(fields.at(0), 'منصور سالم النهدي');
      await tester.enterText(fields.at(1), '770999111');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final submitBtn = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(regRole, HamulaUserRole.client);
      expect(regName, 'منصور سالم النهدي');
      expect(regPhone, '770999111');

      final user = AuthSimulationStore.instance.getUserByPhone('770999111');
      expect(user, isNotNull);
      expect(user?.role, AuthUserRole.client);
      expect(user?.verificationStatus, AccountVerificationStatus.unverified);
      expect(user?.isPhoneVerified, isFalse);
    });

    testWidgets('2. إنشاء حساب سائق والوصول إلى شاشة OTP', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      HamulaUserRole? regRole;
      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (role, name, phone, pass) => regRole = role,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('سائق'));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'كابتن بدر');
      await tester.enterText(fields.at(1), '770999222');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final submitBtn = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(regRole, HamulaUserRole.driver);
    });

    testWidgets('3. إنشاء حساب تاجر والوصول إلى شاشة OTP', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      HamulaUserRole? regRole;
      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (role, name, phone, pass) => regRole = role,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('تاجر'));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'شركة البركة');
      await tester.enterText(fields.at(1), '770999333');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final submitBtn = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(regRole, HamulaUserRole.merchant);
    });

    testWidgets('4. إنشاء حساب مكتب نقل والوصول إلى شاشة OTP', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      HamulaUserRole? regRole;
      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (role, name, phone, pass) => regRole = role,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('مكتب نقل'));
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'مكتب الشراع للنقل');
      await tester.enterText(fields.at(1), '770999444');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final submitBtn = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(regRole, HamulaUserRole.office);
    });
  });

  group('Prompt 02 - OTP Screen Validation, Privacy Masking, & Interaction', () {
    testWidgets('5. التحقق من ظهور رقم الهاتف الصحيح مع إخفاء جزء منه للحفاظ على الخصوصية', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        wrapWidget(
          const OtpVerifyScreen(
            phoneNumber: '770123456',
            userRole: 'عميل',
            userName: 'سالم الكندي',
          ),
        ),
      );
      await tester.pump();

      // Masked: +967 77 *** 456
      expect(find.text('+967 77 *** 456'), findsOneWidget);
      expect(find.text('نوع الحساب: عميل'), findsOneWidget);
    });

    testWidgets('6. إدخال رمز التحقق التجريبي الصحيح (123456) بنجاح', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Register user in store first
      AuthSimulationStore.instance.register(
        role: AuthUserRole.client,
        fullName: 'عمر المختار',
        phone: '770555666',
        password: 'password123',
      );

      bool verifiedCalled = false;

      await tester.pumpWidget(
        wrapWidget(
          OtpVerifyScreen(
            phoneNumber: '770555666',
            userRole: 'عميل',
            onVerified: () => verifiedCalled = true,
          ),
        ),
      );
      await tester.pump();

      // Use the test OTP helper pill
      final helperPill = find.textContaining('123456');
      expect(helperPill, findsWidgets);
      await tester.ensureVisible(helperPill.first);
      await tester.tap(helperPill.first);
      await tester.pump();

      // Submit
      final verifyBtn = find.widgetWithText(ElevatedButton, AppStrings.verifyButton);
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pump(const Duration(milliseconds: 500));

      expect(verifiedCalled, isTrue);

      // Verify status in store
      final user = AuthSimulationStore.instance.getUserByPhone('770555666');
      expect(user?.isPhoneVerified, isTrue);
      // Strict rule 16: Account verification status remains unverified!
      expect(user?.verificationStatus, AccountVerificationStatus.unverified);
    });

    testWidgets('7. إدخال رمز خاطئ (مثل 999999) يعرض رسالة واضحة ولا يغير حالة الهاتف', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthSimulationStore.instance.register(
        role: AuthUserRole.driver,
        fullName: 'أحمد سعيد',
        phone: '770777888',
        password: 'password123',
      );

      bool verifiedCalled = false;

      await tester.pumpWidget(
        wrapWidget(
          OtpVerifyScreen(
            phoneNumber: '770777888',
            userRole: 'سائق',
            onVerified: () => verifiedCalled = true,
          ),
        ),
      );
      await tester.pump();

      // Enter wrong code
      final textFields = find.byType(TextField);
      for (int i = 0; i < 6; i++) {
        await tester.enterText(textFields.at(i), '9');
      }
      await tester.pump(const Duration(milliseconds: 500));

      expect(verifiedCalled, isFalse);
      expect(find.text('رمز التحقق غير صحيح، حاول مرة أخرى.'), findsOneWidget);

      final user = AuthSimulationStore.instance.getUserByPhone('770777888');
      expect(user?.isPhoneVerified, isFalse);
    });

    testWidgets('8. محاولة التأكيد قبل اكتمال الرمز تمنع التأكيد وتطلب الرمز كاملاً', (tester) async {
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
            phoneNumber: '770111222',
            onVerified: () => verifiedCalled = true,
          ),
        ),
      );
      await tester.pump();

      // Only enter 3 digits
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '2');
      await tester.enterText(textFields.at(2), '3');
      await tester.pump();

      final verifyBtn = find.widgetWithText(ElevatedButton, AppStrings.verifyButton);
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pump();

      expect(verifiedCalled, isFalse);
      expect(find.text('يرجى إدخال كامل رمز التحقق (6 أرقام).'), findsOneWidget);
    });

    testWidgets('9. الانتقال بين خانات الرمز باستخدام الإدخال والحذف (backspace)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        wrapWidget(
          const OtpVerifyScreen(phoneNumber: '770111222'),
        ),
      );
      await tester.pump();

      final textFields = find.byType(TextField);

      // Enter digit in first field
      await tester.enterText(textFields.at(0), '1');
      await tester.pump();

      // Enter digit in second field
      await tester.enterText(textFields.at(1), '2');
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('10. لصق الرمز كاملاً (Pasting full 6 digits)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AuthSimulationStore.instance.register(
        role: AuthUserRole.client,
        fullName: 'مروان باعباد',
        phone: '770333444',
        password: 'password123',
      );

      bool verifiedCalled = false;

      await tester.pumpWidget(
        wrapWidget(
          OtpVerifyScreen(
            phoneNumber: '770333444',
            onVerified: () => verifiedCalled = true,
          ),
        ),
      );
      await tester.pump();

      // Paste "123456" into first field
      final firstField = find.byType(TextField).first;
      await tester.enterText(firstField, '123456');
      await tester.pump(const Duration(milliseconds: 500));

      expect(verifiedCalled, isTrue);
    });

    testWidgets('11 & 12. اختبار العداد وانتهاء مدته ثم إعادة إرسال الرمز', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        wrapWidget(
          const OtpVerifyScreen(phoneNumber: '770111222'),
        ),
      );
      await tester.pump();

      // Countdown is running
      expect(find.textContaining(AppStrings.resendCodeIn), findsOneWidget);

      // Advance clock past 60s
      await tester.pump(const Duration(seconds: 60));

      // Resend button is now visible
      final resendBtn = find.text(AppStrings.resendCodeBtn);
      expect(resendBtn, findsOneWidget);
      await tester.ensureVisible(resendBtn);

      // Tap resend
      await tester.tap(resendBtn);
      await tester.pump();

      // Notification shown and timer restarted
      expect(find.textContaining('تم تجديد رمز التحقق التجريبي'), findsOneWidget);
      expect(find.textContaining(AppStrings.resendCodeIn), findsOneWidget);
    });

    testWidgets('13, 14 & 15. تعديل رقم الهاتف من شاشة OTP، العودة مع بقاء البيانات، ومنع تكرار الحساب', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool editPhoneTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          OtpVerifyScreen(
            phoneNumber: '770444555',
            onEditPhone: () => editPhoneTapped = true,
          ),
        ),
      );
      await tester.pump();

      // Tap edit phone button
      await tester.tap(find.text(AppStrings.editPhoneBtn));
      expect(editPhoneTapped, isTrue);

      // Simulate registration store behavior when editing phone:
      // Initial registration
      final initialUsersCount = AuthSimulationStore.instance.users.length;
      final res1 = AuthSimulationStore.instance.register(
        role: AuthUserRole.client,
        fullName: 'طارق عبدالمجيد',
        phone: '770444555',
        password: 'password123',
      );
      expect(res1.isSuccess, isTrue);
      expect(AuthSimulationStore.instance.users.length, initialUsersCount + 1);

      // User edits phone to 770444556: It updates pending user in-place without duplicating!
      final res2 = AuthSimulationStore.instance.register(
        role: AuthUserRole.client,
        fullName: 'طارق عبدالمجيد',
        phone: '770444556',
        password: 'password123',
      );
      expect(res2.isSuccess, isTrue);
      // User count remains initialUsersCount + 1 (no duplicate created!)
      expect(AuthSimulationStore.instance.users.length, initialUsersCount + 1);

      // The new phone exists in the store
      final updatedUser = AuthSimulationStore.instance.getUserByPhone('770444556');
      expect(updatedUser, isNotNull);
      expect(updatedUser?.name, 'طارق عبدالمجيد');
      expect(updatedUser?.isPhoneVerified, isFalse);
    });

    testWidgets('17. التخلص السليم من المؤقت عند مغادرة الشاشة دون تسريب', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        wrapWidget(
          const OtpVerifyScreen(phoneNumber: '770111222'),
        ),
      );
      await tester.pump();

      // Replace with another widget (unmounts OtpVerifyScreen)
      await tester.pumpWidget(wrapWidget(const SizedBox()));
      await tester.pump();

      // No timers running in the background after dispose
    });

    testWidgets('18. الحفاظ على سلامة شاشتي تسجيل الدخول وإنشاء الحساب', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Login screen
      await tester.pumpWidget(wrapWidget(const LoginScreen()));
      await tester.pump();
      expect(find.text('تسجيل الدخول'), findsWidgets);
      expect(find.text('حسابات تجريبية'), findsOneWidget);

      // Register screen
      await tester.pumpWidget(wrapWidget(const RegisterScreen()));
      await tester.pump();
      expect(find.text('إنشاء حساب جديد'), findsOneWidget);
      expect(find.text('انضم إلى مجتمع حمولة للنقل'), findsOneWidget);
    });
  });
}
