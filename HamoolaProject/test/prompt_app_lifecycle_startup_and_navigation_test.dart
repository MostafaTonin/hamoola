import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application/core/router/app_router.dart';
import 'package:flutter_application/core/storage/app_preferences.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/otp_verify_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/identity_verification_screen.dart';
import 'package:flutter_application/features/client/presentation/screens/client_home_screen.dart';
import 'package:flutter_application/features/onboarding/presentation/screens/onboarding_1_screen.dart';
import 'package:flutter_application/features/onboarding/presentation/screens/onboarding_3_screen.dart';
import 'package:flutter_application/features/onboarding/presentation/screens/splash_screen.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.instance.init();
    await AppPreferences.instance.resetForTesting();
    AuthSimulationStore.instance.resetToInitialState();
  });

  Widget wrapRouterApp(GoRouter router) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      routerConfig: router,
    );
  }

  group('1. App Startup & Onboarding First-Time vs Subsequent Runs', () {
    testWidgets('1. Fresh install starts at Splash and navigates to Onboarding1', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      expect(AppPreferences.instance.isOnboardingCompleted, isFalse);
      final router = createAppRouter(initialLocation: AppRoutes.splash);

      await tester.pumpWidget(wrapRouterApp(router));
      // Initially displays SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Fast timer (800ms) completes and navigates to Onboarding1
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(Onboarding1Screen), findsOneWidget);
    });

    testWidgets('2. Completing Onboarding3 sets onboardingCompleted and lands on LoginScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = createAppRouter(initialLocation: AppRoutes.onboarding3);
      await tester.pumpWidget(wrapRouterApp(router));
      await tester.pumpAndSettle();

      expect(find.byType(Onboarding3Screen), findsOneWidget);

      // Tap "ابدأ الآن" button
      final startBtn = find.text('ابدأ الآن');
      expect(startBtn, findsOneWidget);
      await tester.tap(startBtn);
      await tester.pumpAndSettle();

      // Onboarding state is saved
      expect(AppPreferences.instance.isOnboardingCompleted, isTrue);
      // Lands on LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('3. Skipping Onboarding sets onboardingCompleted and lands on LoginScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = createAppRouter(initialLocation: AppRoutes.onboarding1);
      await tester.pumpWidget(wrapRouterApp(router));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap "تخطي" button
      final skipBtn = find.text('تخطي');
      expect(skipBtn, findsOneWidget);
      await tester.tap(skipBtn);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(AppPreferences.instance.isOnboardingCompleted, isTrue);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('4. Subsequent app launch directly opens LoginScreen without Splash or Onboarding', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // User already completed onboarding in previous session
      await AppPreferences.instance.setOnboardingCompleted(true);
      expect(AppPreferences.instance.isOnboardingCompleted, isTrue);

      // Initial route resolves to LoginScreen directly
      final initialRoute = AppPreferences.instance.resolveInitialRoute();
      expect(initialRoute, equals(AppRoutes.login));

      final router = createAppRouter();
      await tester.pumpWidget(wrapRouterApp(router));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(Onboarding1Screen), findsNothing);
    });

    testWidgets('5. Attempting to visit Splash or Onboarding redirects returning user to LoginScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await AppPreferences.instance.setOnboardingCompleted(true);
      final router = createAppRouter(initialLocation: AppRoutes.splash);

      await tester.pumpWidget(wrapRouterApp(router));
      await tester.pumpAndSettle();

      // Redirect guard immediately redirected from splash to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });
  });

  group('2. User Session Restoration and Persistence', () {
    testWidgets('6. Returning user with active session directly opens their respective Home Screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await AppPreferences.instance.setOnboardingCompleted(true);

      // Client Mustafa logs in
      final mustafa = AuthSimulationStore.instance.getUserById('USR-CLIENT-01');
      expect(mustafa, isNotNull);
      AuthSimulationStore.instance.setCurrentUser(mustafa);

      expect(AppPreferences.instance.activeUserId, equals('USR-CLIENT-01'));

      final initialRoute = AppPreferences.instance.resolveInitialRoute();
      expect(initialRoute, equals(AppRoutes.clientHome));

      final router = createAppRouter();
      await tester.pumpWidget(wrapRouterApp(router));
      await tester.pumpAndSettle();

      expect(find.byType(ClientHomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('7. Logging out clears session but retains onboardingCompleted = true', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await AppPreferences.instance.setOnboardingCompleted(true);
      final mustafa = AuthSimulationStore.instance.getUserById('USR-CLIENT-01');
      AuthSimulationStore.instance.setCurrentUser(mustafa);

      // Perform logout
      AuthSimulationStore.instance.logout();

      // Active user cleared, but onboarding stays completed!
      expect(AuthSimulationStore.instance.currentUser, isNull);
      expect(AppPreferences.instance.activeUserId, isNull);
      expect(AppPreferences.instance.isOnboardingCompleted, isTrue);

      // Next app open opens LoginScreen directly, never Onboarding
      expect(AppPreferences.instance.resolveInitialRoute(), equals(AppRoutes.login));
    });
  });

  group('3. Back Navigation & Stack Integrity', () {
    testWidgets('8. Back navigation from RegisterScreen returns to LoginScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await AppPreferences.instance.setOnboardingCompleted(true);
      final router = createAppRouter(initialLocation: AppRoutes.login);
      await tester.pumpWidget(wrapRouterApp(router));
      await tester.pumpAndSettle();

      // Push RegisterScreen
      router.push(AppRoutes.register);
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Tap back button
      final backBtn = find.byTooltip('رجوع');
      expect(backBtn, findsOneWidget);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      // Successfully back on LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('9. Back navigation from OtpVerifyScreen returns to RegisterScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await AppPreferences.instance.setOnboardingCompleted(true);
      final router = createAppRouter(initialLocation: AppRoutes.register);
      await tester.pumpWidget(wrapRouterApp(router));
      await tester.pumpAndSettle();

      // Push OtpVerifyScreen
      router.push(AppRoutes.otpVerify, extra: {'phone': '777123456', 'role': 'عميل'});
      await tester.pumpAndSettle();
      expect(find.byType(OtpVerifyScreen), findsOneWidget);

      // Tap AppBar back
      final backBtn = find.byType(IconButton).first;
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('10. Back navigation from IdentityVerificationScreen returns to previous screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await AppPreferences.instance.setOnboardingCompleted(true);
      final router = createAppRouter(initialLocation: AppRoutes.login);
      await tester.pumpWidget(wrapRouterApp(router));
      await tester.pumpAndSettle();

      // Push KYC
      router.push(AppRoutes.identityVerification, extra: {'phone': '777123456', 'role': 'عميل'});
      await tester.pumpAndSettle();
      expect(find.byType(IdentityVerificationScreen), findsOneWidget);

      // Tap AppBar back icon
      final backBtn = find.byIcon(Icons.arrow_forward_ios_rounded).first;
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('4. App Lifecycle & State Preservation', () {
    testWidgets('11. App retains form inputs and current screen when transitioning to background and back', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await AppPreferences.instance.setOnboardingCompleted(true);
      final router = createAppRouter(initialLocation: AppRoutes.register);
      await tester.pumpWidget(wrapRouterApp(router));
      await tester.pumpAndSettle();

      // Edit name field (first TextFormField on RegisterScreen)
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'محمد صالح الصبري');
      await tester.pumpAndSettle();

      // Simulate App moving to background (Home button or switching apps)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      // Simulate App returning to foreground
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // RegisterScreen remains active and input text is preserved!
      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('محمد صالح الصبري'), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(Onboarding1Screen), findsNothing);
    });
  });
}
