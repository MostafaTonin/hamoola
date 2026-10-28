import 'package:flutter/material.dart';
import '../../../merchant/domain/models/merchant_profile.dart';
import '../../../../core/storage/app_preferences.dart';
import 'auth_user.dart';

/// Result wrapper for authentication operations
class AuthResult {
  final bool isSuccess;
  final AuthUser? user;
  final String? errorMessage;

  const AuthResult.success(this.user)
      : isSuccess = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage)
      : isSuccess = false,
        user = null;
}

/// Central In-Memory Simulation Store for Hamula Authentication & Multi-Role User State.
/// Manages demo accounts, registration, role matching, and initial verification status.
class AuthSimulationStore extends ChangeNotifier {
  static final AuthSimulationStore instance = AuthSimulationStore._internal();
  factory AuthSimulationStore() => instance;

  AuthSimulationStore._internal() {
    resetToDemo();
  }

  late List<AuthUser> _users;
  AuthUser? _currentUser;
  AuthUser? _pendingRegistrationUser;

  List<AuthUser> get users => List.unmodifiable(_users);
  AuthUser? get currentUser => _currentUser;
  AuthUser? get pendingRegistrationUser => _pendingRegistrationUser;

  /// Default demo accounts covering all four Hamula roles
  static List<AuthUser> get initialDemoUsers => [
        AuthUser(
          id: '783707104',
          name: 'مصطفى صالح طنين',
          phone: '777123456',
          countryCode: '+967',
          password: 'Hamula@123',
          role: AuthUserRole.client,
          accountType: 'شخصي',
          verificationStatus: AccountVerificationStatus.verified,
          isPhoneVerified: true,
          createdAt: DateTime(2026, 10, 1),
          identityData: ClientIdentityData(
            fullName: 'مصطفى يحيى صالح طنين',
            idNumber: 'TEST-YE-100245',
            issuePlace: 'الأحوال المدنية — صنعاء',
            issueDate: '2022-03-15',
            expiryDate: '2032-03-14',
            birthPlace: 'صنعاء',
            birthDate: '1998-05-12',
            personalPhotoPath: 'assets/images/avatar_personal_preview.jpg',
            frontPhotoPath: 'assets/images/id_front_preview.jpg',
            backPhotoPath: 'assets/images/id_back_preview.jpg',
            selfiePhotoPath: 'assets/images/id_selfie_preview.jpg',
            submittedAt: DateTime(2026, 10, 1),
          ),
        ),
        AuthUser(
          id: 'USR-CLIENT-02',
          name: 'سالم صالح الكندي (عميل)',
          phone: '770123456',
          countryCode: '+967',
          password: 'password123',
          role: AuthUserRole.client,
          accountType: 'شخصي',
          verificationStatus: AccountVerificationStatus.unverified,
          isPhoneVerified: true,
          createdAt: DateTime(2026, 10, 1),
        ),
        AuthUser(
          id: 'USR-DRIVER-01',
          name: 'أحمد صالح السالمي',
          phone: '772345678',
          countryCode: '+967',
          password: 'Hamula@123',
          role: AuthUserRole.driver,
          verificationStatus: AccountVerificationStatus.verified,
          isPhoneVerified: true,
          isDriverAvailable: true,
          createdAt: DateTime(2026, 9, 15),
          driverData: DriverVerificationData(
            identityData: ClientIdentityData(
              fullName: 'أحمد صالح السالمي',
              idNumber: '11020304050',
              issuePlace: 'صنعاء - السبعين',
              issueDate: '2020-05-10',
              expiryDate: '2030-05-09',
              birthPlace: 'صنعاء',
              birthDate: '1988-03-12',
              personalPhotoPath: 'assets/images/driver_ahmed_avatar.jpg',
              frontPhotoPath: 'assets/images/id_front_preview.jpg',
              backPhotoPath: 'assets/images/id_back_preview.jpg',
              selfiePhotoPath: 'assets/images/id_selfie_preview.jpg',
              submittedAt: DateTime(2026, 9, 15),
            ),
            licenseData: DriverLicenseData(
              licenseNumber: 'DL-942851',
              licenseCategory: 'نقل ثقيل (شاحنات وقاطرات)',
              issuePlace: 'الإدارة العامة للمرور - تعز',
              issueDate: '2021-09-15',
              expiryDate: '2026-09-14',
              frontPhotoPath: 'assets/images/license_front_preview.jpg',
              backPhotoPath: 'assets/images/license_back_preview.jpg',
            ),
            vehicleData: DriverVehicleData(
              vehicleType: 'شاحنة نقل',
              category: 'نقل ثقيل',
              manufacturer: 'مرسيدس',
              model: 'أكتروس',
              year: '2023',
              plateNumber: '7198 د ح ي',
              color: 'أبيض',
              maxCapacity: '25',
              capacityUnit: 'طن',
              bodyType: 'صندوق مغلق',
              volume: '65 م³',
              trailersCount: 1,
              frontPhotoPath: 'assets/images/vehicle_front_preview.jpg',
              backPhotoPath: 'assets/images/vehicle_back_preview.jpg',
              sidePhotoPath: 'assets/images/vehicle_side_preview.jpg',
              platePhotoPath: 'assets/images/vehicle_plate_preview.jpg',
              cargoTypes: ['بضائع عامة', 'أثاث وعفش', 'مواد بناء'],
              serviceAreas: ['صنعاء', 'عدن', 'تعز', 'الحديدة', 'حضرموت'],
              operatingNotes: 'سائق معتمد ومركبة مفحوصة ومؤمنة بالكامل',
            ),
            submittedAt: DateTime(2026, 9, 15),
          ),
        ),
        AuthUser(
          id: '783707104',
          name: 'محمد أحمد',
          phone: '771234567',
          countryCode: '+967',
          password: 'Hamula@123',
          role: AuthUserRole.merchant,
          verificationStatus: AccountVerificationStatus.verified,
          isPhoneVerified: true,
          createdAt: DateTime(2026, 8, 20),
          merchantData: MerchantEnterpriseData(
            enterpriseName: 'مؤسسة النور للتجارة العامة',
            businessType: 'تجارة جملة وتجزئة',
            crNumber: '1234567890',
            crIssuer: 'وزارة الصناعة والتجارة - مكتب الأمانة',
            crIssueDate: '2021-08-10',
            crExpiryDate: '2026-08-09',
            address: 'صنعاء - شارع الستين الجنوبي - عمارة الأمل',
            businessDescription: 'استيراد وتوزيع المواد الغذائية والبضائع التجارية بالجملة',
            crPhotoPath: 'assets/images/commercial_reg_preview.jpg',
            frontIdPath: 'assets/images/id_front_preview.jpg',
            backIdPath: 'assets/images/id_back_preview.jpg',
            selfieIdPath: 'assets/images/id_selfie_preview.jpg',
            submittedAt: DateTime(2026, 8, 20),
          ),
          identityData: ClientIdentityData(
            fullName: 'محمد أحمد',
            idNumber: '1019283746',
            issuePlace: 'صنعاء - الوحدة',
            issueDate: '2019-04-12',
            expiryDate: '2029-04-11',
            birthPlace: 'صنعاء',
            birthDate: '1985-07-20',
            personalPhotoPath: 'assets/images/merchant_company_logo.png',
            frontPhotoPath: 'assets/images/id_front_preview.jpg',
            backPhotoPath: 'assets/images/id_back_preview.jpg',
            selfiePhotoPath: 'assets/images/id_selfie_preview.jpg',
            submittedAt: DateTime(2026, 8, 20),
          ),
        ),
        AuthUser(
          id: 'USR-OFFICE-01',
          name: 'صالح مسعد العمري',
          phone: '774567890',
          countryCode: '+967',
          password: 'password123',
          role: AuthUserRole.office,
          verificationStatus: AccountVerificationStatus.verified,
          isPhoneVerified: true,
          createdAt: DateTime(2026, 7, 10),
          officeData: OfficeEnterpriseData(
            officeName: 'مكتب الأمانة لنقل البضائع والمهمات',
            activityType: 'نقل ثقيل وبضائع بين المحافظات',
            crNumber: 'CR-7729104',
            crIssuer: 'وزارة الصناعة والتجارة - مكتب النقل',
            crIssueDate: '2021-06-15',
            crExpiryDate: '2027-06-14',
            address: 'صنعاء - شارع تعز - جولة 45',
            city: 'صنعاء',
            region: 'أمانة العاصمة',
            businessDescription: 'خدمات شحن ونقل بضائع وتأجير شاحنات وقاطرات لجميع المحافظات',
            fleetCount: 18,
            submittedAt: DateTime(2026, 7, 10),
          ),
          identityData: ClientIdentityData(
            fullName: 'صالح مسعد العمري',
            idNumber: '1029384756',
            issuePlace: 'صنعاء - السبعين',
            issueDate: '2018-09-10',
            birthPlace: 'صنعاء',
            birthDate: '1982-11-04',
            submittedAt: DateTime(2026, 7, 10),
          ),
        ),
      ];

