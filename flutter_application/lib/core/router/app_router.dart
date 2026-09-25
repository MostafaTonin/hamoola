import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/screens/onboarding_1_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_2_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_3_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';

/// Semantic Route Names & Paths for Hamoola
abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding1 = '/onboarding/1';
  static const String onboarding2 = '/onboarding/2';
  static const String onboarding3 = '/onboarding/3';
  static const String journeyStart = '/auth/journey-start';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String otpVerify = '/auth/otp-verify';
  static const String merchantHome = '/merchant/home';
  static const String merchantCargos = '/merchant/cargos';
  static const String merchantCreateCargo = '/merchant/create-cargo';
  static const String merchantMap = '/merchant/map';
}

/// Central AppRouter Configuration
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding1,
      builder: (context, state) => Onboarding1Screen(
        onNext: () => context.go(AppRoutes.onboarding2),
        onSkip: () => context.go(AppRoutes.journeyStart),
      ),
    ),
    GoRoute(
      path: AppRoutes.onboarding2,
      builder: (context, state) => Onboarding2Screen(
        onNext: () => context.go(AppRoutes.onboarding3),
        onSkip: () => context.go(AppRoutes.journeyStart),
      ),
    ),
    GoRoute(
      path: AppRoutes.onboarding3,
      builder: (context, state) => Onboarding3Screen(
        onStartNow: () => context.go(AppRoutes.journeyStart),
        onSkip: () => context.go(AppRoutes.journeyStart),
      ),
    ),
  ],
);
