import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../storage/app_preferences.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/identity_verification_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/terms_screen.dart';
import '../../features/auth/domain/models/auth_simulation_store.dart';
import '../../features/auth/domain/models/auth_user.dart';
import '../../features/auth/presentation/widgets/biometric_modal_sheet.dart';
import '../../features/auth/presentation/widgets/toll_free_dialer_modal_sheet.dart';
import '../../features/client/presentation/screens/client_account_screen.dart';
import '../../features/client/presentation/screens/client_home_screen.dart';
import '../../features/common/presentation/screens/customer_support_screen.dart';
import '../../features/common/presentation/screens/notifications_screen.dart';
import '../../features/common/presentation/screens/service_points_screen.dart';
import '../../features/driver/presentation/screens/driver_account_screen.dart';
import '../../features/driver/presentation/screens/driver_home_screen.dart';
import '../../features/driver/presentation/screens/driver_license_verification_screen.dart';
import '../../features/driver/presentation/screens/driver_vehicle_verification_screen.dart';
import '../../features/driver/presentation/screens/driver_orders_screen.dart';
import '../../features/driver/presentation/screens/driver_trips_screen.dart';
import '../../features/driver/presentation/screens/driver_trip_tracking_screen.dart';
import '../../features/driver/presentation/screens/driver_cargo_map_screen.dart';
import '../../features/driver/presentation/screens/driver_available_orders_screen.dart';
import '../../features/driver/presentation/screens/driver_order_details_screen.dart';
import '../../features/driver/domain/models/cargo_bid_opportunity.dart';
import '../../features/driver/domain/models/driver_simulation_store.dart';
import '../../features/merchant/domain/models/transport_order_draft.dart';
import '../../features/merchant/domain/models/cargo_card_item.dart';
import '../../features/merchant/domain/models/driver_offer.dart';
import '../../features/merchant/domain/models/merchant_simulation_store.dart';
import '../../features/merchant/presentation/screens/commercial_verification_screen.dart';
import '../../features/merchant/presentation/screens/driver_profile_screen.dart';
import '../../features/merchant/presentation/screens/merchant_account_screen.dart';
import '../../features/merchant/presentation/screens/merchant_add_balance_screen.dart';
import '../../features/merchant/presentation/screens/merchant_assignment_payment_screen.dart';
import '../../features/merchant/presentation/widgets/merchant_cargo_details_dialog.dart';
import '../../features/merchant/presentation/screens/merchant_cargo_details_screen.dart';
import '../../features/merchant/presentation/screens/merchant_cargos_screen.dart';
import '../../features/merchant/presentation/screens/merchant_create_cargo_screen.dart';
import '../../features/merchant/presentation/screens/merchant_create_order_screen.dart';
import '../../features/merchant/presentation/screens/merchant_home_screen.dart';
import '../../features/merchant/presentation/screens/merchant_map_screen.dart';
import '../../features/merchant/presentation/screens/merchant_offers_review_screen.dart';
import '../../features/merchant/presentation/screens/merchant_orders_screen.dart';
import '../../features/merchant/presentation/screens/merchant_trip_tracking_screen.dart';
import '../../features/merchant/presentation/screens/merchant_verification_screen.dart';
import '../../features/merchant/presentation/screens/merchant_wallet_screen.dart';
import '../../features/merchant/presentation/screens/wallet_withdraw_balance_screen.dart';
import '../../features/merchant/presentation/screens/select_driver_screen.dart';
import '../../features/merchant/presentation/screens/select_office_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_1_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_2_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_3_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/transport_office/presentation/screens/transport_office_account_screen.dart';
import '../../features/transport_office/presentation/screens/transport_office_drivers_screen.dart';
import '../../features/transport_office/presentation/screens/transport_office_endorse_search_screen.dart';
import '../../features/transport_office/presentation/screens/transport_office_home_screen.dart';
import '../../features/transport_office/presentation/screens/transport_office_orders_screen.dart';
import '../../features/transport_office/presentation/screens/transport_office_trip_details_screen.dart';
import '../../features/transport_office/presentation/screens/transport_office_trip_timeline_screen.dart';
import '../../features/transport_office/presentation/screens/transport_office_trips_screen.dart';

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
  static const String merchantOrders = '/merchant/orders';
  static const String merchantCargos = '/merchant/cargos';
  static const String merchantCargoDetails = '/merchant/cargo-details';
  static const String merchantCreateCargo = '/merchant/create-cargo';
  static const String merchantCreateOrder = '/merchant/create-order';
  static const String merchantSelectOffice = '/merchant/select-office';
  static const String merchantSelectDriver = '/merchant/select-driver';
  static const String merchantDriverProfile = '/merchant/driver-profile';
  static const String merchantMap = '/merchant/map';
  static const String merchantTripTracking = '/merchant/trip-tracking';
  static const String merchantOffersReview = '/merchant/offers-review';
  static const String merchantAssignmentPayment = '/merchant/assignment-payment';
  static const String merchantAccount = '/merchant/account';
  static const String merchantVerification = '/merchant/verification';
  static const String merchantWallet = '/merchant/wallet';
  static const String merchantAddBalance = '/merchant/add-balance';
  static const String withdrawBalance = '/wallet/withdraw';
  static const String driverHome = '/driver/home';
  static const String driverAccount = '/driver/account';
  static const String driverOrders = '/driver/orders';
  static const String driverTrips = '/driver/trips';
  static const String driverTripTracking = '/driver/trip-tracking';
  static const String driverCargoMap = '/driver/cargo-map';
  static const String driverAvailableOrders = '/driver/available-orders';
  static const String driverOrderDetails = '/driver/order-details';
  static const String clientHome = '/client/home';
  static const String clientAccount = '/client/account';
  static const String transportOfficeHome = '/office/home';
  static const String transportOfficeOrders = '/office/orders';
  static const String transportOfficeDrivers = '/office/drivers';
  static const String transportOfficeEndorseDriver = '/office/drivers/endorse';
  static const String transportOfficeAccount = '/office/account';
  static const String transportOfficeTrips = '/office/trips';
  static const String transportOfficeTripDetails = '/office/trips/details';
  static const String transportOfficeTripTimeline = '/office/trips/timeline';
}