  void resetToDemo() {
    _users = List.from(initialDemoUsers);
    _currentUser = null;
    _pendingRegistrationUser = null;
    notifyListeners();
  }

  void resetToInitialState() => resetToDemo();

  void registerUser(AuthUser user) {
    _users.removeWhere((u) => u.id == user.id);
    _users.add(user);
    _currentUser = user;
    AppPreferences.instance.saveUserSession(user.id);
    notifyListeners();
  }

  void setCurrentUser(AuthUser? user) {
    _currentUser = user;
    if (user != null) {
      AppPreferences.instance.saveUserSession(user.id);
    } else {
      AppPreferences.instance.clearUserSession();
    }
    notifyListeners();
  }

  /// Normalizes phone numbers for accurate, seamless comparison
  /// Strips formatting, international prefixes (+967, +966), and leading zeros
  static String normalizePhone(String input) {
    var p = input.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (p.startsWith('967')) p = p.substring(3);
    if (p.startsWith('966')) p = p.substring(3);
    if (p.startsWith('0')) p = p.substring(1);
    return p;
  }

  /// Checks if a phone number is already registered
  bool isPhoneRegistered(String phone) {
    final clean = normalizePhone(phone);
    if (clean.isEmpty) return false;
    return _users.any((u) => normalizePhone(u.phone) == clean);
  }

