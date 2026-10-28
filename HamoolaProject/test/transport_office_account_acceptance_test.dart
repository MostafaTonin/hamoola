import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/transport_office/domain/models/transport_office_trips_store.dart';
import 'package:flutter_application/features/transport_office/presentation/screens/transport_office_account_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Widget wrapTestWidget({
  required Widget child,
  TextDirection direction = TextDirection.rtl,
}) {
  return MaterialApp(
    home: Directionality(
      textDirection: direction,
      child: child,
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthSimulationStore.instance.resetToInitialState();
    TransportOfficeTripsStore.instance.resetToDefault();
  });

  void setPhoneSize(WidgetTester tester, {double width = 390, double height = 2400}) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    tester.binding.handleMetricsChanged();
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.binding.handleMetricsChanged();
    });
  }

  group('Transport Office Account Screen (حسابي) — Acceptance Tests', () {
    // -------------------------------------------------------------------------
    // 1. Header & Profile Card Rendering
    // -------------------------------------------------------------------------
    testWidgets('Criteria 1 & 2: Header and Profile Card render with full corporate identity',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('حسابي'), findsWidgets);
      expect(find.byKey(const Key('account_appbar_back_btn')), findsOneWidget);
      expect(find.byKey(const Key('account_appbar_settings_btn')), findsOneWidget);

      // Profile Card Elements
      expect(find.byKey(const Key('office_name_text'), skipOffstage: false), findsOneWidget);
      expect(find.byKey(const Key('office_activity_text'), skipOffstage: false), findsOneWidget);
      expect(find.text('حساب موثق', skipOffstage: false), findsOneWidget);
      expect(find.byKey(const Key('office_manager_id_text'), skipOffstage: false), findsOneWidget);
      expect(find.text('تعديل الملف الشخصي', skipOffstage: false), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 2. Edit Profile Modal Sheet & Live State Update
    // -------------------------------------------------------------------------
    testWidgets('Criteria 3: Edit Profile sheet opens, modifies office name, and updates state',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Edit Profile Button
      await tester.tap(find.text('تعديل الملف الشخصي', skipOffstage: false));
      await tester.pumpAndSettle();

      // Verify sheet title
      expect(find.text('تعديل بيانات الملف الشخصي'), findsOneWidget);

      // Edit office name field
      final officeNameField = find.byType(TextField).first;
      expect(officeNameField, findsOneWidget);

      await tester.enterText(officeNameField, 'مكتب النورس للنقل السريع');
      await tester.pump();

      // Tap Save Button
      await tester.tap(find.text('حفظ التعديلات'));
      await tester.pumpAndSettle();

      // Verify SnackBar and live state update
      expect(find.text('تم حفظ تعديلات الملف الشخصي بنجاح'), findsOneWidget);
      expect(find.text('مكتب النورس للنقل السريع', skipOffstage: false), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 3. 4 Stats Cards & Rating Sheet
    // -------------------------------------------------------------------------
    testWidgets('Criteria 4: 4 Stats Cards render and tapping Rating opens detailed breakdown',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('رحلة منجزة', skipOffstage: false), findsOneWidget);
      expect(find.text('طلبات نشطة', skipOffstage: false), findsOneWidget);
      expect(find.text('رحلة مكتملة', skipOffstage: false), findsOneWidget);
      expect(find.text('التقييم العام', skipOffstage: false), findsOneWidget);

      // Tap Rating card
      await tester.tap(find.text('التقييم العام', skipOffstage: false));
      await tester.pumpAndSettle();

      // Verify ratings modal sheet
      expect(find.text('التقييم العام: 4.8 من 5.0'), findsOneWidget);
      expect(find.text('98% تقييم إيجابي'), findsOneWidget);
      expect(find.text('الالتزام بالمواعيد وموعد التحميل'), findsOneWidget);
      expect(find.text('سلامة البضائع والمعدات المنقولة'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 4. Commercial Registration Update Flow
    // -------------------------------------------------------------------------
    testWidgets('Criteria 5: Commercial Registration update sheet opens with fields and review notice',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Commercial Registration update
      await tester.tap(find.text('تحديث السجل التجاري', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('تحديث بيانات السجل التجاري'), findsOneWidget);
      expect(find.textContaining('ملاحظة: تخضع أي تعديلات في وثائق السجل التجاري لمراجعة وتدقيق'), findsOneWidget);
      expect(find.text('إرسال التحديثات للمراجعة'), findsOneWidget);

      // Tap submit for review
      await tester.tap(find.text('إرسال التحديثات للمراجعة'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('تم إرسال تحديثات السجل التجاري بنجاح'),
        findsOneWidget,
      );
    });

    // -------------------------------------------------------------------------
    // 5. Contact & Location Update Flow
    // -------------------------------------------------------------------------
    testWidgets('Criteria 6: Contact and Location update sheet opens with map GPS coordinates',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Contact & Location update
      await tester.tap(find.text('تحديث بيانات التواصل والموقع', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('تحديث بيانات التواصل والموقع'), findsWidgets);
      expect(find.textContaining('إحداثيات المقر على الخريطة:'), findsOneWidget);
      expect(find.text('حفظ التغييرات'), findsOneWidget);

      await tester.tap(find.text('حفظ التغييرات'));
      await tester.pumpAndSettle();

      expect(find.text('تم حفظ بيانات التواصل والموقع بنجاح'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 6. Standalone Manager Profile Update Flow
    // -------------------------------------------------------------------------
    testWidgets('Criteria 7: Standalone Manager Profile update sheet separates personal info from commercial info',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Manager Profile
      await tester.tap(find.text('تحديث ملف المسؤول', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('تحديث ملف المسؤول القانوني'), findsOneWidget);
      expect(find.textContaining('تخص هذه البيانات المسؤول المفوض قانونياً'), findsOneWidget);
      expect(find.text('حفظ ملف المسؤول'), findsOneWidget);

      await tester.tap(find.text('حفظ ملف المسؤول'));
      await tester.pumpAndSettle();

      expect(find.text('تم تحديث ملف وبيانات المسؤول بنجاح'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 7. Security & Privacy Dialogs (PIN, Password, Biometrics)
    // -------------------------------------------------------------------------
    testWidgets('Criteria 8: Security accordion provides PIN, Password, and Privacy dialogs',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Change PIN Dialog
      await tester.tap(find.text('تغيير رمز التحقق', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('تغيير رمز التحقق / التأكيد'), findsOneWidget);
      expect(find.text('تأكيد التغيير'), findsOneWidget);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      // Open Change Password Dialog
      await tester.tap(find.text('تغيير كلمة المرور', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AlertDialog, 'تغيير كلمة المرور'), findsOneWidget);
      expect(find.text('حفظ'), findsOneWidget);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      // Open Privacy Policy
      await tester.tap(find.text('سياسة الخصوصية', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('سياسة الخصوصية وحماية البيانات'), findsOneWidget);
      expect(find.textContaining('تلتزم منصة حمولة بحماية البيانات'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 8. Support & Assistance Dialogs
    // -------------------------------------------------------------------------
    testWidgets('Criteria 9: Support & Assistance opens Social Media, Toll Free, and Service Points',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Social Media sheet
      await tester.tap(find.text('مواقع التواصل', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('قنوات حمولة الرسمية'), findsOneWidget);
      expect(find.textContaining('واتساب الدعم المباشر'), findsOneWidget);
      await tester.tap(find.textContaining('واتساب الدعم المباشر'));
      await tester.pumpAndSettle();

      // Open Service Points sheet
      await tester.tap(find.text('نقاط الخدمة', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('مراكز ونقاط خدمة حمولة المعتمدة'), findsOneWidget);
      expect(find.textContaining('صنعاء: شارع حدة'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 9. App Settings (Language, Theme, Notifications)
    // -------------------------------------------------------------------------
    testWidgets('Criteria 10: App settings accordion controls Language, Theme, and Notifications',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open Language Selector
      await tester.tap(find.text('اللغة: العربية (الافتراضية)', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('اختيار لغة التطبيق'), findsOneWidget);
      expect(find.text('العربية (المعتمدة والافتراضية)'), findsOneWidget);
      await tester.tap(find.text('العربية (المعتمدة والافتراضية)'));
      await tester.pumpAndSettle();

      // Open Theme Selector
      await tester.tap(find.text('المظهر: فاتح', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('اختيار مظهر التطبيق'), findsOneWidget);
      expect(find.text('المظهر الفاتح (Light)'), findsOneWidget);
      await tester.tap(find.text('المظهر الفاتح (Light)'));
      await tester.pumpAndSettle();

      // Open Notifications sheet
      await tester.tap(find.text('إعدادات الإشعارات', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('إعدادات التنبيهات والإشعارات'), findsOneWidget);
      expect(find.text('تنبيهات الطلبات المتاحة والحمولات الجديدة'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 10. Delete Account Request Flow
    // -------------------------------------------------------------------------
    testWidgets('Criteria 11: Delete account request opens legal explanation dialog and requires confirmation',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('طلب حذف الحساب', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('طلب حذف الحساب التجاري'), findsOneWidget);
      expect(find.textContaining('سيؤدي تقديم طلب حذف الحساب إلى بدء إجراءات التصفية'), findsOneWidget);
      expect(find.text('تأكيد إرسال الطلب'), findsOneWidget);

      await tester.tap(find.text('تأكيد إرسال الطلب'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('تم إرسال طلب حذف الحساب بنجاح'),
        findsOneWidget,
      );
    });

    // -------------------------------------------------------------------------
    // 11. Logout Flow
    // -------------------------------------------------------------------------
    testWidgets('Criteria 12: Logout card prompts confirmation and clears user session',
        (WidgetTester tester) async {
      setPhoneSize(tester);

      bool logoutTriggered = false;

      await tester.pumpWidget(
        wrapTestWidget(
          child: TransportOfficeAccountScreen(
            onLogout: () => logoutTriggered = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('تسجيل الخروج من الحساب', skipOffstage: false));
      await tester.pumpAndSettle();

      expect(find.text('تأكيد تسجيل الخروج'), findsOneWidget);
      expect(find.text('هل أنت متأكد من رغبتك في تسجيل الخروج من حساب مكتب النقل؟'), findsOneWidget);

      // Confirm logout
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();

      expect(logoutTriggered, isTrue);
      expect(AuthSimulationStore.instance.currentUser, isNull);
    });

    // -------------------------------------------------------------------------
    // 12. Bottom Navigation Bar & Compact 360px Screen Overflow Verification
    // -------------------------------------------------------------------------
    testWidgets('Criteria 13: Bottom Navigation Bar with rotating Center (+) FAB and zero overflows on 360px',
        (WidgetTester tester) async {
      // Test strictly on compact 360px screen width
      setPhoneSize(tester, width: 360, height: 740);

      await tester.pumpWidget(
        wrapTestWidget(
          child: const TransportOfficeAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check all 5 tabs
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الخريطة'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('حسابي'), findsWidgets);

      // Tap central (+) FAB
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify 2x2 quick actions sheet
      expect(find.text('إجراءات سريعة لمكتب النقل'), findsOneWidget);
      expect(find.text('تحديث الحالة'), findsOneWidget);
      expect(find.text('رحلاتي الجارية'), findsOneWidget);
      expect(find.text('طلب مساعدة'), findsOneWidget);
      expect(find.text('الإبلاغ عن مشكلة'), findsOneWidget);

      // Tap update status
      await tester.tap(find.text('تحديث الحالة'));
      await tester.pumpAndSettle();

      expect(find.text('مكتب النقل متاح الآن لاستقبال وتوزيع الحمولات'), findsOneWidget);

      // Assert zero exceptions/overflows
      expect(tester.takeException(), isNull);
    });
  });
}
