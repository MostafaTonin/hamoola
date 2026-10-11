import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/identity_verification_screen.dart';
import '../../features/auth/presentation/screens/journey_start_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/terms_screen.dart';
import '../../features/auth/presentation/widgets/biometric_modal_sheet.dart';
import '../../features/auth/presentation/widgets/toll_free_dialer_modal_sheet.dart';
import '../../features/common/presentation/screens/customer_support_screen.dart';
import '../../features/common/presentation/screens/notifications_screen.dart';
import '../../features/common/presentation/screens/service_points_screen.dart';
import '../../features/driver/presentation/screens/driver_home_screen.dart';
import '../../features/driver/presentation/screens/driver_license_verification_screen.dart';
import '../../features/driver/presentation/screens/driver_vehicle_verification_screen.dart';
import '../../features/merchant/presentation/screens/commercial_verification_screen.dart';
import '../../features/merchant/presentation/screens/driver_profile_screen.dart';
import '../../features/merchant/presentation/screens/merchant_account_screen.dart';
import '../../features/merchant/presentation/screens/merchant_add_balance_screen.dart';
import '../../features/merchant/presentation/screens/merchant_cargos_screen.dart';
import '../../features/merchant/presentation/screens/merchant_create_cargo_screen.dart';
import '../../features/merchant/presentation/screens/merchant_create_order_screen.dart';
import '../../features/merchant/presentation/screens/merchant_home_screen.dart';
import '../../features/merchant/presentation/screens/merchant_map_screen.dart';
import '../../features/merchant/presentation/screens/merchant_offers_review_screen.dart';
import '../../features/merchant/presentation/screens/merchant_trip_tracking_screen.dart';
import '../../features/merchant/presentation/screens/merchant_verification_screen.dart';
import '../../features/merchant/presentation/screens/merchant_wallet_screen.dart';
import '../../features/merchant/presentation/screens/select_office_screen.dart';
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
  static const String forgotPassword = '/auth/forgot-password';
  static const String terms = '/auth/terms';
  static const String servicePoints = '/services/points';
  static const String customerSupport = '/support';
  static const String notifications = '/notifications';
  static const String otpVerify = '/auth/otp-verify';
  static const String identityVerification = '/auth/identity-verify';
  static const String merchantCommercialVerification = '/merchant/commercial-verify';
  static const String driverLicenseVerification = '/driver/verify-license';
  static const String driverVehicleVerification = '/driver/verify-vehicle';
  static const String merchantHome = '/merchant/home';
  static const String merchantCargos = '/merchant/cargos';
  static const String merchantCreateCargo = '/merchant/create-cargo';
  static const String merchantCreateOrder = '/merchant/create-order';
  static const String merchantSelectOffice = '/merchant/select-office';
  static const String merchantDriverProfile = '/merchant/driver-profile';
  static const String merchantMap = '/merchant/map';
  static const String merchantTripTracking = '/merchant/trip-tracking';
  static const String merchantOffersReview = '/merchant/offers-review';
  static const String merchantAccount = '/merchant/account';
  static const String merchantVerification = '/merchant/verification';
  static const String merchantWallet = '/merchant/wallet';
  static const String merchantAddBalance = '/merchant/add-balance';
  static const String driverHome = '/driver/home';
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
    GoRoute(
      path: AppRoutes.journeyStart,
      builder: (context, state) => JourneyStartScreen(
        onLogin: () => context.go(AppRoutes.login),
        onRegister: () => context.go(AppRoutes.register),
        onSkip: () => context.go(AppRoutes.login),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => LoginScreen(
        onRegister: () => context.push(AppRoutes.register),
        onForgotPassword: () => context.push(AppRoutes.forgotPassword),
        onBiometricLogin: () {
          BiometricModalSheet.show(
            context,
            onSuccess: () {
              context.go(AppRoutes.merchantHome);
            },
          );
        },
        onTollFree: () {
          TollFreeDialerModalSheet.show(context);
        },
        onServicePoints: () => context.push(AppRoutes.servicePoints),
        onCustomerSupport: () => context.push(AppRoutes.customerSupport),
        onSubmitLogin: (role, phone, password, isOffline) {
          if (role == 'سائق') {
            context.go(AppRoutes.driverHome);
          } else {
            context.go(AppRoutes.merchantHome);
          }
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => RegisterScreen(
        onBack: () => context.pop(),
        onLogin: () => context.go(AppRoutes.login),
        onTerms: () => context.push(AppRoutes.terms),
        onSubmitRegister: (role, name, phone, password) {
          context.push(AppRoutes.otpVerify);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.otpVerify,
      builder: (context, state) => OtpVerifyScreen(
        onBack: () => context.pop(),
        onVerified: () => context.go(AppRoutes.identityVerification),
        onEditPhone: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.identityVerification,
      builder: (context, state) => IdentityVerificationScreen(
        onBack: () => context.pop(),
        onSkip: () => context.go(AppRoutes.merchantHome),
        onVerificationComplete: (isApproved) {
          context.go(AppRoutes.merchantHome);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantCommercialVerification,
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'تاجر';
        return CommercialVerificationScreen(
          role: role,
          onBack: () => context.pop(),
          onSkip: () => context.go(AppRoutes.merchantHome),
          onVerificationComplete: (isApproved) {
            context.go(AppRoutes.merchantHome);
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.driverLicenseVerification,
      builder: (context, state) => DriverLicenseVerificationScreen(
        onBack: () => context.pop(),
        onNext: () => context.push(AppRoutes.driverVehicleVerification),
        onSkip: () => context.go(AppRoutes.driverHome),
      ),
    ),
    GoRoute(
      path: AppRoutes.driverVehicleVerification,
      builder: (context, state) => DriverVehicleVerificationScreen(
        onBack: () => context.pop(),
        onSkip: () => context.go(AppRoutes.driverHome),
        onVerificationComplete: (isApproved) {
          context.go(AppRoutes.driverHome);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => ForgotPasswordScreen(
        onBackToLogin: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.terms,
      builder: (context, state) => TermsScreen(
        onBack: () => context.pop(),
        onAccept: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.servicePoints,
      builder: (context, state) => ServicePointsScreen(
        onBack: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.customerSupport,
      builder: (context, state) => CustomerSupportScreen(
        onBack: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => NotificationsScreen(
        onBack: () => context.pop(),
        onNotificationTap: (item) {
          if (item.targetRoute != null) {
            if (item.routeArgument != null) {
              context.push('${item.targetRoute}?orderId=${item.routeArgument}');
            } else {
              context.push(item.targetRoute!);
            }
          }
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantHome,
      builder: (context, state) => MerchantHomeScreen(
        onLogout: () => context.go(AppRoutes.login),
        onServicePoints: () => context.push(AppRoutes.servicePoints),
        onSupport: () => context.push(AppRoutes.customerSupport),
        onVerifyNow: () => context.push(AppRoutes.merchantCommercialVerification),
        onNotifications: () => context.push(AppRoutes.notifications),
        onCargos: () => context.push(AppRoutes.merchantCargos),
        onMap: () => context.push(AppRoutes.merchantMap),
        onWallet: () => context.push(AppRoutes.merchantWallet),
        onAccount: () => context.push(AppRoutes.merchantAccount),
        onCreateOrder: () => context.push(AppRoutes.merchantCreateOrder),
        onOrderDetails: (id) => context.push(AppRoutes.merchantTripTracking),
        onReviewOffers: (id) => context.push(AppRoutes.merchantOffersReview),
        onSwitchToDriver: () => context.push(AppRoutes.driverHome),
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantCargos,
      builder: (context, state) => MerchantCargosScreen(
        onBack: () => context.pop(),
        onHome: () => context.go(AppRoutes.merchantHome),
        onAddCargo: () => context.push(AppRoutes.merchantCreateCargo),
        onCargoSelected: (cargo) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم اختيار الحمولة: ${cargo.name} (${cargo.id})'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantCreateCargo,
      builder: (context, state) => MerchantCreateCargoScreen(
        onBack: () => context.pop(),
        onSubmitCargo: (cargo) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إنشاء الحمولة بنجاح: ${cargo.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop();
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantCreateOrder,
      builder: (context, state) => MerchantCreateOrderScreen(
        onBack: () => context.pop(),
        onAddNewCargo: () => context.push(AppRoutes.merchantCreateCargo),
        onSelectOffice: () => context.push(AppRoutes.merchantSelectOffice),
        onSelectDriver: () => context.push(AppRoutes.merchantDriverProfile),
        onOrderPublishedHome: () => context.go(AppRoutes.merchantHome),
        onOrderPublishedOffers: () {
          context.go(AppRoutes.merchantHome);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الانتقال لقائمة العروض الواردة للطلب'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantSelectOffice,
      builder: (context, state) => SelectOfficeScreen(
        onBack: () => context.pop(),
        onOfficeSelected: (office) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم اختيار مكتب: ${office.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop();
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantDriverProfile,
      builder: (context, state) => DriverProfileScreen(
        onBack: () => context.pop(),
        onDirectOrder: (driver) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحديد السائق: ${driver.name} لطلب النقل'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        onCall: (phone) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('الاتصال بالسائق: $phone'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onMessage: (phone) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('مراسلة السائق: $phone'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantMap,
      builder: (context, state) => MerchantMapScreen(
        onBack: () => context.pop(),
        onViewDriverProfile: (truck) =>
            context.push(AppRoutes.merchantDriverProfile),
        onDirectOrder: (truck) =>
            context.push(AppRoutes.merchantCreateOrder),
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantTripTracking,
      builder: (context, state) => MerchantTripTrackingScreen(
        onBack: () => context.pop(),
        onCallDriver: (phone) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('الاتصال بالسائق: $phone'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onEmergencyCall: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الاتصال بغرفة الطوارئ والدعم اللوجستي'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantAccount,
      builder: (context, state) => MerchantAccountScreen(
        onBack: () => context.pop(),
        onHome: () => context.go(AppRoutes.merchantHome),
        onOrders: () => context.push(AppRoutes.merchantCargos),
        onMap: () => context.push(AppRoutes.merchantMap),
        onWallet: () => context.push(AppRoutes.merchantWallet),
        onVerification: () => context.push(AppRoutes.merchantCommercialVerification),
        onSettings: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الإعدادات العامة وتفضيلات الحساب'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onSupport: () => context.push(AppRoutes.customerSupport),
        onTerms: () => context.push(AppRoutes.terms),
        onLogout: () => context.go(AppRoutes.login),
        onFab: () => context.push(AppRoutes.merchantCreateOrder),
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantVerification,
      builder: (context, state) => MerchantVerificationScreen(
        onBack: () => context.pop(),
        onVerificationComplete: (isApproved) {
          context.pop();
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantOffersReview,
      builder: (context, state) {
        final orderId = state.uri.queryParameters['orderId'] ?? 'REQ-1024';
        return MerchantOffersReviewScreen(
          orderId: orderId,
          onBack: () => context.pop(),
          onDriverProfile: (driverId) =>
              context.push(AppRoutes.merchantDriverProfile),
          onOfferAccepted: (offer) {
            context.push(AppRoutes.merchantTripTracking);
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.merchantWallet,
      builder: (context, state) => MerchantWalletScreen(
        onBack: () => context.pop(),
        onAddBalance: () => context.push(AppRoutes.merchantAddBalance),
        onTransactionTap: (tx) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تفاصيل الحركة: ${tx.title} (${tx.ref})'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantAddBalance,
      builder: (context, state) => MerchantAddBalanceScreen(
        onClose: () => context.pop(),
        onSubmitDeposit: (data) {},
        onSuccessDone: () => context.pop(),
      ),
    ),
    GoRoute(
      path: AppRoutes.driverHome,
      builder: (context, state) => DriverHomeScreen(
        onNotifications: () => context.push(AppRoutes.notifications),
        onSwitchToMerchant: () => context.go(AppRoutes.merchantHome),
        onWallet: () => context.push(AppRoutes.merchantWallet),
        onSupport: () => context.push(AppRoutes.customerSupport),
        onLogout: () => context.go(AppRoutes.login),
        onTripDetails: (tripId) => context.push(AppRoutes.merchantTripTracking),
        onVerifyLicense: () => context.push(AppRoutes.driverLicenseVerification),
      ),
    ),
  ],
);