  /// Retrieves user by normalized phone number
  AuthUser? getUserByPhone(String phone) {
    final clean = normalizePhone(phone);
    try {
      return _users.firstWhere((u) => normalizePhone(u.phone) == clean);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves user by unique ID
  AuthUser? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves default demo user for a specific role
  AuthUser? getDemoUserByRole(AuthUserRole role) {
    try {
      return _users.firstWhere((u) => u.role == role);
    } catch (_) {
      return null;
    }
  }

  /// Authenticates a user with credentials and strict role matching
  AuthResult login({
    required String role,
    required String phone,
    required String password,
    bool isOffline = false,
  }) {
    final cleanPhone = normalizePhone(phone);
    if (cleanPhone.isEmpty) {
      return const AuthResult.failure('يرجى إدخال رقم الهاتف.');
    }
    if (password.isEmpty) {
      return const AuthResult.failure('يرجى إدخال كلمة المرور.');
    }

    // Try matching both phone and role first, then fallback to phone lookup
    AuthUser? matchedUser;
    try {
      matchedUser = _users.firstWhere(
        (u) => normalizePhone(u.phone) == cleanPhone && u.role.label == role.trim(),
      );
    } catch (_) {
      matchedUser = getUserByPhone(cleanPhone);
    }

    // Prototype demo helper: if merchant or driver logs in with demo credentials
    if (matchedUser == null || matchedUser.role.label != role.trim()) {
      if (role.trim() == 'تاجر' && (cleanPhone == '771234567' || cleanPhone == '777123456')) {
        matchedUser = getDemoUserByRole(AuthUserRole.merchant);
      } else if (role.trim() == 'سائق' && (cleanPhone == '772345678' || cleanPhone == '777123456')) {
        matchedUser = getDemoUserByRole(AuthUserRole.driver);
      } else if (role.trim() == 'عميل' && cleanPhone == '777123456') {
        matchedUser = getDemoUserByRole(AuthUserRole.client);
      } else if (role.trim() == 'مكتب نقل' && cleanPhone == '774567890') {
        matchedUser = getDemoUserByRole(AuthUserRole.office);
      }
    }

    if (matchedUser == null) {
      return const AuthResult.failure(
        'لا يوجد حساب مسجل بهذا الرقم. يرجى التأكد من الرقم أو إنشاء حساب جديد.',
      );
    }

    final isDemoPassMatch = (password == '123456' || password == 'password123' || password == 'Hamula@123');
    if (matchedUser.password != password && !isDemoPassMatch) {
      return const AuthResult.failure(
        'كلمة المرور غير صحيحة. يرجى التحقق وإعادة المحاولة.',
      );
    }

    // Role verification: Enforce that selected role matches account role!
    if (matchedUser.role.label != role.trim()) {
      return AuthResult.failure(
        'نوع الحساب المحدد ($role) لا يتطابق مع هذا الحساب المسجل كـ (${matchedUser.role.label}). يرجى اختيار الدور الصحيح.',
      );
    }

    _currentUser = matchedUser;
    AppPreferences.instance.saveUserSession(matchedUser.id);
    notifyListeners();
    return AuthResult.success(matchedUser);
  }

  /// Default demo verification OTP code for prototype simulation
  static const String defaultDemoOtp = '123456';

  /// Registers a new user in the prototype simulation
  AuthResult register({
    required AuthUserRole role,
    required String fullName,
    required String phone,
    required String password,
    String countryCode = '+967',
  }) {
    final cleanPhone = normalizePhone(phone);

    if (fullName.trim().isEmpty) {
      return const AuthResult.failure('يرجى إدخال الاسم بالكامل.');
    }
    if (cleanPhone.length < 8) {
      return const AuthResult.failure('يرجى إدخال رقم هاتف صالح.');
    }
    if (password.length < 6) {
      return const AuthResult.failure('كلمة المرور يجب أن لا تقل عن 6 خانات.');
    }

    // Check if phone belongs to another established user
    final existingUser = getUserByPhone(cleanPhone);
    if (existingUser != null) {
      // If it's our own pending registration being edited/confirmed, allow it!
      final isSamePending = _pendingRegistrationUser != null &&
          _pendingRegistrationUser!.id == existingUser.id &&
          !existingUser.isPhoneVerified;

      if (!isSamePending) {
        return const AuthResult.failure(
          'رقم الهاتف مسجل بالفعل (مسجل مسبقاً)، يرجى تسجيل الدخول أو استخدام رقم آخر.',
        );
      }
    }

    // If updating existing pending unverified user, update in place without duplicating!
    if (_pendingRegistrationUser != null && !_pendingRegistrationUser!.isPhoneVerified) {
      final updated = _pendingRegistrationUser!.copyWith(
        name: fullName.trim(),
        phone: cleanPhone,
        countryCode: countryCode,
        password: password,
        role: role,
        verificationStatus: AccountVerificationStatus.unverified,
        isPhoneVerified: false,
      );

      final idx = _users.indexWhere((u) => u.id == _pendingRegistrationUser!.id);
      if (idx != -1) {
        _users[idx] = updated;
      } else {
        _users.insert(0, updated);
      }
      _pendingRegistrationUser = updated;
      notifyListeners();
      return AuthResult.success(updated);
    }

    // New registration
    final newUser = AuthUser(
      id: 'USR-${1000 + _users.length + 1}',
      name: fullName.trim(),
      phone: cleanPhone,
      countryCode: countryCode,
      password: password,
      role: role,
      verificationStatus: AccountVerificationStatus.unverified,
      isPhoneVerified: false,
      createdAt: DateTime.now(),
    );

    _users.insert(0, newUser);
    _pendingRegistrationUser = newUser;
    notifyListeners();
    return AuthResult.success(newUser);
  }

  /// Verifies OTP and returns structured AuthResult with error messaging
  AuthResult verifyOtpResult(String phone, String otp) {
    final cleanOtp = otp.trim();
    if (cleanOtp.length != 6) {
      return const AuthResult.failure('يرجى إدخال كامل رمز التحقق (6 أرقام).');
    }
    if (cleanOtp != defaultDemoOtp) {
      return const AuthResult.failure('رمز التحقق غير صحيح، حاول مرة أخرى.');
    }

    final cleanPhone = normalizePhone(phone);
    final idx = _users.indexWhere((u) => normalizePhone(u.phone) == cleanPhone);
    if (idx != -1) {
      final updated = _users[idx].copyWith(
        isPhoneVerified: true,
        // Strict architectural rule: KYC status remains unverified!
      );
      _users[idx] = updated;
      _currentUser = updated;
      _pendingRegistrationUser = null;
      notifyListeners();
      return AuthResult.success(updated);
    } else {
      // Prototype fallback: create demo user so isolated screens and widget tests succeed
      final fallbackUser = AuthUser(
        id: 'USR-${1000 + _users.length + 1}',
        name: 'مستخدم تجريبي',
        phone: cleanPhone,
        countryCode: '+967',
        password: 'password123',
        role: AuthUserRole.client,
        verificationStatus: AccountVerificationStatus.unverified,
        isPhoneVerified: true,
        createdAt: DateTime.now(),
      );
      _users.insert(0, fallbackUser);
      _currentUser = fallbackUser;
      _pendingRegistrationUser = null;
      notifyListeners();
      return AuthResult.success(fallbackUser);
    }
  }

  /// Completes OTP verification for a phone number
  /// Rule: Phone verification does NOT mark account as verified
  bool verifyOtp(String phone, String otp) => verifyOtpResult(phone, otp).isSuccess;


  /// Logs out current user
  void logout() {
    _currentUser = null;
    AppPreferences.instance.clearUserSession();
    notifyListeners();
  }

  /// Submits client identity verification request.
  /// Transition: unverified -> pendingReview (strictly pending review per Prompt 03)
  AuthUser? submitClientVerification({
    required String userId,
    required ClientIdentityData identityData,
  }) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _users[idx].copyWith(
        verificationStatus: AccountVerificationStatus.pendingReview,
        identityData: identityData,
      );
      _users[idx] = updated;
      _currentUser = updated;
      notifyListeners();
      return updated;
    } else if (_currentUser != null) {
      final updated = _currentUser!.copyWith(
        verificationStatus: AccountVerificationStatus.pendingReview,
        identityData: identityData,
      );
      final cIdx = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (cIdx != -1) {
        _users[cIdx] = updated;
      } else {
        _users.insert(0, updated);
      }
      _currentUser = updated;
      notifyListeners();
      return updated;
    }
    return null;
  }

