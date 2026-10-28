import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/register_screen.dart';

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
        child: MediaQuery(
          data: MediaQueryData(size: size),
          child: child,
        ),
      ),
    );
  }

  group('Prompt 01: Client Login and Registration Flow Tests', () {
    // -------------------------------------------------------------------------
    // 1. فتح شاشة تسجيل الدخول والتأكد من تعبئة بيانات العميل التجريبي
    // -------------------------------------------------------------------------
    testWidgets('1. Login screen opens with client demo data pre-filled', (tester) async {
      await tester.pumpWidget(wrapWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Check pre-filled phone number
      expect(find.text('777123456'), findsOneWidget);

      // Check pre-filled password
      final passwordFinder = find.byWidgetPredicate(
        (w) => w is EditableText && w.controller.text == 'Hamula@123',
      );
      expect(passwordFinder, findsOneWidget);

      // Check country code indicator
      expect(find.text('+967'), findsOneWidget);

      // Check role selection indicator has 'عميل'
      expect(find.text('عميل'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 2. تسجيل الدخول بالحساب التجريبي والانتقال إلى المسار الصحيح
    // -------------------------------------------------------------------------
    testWidgets('2. Logging in with client demo credentials succeeds and returns client role', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? submittedRole;
      String? submittedPhone;
      String? submittedPassword;

      await tester.pumpWidget(
        wrapWidget(
          LoginScreen(
            onSubmitLogin: (role, phone, password, isOffline) {
              submittedRole = role;
              submittedPhone = phone;
              submittedPassword = password;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap primary "تسجيل الدخول" button
      final loginBtn = find.widgetWithText(ElevatedButton, 'تسجيل الدخول');
      expect(loginBtn, findsOneWidget);
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(submittedRole, equals('عميل'));
      expect(submittedPhone, equals('777123456'));
      expect(submittedPassword, equals('Hamula@123'));

      // Verify currentUser in AuthSimulationStore
      final currentUser = AuthSimulationStore.instance.currentUser;
      expect(currentUser, isNotNull);
      expect(currentUser!.role, equals(AuthUserRole.client));
      expect(currentUser.name, equals('مصطفى صالح طنين'));
      expect(currentUser.displayName, equals('مصطفى'));
      expect(currentUser.accountType, equals('شخصي'));
    });

    // -------------------------------------------------------------------------
    // 3. تغيير كلمة المرور إلى قيمة خاطئة والتأكد من رفض الدخول
    // -------------------------------------------------------------------------
    testWidgets('3. Changing password to incorrect value rejects login and keeps fields', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool loginTriggered = false;

      await tester.pumpWidget(
        wrapWidget(
          LoginScreen(
            onSubmitLogin: (r, p, pw, off) => loginTriggered = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find password field and enter wrong password
      final passwordField = find.widgetWithText(TextFormField, 'أدخل كلمة المرور');
      await tester.enterText(passwordField, 'WrongPass@999');
      await tester.pumpAndSettle();

      // Tap login
      final loginBtn = find.widgetWithText(ElevatedButton, 'تسجيل الدخول');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Login callback should NOT be called
      expect(loginTriggered, isFalse);

      // Error message should be visible
      expect(find.textContaining('كلمة المرور غير صحيحة'), findsWidgets);

      // Fields should NOT be cleared
      expect(find.text('777123456'), findsOneWidget);
      expect(find.text('WrongPass@999'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 4. إظهار كلمة المرور وإخفائها
    // -------------------------------------------------------------------------
    testWidgets('4. Password visibility toggle works correctly', (tester) async {
      await tester.pumpWidget(wrapWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      // Verify initial obscureText state is true
      EditableText editable = tester.widget(
        find.byWidgetPredicate((w) => w is EditableText && w.controller.text == 'Hamula@123'),
      );
      expect(editable.obscureText, isTrue);

      // Find visibility toggle icon button
      final toggleBtn = find.byIcon(Icons.visibility_off_outlined);
      expect(toggleBtn, findsOneWidget);

      // Tap toggle to show password
      await tester.tap(toggleBtn);
      await tester.pumpAndSettle();

      editable = tester.widget(
        find.byWidgetPredicate((w) => w is EditableText && w.controller.text == 'Hamula@123'),
      );
      expect(editable.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap toggle again to hide password
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      editable = tester.widget(
        find.byWidgetPredicate((w) => w is EditableText && w.controller.text == 'Hamula@123'),
      );
      expect(editable.obscureText, isTrue);
    });

    // -------------------------------------------------------------------------
    // 5. فتح إنشاء الحساب والتأكد من تعبئة الحقول الافتراضية
    // -------------------------------------------------------------------------
    testWidgets('5. Register screen opens with client demo defaults pre-filled', (tester) async {
      await tester.pumpWidget(wrapWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Check full name pre-filled
      expect(find.text('مصطفى صالح طنين'), findsOneWidget);

      // Check phone pre-filled
      expect(find.text('777123456'), findsOneWidget);

      // Check password & confirm password pre-filled
      final passFinders = find.byWidgetPredicate(
        (w) => w is EditableText && w.controller.text == 'Hamula@123',
      );
      expect(passFinders, findsNWidgets(2));

      // Check country code
      expect(find.text('+967'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 6. التحقق من أن الموافقة على الشروط ليست محددة تلقائياً
    // -------------------------------------------------------------------------
    testWidgets('6. Terms and conditions checkbox is NOT checked by default', (tester) async {
      await tester.pumpWidget(wrapWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    // -------------------------------------------------------------------------
    // 7. تجربة إنشاء الحساب دون الموافقة على الشروط
    // -------------------------------------------------------------------------
    testWidgets('7. Submitting registration without agreeing to terms displays error', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool registerTriggered = false;

      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (r, n, p, pw) => registerTriggered = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap primary "إنشاء الحساب" button with checkbox unchecked
      final registerBtn = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      expect(registerBtn, findsOneWidget);
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      // Register callback must NOT be triggered
      expect(registerTriggered, isFalse);

      // Terms required error message must be shown
      expect(find.text(AppStrings.termsRequiredError), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 8. تجربة كلمتي مرور غير متطابقتين
    // -------------------------------------------------------------------------
    testWidgets('8. Submitting with mismatched passwords displays error', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool registerTriggered = false;

      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (r, n, p, pw) => registerTriggered = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Agree to terms
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Change confirm password field
      final confirmField = find.widgetWithText(TextFormField, AppStrings.confirmPasswordHint);
      await tester.enterText(confirmField, 'DifferentPass@123');
      await tester.pumpAndSettle();

      // Tap submit
      final registerBtn = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      expect(registerTriggered, isFalse);
      expect(find.text(AppStrings.passwordMismatchError), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 9. التأكد من منع إنشاء حساب مكرر
    // -------------------------------------------------------------------------
    testWidgets('9. Submitting with an already existing phone number prevents duplicate account', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool registerTriggered = false;

      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (r, n, p, pw) => registerTriggered = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Agree to terms (phone is 777123456 which is already registered in store)
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Tap submit
      final registerBtn = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      expect(registerTriggered, isFalse);
      expect(find.textContaining('رقم الهاتف مسجل بالفعل'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 10. التأكد من الانتقال إلى شاشة التحقق من الهاتف مع الاحتفاظ ببيانات الحساب
    // -------------------------------------------------------------------------
    testWidgets('10. Submitting valid new registration transitions to OTP with account data', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      HamulaUserRole? registeredRole;
      String? registeredName;
      String? registeredPhone;
      String? registeredPassword;

      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (role, name, phone, password) {
              registeredRole = role;
              registeredName = name;
              registeredPhone = phone;
              registeredPassword = password;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter a new unregistered phone number
      final phoneField = find.widgetWithText(TextFormField, 'أدخل رقم الهاتف');
      await tester.enterText(phoneField, '771998877');
      await tester.pumpAndSettle();

      // Agree to terms
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Tap submit
      final registerBtn = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      await tester.ensureVisible(registerBtn);
      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      expect(registeredRole, equals(HamulaUserRole.client));
      expect(registeredName, equals('مصطفى صالح طنين'));
      expect(registeredPhone, equals('771998877'));
      expect(registeredPassword, equals('Hamula@123'));

      // Verify pending user in AuthSimulationStore
      final pendingUser = AuthSimulationStore.instance.pendingRegistrationUser;
      expect(pendingUser, isNotNull);
      expect(pendingUser!.role, equals(AuthUserRole.client));
      expect(pendingUser.phone, equals('771998877'));
      expect(pendingUser.isPhoneVerified, isFalse);
      expect(pendingUser.verificationStatus, equals(AccountVerificationStatus.unverified));
    });

    // -------------------------------------------------------------------------
    // 11. التأكد من بقاء خيارات الأدوار الأخرى دون كسر
    // -------------------------------------------------------------------------
    testWidgets('11. Driver, merchant, and transport office roles remain functional', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. In LoginScreen, switching roles and logging in works
      String? loggedRole;
      await tester.pumpWidget(
        wrapWidget(
          LoginScreen(
            onSubmitLogin: (role, phone, pw, off) => loggedRole = role,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap driver role card
      await tester.tap(find.text('سائق').first);
      await tester.pumpAndSettle();

      // Enter driver demo phone & password
      final phoneField = find.widgetWithText(TextFormField, 'أدخل رقم الهاتف');
      await tester.enterText(phoneField, '772345678');
      final passField = find.widgetWithText(TextFormField, 'أدخل كلمة المرور');
      await tester.enterText(passField, 'password123');
      await tester.pumpAndSettle();

      // Login
      await tester.tap(find.widgetWithText(ElevatedButton, 'تسجيل الدخول'));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(loggedRole, equals('سائق'));

      // 2. In RegisterScreen, role selector allows switching between all 4 roles
      await tester.pumpWidget(wrapWidget(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('سائق'), findsWidgets);
      expect(find.text('تاجر'), findsWidgets);
      expect(find.text('مكتب نقل'), findsWidgets);
      expect(find.text('عميل'), findsWidgets);

      // Tap each role card without error
      await tester.tap(find.text('سائق').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('تاجر').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('مكتب نقل').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('عميل').first);
      await tester.pumpAndSettle();
      expect(find.text('مصطفى صالح طنين'), findsOneWidget);
    });
  });
}
