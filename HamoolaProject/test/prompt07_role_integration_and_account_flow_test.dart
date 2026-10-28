import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/auth/presentation/screens/identity_verification_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/otp_verify_screen.dart';
import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthSimulationStore.instance.resetToInitialState();
    MerchantSimulationStore.instance.resetToInitialState();
  });

  group('Prompt 07: 12 Mandatory Integration & Lifecycle Test Scenarios', () {
    // -------------------------------------------------------------------------
    // Scenario 1: New Account Registration for All 4 Roles
    // -------------------------------------------------------------------------
    test('1. New account registration correctly provisions all four distinct roles', () {
      final store = AuthSimulationStore.instance;

      final rolesToTest = [
        (AuthUserRole.client, 'عميل تجريبي جديد', '770000001'),
        (AuthUserRole.driver, 'سائق تجريبي جديد', '770000002'),
        (AuthUserRole.merchant, 'تاجر تجريبي جديد', '770000003'),
        (AuthUserRole.office, 'مكتب نقل تجريبي جديد', '770000004'),
      ];

      for (final item in rolesToTest) {
        final result = store.register(
          role: item.$1,
          fullName: item.$2,
          phone: item.$3,
          password: 'password123',
        );

        expect(result.isSuccess, isTrue, reason: 'Registration failed for role ${item.$1}');
        final user = result.user!;
        expect(user.role, equals(item.$1));
        expect(user.name, equals(item.$2));
        expect(user.phone, equals(item.$3));
        expect(user.isPhoneVerified, isFalse, reason: 'New account must start phone unverified');
        expect(user.verificationStatus, equals(AccountVerificationStatus.unverified),
            reason: 'New account must start KYC unverified');
      }
    });

    // -------------------------------------------------------------------------
    // Scenario 2: Valid and Invalid Phone OTP Verification
    // -------------------------------------------------------------------------
    test('2. OTP verification distinguishes between valid and invalid codes & preserves KYC status', () {
      final store = AuthSimulationStore.instance;
      final regResult = store.register(
        role: AuthUserRole.client,
        fullName: 'أحمد صالح',
        phone: '770111222',
        password: 'password123',
      );
      expect(regResult.isSuccess, isTrue);

      // Attempt invalid code
      final invalidResult = store.verifyOtpResult('770111222', '000000');
      expect(invalidResult.isSuccess, isFalse);
      expect(invalidResult.errorMessage, contains('رمز التحقق غير صحيح'));

      // Check user is still not phone-verified
      final userBefore = store.getUserByPhone('770111222');
      expect(userBefore?.isPhoneVerified, isFalse);

      // Submit valid code (123456)
      final validResult = store.verifyOtpResult('770111222', '123456');
      expect(validResult.isSuccess, isTrue);
      expect(validResult.user?.isPhoneVerified, isTrue);

      // CRITICAL RULE: Phone verification does NOT mark account as KYC verified
      expect(validResult.user?.verificationStatus, equals(AccountVerificationStatus.unverified));
    });

    // -------------------------------------------------------------------------
    // Scenario 3: Completing and Submitting KYC Verification for Each Role
    // -------------------------------------------------------------------------
    test('3. Verification submission transitions account to pending_review for each role', () {
      final store = AuthSimulationStore.instance;

      // 3a. Client Identity Verification
      final clientReg = store.register(
        role: AuthUserRole.client,
        fullName: 'عميل التوثيق',
        phone: '770222333',
        password: 'password123',
      );
      store.verifyOtp('770222333', '123456');
      final clientSubmitted = store.submitClientVerification(
        userId: clientReg.user!.id,
        identityData: ClientIdentityData(
          fullName: 'عميل التوثيق الكامل',
          idNumber: '1098765432',
          issuePlace: 'صنعاء',
          issueDate: '2022-01-01',
          birthPlace: 'صنعاء',
          birthDate: '1990-01-01',
          submittedAt: DateTime.now(),
        ),
      );
      expect(clientSubmitted?.verificationStatus, equals(AccountVerificationStatus.pendingReview));

      // 3b. Driver Multi-Step Verification
      final driverReg = store.register(
        role: AuthUserRole.driver,
        fullName: 'سائق التوثيق',
        phone: '770333444',
        password: 'password123',
      );
      store.verifyOtp('770333444', '123456');
      final driverSubmitted = store.submitDriverVerification(
        userId: driverReg.user!.id,
        driverData: DriverVerificationData(
          identityData: ClientIdentityData(
            fullName: 'سائق التوثيق الكامل',
            idNumber: '1029384756',
            issuePlace: 'عدن',
            issueDate: '2020-05-10',
            birthPlace: 'عدن',
            birthDate: '1988-03-12',
            submittedAt: DateTime.now(),
          ),
          licenseData: const DriverLicenseData(
            licenseNumber: 'LIC-883920',
            licenseCategory: 'نقل ثقيل',
            issuePlace: 'إدارة المرور',
            issueDate: '2020-01-01',
            expiryDate: '2030-01-01',
          ),
          vehicleData: const DriverVehicleData(
            vehicleType: 'شاحنة تبريد',
            category: 'نقل ثقيل',
            manufacturer: 'مرسيدس',
            model: 'أكتروس',
            year: '2022',
            plateNumber: '12345-عدن',
            color: 'أبيض',
            maxCapacity: '15 طن',
            bodyType: 'تبريد',
          ),
          submittedAt: DateTime.now(),
        ),
      );
      expect(driverSubmitted?.verificationStatus, equals(AccountVerificationStatus.pendingReview));

      // 3c. Merchant Commercial Verification
      final merchantReg = store.register(
        role: AuthUserRole.merchant,
        fullName: 'تاجر التوثيق',
        phone: '770444555',
        password: 'password123',
      );
      store.verifyOtp('770444555', '123456');
      final merchantSubmitted = store.submitMerchantVerification(
        userId: merchantReg.user!.id,
        merchantData: MerchantEnterpriseData(
          enterpriseName: 'شركة النجم التجاري',
          businessType: 'استيراد وتوزيع',
          crNumber: 'CR-554433',
          submittedAt: DateTime.now(),
        ),
        identityData: ClientIdentityData(
          fullName: 'تاجر التوثيق',
          idNumber: '1038294719',
          issuePlace: 'الحديدة',
          issueDate: '2019-02-02',
          birthPlace: 'الحديدة',
          birthDate: '1982-04-15',
          submittedAt: DateTime.now(),
        ),
      );
      expect(merchantSubmitted?.verificationStatus, equals(AccountVerificationStatus.pendingReview));

      // 3d. Transport Office Verification
      final officeReg = store.register(
        role: AuthUserRole.office,
        fullName: 'مكتب التوثيق',
        phone: '770555666',
        password: 'password123',
      );
      store.verifyOtp('770555666', '123456');
      final officeSubmitted = store.submitOfficeVerification(
        userId: officeReg.user!.id,
        officeData: const OfficeEnterpriseData(
          officeName: 'مكتب الوفاق للنقل والشحن',
          activityType: 'نقل لوجستي شامل',
          crNumber: 'CR-998877',
        ),
        identityData: ClientIdentityData(
          fullName: 'مكتب التوثيق المدير',
          idNumber: '1092837465',
          issuePlace: 'تعز',
          issueDate: '2018-06-01',
          birthPlace: 'تعز',
          birthDate: '1979-11-20',
          submittedAt: DateTime.now(),
        ),
      );
      expect(officeSubmitted?.verificationStatus, equals(AccountVerificationStatus.pendingReview));
    });

    // -------------------------------------------------------------------------
    // Scenario 4: Skipping Verification and Resuming Later Without Data Loss
    // -------------------------------------------------------------------------
    test('4. Skipping verification preserves account data and allows resuming from home', () {
      final store = AuthSimulationStore.instance;

      // Register and verify phone
      final reg = store.register(
        role: AuthUserRole.driver,
        fullName: 'سائق تخطي',
        phone: '770666777',
        password: 'password123',
      );
      store.verifyOtp('770666777', '123456');

      // User partially enters license data, then skips
      store.saveDriverProgress(
        userId: reg.user!.id,
        licenseData: const DriverLicenseData(
          licenseNumber: 'LIC-PROGRESS-123',
          licenseCategory: 'نقل عام',
          issuePlace: 'صنعاء',
          issueDate: '2021-01-01',
          expiryDate: '2031-01-01',
        ),
      );

      // User skips
      final skippedUser = store.skipDriverVerification(reg.user!.id);
      expect(skippedUser?.verificationStatus, equals(AccountVerificationStatus.unverified));

      // Verify that previously saved license progress is retained!
      final retrieved = store.getUserById(reg.user!.id);
      expect(retrieved?.driverData?.licenseData?.licenseNumber, equals('LIC-PROGRESS-123'));
      expect(retrieved?.driverData?.licenseData?.licenseCategory, equals('نقل عام'));

      // Later, user resumes and completes remaining vehicle data
      final finalSubmission = store.submitDriverVerification(
        userId: reg.user!.id,
        driverData: DriverVerificationData(
          licenseData: retrieved?.driverData?.licenseData,
          vehicleData: const DriverVehicleData(
            vehicleType: 'دينا قلاب',
            category: 'نقل متوسط',
            manufacturer: 'إيسوزو',
            model: 'NPR',
            year: '2020',
            plateNumber: '4455-صنعاء',
            color: 'أزرق',
            maxCapacity: '7 طن',
            bodyType: 'قلاب',
          ),
          submittedAt: DateTime.now(),
        ),
      );

      expect(finalSubmission?.verificationStatus, equals(AccountVerificationStatus.pendingReview));
      expect(finalSubmission?.driverData?.licenseData?.licenseNumber, equals('LIC-PROGRESS-123'));
    });

    // -------------------------------------------------------------------------
    // Scenario 5: Login with Unverified Account Within Permitted Boundaries
    // -------------------------------------------------------------------------
    test('5. Unverified account can log in and retain unverified status without auto-verification', () {
      final store = AuthSimulationStore.instance;

      // Unverified client
      store.register(
        role: AuthUserRole.client,
        fullName: 'عميل غير موثق',
        phone: '770777888',
        password: 'password123',
      );
      store.verifyOtp('770777888', '123456');

      // Log in
      final loginResult = store.login(
        role: 'عميل',
        phone: '770777888',
        password: 'password123',
      );

      expect(loginResult.isSuccess, isTrue);
      // Status must remain strictly unverified!
      expect(loginResult.user?.verificationStatus, equals(AccountVerificationStatus.unverified));
      expect(store.currentUser?.verificationStatus, equals(AccountVerificationStatus.unverified));
    });

    // -------------------------------------------------------------------------
    // Scenario 6: Login with Verified Account
    // -------------------------------------------------------------------------
    test('6. Verified accounts log in with correct role and status', () {
      final store = AuthSimulationStore.instance;

      // Merchant demo account
      final merchantLogin = store.login(
        role: 'تاجر',
        phone: '771234567',
        password: 'password123',
      );
      expect(merchantLogin.isSuccess, isTrue);
      expect(merchantLogin.user?.role, equals(AuthUserRole.merchant));
      expect(merchantLogin.user?.verificationStatus, equals(AccountVerificationStatus.verified));

      // Transport office demo account
      final officeLogin = store.login(
        role: 'مكتب نقل',
        phone: '774567890',
        password: 'password123',
      );
      expect(officeLogin.isSuccess, isTrue);
      expect(officeLogin.user?.role, equals(AuthUserRole.office));
      expect(officeLogin.user?.verificationStatus, equals(AccountVerificationStatus.verified));
    });

    // -------------------------------------------------------------------------
    // Scenario 7: Logout and Session Isolation Across Roles
    // -------------------------------------------------------------------------
    test('7. Logout properly clears active session and prevents state leakage across roles', () {
      final store = AuthSimulationStore.instance;

      // 1. Login as Trader
      store.login(role: 'تاجر', phone: '771234567', password: 'password123');
      expect(store.currentUser?.role, equals(AuthUserRole.merchant));
      expect(store.currentUser?.name, contains('محمد أحمد اليماني'));

      // 2. Perform Logout
      store.logout();
      expect(store.currentUser, isNull);

      // 3. Login as Driver
      store.login(role: 'سائق', phone: '772345678', password: 'password123');
      expect(store.currentUser?.role, equals(AuthUserRole.driver));
      expect(store.currentUser?.name, contains('كابتن أحمد السالمي'));

      // 4. Verify no merchant data is attached to the driver session
      expect(store.currentUser?.merchantData, isNull);
      expect(store.currentUser?.driverData, isNotNull);
    });

    // -------------------------------------------------------------------------
    // Scenario 8: Back-Navigation Without Form Data Loss
    // -------------------------------------------------------------------------
    test('8. Draft updates survive and avoid overwriting unrelated fields during editing', () {
      final store = AuthSimulationStore.instance;

      final reg = store.register(
        role: AuthUserRole.merchant,
        fullName: 'تاجر المسودة',
        phone: '770888999',
        password: 'password123',
      );
      final uid = reg.user!.id;

      // Save owner identity draft
      store.saveMerchantProgress(
        userId: uid,
        identityData: ClientIdentityData(
          fullName: 'الاسم المعدل للمالك',
          idNumber: '1092837465',
          issuePlace: 'صنعاء',
          issueDate: '2020-01-01',
          birthPlace: 'صنعاء',
          birthDate: '1985-01-01',
          submittedAt: DateTime.now(),
        ),
      );
      expect(store.getUserById(uid)?.identityData?.fullName, equals('الاسم المعدل للمالك'));

      // Save commercial register draft later
      store.saveMerchantProgress(
        userId: uid,
        merchantData: MerchantEnterpriseData(
          enterpriseName: 'شركة المسودة التجارية',
          crNumber: 'CR-DRAFT-1',
          submittedAt: DateTime.now(),
        ),
      );

      final userAfter = store.getUserById(uid);
      expect(userAfter?.identityData?.fullName, equals('الاسم المعدل للمالك'));
      expect(userAfter?.merchantData?.enterpriseName, equals('شركة المسودة التجارية'));
      expect(userAfter?.merchantData?.crNumber, equals('CR-DRAFT-1'));
    });

    // -------------------------------------------------------------------------
    // Scenario 9: Role Isolation and Access Control
    // -------------------------------------------------------------------------
    test('9. Role authentication rejects cross-role impersonation attempts', () {
      final store = AuthSimulationStore.instance;

      // Phone 771234567 is registered as Merchant. Attempting to log in as Driver must fail!
      final crossLoginResult = store.login(
        role: 'سائق',
        phone: '771234567',
        password: 'password123',
      );

      expect(crossLoginResult.isSuccess, isFalse);
      expect(crossLoginResult.errorMessage, contains('لا يتطابق مع هذا الحساب المسجل كـ (تاجر)'));

      // Attempting to log in as Customer must also fail
      final crossLoginCustomer = store.login(
        role: 'عميل',
        phone: '771234567',
        password: 'password123',
      );
      expect(crossLoginCustomer.isSuccess, isFalse);
    });

    // -------------------------------------------------------------------------
    // Scenario 10: Protection Against Rapid / Repeated Clicks
    // -------------------------------------------------------------------------
    test('10. Rapid repeated register and verification calls do not corrupt state or crash', () {
      final store = AuthSimulationStore.instance;

      // Simulate rapid double register
      final res1 = store.register(
        role: AuthUserRole.client,
        fullName: 'مستخدم سريع',
        phone: '770999000',
        password: 'password123',
      );
      expect(res1.isSuccess, isTrue);

      // Re-invoking register while pending registration updates existing in-place
      final res2 = store.register(
        role: AuthUserRole.client,
        fullName: 'مستخدم سريع معدل',
        phone: '770999000',
        password: 'password123',
      );
      expect(res2.isSuccess, isTrue);
      expect(res2.user?.id, equals(res1.user?.id));

      // Verify OTP repeatedly
      store.verifyOtp('770999000', '123456');
      store.verifyOtp('770999000', '123456');

      final user = store.getUserByPhone('770999000');
      expect(user?.isPhoneVerified, isTrue);
    });

    // -------------------------------------------------------------------------
    // Scenario 11: Preventing Duplicate Accounts & Duplicate Submissions
    // -------------------------------------------------------------------------
    test('11. Store rejects duplicate phone numbers for established accounts', () {
      final store = AuthSimulationStore.instance;

      // Driver demo account phone is 770123456
      final duplicateReg = store.register(
        role: AuthUserRole.merchant,
        fullName: 'محاولة مكررة',
        phone: '770123456',
        password: 'password123',
      );

      expect(duplicateReg.isSuccess, isFalse);
      expect(duplicateReg.errorMessage, contains('مسجل بالفعل'));
    });

    // -------------------------------------------------------------------------
    // Scenario 12: Router and Navigation Integrity Across Roles
    // -------------------------------------------------------------------------
    testWidgets('12. LoginScreen forwards to role-appropriate home and respects stored roles', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final store = AuthSimulationStore.instance;
      String? routedRole;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: LoginScreen(
                onSubmitLogin: (role, phone, password, isOffline) {
                  routedRole = role;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter merchant credentials
      final phoneField = find.byType(TextFormField).first;
      final passField = find.byType(TextFormField).last;

      // Select 'تاجر' tab
      await tester.tap(find.text('تاجر'));
      await tester.pumpAndSettle();

      await tester.enterText(phoneField, '771234567');
      await tester.enterText(passField, 'password123');

      final submitBtn = find.widgetWithText(ElevatedButton, 'تسجيل الدخول');
      await tester.tap(submitBtn);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(routedRole, equals('تاجر'));
      expect(store.currentUser?.role, equals(AuthUserRole.merchant));
    });

    testWidgets('12b. IdentityVerificationScreen loads cleanly with role and protects form', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: IdentityVerificationScreen(
                userId: 'USR-CLIENT-01',
                userName: 'عبدالله محمد',
                userPhone: '770987654',
                userRole: 'عميل',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the screen loads properly with title
      expect(find.text('توثيق الهوية الشخصية'), findsWidgets);
    });

    testWidgets('12c. OtpVerifyScreen loads cleanly with countdown and role badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: OtpVerifyScreen(
                phoneNumber: '+967 770 123 456',
                userRole: 'عميل',
                userName: 'سالم أحمد',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.otpTitle), findsOneWidget);
      expect(find.text(AppStrings.verifyButton), findsOneWidget);
    });
  });
}
