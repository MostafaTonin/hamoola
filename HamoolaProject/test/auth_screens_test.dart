import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/presentation/screens/journey_start_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/register_screen.dart';

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

  group('JourneyStartScreen Tests', () {
    testWidgets('renders title, badge, login and register buttons, handles taps',
        (tester) async {
      bool loginTapped = false;
      bool registerTapped = false;
      bool skipTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          JourneyStartScreen(
            onLogin: () => loginTapped = true,
            onRegister: () => registerTapped = true,
            onSkip: () => skipTapped = true,
          ),
        ),
      );

      await tester.pump();

      expect(find.text(AppStrings.journeyStartTitle), findsOneWidget);
      expect(find.text(AppStrings.journeyStartBadge), findsOneWidget);
      expect(find.text(AppStrings.login), findsOneWidget);
      expect(find.text(AppStrings.createAccount), findsOneWidget);
      expect(find.text(AppStrings.skip), findsOneWidget);

      await tester.tap(find.text(AppStrings.login));
      expect(loginTapped, isTrue);

      await tester.tap(find.text(AppStrings.createAccount));
      expect(registerTapped, isTrue);

      await tester.tap(find.text(AppStrings.skip));
      expect(skipTapped, isTrue);
    });
  });

  group('LoginScreen Tests', () {
    testWidgets('renders fields, validates empty inputs, selects role, and submits valid form',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool loginSubmitted = false;
      String? submittedRole;
      String? submittedPhone;
      bool registerTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          LoginScreen(
            onRegister: () => registerTapped = true,
            onSubmitLogin: (role, phone, pass, offline) {
              loginSubmitted = true;
              submittedRole = role;
              submittedPhone = phone;
            },
          ),
        ),
      );

      await tester.pump();

      expect(find.text(AppStrings.login), findsWidgets);
      expect(find.text('+967'), findsOneWidget);
      expect(find.text('تسجيل الدخول بالبصمة'), findsOneWidget);
      expect(find.text('دخول بدون نت'), findsOneWidget);
      expect(find.text('عميل'), findsOneWidget);
      expect(find.text('سائق'), findsOneWidget);
      expect(find.text('تاجر'), findsOneWidget);
      expect(find.text('مكتب نقل'), findsOneWidget);

      // Tap submit with empty fields -> shows validation errors
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.login));
      await tester.pump();

      expect(find.text(AppStrings.phoneRequiredError), findsOneWidget);
      expect(find.text(AppStrings.passwordRequiredError), findsOneWidget);
      expect(loginSubmitted, isFalse);

      // Select 'تاجر' role
      await tester.tap(find.text('تاجر'));
      await tester.pump();

      // Enter invalid short phone
      final phoneFinder = find.byType(TextFormField).first;
      final passFinder = find.byType(TextFormField).last;

      await tester.enterText(phoneFinder, '77123');
      await tester.enterText(passFinder, '123456');
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.login));
      await tester.pump();

      expect(find.text(AppStrings.phoneInvalidError), findsOneWidget);

      // Enter valid 9-digit phone
      await tester.enterText(phoneFinder, '771234567');
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.login));
      await tester.pump(const Duration(milliseconds: 350));

      expect(loginSubmitted, isTrue);
      expect(submittedRole, 'تاجر');
      expect(submittedPhone, '771234567');

      // Tap create account link
      await tester.tap(find.text('إنشاء حساب'));
      expect(registerTapped, isTrue);
    });
  });

  group('RegisterScreen Tests', () {
    testWidgets('renders role cards, validates inputs & terms, and submits registration',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      HamulaUserRole? registeredRole;
      String? registeredName;

      await tester.pumpWidget(
        wrapWidget(
          RegisterScreen(
            onSubmitRegister: (role, name, phone, pass) {
              registeredRole = role;
              registeredName = name;
            },
          ),
        ),
      );

      await tester.pump();

      expect(find.text(AppStrings.register), findsOneWidget);
      expect(find.text(AppStrings.roleMerchant), findsOneWidget);
      expect(find.text(AppStrings.roleDriver), findsOneWidget);
      expect(find.text(AppStrings.roleOffice), findsOneWidget);

      // Switch to Driver role
      await tester.tap(find.text(AppStrings.roleDriver));
      await tester.pump();

      final submitFinder = find.widgetWithText(ElevatedButton, AppStrings.registerSubmit);
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pump();

      expect(find.text(AppStrings.nameRequiredError), findsOneWidget);
      expect(find.text(AppStrings.phoneRequiredError), findsOneWidget);
      expect(find.text(AppStrings.passwordRequiredError), findsNWidgets(2));
      expect(find.text(AppStrings.termsRequiredError), findsOneWidget);

      // Fill in valid data
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'علي عبدالله');
      await tester.enterText(fields.at(1), '772223344');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      // Check terms box
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Submit
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pump();

      expect(registeredRole, HamulaUserRole.driver);
      expect(registeredName, 'علي عبدالله');
    });
  });
}

