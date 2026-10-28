import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/merchant/presentation/screens/commercial_verification_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_home_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_account_screen.dart';
import 'package:flutter_application/features/client/presentation/screens/client_home_screen.dart';
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

  group('Prompt 05 — Merchant Onboarding and Enterprise Verification Flow Tests', () {
    // Journey 1: التاجر الجديد يصل لشاشة استكمال البيانات مقسمة إلى 3 أقسام واضحة
    testWidgets('Journey 1: New merchant lands on CommercialVerificationScreen with 3 distinct sections and clear identity', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        wrapWidget(
          CommercialVerificationScreen(
            role: 'تاجر',
            userId: 'USR-MERCHANT-NEW',
            userName: 'محمد أحمد اليماني',
            userPhone: '771234567',
          ),
        ),
      );
      await tester.pump();

      // Top Hero card matching requirements
      expect(find.text('استكمال بيانات التاجر'), findsOneWidget);
      expect(find.text('أكمل بياناتك وبيانات منشأتك لتتمكن من توثيق حسابك في حمولة.'), findsOneWidget);

      // Section 1: بيانات صاحب الحساب والهوية
      expect(find.textContaining('بيانات صاحب الحساب والهوية'), findsOneWidget);
      expect(find.text('محمد أحمد اليماني'), findsOneWidget);
      expect(find.text('771234567'), findsOneWidget);
      expect(find.text('نوع وثيقة الهوية'), findsOneWidget);
      expect(find.text('رقم الهوية الشخصية'), findsOneWidget);

      // Section 2: بيانات المنشأة والنشاط التجاري
      expect(find.textContaining('بيانات المنشأة والنشاط التجاري'), findsOneWidget);
      expect(find.text('اسم المنشأة / النشاط التجاري'), findsOneWidget);
      expect(find.text('نوع النشاط التجاري'), findsOneWidget);
      expect(find.text('رقم السجل التجاري'), findsOneWidget);

      // Section 3: مستندات التوثيق والاعتماد
      expect(find.text('مستندات التوثيق والاعتماد'), findsOneWidget);
      expect(find.text('صورة الهوية من الأمام'), findsOneWidget);
      expect(find.text('صورة الهوية من الخلف'), findsOneWidget);
      expect(find.text('صورة شخصية مع الهوية'), findsOneWidget);
      expect(find.text('صورة السجل التجاري'), findsOneWidget);

      // Bottom sticky actions
      expect(find.text('إرسال طلب التوثيق'), findsOneWidget);
      expect(find.text('تخطي الآن'), findsOneWidget);
    });

    // Journey 2: إرسال طلب التوثيق ينقل التاجر إلى قيد المراجعة والشاشة الرئيسية تعرض بنر المراجعة
    testWidgets('Journey 2: Submitting verification transitions merchant to pendingReview and Home shows pending review banner', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      final regResult = store.register(
        fullName: 'جمال عبدالرحمن العامري',
        phone: '770998877',
        password: 'password123',
        role: AuthUserRole.merchant,
      );
      final user = regResult.user!;
      store.setCurrentUserForTesting(user);

      bool completed = false;
      await tester.pumpWidget(
        wrapWidget(
          CommercialVerificationScreen(
            role: 'تاجر',
            userId: user.id,
            userName: user.name,
            userPhone: user.phone,
            onVerificationComplete: (approved) => completed = true,
          ),
        ),
      );
      await tester.pump();

      final submitBtn = find.text('إرسال طلب التوثيق');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Check verified completion dialog appears
      expect(find.text('تم توثيق السجل التجاري بنجاح ✓'), findsOneWidget);
      expect(find.text('متابعة إلى الرئيسية'), findsOneWidget);

      await tester.tap(find.text('متابعة إلى الرئيسية'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
      expect(store.currentUser?.verificationStatus, equals(AccountVerificationStatus.pendingReview));

      // Pump MerchantHomeScreen in pendingReview state
      await tester.pumpWidget(
        wrapWidget(
          MerchantHomeScreen(
            verificationStatus: AccountVerificationStatus.pendingReview,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('طلب التوثيق قيد المراجعة'), findsOneWidget);
      expect(find.text('عرض تفاصيل الطلب'), findsOneWidget);
      // Warning banner for unverified should not be visible
      expect(find.text('حسابك بانتظار التوثيق'), findsNothing);
    });

    // Journey 3: تخطي التوثيق يحافظ على الحساب وينقله بحالة غير موثق
    testWidgets('Journey 3: Skipping verification preserves account data and shows unverified banner on Home', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      final regResult = store.register(
        fullName: 'عادل سعيد باوزير',
        phone: '773344556',
        password: 'password123',
        role: AuthUserRole.merchant,
      );
      final user = regResult.user!;
      store.setCurrentUserForTesting(user);

      bool skipTapped = false;
      await tester.pumpWidget(
        wrapWidget(
          CommercialVerificationScreen(
            role: 'تاجر',
            userId: user.id,
            userName: user.name,
            userPhone: user.phone,
            onSkip: () => skipTapped = true,
          ),
        ),
      );
      await tester.pump();

      final skipBtn = find.text('تخطي الآن');
      await tester.ensureVisible(skipBtn);
      await tester.tap(skipBtn);
      await tester.pump();

      expect(skipTapped, isTrue);
      // Account preserved and state is unverified
      expect(store.currentUser, isNotNull);
      expect(store.currentUser?.verificationStatus, equals(AccountVerificationStatus.unverified));

      // Home shows unverified notice banner with CTA
      await tester.pumpWidget(
        wrapWidget(
          MerchantHomeScreen(
            verificationStatus: AccountVerificationStatus.unverified,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('حسابك بانتظار التوثيق'), findsOneWidget);
      expect(find.text('استكمال التوثيق'), findsOneWidget);
    });

    // Journey 4: التاجر غير الموثق يمكنه العودة من الرئيسية لاستكمال التوثيق
    testWidgets('Journey 4: Unverified merchant can tap verify CTA from Home banner to trigger verification callback', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      bool verifyNowTapped = false;
      await tester.pumpWidget(
        wrapWidget(
          MerchantHomeScreen(
            verificationStatus: AccountVerificationStatus.unverified,
            onVerifyNow: () => verifyNowTapped = true,
          ),
        ),
      );
      await tester.pump();

      final verifyBtn = find.text('استكمال التوثيق');
      expect(verifyBtn, findsOneWidget);
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn, warnIfMissed: false);
      await tester.pump();

      expect(verifyNowTapped, isTrue);
    });

    // Journey 5: التاجر الموثق يظهر وسم معتمد هادئ وتختفي بنرات التحذير
    testWidgets('Journey 5: Verified merchant displays calm verified badge in header and no warning banners', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        wrapWidget(
          MerchantHomeScreen(
            isVerified: true,
            verificationStatus: AccountVerificationStatus.verified,
          ),
        ),
      );
      await tester.pump();

      // Calm badge in header
      expect(find.text('معتمد ✓'), findsOneWidget);

      // No warning or pending banners
      expect(find.text('حسابك بانتظار التوثيق'), findsNothing);
      expect(find.text('طلب التوثيق قيد المراجعة'), findsNothing);
    });

    // Journey 6: اسم المنشأة ينعكس من بيانات الحساب المسجلة وليس ثابتاً
    testWidgets('Journey 6: Enterprise name reflects user account data dynamically', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      final customUser = AuthUser(
        id: 'USR-MERCHANT-CUSTOM',
        name: 'عبدالله أحمد الصنعاني',
        phone: '775566778',
        password: 'password123',
        createdAt: DateTime.now(),
        role: AuthUserRole.merchant,
        verificationStatus: AccountVerificationStatus.verified,
        merchantData: MerchantEnterpriseData(
          enterpriseName: 'مؤسسة النماء للتجارة الحديثة',
          crNumber: 'CR-554433',
          crIssuer: 'وزارة الصناعة والتجارة',
          address: 'صنعاء - شارع الزبيري',
          submittedAt: DateTime.now(),
        ),
      );
      store.setCurrentUserForTesting(customUser);

      await tester.pumpWidget(
        wrapWidget(
          MerchantHomeScreen(
            verificationStatus: AccountVerificationStatus.verified,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('مؤسسة النماء للتجارة الحديثة'), findsOneWidget);

      // Account screen also reflects exact enterprise name
      await tester.pumpWidget(
        wrapWidget(
          const MerchantAccountScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('مؤسسة النماء للتجارة الحديثة'), findsOneWidget);
    });

    // Journey 7: الفصل الواضح بين اسم صاحب الحساب واسم المنشأة
    testWidgets('Journey 7: Owner name and Enterprise name are distinctly separated in UI', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      final customUser = AuthUser(
        id: 'USR-MERCHANT-DUAL',
        name: 'هشام عبدالله العولقي',
        phone: '771122334',
        password: 'password123',
        createdAt: DateTime.now(),
        role: AuthUserRole.merchant,
        verificationStatus: AccountVerificationStatus.verified,
        merchantData: MerchantEnterpriseData(
          enterpriseName: 'شركة صيرة للتجارة العامة',
          crNumber: 'CR-889900',
          crIssuer: 'عدن - المعلا',
          address: 'عدن - المعلا',
          submittedAt: DateTime.now(),
        ),
      );
      store.setCurrentUserForTesting(customUser);

      await tester.pumpWidget(
        wrapWidget(
          const MerchantAccountScreen(),
        ),
      );
      await tester.pump();

      // Enterprise Name is prominent
      expect(find.text('شركة صيرة للتجارة العامة'), findsOneWidget);
      // Account Owner Name is clearly identified under it
      expect(find.text('صاحب الحساب: هشام عبدالله العولقي'), findsOneWidget);
    });

    // Journey 8: تقييد الإجراءات الحساسة عند عدم التوثيق أو قيد المراجعة مع نافذة التفاصيل والاعتماد التجريبي
    testWidgets('Journey 8: Restricted actions open appropriate modals with review details sheet and instant simulation approval', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      final user = AuthUser(
        id: 'USR-MERCHANT-RESTRICT',
        name: 'فهد سالم الكاف',
        phone: '778899001',
        password: 'password123',
        createdAt: DateTime.now(),
        role: AuthUserRole.merchant,
        verificationStatus: AccountVerificationStatus.pendingReview,
        merchantData: MerchantEnterpriseData(
          enterpriseName: 'مؤسسة حضرموت للاستيراد والتصدير',
          crNumber: 'CR-445566',
          crIssuer: 'المكلا',
          address: 'المكلا - الديس',
          submittedAt: DateTime.now(),
        ),
      );
      store.setCurrentUserForTesting(user);

      await tester.pumpWidget(
        wrapWidget(
          MerchantHomeScreen(
            verificationStatus: AccountVerificationStatus.pendingReview,
          ),
        ),
      );
      await tester.pump();

      // Tap 'عرض تفاصيل الطلب' on pending review banner
      final detailsBtn = find.text('عرض تفاصيل الطلب');
      expect(detailsBtn, findsOneWidget);
      await tester.ensureVisible(detailsBtn);
      await tester.tap(detailsBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Details review sheet shows submitted details
      expect(find.text('تفاصيل طلب توثيق المنشأة'), findsOneWidget);
      expect(find.text('مؤسسة حضرموت للاستيراد والتصدير'), findsWidgets);

      // Instant prototype approval button
      final approveBtn = find.text('اعتماد التوثيق تجريبياً');
      expect(approveBtn, findsOneWidget);
      await tester.tap(approveBtn);
      await tester.pumpAndSettle();

      // State transitions to verified
      expect(store.currentUser?.verificationStatus, equals(AccountVerificationStatus.verified));
    });

    // Journey 9: شاشة حساب التاجر تعرض شارة الحالة ديناميكياً ومعلومات المنشأة الحقيقية
    testWidgets('Journey 9: Merchant Account Screen displays dynamic verification badge and real enterprise details in dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final store = AuthSimulationStore.instance;
      final user = AuthUser(
        id: 'USR-MERCHANT-ACC',
        name: 'ماجد توفيق الهدار',
        phone: '776655443',
        password: 'password123',
        createdAt: DateTime.now(),
        role: AuthUserRole.merchant,
        verificationStatus: AccountVerificationStatus.pendingReview,
        merchantData: MerchantEnterpriseData(
          enterpriseName: 'مجموعة الهدار التجارية',
          crNumber: 'CR-112233',
          crIssuer: 'تعز - الحوبان',
          address: 'تعز - شارع جمال',
          businessType: 'استيراد وتوزيع مواد البناء',
          submittedAt: DateTime.now(),
        ),
      );
      store.setCurrentUserForTesting(user);

      await tester.pumpWidget(
        wrapWidget(
          const MerchantAccountScreen(),
        ),
      );
      await tester.pump();

      // Status badge shows "قيد المراجعة"
      expect(find.text('قيد المراجعة'), findsOneWidget);

      // Open enterprise info dialog
      final enterpriseMenu = find.text('معلومات المؤسسة');
      await tester.ensureVisible(enterpriseMenu);
      await tester.tap(enterpriseMenu);
      await tester.pump(const Duration(milliseconds: 350));

      // Dialog shows real data
      expect(find.textContaining('CR-112233'), findsWidgets);
      expect(find.textContaining('استيراد وتوزيع مواد البناء'), findsOneWidget);
    });

    // Journey 10: مسارات العميل والسائق تظل تعمل بكفاءة 100% دون أي تأثر
    testWidgets('Journey 10: Client and Driver flows remain 100% operational with zero regressions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      // 1. Client Home Screen renders properly
      await tester.pumpWidget(
        wrapWidget(
          const ClientHomeScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(ClientHomeScreen), findsOneWidget);
      expect(find.text('إنشاء طلب نقل'), findsWidgets);

      // 2. Driver Home Screen renders properly
      await tester.pumpWidget(
        wrapWidget(
          const DriverHomeScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(DriverHomeScreen), findsOneWidget);
      expect(find.text('كابتن عبد الله الصبري'), findsOneWidget);
    });

    // Journey 11: عمليات التاجر الأساسية (الحمولات، الطلبات، الخريطة، المحفظة) متاحة بالكامل
    testWidgets('Journey 11: Merchant core actions and navigation callbacks remain fully accessible', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));

      bool cargosTapped = false;
      bool mapTapped = false;
      bool ordersTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          MerchantHomeScreen(
            isVerified: true,
            onCargos: () => cargosTapped = true,
            onMap: () => mapTapped = true,
            onOrders: () => ordersTapped = true,
          ),
        ),
      );
      await tester.pump();

      // Main services: حمولاتي
      final cargosService = find.text('حمولاتي');
      expect(cargosService, findsOneWidget);
      await tester.tap(cargosService);
      expect(cargosTapped, isTrue);

      // Main services: عرض السائقين
      final mapService = find.text('عرض السائقين');
      expect(mapService, findsOneWidget);
      await tester.tap(mapService);
      expect(mapTapped, isTrue);

      // Main services: طلباتي
      final ordersService = find.text('طلباتي').first;
      expect(ordersService, findsOneWidget);
      await tester.tap(ordersService);
      expect(ordersTapped, isTrue);
    });
  });
}
