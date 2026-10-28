import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/auth/presentation/screens/identity_verification_screen.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_license_verification_screen.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_vehicle_verification_screen.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_home_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthSimulationStore.instance.resetToDemo();
  });

  Widget wrapWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    );
  }

  group('Prompt 04 — Driver Journey and Transporter Verification Flow Tests', () {
    // Journey 1: سائق يدخل بيانات الهوية والرخصة والناقلة بالتتابع
    testWidgets('Journey 1: Driver completes Identity, License, and Vehicle verification steps sequentially', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      // 1. Identity Screen for Driver
      bool identityNextCalled = false;
      await tester.pumpWidget(
        wrapWidget(
          IdentityVerificationScreen(
            userId: 'USR-DRIVER-01',
            userRole: 'سائق',
            onNext: () => identityNextCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check driver identity screen shows driver continue button
      expect(find.text('متابعة إلى رخصة القيادة'), findsOneWidget);
      final idNextBtn = find.text('متابعة إلى رخصة القيادة');
      await tester.ensureVisible(idNextBtn);
      await tester.tap(idNextBtn);
      await tester.pumpAndSettle();
      expect(identityNextCalled, isTrue);

      // 2. License Screen
      bool licenseNextCalled = false;
      await tester.pumpWidget(
        wrapWidget(
          DriverLicenseVerificationScreen(
            onNext: () => licenseNextCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('بيانات رخصة القيادة'), findsOneWidget);
      expect(find.text('DL-942851'), findsOneWidget);
      final licNextBtn = find.text('متابعة إلى بيانات المركبة');
      await tester.ensureVisible(licNextBtn);
      await tester.tap(licNextBtn);
      await tester.pumpAndSettle();
      expect(licenseNextCalled, isTrue);

      // 3. Vehicle Screen
      bool vehicleCompleteCalled = false;
      await tester.pumpWidget(
        wrapWidget(
          DriverVehicleVerificationScreen(
            onVerificationComplete: (val) => vehicleCompleteCalled = val,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('بيانات مركبتك'), findsOneWidget);
      expect(find.text('معلومات الخدمة ونطاق العمل'), findsOneWidget);
      expect(find.text('7198 د ح ي'), findsOneWidget);

      final submitBtn = find.text('إرسال طلب التوثيق');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('تم توثيق بيانات السائق والمركبة بنجاح ✓'), findsOneWidget);
      final continueHomeBtn = find.text('متابعة إلى الرئيسية');
      await tester.tap(continueHomeBtn);
      await tester.pumpAndSettle();
      expect(vehicleCompleteCalled, isTrue);
    });

    // Journey 2: سائق يرسل طلب التوثيق وتظهر الرئيسية بحالة قيد المراجعة
    testWidgets('Journey 2: Driver submits verification and Home reflects pendingReview state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      // Driver submits verification
      store.submitDriverVerification(
        userId: 'USR-DRIVER-01',
        driverData: DriverVerificationData(
          licenseData: const DriverLicenseData(
            licenseNumber: 'DL-942851',
            licenseCategory: 'نقل ثقيل (شاحنات وقاطرات)',
            issuePlace: 'تعز',
            issueDate: '2021-09-15',
            expiryDate: '2026-09-14',
          ),
          vehicleData: const DriverVehicleData(
            vehicleType: 'شاحنة نقل',
            category: 'نقل ثقيل',
            manufacturer: 'مرسيدس',
            model: 'أكتروس',
            year: '2023',
            plateNumber: '7198 د ح ي',
            color: 'أبيض',
            maxCapacity: '25',
            bodyType: 'صندوق مغلق',
          ),
          submittedAt: DateTime.now(),
        ),
      );

      final user = store.users.firstWhere((u) => u.id == 'USR-DRIVER-01');
      expect(user.verificationStatus, equals(AccountVerificationStatus.pendingReview));

      await tester.pumpWidget(wrapWidget(const DriverHomeScreen()));
      await tester.pumpAndSettle();

      // Check pending review banner
      expect(find.text('طلب التوثيق قيد المراجعة'), findsOneWidget);
      expect(find.text('عرض الطلب'), findsOneWidget);

      // Verify bidding is locked in pending review state
      final bidBtn = find.text('تقديم عرض سعر').first;
      await tester.ensureVisible(bidBtn);
      await tester.tap(bidBtn);
      await tester.pumpAndSettle();

      expect(find.text('الطلب قيد المراجعة'), findsWidgets);
      expect(find.textContaining('سيتم إتاحة تقديم عروض الأسعار فور اعتماد الحساب'), findsOneWidget);
    });

    // Journey 3: سائق يتخطى التوثيق ويصل إلى الرئيسية بحالة غير موثق
    testWidgets('Journey 3: Driver skips verification and Home reflects unverified state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      store.skipDriverVerification('USR-DRIVER-01');

      final user = store.users.firstWhere((u) => u.id == 'USR-DRIVER-01');
      expect(user.verificationStatus, equals(AccountVerificationStatus.unverified));

      await tester.pumpWidget(wrapWidget(const DriverHomeScreen()));
      await tester.pumpAndSettle();

      // Check unverified banner and action button
      expect(find.text('حسابك غير موثق'), findsOneWidget);
      expect(find.text('استكمال التوثيق'), findsOneWidget);

      // Verify bidding restriction dialog appears
      final bidBtn = find.text('تقديم عرض سعر').first;
      await tester.ensureVisible(bidBtn);
      await tester.tap(bidBtn);
      await tester.pumpAndSettle();

      expect(find.text('توثيق الحساب مطلوب'), findsOneWidget);
      expect(find.textContaining('يلزم إكمال إدخال بيانات الهوية والرخصة والناقلة'), findsOneWidget);
    });

    // Journey 4: سائق يعود لاحقاً لاستكمال التوثيق
    testWidgets('Journey 4: Driver returns to complete verification from Home banner', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      store.skipDriverVerification('USR-DRIVER-01');

      bool completeVerificationTapped = false;
      await tester.pumpWidget(
        wrapWidget(
          DriverHomeScreen(
            onVerifyLicense: () => completeVerificationTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final completeBtn = find.text('استكمال التوثيق');
      expect(completeBtn, findsOneWidget);
      await tester.tap(completeBtn);
      await tester.pumpAndSettle();

      expect(completeVerificationTapped, isTrue);
    });

    // Journey 5: سائق معتمد يصل إلى الخدمات التي تتطلب التوثيق
    testWidgets('Journey 5: Verified driver has full access to bidding and services', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      store.simulateApproveDriverVerification('USR-DRIVER-01');

      await tester.pumpWidget(wrapWidget(const DriverHomeScreen()));
      await tester.pumpAndSettle();

      // Check verified badge
      expect(find.text('معتمد ✓'), findsOneWidget);
      expect(find.textContaining('حساب موثق ومؤهل لتقديم عروض الأسعار'), findsOneWidget);

      // Bidding modal opens directly
      final bidBtn = find.text('تقديم عرض سعر').first;
      await tester.ensureVisible(bidBtn);
      await tester.tap(bidBtn);
      await tester.pumpAndSettle();

      expect(find.text('تقديم عرض سعر (مزايدة)'), findsOneWidget);
      expect(find.text('إرسال العرض للتاجر'), findsOneWidget);
    });

    // Journey 6: سائق موثق لكنه غير متاح لا يظهر بوصفه متاحاً (توثيق ≠ توفر)
    testWidgets('Journey 6: Availability is completely independent from verification status', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      // Driver is verified, but goes offline
      store.simulateApproveDriverVerification('USR-DRIVER-01');
      store.setDriverAvailability(userId: 'USR-DRIVER-01', isAvailable: false);

      final user = store.users.firstWhere((u) => u.id == 'USR-DRIVER-01');
      expect(user.verificationStatus, equals(AccountVerificationStatus.verified));
      expect(user.isDriverAvailable, isFalse);

      await tester.pumpWidget(wrapWidget(const DriverHomeScreen()));
      await tester.pumpAndSettle();

      // Account is verified
      expect(find.text('معتمد ✓'), findsOneWidget);
      // Status bar shows offline
      expect(find.textContaining('غير متصل • لن تتلقى تنبيهات بحمولات جديدة'), findsOneWidget);

      // Toggle to online
      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('متصل • متاح لاستقبال طلبات النقل والمزايدة'), findsOneWidget);
      final updatedUser = store.users.firstWhere((u) => u.id == 'USR-DRIVER-01');
      expect(updatedUser.isDriverAvailable, isTrue);
    });

    // Journey 7: التأكد من أن أنواع الناقلات وحقولها مدعومة بالكامل
    testWidgets('Journey 7: Vehicle screen supports vehicle types and body categories', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        wrapWidget(
          const DriverVehicleVerificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Vehicle types check
      expect(find.text('شاحنة نقل'), findsOneWidget);
      expect(find.text('صندوق مغلق'), findsOneWidget);
      expect(find.text('طن'), findsOneWidget);
      expect(find.text('معلومات الخدمة ونطاق العمل'), findsOneWidget);
      expect(find.text('أنواع الحمولات التي تستطيع نقلها'), findsOneWidget);
      expect(find.text('مناطق ومحافظات الخدمة'), findsOneWidget);
    });

    // Journey 8: التأكد من الاحتفاظ بالبيانات عند الرجوع والتنقل
    testWidgets('Journey 8: Progress is saved in store during step navigation', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;

      // Enter license screen and continue
      await tester.pumpWidget(
        wrapWidget(
          DriverLicenseVerificationScreen(
            onNext: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final licNextBtn = find.text('متابعة إلى بيانات المركبة');
      await tester.ensureVisible(licNextBtn);
      await tester.tap(licNextBtn);
      await tester.pumpAndSettle();

      final user = store.users.firstWhere((u) => u.id == 'USR-DRIVER-01');
      expect(user.driverData?.licenseData?.licenseNumber, equals('DL-942851'));
    });

    // Journey 9: التأكد من عمل شريط المحاكاة الحي وتبديل الحالات دون تكرار
    testWidgets('Journey 9: Interactive simulation switcher toggles between all 3 states', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(wrapWidget(const DriverHomeScreen()));
      await tester.pumpAndSettle();

      // Default is verified
      expect(find.text('معتمد ✓'), findsOneWidget);

      // Tap 'غير موثق' in simulation bar
      await tester.tap(find.text('غير موثق'));
      await tester.pumpAndSettle();
      expect(find.text('حسابك غير موثق'), findsOneWidget);

      // Tap 'قيد المراجعة' in simulation bar
      await tester.tap(find.text('قيد المراجعة'));
      await tester.pumpAndSettle();
      expect(find.text('طلب التوثيق قيد المراجعة'), findsOneWidget);

      // Tap 'موثق' in simulation bar
      await tester.tap(find.text('موثق'));
      await tester.pumpAndSettle();
      expect(find.text('معتمد ✓'), findsOneWidget);
    });

    // Journey 10: التأكد من سلامة الخدمات التشغيلية وملخص النشاط
    testWidgets('Journey 10: Operational services grid and activity metrics render correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(wrapWidget(const DriverHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('الخدمات التشغيلية'), findsOneWidget);
      expect(find.text('طلبات النقل'), findsOneWidget);
      expect(find.text('عروضي'), findsWidgets);
      expect(find.text('رحلاتي'), findsOneWidget);
      expect(find.text('ناقلاتي'), findsOneWidget);
      expect(find.text('سجل العمليات'), findsOneWidget);

      // Activity metrics
      expect(find.text('أرباح اليوم'), findsOneWidget);
      expect(find.text('85,000 ر.ي'), findsOneWidget);
      expect(find.text('عروضي النشطة'), findsOneWidget);
      expect(find.text('التقييم العام'), findsOneWidget);
    });
  });
}