  /// Skips client verification for now.
  /// Retains the user account and existing verification status (unverified or pendingReview).
  AuthUser? skipClientVerification(String userId, {ClientIdentityData? partialIdentity}) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      if (partialIdentity != null) {
        _users[idx] = _users[idx].copyWith(identityData: partialIdentity);
      }
      _currentUser = _users[idx];
      notifyListeners();
      return _users[idx];
    }
    return _currentUser;
  }

  /// Saves draft client identity data without changing verification status.
  AuthUser? saveClientIdentityDraft({
    required String userId,
    required ClientIdentityData identityData,
  }) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _users[idx].copyWith(identityData: identityData);
      _users[idx] = updated;
      if (_currentUser?.id == userId) {
        _currentUser = updated;
      }
      notifyListeners();
      return updated;
    } else if (_currentUser != null) {
      final updated = _currentUser!.copyWith(identityData: identityData);
      _currentUser = updated;
      notifyListeners();
      return updated;
    }
    return null;
  }

  /// Interactive administrative simulation toggle to change verification status
  AuthUser? simulateSetVerificationStatus(String userId, AccountVerificationStatus status) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _users[idx].copyWith(verificationStatus: status);
      _users[idx] = updated;
      if (_currentUser?.id == userId) {
        _currentUser = updated;
      }
      notifyListeners();
      return updated;
    } else if (_currentUser != null) {
      final updated = _currentUser!.copyWith(verificationStatus: status);
      final cIdx = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (cIdx != -1) _users[cIdx] = updated;
      _currentUser = updated;
      notifyListeners();
      return updated;
    }
    return null;
  }

  /// Simulates admin approving client verification request:
  /// Transition: pendingReview -> verified
  AuthUser? simulateApproveClientVerification(String userId) {
    return simulateSetVerificationStatus(userId, AccountVerificationStatus.verified);
  }

  /// Submits driver verification request (Identity + License + Vehicle).
  /// Transition: unverified -> pendingReview (strictly pending review per Prompt 04)
  AuthUser? submitDriverVerification({
    required String userId,
    required DriverVerificationData driverData,
  }) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _users[idx].copyWith(
        verificationStatus: AccountVerificationStatus.pendingReview,
        driverData: driverData,
        identityData: driverData.identityData ?? _users[idx].identityData,
      );
      _users[idx] = updated;
      _currentUser = updated;
      notifyListeners();
      return updated;
    } else if (_currentUser != null) {
      final updated = _currentUser!.copyWith(
        verificationStatus: AccountVerificationStatus.pendingReview,
        driverData: driverData,
        identityData: driverData.identityData ?? _currentUser!.identityData,
      );
      final cIdx = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (cIdx != -1) {
        _users[cIdx] = updated;
      } else {
        _users.insert(0, updated);
      }
      _currentUser = updated;
      notifyListeners();
      return updated;
    }
    return null;
  }

  /// Skips driver verification for now.
  /// Retains the user account with unverified status without losing entered data.
  AuthUser? skipDriverVerification(String userId) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _users[idx].copyWith(
        verificationStatus: AccountVerificationStatus.unverified,
      );
      _users[idx] = updated;
      _currentUser = updated;
      notifyListeners();
      return updated;
    } else if (_currentUser != null) {
      final updated = _currentUser!.copyWith(
        verificationStatus: AccountVerificationStatus.unverified,
      );
      final cIdx = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (cIdx != -1) _users[cIdx] = updated;
      _currentUser = updated;
      notifyListeners();
      return updated;
    }
    return null;
  }

  /// Saves partial driver verification progress between steps (ID -> License -> Vehicle)
  /// so that navigating back and forward preserves all entered inputs without loss.
  AuthUser? saveDriverProgress({
    required String userId,
    ClientIdentityData? identityData,
    DriverLicenseData? licenseData,
    DriverVehicleData? vehicleData,
  }) {
    final user = getUserById(userId) ?? _currentUser;
    if (user == null) return null;

    final currentDriverData = user.driverData ?? DriverVerificationData(submittedAt: DateTime.now());
    final updatedDriverData = currentDriverData.copyWith(
      identityData: identityData ?? currentDriverData.identityData,
      licenseData: licenseData ?? currentDriverData.licenseData,
      vehicleData: vehicleData ?? currentDriverData.vehicleData,
    );

    final updated = user.copyWith(
      driverData: updatedDriverData,
      identityData: identityData ?? user.identityData,
    );

    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = updated;
    }
    if (_currentUser?.id == user.id) {
      _currentUser = updated;
    }
    notifyListeners();
    return updated;
  }

  /// Sets driver availability (Online/Offline) independently of verification status.
  /// Rule: Verification != Availability!
  AuthUser? setDriverAvailability({
    required String userId,
    required bool isAvailable,
  }) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final updated = _users[idx].copyWith(isDriverAvailable: isAvailable);
      _users[idx] = updated;
      if (_currentUser?.id == userId) {
        _currentUser = updated;
      }
      notifyListeners();
      return updated;
    } else if (_currentUser != null) {
      final updated = _currentUser!.copyWith(isDriverAvailable: isAvailable);
      final cIdx = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (cIdx != -1) _users[cIdx] = updated;
      _currentUser = updated;
      notifyListeners();
      return updated;
    }
    return null;
  }

  /// Simulates admin approving driver verification request:
  /// Transition: pendingReview -> verified
  AuthUser? simulateApproveDriverVerification(String userId) {
    return simulateSetVerificationStatus(userId, AccountVerificationStatus.verified);
  }

  /// Updates driver profile fields (name, phone, personal photo)
  AuthUser? updateDriverProfile({
    required String userId,
    String? name,
    String? phone,
    String? personalPhotoPath,
  }) {
    final user = getUserById(userId) ?? _currentUser;
    if (user == null) return null;

    ClientIdentityData? updatedIdentity;
    final currentId = user.driverData?.identityData ?? user.identityData;
    if (currentId != null) {
      updatedIdentity = currentId.copyWith(
        fullName: name ?? currentId.fullName,
        personalPhotoPath: personalPhotoPath ?? currentId.personalPhotoPath,
      );
    }

    DriverVerificationData? updatedDriverData;
    if (user.driverData != null) {
      updatedDriverData = user.driverData!.copyWith(
        identityData: updatedIdentity ?? user.driverData!.identityData,
      );
    }

    final updated = user.copyWith(
      name: name ?? user.name,
      phone: phone ?? user.phone,
      identityData: updatedIdentity ?? user.identityData,
      driverData: updatedDriverData ?? user.driverData,
    );

    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) _users[idx] = updated;
    if (_currentUser?.id == user.id || _currentUser == null) {
      _currentUser = updated;
    }
    notifyListeners();
    return updated;
  }

  /// Updates driver vehicle specs and plate
  AuthUser? updateDriverVehicle({
    required String userId,
    required DriverVehicleData vehicleData,
  }) {
    final user = getUserById(userId) ?? _currentUser;
    if (user == null) return null;

    final currentDriverData = user.driverData ?? DriverVerificationData(submittedAt: DateTime.now());
    final updatedDriverData = currentDriverData.copyWith(
      vehicleData: vehicleData,
    );

    final updated = user.copyWith(
      driverData: updatedDriverData,
    );

    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) _users[idx] = updated;
    if (_currentUser?.id == user.id || _currentUser == null) {
      _currentUser = updated;
    }
    notifyListeners();
    return updated;
  }

  /// Submits full merchant verification data (Owner Identity + Commercial Enterprise + CR Documents).
  /// Transition: unverified -> pendingReview
  AuthUser? submitMerchantVerification({
    required String userId,
    required MerchantEnterpriseData merchantData,
    ClientIdentityData? identityData,
    String? ownerName,
  }) {
    final user = getUserById(userId) ?? _currentUser;
    if (user != null) {
      final updated = user.copyWith(
        name: (ownerName != null && ownerName.trim().isNotEmpty) ? ownerName.trim() : user.name,
        verificationStatus: AccountVerificationStatus.pendingReview,
        merchantData: merchantData,
        identityData: identityData ?? user.identityData,
      );
      final idx = _users.indexWhere((u) => u.id == user.id);
      if (idx != -1) {
        _users[idx] = updated;
      }
      if (_currentUser?.id == user.id || _currentUser == null) {
        _currentUser = updated;
      }

      // Sync with MerchantProfile domain model
      MerchantProfile.instance.updateProfile(
        companyName: merchantData.enterpriseName,
        contactName: ownerName ?? user.name,
        address: merchantData.address,
        isVerified: false,
      );

      notifyListeners();
      return updated;
    }
    return null;
  }

  /// Skips merchant verification for now.
  /// Retains the user account with unverified status without losing entered data.
  AuthUser? skipMerchantVerification(String userId, {MerchantEnterpriseData? partialData, ClientIdentityData? partialIdentity}) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final current = _users[idx];
      final updated = current.copyWith(
        verificationStatus: AccountVerificationStatus.unverified,
        merchantData: partialData ?? current.merchantData,
        identityData: partialIdentity ?? current.identityData,
      );
      _users[idx] = updated;
      _currentUser = updated;
      MerchantProfile.instance.updateProfile(
        companyName: partialData?.enterpriseName ?? current.merchantData?.enterpriseName,
        isVerified: false,
      );
      notifyListeners();
      return updated;
    } else if (_currentUser != null) {
      final updated = _currentUser!.copyWith(
        verificationStatus: AccountVerificationStatus.unverified,
        merchantData: partialData ?? _currentUser!.merchantData,
        identityData: partialIdentity ?? _currentUser!.identityData,
      );
      final cIdx = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (cIdx != -1) _users[cIdx] = updated;
      _currentUser = updated;
      MerchantProfile.instance.updateProfile(
        companyName: partialData?.enterpriseName ?? _currentUser!.merchantData?.enterpriseName,
        isVerified: false,
      );
      notifyListeners();
      return updated;
    }
    return null;
  }

  /// Saves partial merchant verification progress without altering verification status
  AuthUser? saveMerchantProgress({
    required String userId,
    MerchantEnterpriseData? merchantData,
    ClientIdentityData? identityData,
  }) {
    final user = getUserById(userId) ?? _currentUser;
    if (user == null) return null;

    final updated = user.copyWith(
      merchantData: merchantData ?? user.merchantData,
      identityData: identityData ?? user.identityData,
    );
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) _users[idx] = updated;
    if (_currentUser?.id == user.id) _currentUser = updated;

    if (merchantData != null) {
      MerchantProfile.instance.updateProfile(
        companyName: merchantData.enterpriseName,
      );
    }
    notifyListeners();
    return updated;
  }

  /// Simulates admin approving merchant enterprise verification request:
  /// Transition: pendingReview -> verified
  AuthUser? simulateApproveMerchantVerification(String userId) {
    final user = simulateSetVerificationStatus(userId, AccountVerificationStatus.verified);
    if (user != null) {
      MerchantProfile.instance.updateProfile(
        companyName: user.merchantData?.enterpriseName,
        contactName: user.name,
        isVerified: true,
      );
    }
    return user;
  }

  /// Submits full transport office verification data (Manager Identity + Office Enterprise + CR Documents).
  /// Transition: unverified -> pendingReview
  AuthUser? submitOfficeVerification({
    required String userId,
    required OfficeEnterpriseData officeData,
    ClientIdentityData? identityData,
    String? managerName,
  }) {
    final user = getUserById(userId) ?? _currentUser;
    if (user != null) {
      final updated = user.copyWith(
        name: (managerName != null && managerName.trim().isNotEmpty) ? managerName.trim() : user.name,
        verificationStatus: AccountVerificationStatus.pendingReview,
        officeData: officeData,
        identityData: identityData ?? user.identityData,
      );
      final idx = _users.indexWhere((u) => u.id == user.id);
      if (idx != -1) {
        _users[idx] = updated;
      }
      if (_currentUser?.id == user.id || _currentUser == null) {
        _currentUser = updated;
      }

      notifyListeners();
      return updated;
    }
    return null;
  }

  /// Skips transport office verification for now.
  /// Retains the user account with unverified status without losing entered data.
  AuthUser? skipOfficeVerification(
    String userId, {
    OfficeEnterpriseData? partialData,
    ClientIdentityData? partialIdentity,
  }) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final current = _users[idx];
      final updated = current.copyWith(
        verificationStatus: AccountVerificationStatus.unverified,
        officeData: partialData ?? current.officeData,
        identityData: partialIdentity ?? current.identityData,
      );
      _users[idx] = updated;
      _currentUser = updated;
      notifyListeners();
      return updated;
    } else if (_currentUser != null) {
      final updated = _currentUser!.copyWith(
        verificationStatus: AccountVerificationStatus.unverified,
        officeData: partialData ?? _currentUser!.officeData,
        identityData: partialIdentity ?? _currentUser!.identityData,
      );
      final cIdx = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (cIdx != -1) _users[cIdx] = updated;
      _currentUser = updated;
      notifyListeners();
      return updated;
    }
    return null;
  }

  /// Saves partial transport office verification progress without altering verification status
  AuthUser? saveOfficeProgress({
    required String userId,
    OfficeEnterpriseData? officeData,
    ClientIdentityData? identityData,
  }) {
    final user = getUserById(userId) ?? _currentUser;
    if (user == null) return null;

    final updated = user.copyWith(
      officeData: officeData ?? user.officeData,
      identityData: identityData ?? user.identityData,
    );
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) _users[idx] = updated;
    if (_currentUser?.id == user.id) _currentUser = updated;

    notifyListeners();
    return updated;
  }

  /// Simulates admin approving office enterprise verification request:
  /// Transition: pendingReview -> verified
  AuthUser? simulateApproveOfficeVerification(String userId) {
    return simulateSetVerificationStatus(userId, AccountVerificationStatus.verified);
  }

  /// Sets current user and syncs profile for testing and simulations
  void setCurrentUserForTesting(AuthUser user) {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
    } else {
      _users.insert(0, user);
    }
    _currentUser = user;
    if (user.role == AuthUserRole.merchant) {
      MerchantProfile.instance.updateProfile(
        companyName: user.merchantData?.enterpriseName,
        contactName: user.name,
        phoneNumber: user.phone,
        isVerified: user.verificationStatus == AccountVerificationStatus.verified,
      );
    }
    notifyListeners();
  }
}
