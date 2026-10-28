import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/merchant/presentation/screens/commercial_verification_screen.dart';
import 'package:flutter_application/features/transport_office/presentation/screens/transport_office_account_screen.dart';
import 'package:flutter_application/features/transport_office/presentation/screens/transport_office_home_screen.dart';
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

  void setPhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Prompt 06 — Transport Office Verification & Home Flow Tests', () {
    testWidgets('Journey 1: CommercialVerificationScreen adapts cleanly for transport office role',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      final store = AuthSimulationStore.instance;
      final officeUser = AuthUser(
        id: 'USR-OFFICE-TEST',
        name: 'صالح مسعد العمري',
        phone: '774567890',
        password: 'password123',
        role: AuthUserRole.office,
        verificationStatus: AccountVerificationStatus.unverified,
        createdAt: DateTime(2026, 7, 10),
      );
      store.registerUser(officeUser);

      bool verificationCompleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CommercialVerificationScreen(
            role: 'مكتب نقل',
            userId: 'USR-OFFICE-TEST',
            onVerificationComplete: (val) => verificationCompleted = val,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and titles tailored for transport office
      expect(find.text('بيانات مكتب النقل'), findsOneWidget);
      expect(find.text('1. بيانات المسؤول عن الحساب والهوية'), findsOneWidget);
      expect(find.text('الاسم الكامل للمسؤول'), findsOneWidget);
      expect(find.text('2. بيانات مكتب النقل والنشاط التجاري'), findsOneWidget);
      expect(find.text('اسم مكتب النقل'), findsOneWidget);

      // Verify default office enterprise fields
      expect(find.text('مكتب الأمانة لنقل البضائع والمهمات'), findsOneWidget);
      expect(find.text('CR-7729104'), findsOneWidget);
      expect(find.text('وزارة الصناعة والتجارة - مكتب النقل'), findsOneWidget);

      // Tap sticky submit button
      final submitBtn = find.text('إرسال طلب التوثيق');
      expect(submitBtn, findsOneWidget);

      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Success modal
      expect(find.text('تم توثيق السجل التجاري بنجاح ✓'), findsOneWidget);
      expect(find.text('متابعة إلى الرئيسية'), findsOneWidget);

      await tester.tap(find.text('متابعة إلى الرئيسية'));
      await tester.pumpAndSettle();

      expect(verificationCompleted, isTrue);

      final updatedUser = store.getUserById('USR-OFFICE-TEST');
      expect(updatedUser?.verificationStatus, AccountVerificationStatus.pendingReview);
      expect(updatedUser?.officeData?.officeName, 'مكتب الأمانة لنقل البضائع والمهمات');
    });

    testWidgets('Journey 2: TransportOfficeHomeScreen displays greeting, office name, assistant & notifications',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: TransportOfficeHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('أهلًا بك في حمولة'), findsOneWidget);
      expect(find.text('مكتب النقل السالمي'), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('Journey 3: TransportOfficeHomeScreen features 4 rotating hero cards and stats row',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: TransportOfficeHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // Hero Carousel card 1
      expect(find.text('فرص نقل جديدة بانتظارك'), findsOneWidget);
      expect(find.text('عرض الطلبات'), findsOneWidget);

      // Stats Cards
      expect(find.text('الطلبات المتاحة'), findsOneWidget);
      expect(find.text('الطلبات النشطة'), findsOneWidget);
      expect(find.text('الرحلات المكتملة'), findsOneWidget);
    });

    testWidgets('Journey 4: Quick services row displays 4 services',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: TransportOfficeHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('الخدمات السريعة'), findsOneWidget);
      expect(find.text('رحلاتي'), findsOneWidget);
      expect(find.text('محفظتي'), findsOneWidget);
      expect(find.text('أرباحي'), findsOneWidget);
    });

    testWidgets('Journey 5: Available Orders section filters between public and private orders',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: TransportOfficeHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('الطلبات المتاحة لك'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('العامة'), findsOneWidget);
      expect(find.text('الخاصة'), findsOneWidget);

      // Default has both
      expect(find.text('نقل مواد بناء (أسمنت)'), findsOneWidget);
      expect(find.text('نقل مواسير حديدية'), findsOneWidget);

      // Filter by public
      await tester.tap(find.text('العامة'));
      await tester.pumpAndSettle();
      expect(find.text('نقل مواد بناء (أسمنت)'), findsOneWidget);
      expect(find.text('نقل مواسير حديدية'), findsNothing);
    });

    testWidgets('Journey 6: Bottom Navigation Bar with (+) FAB opens 4 quick actions',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: TransportOfficeHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الخريطة'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // Tap central (+) button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('تحديث الحالة'), findsOneWidget);
      expect(find.text('رحلاتي الجارية'), findsOneWidget);
      expect(find.text('طلب مساعدة'), findsOneWidget);
      expect(find.text('الإبلاغ عن مشكلة'), findsOneWidget);
    });

    testWidgets('Journey 7: TransportOfficeAccountScreen displays full office & manager enterprise profile',
        (WidgetTester tester) async {
      setPhoneSize(tester);
      tester.binding.handleMetricsChanged();

      await tester.pumpWidget(
        const MaterialApp(
          home: TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('حسابي'), findsWidgets);
      expect(find.byKey(const Key('office_name_text'), skipOffstage: false), findsOneWidget);
      expect(find.byKey(const Key('office_activity_text'), skipOffstage: false), findsOneWidget);
      expect(find.byKey(const Key('office_manager_id_text'), skipOffstage: false), findsOneWidget);
      expect(find.text('حساب موثق', skipOffstage: false), findsOneWidget);
      expect(find.text('تعديل الملف الشخصي', skipOffstage: false), findsOneWidget);

      // Stats row
      expect(find.text('رحلة منجزة', skipOffstage: false), findsOneWidget);
      expect(find.text('طلبات نشطة', skipOffstage: false), findsOneWidget);
      expect(find.text('رحلة مكتملة', skipOffstage: false), findsOneWidget);
      expect(find.text('التقييم العام', skipOffstage: false), findsOneWidget);

      // Sections
      expect(find.text('بيانات المكتب', skipOffstage: false), findsOneWidget);
      expect(find.text('تحديث السجل التجاري', skipOffstage: false), findsOneWidget);
      expect(find.text('تحديث بيانات التواصل والموقع', skipOffstage: false), findsOneWidget);
      expect(find.text('تحديث ملف المسؤول', skipOffstage: false), findsOneWidget);
      expect(find.text('الأمان والخصوصية', skipOffstage: false), findsOneWidget);
      expect(find.text('تسجيل الخروج من الحساب', skipOffstage: false), findsOneWidget);
    });
  });
}
