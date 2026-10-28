import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/models/auth_user.dart';
import '../../features/auth/domain/models/auth_simulation_store.dart';
import '../router/app_router.dart';

/// Central Persistent Storage & App State Manager for Hamoola.
/// Manages:
/// 1. Onboarding completion state (persisted across restarts, never cleared on logout).
/// 2. Active user session ID (persisted across restarts, cleared strictly on logout).
/// 3. Instantaneous initial route resolution for fast startup without artificial delays.
class AppPreferences extends ChangeNotifier {
  static final AppPreferences instance = AppPreferences._internal();
  factory AppPreferences() => instance;

  AppPreferences._internal();

  static const String keyOnboardingCompleted = 'hamula_onboarding_completed';
  static const String keyActiveUserId = 'hamula_active_user_id';
  static const String keyOfficeAvailability = 'hamula_office_availability';

  SharedPreferences? _prefs;
  bool _inMemoryOnboardingCompleted = false;
  String? _inMemoryActiveUserId;
  bool _inMemoryOfficeAvailability = true;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initializes preferences. Can be called during app boot or injected in tests.
  Future<void> init({SharedPreferences? customPrefs}) async {
    if (customPrefs != null) {
      _prefs = customPrefs;
    } else {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        debugPrint('AppPreferences init warning: $e');
      }
    }

    _inMemoryOnboardingCompleted =
        _prefs?.getBool(keyOnboardingCompleted) ?? false;
    _inMemoryActiveUserId = _prefs?.getString(keyActiveUserId);

    // If an active user was saved, restore session into AuthSimulationStore
    if (_inMemoryActiveUserId != null && _inMemoryActiveUserId!.isNotEmpty) {
      final user = AuthSimulationStore.instance.getUserById(_inMemoryActiveUserId!);
      if (user != null) {
        AuthSimulationStore.instance.setCurrentUser(user);
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Whether the user has already completed onboarding.
  bool get isOnboardingCompleted =>
      _prefs?.getBool(keyOnboardingCompleted) ?? _inMemoryOnboardingCompleted;

  /// Sets onboarding completion status and saves to persistent storage.
  Future<void> setOnboardingCompleted(bool completed) async {
    _inMemoryOnboardingCompleted = completed;
    try {
      await _prefs?.setBool(keyOnboardingCompleted, completed);
    } catch (_) {}
    notifyListeners();
  }

  /// Active logged in user ID if any.
  String? get activeUserId =>
      _prefs?.getString(keyActiveUserId) ?? _inMemoryActiveUserId;

  /// Saves user session on successful login.
  Future<void> saveUserSession(String userId) async {
    _inMemoryActiveUserId = userId;
    try {
      await _prefs?.setString(keyActiveUserId, userId);
    } catch (_) {}
    notifyListeners();
  }

  /// Availability status of transport office for accepting private orders
  bool get isOfficeAvailable =>
      _prefs?.getBool(keyOfficeAvailability) ?? _inMemoryOfficeAvailability;

  /// Updates and persists transport office availability status
  Future<void> setOfficeAvailable(bool available) async {
    _inMemoryOfficeAvailability = available;
    try {
      await _prefs?.setBool(keyOfficeAvailability, available);
    } catch (_) {}
    notifyListeners();
  }

  /// Clears active user session upon logout.
  /// IMPORTANT: Strictly leaves `isOnboardingCompleted` intact!
  Future<void> clearUserSession() async {
    _inMemoryActiveUserId = null;
    try {
      await _prefs?.remove(keyActiveUserId);
    } catch (_) {}
    notifyListeners();
  }

  /// Resolves the corresponding Home route for an AuthUserRole.
  static String resolveHomeRoute(AuthUserRole role) {
    switch (role) {
      case AuthUserRole.client:
        return AppRoutes.clientHome;
      case AuthUserRole.driver:
        return AppRoutes.driverHome;
      case AuthUserRole.merchant:
        return AppRoutes.merchantHome;
      case AuthUserRole.office:
        return AppRoutes.transportOfficeHome;
    }
  }

  /// Resolves the instantaneous initial route for the application:
  /// - New user (onboarding incomplete): Splash (fast boot) -> Onboarding
  /// - Returning user with active session: Home screen according to their role
  /// - Returning user without active session: Login screen directly
  String resolveInitialRoute() {
    if (!isOnboardingCompleted) {
      return AppRoutes.splash;
    }

    final currentUser = AuthSimulationStore.instance.currentUser;
    if (currentUser != null) {
      return resolveHomeRoute(currentUser.role);
    }

    // Default for returning unauthenticated user: Direct to Login!
    return AppRoutes.login;
  }

  /// Resets everything for testing fresh install scenarios.
  Future<void> resetForTesting() async {
    _inMemoryOnboardingCompleted = false;
    _inMemoryActiveUserId = null;
    try {
      await _prefs?.clear();
    } catch (_) {}
    notifyListeners();
  }
}