/// Factory to generate AppRouter Configuration with dynamic initialLocation & redirect guard
GoRouter createAppRouter({String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation ?? AppPreferences.instance.resolveInitialRoute(),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      // If user has already completed onboarding, do NOT allow navigating to splash or onboarding
      if (AppPreferences.instance.isOnboardingCompleted) {
        if (loc == AppRoutes.splash || loc.startsWith('/onboarding')) {
          final currentUser = AuthSimulationStore.instance.currentUser;
          if (currentUser != null) {
            return AppPreferences.resolveHomeRoute(currentUser.role);
          }
          return AppRoutes.login;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding1,
        builder: (context, state) => Onboarding1Screen(
          onNext: () => context.go(AppRoutes.onboarding2),
          onSkip: () async {
            await AppPreferences.instance.setOnboardingCompleted(true);
            if (context.mounted) context.go(AppRoutes.login);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding2,
        builder: (context, state) => Onboarding2Screen(
          onNext: () => context.go(AppRoutes.onboarding3),
          onSkip: () async {
            await AppPreferences.instance.setOnboardingCompleted(true);
            if (context.mounted) context.go(AppRoutes.login);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding3,
        builder: (context, state) => Onboarding3Screen(
          onStartNow: () async {
            await AppPreferences.instance.setOnboardingCompleted(true);
            if (context.mounted) context.go(AppRoutes.login);
          },
          onSkip: () async {
            await AppPreferences.instance.setOnboardingCompleted(true);
            if (context.mounted) context.go(AppRoutes.login);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.journeyStart,
        redirect: (context, state) => AppRoutes.login,
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
              final currentUser = AuthSimulationStore.instance.currentUser;
              if (currentUser != null) {
                switch (currentUser.role) {
                  case AuthUserRole.driver:
                    context.go(AppRoutes.driverHome);
                    break;
                  case AuthUserRole.client:
                    context.go(AppRoutes.clientHome);
                    break;
                  case AuthUserRole.office:
                    context.go(AppRoutes.transportOfficeHome);
                    break;
                  case AuthUserRole.merchant:
                    context.go(AppRoutes.merchantHome);
                    break;
                }
              } else {
                context.go(AppRoutes.merchantHome);
              }
            },
          );
        },
        onTollFree: () {
          TollFreeDialerModalSheet.show(context);
        },
        onServicePoints: () => context.push(AppRoutes.servicePoints),
        onCustomerSupport: () => context.push(AppRoutes.customerSupport),
        onSubmitLogin: (role, phone, password, isOffline) {
          final effectiveRole =
              AuthSimulationStore.instance.currentUser?.role.label ?? role;
          if (effectiveRole == 'سائق') {
            context.go(AppRoutes.driverHome);
          } else if (effectiveRole == 'عميل') {
            context.go(AppRoutes.clientHome);
          } else if (effectiveRole == 'مكتب نقل') {
            context.go(AppRoutes.transportOfficeHome);
          } else {
            context.go(AppRoutes.merchantHome);
          }
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => RegisterScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
        onLogin: () => context.go(AppRoutes.login),
        onTerms: () => context.push(AppRoutes.terms),
        onSubmitRegister: (role, name, phone, password) {
          final pendingUser = AuthSimulationStore.instance.pendingRegistrationUser;
          context.push(
            AppRoutes.otpVerify,
            extra: {
              'phone': phone,
              'role': role.label,
              'userName': name,
              'userId': pendingUser?.id,
            },
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.otpVerify,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final phone = extra?['phone'] as String? ?? '+967 777 123 456';
        final role = extra?['role'] as String?;
        final userName = extra?['userName'] as String?;
        final userId = extra?['userId'] as String?;

        return OtpVerifyScreen(
          phoneNumber: phone,
          userRole: role,
          userName: userName,
          userId: userId,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.register),
          onEditPhone: () => context.canPop() ? context.pop() : context.go(AppRoutes.register),
          onVerified: () {
            // Forward to the verification route corresponding to the selected role
            if (role == 'سائق') {
              context.go(
                AppRoutes.identityVerification,
                extra: {
                  'phone': phone,
                  'role': 'سائق',
                  'userName': userName,
                  'userId': userId,
                },
              );
            } else if (role == 'تاجر') {
              context.go(
                AppRoutes.identityVerification,
                extra: {
                  'phone': phone,
                  'role': 'تاجر',
                  'userName': userName,
                  'userId': userId,
                },
              );
            } else if (role == 'مكتب نقل') {
              context.go(
                '${AppRoutes.merchantCommercialVerification}?role=مكتب نقل',
                extra: {
                  'phone': phone,
                  'role': 'مكتب نقل',
                  'userName': userName,
                  'userId': userId,
                },
              );
            } else {
              context.go(
                AppRoutes.identityVerification,
                extra: {
                  'phone': phone,
                  'role': role,
                  'userName': userName,
                  'userId': userId,
                },
              );
            }
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.identityVerification,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final role = state.uri.queryParameters['role'] ?? extra?['role'] as String?;
        final isDriver = role == 'سائق';
        final isMerchant = role == 'تاجر';
        return IdentityVerificationScreen(
          userId: extra?['userId'] as String?,
          userName: extra?['userName'] as String?,
          userPhone: extra?['phone'] as String?,
          userRole: role,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
          onNext: isDriver
              ? () => context.push(AppRoutes.driverLicenseVerification)
              : (isMerchant
                  ? () => context.push(
                        '${AppRoutes.merchantCommercialVerification}?role=تاجر',
                        extra: {
                          'phone': extra?['phone'],
                          'role': 'تاجر',
                          'userName': extra?['userName'],
                          'userId': extra?['userId'],
                        },
                      )
                  : null),
          onSkip: () => isDriver
              ? context.go(AppRoutes.driverHome)
              : (isMerchant
                  ? context.go(AppRoutes.merchantHome)
                  : context.go(AppRoutes.clientHome)),
          onVerificationComplete: (isApproved) {
            if (isDriver) {
              context.go(AppRoutes.driverHome);
            } else if (isMerchant) {
              context.go(AppRoutes.merchantHome);
            } else {
              context.go(AppRoutes.clientHome);
            }
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.clientHome,
      builder: (context, state) => ClientHomeScreen(
        onCreateOrder: () => context.push(AppRoutes.merchantCreateOrder),
        onMyCargos: () => context.push(AppRoutes.merchantCargos),
        onMyOffers: () => context.push(AppRoutes.merchantOffersReview),
        onTrackCargo: () => context.push(AppRoutes.merchantTripTracking),
        onHistory: () => context.push(AppRoutes.merchantOrders),
        onNotifications: () => context.push(AppRoutes.notifications),
        onVerifyNow: () => context.push(AppRoutes.identityVerification),
        onAccount: () => context.push(AppRoutes.clientAccount),
        onMap: () => context.push(AppRoutes.merchantMap),
        onWallet: () => context.push('${AppRoutes.merchantWallet}?role=client'),
        onSupport: () => context.push(AppRoutes.customerSupport),
        onAddCargo: () => context.push(AppRoutes.merchantCreateCargo),
        onOrders: () => context.push(AppRoutes.merchantOrders),
        onReviewOffers: (id) => context.push(AppRoutes.merchantOffersReview),
        onOrderDetails: (id) => context.push(AppRoutes.merchantCargoDetails),
        onLogout: () {
          AuthSimulationStore.instance.logout();
          context.go(AppRoutes.login);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.clientAccount,
      builder: (context, state) => ClientAccountScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.clientHome),
        onHome: () => context.go(AppRoutes.clientHome),
        onOrders: () => context.push(AppRoutes.merchantOrders),
        onCargos: () => context.push(AppRoutes.merchantCargos),
        onMap: () => context.push(AppRoutes.merchantMap),
        onWallet: () => context.push('${AppRoutes.merchantWallet}?role=client'),
        onIdentityUpdate: () => context.push(AppRoutes.identityVerification),
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
        onLogout: () {
          AuthSimulationStore.instance.logout();
          context.go(AppRoutes.login);
        },
        onFab: () => context.push(AppRoutes.merchantCreateOrder),
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantCommercialVerification,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final role = state.uri.queryParameters['role'] ??
            extra?['role'] as String? ??
            'تاجر';
        final phone = state.uri.queryParameters['phone'] ??
            extra?['phone'] as String?;
        final userName = state.uri.queryParameters['userName'] ??
            extra?['userName'] as String?;
        final userId = state.uri.queryParameters['userId'] ??
            extra?['userId'] as String?;
        return CommercialVerificationScreen(
          role: role,
          userId: userId,
          userName: userName,
          userPhone: phone,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
          onSkip: () => context.go(role == 'مكتب نقل' ? AppRoutes.transportOfficeHome : AppRoutes.merchantHome),
          onVerificationComplete: (isApproved) {
            context.go(role == 'مكتب نقل' ? AppRoutes.transportOfficeHome : AppRoutes.merchantHome);
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.driverLicenseVerification,
      builder: (context, state) => DriverLicenseVerificationScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.driverHome),
        onNext: () => context.push(AppRoutes.driverVehicleVerification),
        onSkip: () => context.go(AppRoutes.driverHome),
      ),
    ),
    GoRoute(
      path: AppRoutes.driverVehicleVerification,
      builder: (context, state) => DriverVehicleVerificationScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.driverLicenseVerification),
        onSkip: () => context.go(AppRoutes.driverHome),
        onVerificationComplete: (isApproved) {
          context.go(AppRoutes.driverHome);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => ForgotPasswordScreen(
        onBackToLogin: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
      ),
    ),
    GoRoute(
      path: AppRoutes.terms,
      builder: (context, state) => TermsScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
        onAccept: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
      ),
    ),
    GoRoute(
      path: AppRoutes.servicePoints,
      builder: (context, state) => ServicePointsScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
      ),
    ),
    GoRoute(
      path: AppRoutes.customerSupport,
      builder: (context, state) => CustomerSupportScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
      ),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => NotificationsScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.login),
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
        onLogout: () {
          AuthSimulationStore.instance.logout();
          context.go(AppRoutes.login);
        },
        onServicePoints: () => context.push(AppRoutes.servicePoints),
        onSupport: () => context.push(AppRoutes.customerSupport),
        onVerifyNow: () => context.push(AppRoutes.merchantCommercialVerification),
        onNotifications: () => context.push(AppRoutes.notifications),
        onOrders: () => context.push(AppRoutes.merchantOrders),
        onCargos: () => context.push(AppRoutes.merchantCargos),
        onMap: () => context.push(AppRoutes.merchantMap),
        onWallet: () => context.push('${AppRoutes.merchantWallet}?role=merchant'),
        onAccount: () => context.push(AppRoutes.merchantAccount),
        onCreateOrder: () => context.push(AppRoutes.merchantCreateOrder),
        onOrderDetails: (id) => context.push(AppRoutes.merchantTripTracking, extra: id),
        onReviewOffers: (id) => context.push(AppRoutes.merchantOffersReview),
        onSwitchToDriver: () => context.push(AppRoutes.driverHome),
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantOrders,
      builder: (context, state) => MerchantOrdersScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantHome),
        onHome: () => context.go(AppRoutes.merchantHome),
        onMap: () => context.push(AppRoutes.merchantMap),
        onAccount: () => context.push(AppRoutes.merchantAccount),
        onCreateOrder: () => context.push(AppRoutes.merchantCreateOrder),
        onOrderDetails: (id) => context.push(AppRoutes.merchantTripTracking, extra: id),
        onReviewOffers: (id) => context.push(AppRoutes.merchantOffersReview),
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantCargos,
      builder: (context, state) => MerchantCargosScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantHome),
        onHome: () => context.go(AppRoutes.merchantHome),
        onAddCargo: () => context.push(AppRoutes.merchantCreateCargo),
        onCargoSelected: (cargo) {
          MerchantCargoDetailsDialog.show(context, cargo);
        },
        onViewCargoDetails: (cargo) {
          MerchantCargoDetailsDialog.show(context, cargo);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantCargoDetails,
      builder: (context, state) {
        final cargo = state.extra is CargoCardItem
            ? state.extra as CargoCardItem
            : MerchantSimulationStore.instance.cargos.first;
        return MerchantCargoDetailsScreen(
          cargo: cargo,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantOrders),
          onCreateOrder: (selectedCargo) {
            context.push(AppRoutes.merchantCreateOrder, extra: selectedCargo);
          },
          onOrderDetails: (orderId) {
            context.push(AppRoutes.merchantTripTracking, extra: orderId);
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.merchantCreateCargo,
      builder: (context, state) => MerchantCreateCargoScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantCargos),
        onSubmitCargo: (cargo) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إنشاء الحمولة بنجاح: ${cargo.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop(cargo);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantCreateOrder,
      builder: (context, state) => MerchantCreateOrderScreen(
        initialCargo: state.extra is CargoCardItem
            ? state.extra as CargoCardItem
            : null,
        initialDriver: state.extra is DriverProfile
            ? state.extra as DriverProfile
            : null,
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantOrders),
        onAddNewCargo: () => context.push(AppRoutes.merchantCreateCargo),
        onSelectOffice: () => context.push(AppRoutes.merchantSelectOffice),
        onSelectDriver: () => context.push(AppRoutes.merchantDriverProfile),
        onOrderPublishedHome: () => context.go(AppRoutes.merchantOrders),
        onOrderPublishedOffers: () {
          context.go(AppRoutes.merchantOrders);
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
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantCreateOrder),
        onOfficeSelected: (office) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم اختيار مكتب: ${office.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop(office);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantSelectDriver,
      builder: (context, state) => SelectDriverScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantCreateOrder),
        onDriverSelected: (driver) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم اختيار السائق: ${driver.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop(driver);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantDriverProfile,
      builder: (context, state) {
        final driver = state.extra is DriverProfile
            ? state.extra as DriverProfile
            : DriverProfile.demoDriver;
        return DriverProfileScreen(
          driver: driver,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantSelectDriver),
          onDirectOrder: (driver) {
            context.go(AppRoutes.merchantOrders);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إسناد الطلب للسائق: ${driver.name}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          onCreateNewOrderWithDriver: (driver) {
            context.push(AppRoutes.merchantCreateOrder, extra: driver);
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
        );
      },
    ),
    GoRoute(
      path: AppRoutes.merchantMap,
      builder: (context, state) => MerchantMapScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantHome),
        onHome: () => context.go(AppRoutes.merchantHome),
        onOrders: () => context.push(AppRoutes.merchantOrders),
        onAccount: () => context.push(AppRoutes.merchantAccount),
        onCreateOrder: () => context.push(AppRoutes.merchantCreateOrder),
        onViewDriverProfile: (truck) {
          final profile = DriverProfile(
            id: truck.id,
            name: truck.driverName,
            phone: truck.phone,
            rating: truck.rating,
            city: truck.currentCity,
            vehicleType: truck.vehicleType,
            plateNumber: truck.plateNumber,
            capacity: truck.capacity,
            completedTrips: truck.reviewsCount,
            isOnline: truck.isAvailable,
          );
          context.push(AppRoutes.merchantDriverProfile, extra: profile);
        },
        onDirectOrder: (truck) {
          final profile = DriverProfile(
            id: truck.id,
            name: truck.driverName,
            phone: truck.phone,
            rating: truck.rating,
            city: truck.currentCity,
            vehicleType: truck.vehicleType,
            plateNumber: truck.plateNumber,
            capacity: truck.capacity,
            completedTrips: truck.reviewsCount,
            isOnline: truck.isAvailable,
          );
          context.push(AppRoutes.merchantCreateOrder, extra: profile);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantTripTracking,
      builder: (context, state) {
        final orderId = state.extra is String
            ? state.extra as String
            : (state.uri.queryParameters['orderId'] ??
                (state.extra is Map ? (state.extra as Map)['orderId'] as String? : null));
        return MerchantTripTrackingScreen(
          orderId: orderId,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantOrders),
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
        );
      },
    ),
    GoRoute(
      path: AppRoutes.merchantAccount,
      builder: (context, state) => MerchantAccountScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantHome),
        onHome: () => context.go(AppRoutes.merchantHome),
        onOrders: () => context.push(AppRoutes.merchantOrders),
        onCargos: () => context.push(AppRoutes.merchantCargos),
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
        onLogout: () {
          AuthSimulationStore.instance.logout();
          context.go(AppRoutes.login);
        },
        onFab: () => context.push(AppRoutes.merchantCreateOrder),
      ),
    ),
    GoRoute(
      path: AppRoutes.merchantVerification,
      builder: (context, state) => MerchantVerificationScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantAccount),
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
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantOrders),
          onDriverProfile: (driverId) =>
              context.push(AppRoutes.merchantDriverProfile),
          onOfferAccepted: (offer) {
            context.push(
              AppRoutes.merchantAssignmentPayment,
              extra: {'offer': offer, 'orderId': orderId},
            );
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.merchantAssignmentPayment,
      builder: (context, state) {
        final extraMap = state.extra is Map<String, dynamic>
            ? state.extra as Map<String, dynamic>
            : <String, dynamic>{};
        final offer = extraMap['offer'] is DriverOffer
            ? extraMap['offer'] as DriverOffer
            : null;
        final orderId = extraMap['orderId'] is String
            ? extraMap['orderId'] as String
            : (state.uri.queryParameters['orderId'] ?? 'REQ-1024');

        return MerchantAssignmentPaymentScreen(
          offer: offer,
          orderId: orderId,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.merchantOffersReview),
          onAddBalance: () => context.push(AppRoutes.merchantAddBalance),
          onPaymentSuccess: (id) {
            context.go(AppRoutes.merchantTripTracking, extra: id);
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.merchantWallet,
      builder: (context, state) {
        AuthUserRole role = AuthUserRole.merchant;
        final roleParam = state.uri.queryParameters['role'];
        if (roleParam != null) {
          if (roleParam == 'client') {
            role = AuthUserRole.client;
          } else if (roleParam == 'office' || roleParam == 'transport_office') {
            role = AuthUserRole.office;
          } else if (roleParam == 'driver') {
            role = AuthUserRole.driver;
          }
        } else if (state.extra is AuthUserRole) {
          role = state.extra as AuthUserRole;
        } else if (AuthSimulationStore.instance.currentUser?.role != null) {
          role = AuthSimulationStore.instance.currentUser!.role;
        }

        return MerchantWalletScreen(
          userRole: role,
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              switch (role) {
                case AuthUserRole.client:
                  context.go(AppRoutes.clientHome);
                  break;
                case AuthUserRole.office:
                  context.go(AppRoutes.transportOfficeHome);
                  break;
                case AuthUserRole.driver:
                  context.go(AppRoutes.driverHome);
                  break;
                case AuthUserRole.merchant:
                  context.go(AppRoutes.merchantHome);
                  break;
              }
            }
          },
          onAddBalance: () => context.push('${AppRoutes.merchantAddBalance}?role=${role.name}'),
          onWithdraw: () => context.push('${AppRoutes.withdrawBalance}?role=${role.name}'),
          onTransactionTap: (tx) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تفاصيل الحركة: ${tx.title} (${tx.ref})'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.merchantAddBalance,
      builder: (context, state) {
        AuthUserRole role = AuthUserRole.merchant;
        final roleParam = state.uri.queryParameters['role'];
        if (roleParam != null) {
          if (roleParam == 'client') {
            role = AuthUserRole.client;
          } else if (roleParam == 'office' || roleParam == 'transport_office') {
            role = AuthUserRole.office;
          } else if (roleParam == 'driver') {
            role = AuthUserRole.driver;
          }
        } else if (state.extra is AuthUserRole) {
          role = state.extra as AuthUserRole;
        } else if (AuthSimulationStore.instance.currentUser?.role != null) {
          role = AuthSimulationStore.instance.currentUser!.role;
        }

        final initialAmount = state.uri.queryParameters['amount'];

        return MerchantAddBalanceScreen(
          userRole: role,
          initialAmount: initialAmount,
          onClose: () => context.canPop()
              ? context.pop()
              : context.go('${AppRoutes.merchantWallet}?role=${role.name}'),
          onSubmitDeposit: (data) {},
          onSuccessDone: () => context.canPop()
              ? context.pop()
              : context.go('${AppRoutes.merchantWallet}?role=${role.name}'),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.withdrawBalance,
      builder: (context, state) {
        AuthUserRole role = AuthUserRole.driver;
        final roleParam = state.uri.queryParameters['role'];
        if (roleParam != null) {
          if (roleParam == 'office' || roleParam == 'transport_office') {
            role = AuthUserRole.office;
          } else if (roleParam == 'merchant') {
            role = AuthUserRole.merchant;
          } else if (roleParam == 'client') {
            role = AuthUserRole.client;
          } else if (roleParam == 'driver') {
            role = AuthUserRole.driver;
          }
        } else if (state.extra is AuthUserRole) {
          role = state.extra as AuthUserRole;
        } else if (AuthSimulationStore.instance.currentUser?.role != null) {
          role = AuthSimulationStore.instance.currentUser!.role;
        }

        final initialAmount = state.uri.queryParameters['amount'];

        return WalletWithdrawBalanceScreen(
          userRole: role,
          initialAmount: initialAmount,
          onBack: () => context.canPop()
              ? context.pop()
              : context.go('${AppRoutes.merchantWallet}?role=${role.name}'),
          onSubmitWithdrawal: (data) {},
          onSuccessDone: () => context.canPop()
              ? context.pop()
              : context.go('${AppRoutes.merchantWallet}?role=${role.name}'),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.driverHome,
      builder: (context, state) => DriverHomeScreen(
        onNotifications: () => context.push(AppRoutes.notifications),
        onSwitchToMerchant: () => context.go(AppRoutes.merchantHome),
        onWallet: () => context.push('${AppRoutes.merchantWallet}?role=driver'),
        onSupport: () => context.push(AppRoutes.customerSupport),
        onLogout: () {
          AuthSimulationStore.instance.logout();
          context.go(AppRoutes.login);
        },
        onTripDetails: (tripId) => context.push(AppRoutes.driverTripTracking, extra: tripId),
        onVerifyLicense: () => context.push(AppRoutes.driverLicenseVerification),
        onAccount: () => context.push(AppRoutes.driverAccount),
        onOrders: () => context.push(AppRoutes.driverOrders),
        onTrips: () => context.push(AppRoutes.driverTrips),
        onMap: () => context.push(AppRoutes.driverCargoMap),
      ),
    ),
    GoRoute(
      path: AppRoutes.driverOrders,
      builder: (context, state) {
        final initialCategory = state.extra as String?;
        return DriverOrdersScreen(
          initialCategory: initialCategory,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.driverHome),
          onTripDetails: (tripId) => context.push(AppRoutes.driverTripTracking, extra: tripId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.driverTrips,
      builder: (context, state) {
        final initialCategory = state.extra as String?;
        return DriverTripsScreen(
          initialCategory: initialCategory,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.driverHome),
          onTripDetails: (tripId) => context.push(AppRoutes.driverTripTracking, extra: tripId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.driverTripTracking,
      builder: (context, state) {
        final tripId = state.extra as String?;
        return DriverTripTrackingScreen(
          tripId: tripId,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.driverHome),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.driverCargoMap,
      builder: (context, state) => DriverCargoMapScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.driverHome),
      ),
    ),
    GoRoute(
      path: AppRoutes.driverAvailableOrders,
      builder: (context, state) {
        final initialFilter = (state.extra as String?) ?? 'الكل';
        return DriverAvailableOrdersScreen(
          initialFilter: initialFilter,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.driverHome),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.driverOrderDetails,
      builder: (context, state) {
        CargoBidOpportunity? cargo;
        if (state.extra is CargoBidOpportunity) {
          cargo = state.extra as CargoBidOpportunity;
        } else if (state.extra is Map && (state.extra as Map)['cargo'] is CargoBidOpportunity) {
          cargo = (state.extra as Map)['cargo'] as CargoBidOpportunity;
        } else {
          final id = state.uri.queryParameters['id'] ??
              (state.extra is String ? state.extra as String : null);
          if (id != null) {
            cargo = DriverSimulationStore.instance.findOpportunityById(id);
          }
        }
        return DriverOrderDetailsScreen(
          cargo: cargo,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.driverHome),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.driverAccount,
      builder: (context, state) => DriverAccountScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.driverHome),
        onHome: () => context.go(AppRoutes.driverHome),
        onOrders: () => context.push(AppRoutes.driverOrders),
        onMap: () => context.push(AppRoutes.driverCargoMap),
        onWallet: () => context.push('${AppRoutes.merchantWallet}?role=driver'),
        onSupport: () => context.push(AppRoutes.customerSupport),
        onNotifications: () => context.push(AppRoutes.notifications),
        onLogout: () {
          AuthSimulationStore.instance.logout();
          context.go(AppRoutes.login);
        },
        onVerifyLicense: () => context.push(AppRoutes.driverLicenseVerification),
        onVerifyVehicle: () => context.push(AppRoutes.driverVehicleVerification),
      ),
    ),
    GoRoute(
      path: AppRoutes.transportOfficeHome,
      builder: (context, state) => TransportOfficeHomeScreen(
        onVerifyNow: () => context.push(
          '${AppRoutes.merchantCommercialVerification}?role=مكتب نقل',
          extra: {'role': 'مكتب نقل'},
        ),
        onAccount: () => context.push(AppRoutes.transportOfficeAccount),
        onNotifications: () => context.push(AppRoutes.notifications),
        onLogout: () {
          AuthSimulationStore.instance.logout();
          context.go(AppRoutes.login);
        },
        onOrderDetails: (orderId) => context.push(
          '${AppRoutes.merchantCargoDetails}?id=$orderId',
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.transportOfficeOrders,
      builder: (context, state) {
        final initialTab = state.uri.queryParameters['tab'] ??
            (state.extra is String ? state.extra as String : null);
        return TransportOfficeOrdersScreen(
          initialTab: initialTab,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.transportOfficeHome),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.transportOfficeDrivers,
      builder: (context, state) => TransportOfficeDriversScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.transportOfficeHome),
        onAddEndorsement: () => context.push(AppRoutes.transportOfficeEndorseDriver),
      ),
    ),
    GoRoute(
      path: AppRoutes.transportOfficeEndorseDriver,
      builder: (context, state) => TransportOfficeEndorseSearchScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.transportOfficeDrivers),
      ),
    ),
    GoRoute(
      path: AppRoutes.transportOfficeAccount,
      builder: (context, state) => TransportOfficeAccountScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.transportOfficeHome),
        onVerifyNow: () => context.push(
          '${AppRoutes.merchantCommercialVerification}?role=مكتب نقل',
          extra: {'role': 'مكتب نقل'},
        ),
        onSupport: () => context.push(AppRoutes.customerSupport),
        onTerms: () => context.push(AppRoutes.terms),
        onLogout: () {
          AuthSimulationStore.instance.logout();
          context.go(AppRoutes.login);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.transportOfficeTrips,
      builder: (context, state) => TransportOfficeTripsScreen(
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.transportOfficeHome),
      ),
    ),
    GoRoute(
      path: AppRoutes.transportOfficeTripDetails,
      builder: (context, state) {
        final tripId = state.uri.queryParameters['id'] ??
            (state.extra is String ? state.extra as String : 'R-1042');
        return TransportOfficeTripDetailsScreen(
          tripId: tripId,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.transportOfficeTrips),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.transportOfficeTripTimeline,
      builder: (context, state) {
        final tripId = state.uri.queryParameters['id'] ??
            (state.extra is String ? state.extra as String : 'R-1042');
        return TransportOfficeTripTimelineScreen(
          tripId: tripId,
          onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.transportOfficeTrips),
        );
      },
    ),
  ],
);
}

/// Singleton appRouter instance used across the app
GoRouter appRouter = createAppRouter();

/// Re-creates or refreshes the appRouter instance with updated configuration
void refreshAppRouter({String? initialLocation}) {
  appRouter = createAppRouter(initialLocation: initialLocation);
}


