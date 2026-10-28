import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_account_screen.dart';

void main() {
  setUp(() {
    AuthSimulationStore.instance.resetToDemo();
  });

  Widget createTestWidget({
    VoidCallback? onBack,
    VoidCallback? onHome,
    VoidCallback? onOrders,
    VoidCallback? onMap,
    VoidCallback? onWallet,
    VoidCallback? onSupport,
    VoidCallback? onLogout,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: DriverAccountScreen(
          onBack: onBack,
          onHome: onHome,
          onOrders: onOrders,
          onMap: onMap,
          onWallet: onWallet,
          onSupport: onSupport,
          onLogout: onLogout,
        ),
      ),
    );
  }

  group('DriverAccountScreen Full Acceptance Tests', () {
    testWidgets('1. Renders top bar, profile card, statistics, and all main sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1100));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Top Bar
      expect(find.text('حسابي'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.settings_outlined), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.chevron_right_rounded), findsAtLeastNWidgets(1));

      // Profile Card
      expect(find.text('سائق في منصة حمولة'), findsOneWidget);
      expect(find.text('حساب موثّق'), findsOneWidget);
      expect(find.textContaining('رقم السائق:'), findsOneWidget);
      expect(find.text('تعديل الملف الشخصي'), findsOneWidget);

      // 3 Statistics Cards
      expect(find.text('حمولة منقولة'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
      expect(find.text('طلبات نشطة'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('رحلة مكتملة'), findsOneWidget);
      expect(find.text('96'), findsOneWidget);

      // Section: بيانات السائق
      expect(find.text('بيانات السائق'), findsOneWidget);
      expect(find.text('المعلومات الشخصية'), findsOneWidget);
      expect(find.text('بيانات الهوية الوطنية'), findsOneWidget);
      expect(find.text('رخصة القيادة'), findsOneWidget);
      expect(find.text('بيانات التواصل'), findsOneWidget);
      expect(find.text('العنوان والموقع'), findsOneWidget);

      // Section: بيانات الناقلة (with button inside and vehicle specs)
      expect(find.text('بيانات الناقلة'), findsOneWidget);
      expect(find.text('شاحنة نقل بضائع'), findsOneWidget);
      expect(find.text('معتمدة'), findsOneWidget);
      expect(find.textContaining('رقم اللوحة:'), findsOneWidget);
      expect(find.textContaining('نوع الناقلة:'), findsOneWidget);
      expect(find.textContaining('سعة الحمولة:'), findsOneWidget);
      expect(find.text('تحديث بيانات الناقلة'), findsOneWidget);

      // Verified: "عمليات حمولة" is explicitly NOT present
      expect(find.text('عمليات حمولة'), findsNothing);

      // Scroll to view lower sections
      await tester.scrollUntilVisible(find.text('الخصوصية والأمان'), 200);
      await tester.pumpAndSettle();

      // Section: الخصوصية والأمان
      expect(find.text('الخصوصية والأمان'), findsOneWidget);
      expect(find.text('تغيير رمز التأكيد'), findsOneWidget);
      expect(find.text('تغيير كلمة المرور'), findsOneWidget);
      expect(find.text('استخدام البصمة لتسجيل الدخول'), findsOneWidget);
      expect(find.text('استخدام البصمة لتأكيد الدفع'), findsOneWidget);
      expect(find.text('سياسة الخصوصية'), findsOneWidget);
      expect(find.text('الشروط والأحكام'), findsOneWidget);

      // Section: الدعم والمساعدة
      await tester.scrollUntilVisible(find.text('الدعم والمساعدة'), 200);
      await tester.pumpAndSettle();
      expect(find.text('الدعم والمساعدة'), findsOneWidget);
      expect(find.text('خدمة العملاء'), findsOneWidget);
      expect(find.text('مواقع التواصل'), findsOneWidget);
      expect(find.text('الرقم المجاني'), findsOneWidget);
      expect(find.text('نقاط الخدمة'), findsOneWidget);
      expect(find.text('الإبلاغ عن مشكلة'), findsOneWidget);
      expect(find.text('طلب مساعدة'), findsOneWidget);

      // Section: إعدادات التطبيق
      await tester.scrollUntilVisible(find.text('إعدادات التطبيق'), 200);
      await tester.pumpAndSettle();
      expect(find.text('إعدادات التطبيق'), findsOneWidget);
      expect(find.text('اللغة'), findsOneWidget);
      expect(find.text('المظهر'), findsOneWidget);
      expect(find.text('إعدادات الإشعارات'), findsOneWidget);

      // Logout Card
      await tester.scrollUntilVisible(find.text('تسجيل الخروج'), 200);
      await tester.pumpAndSettle();
      expect(find.text('تسجيل الخروج'), findsOneWidget);
    });

    testWidgets('2. Profile Edit Dialog updates driver name and phone', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap "تعديل الملف الشخصي"
      final editButton = find.text('تعديل الملف الشخصي');
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify bottom sheet title
      expect(find.text('تعديل الملف الشخصي للسائق'), findsOneWidget);

      // Find text fields
      final nameFinder = find.widgetWithText(TextField, 'الاسم الكامل');
      final phoneFinder = find.widgetWithText(TextField, 'رقم الهاتف');
      expect(nameFinder, findsOneWidget);
      expect(phoneFinder, findsOneWidget);

      // Enter new data
      await tester.enterText(nameFinder, 'أحمد محمد سالم');
      await tester.enterText(phoneFinder, '777987654');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('حفظ التعديلات'));
      await tester.pumpAndSettle();

      // Verify profile card immediately displays updated name
      expect(find.text('أحمد محمد سالم'), findsOneWidget);
      expect(find.textContaining('777 987 654'), findsOneWidget);
    });

    testWidgets('3. Transporter Update Dialog updates vehicle specs and plate', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find "تحديث بيانات الناقلة" and scroll to it
      final updateTruckBtn = find.text('تحديث بيانات الناقلة');
      await tester.scrollUntilVisible(updateTruckBtn, 200);
      await tester.pumpAndSettle();
      expect(updateTruckBtn, findsOneWidget);
      await tester.tap(updateTruckBtn);
      await tester.pumpAndSettle();

      // Verify update sheet opens
      expect(find.text('قم بتعديل بيانات المركبة المسجلة لدى السائق في منصة حمولة'), findsOneWidget);

      // Enter new plate
      final plateFinder = find.widgetWithText(TextField, 'رقم اللوحة');
      expect(plateFinder, findsOneWidget);
      await tester.enterText(plateFinder, '12345 | أ ب ج');

      // Tap save
      await tester.tap(find.text('حفظ بيانات الناقلة'));
      await tester.pumpAndSettle();

      // Verify card updated
      expect(find.textContaining('12345 | أ ب ج'), findsOneWidget);
    });

    testWidgets('4. Driver Data items open interactive details sheets', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap "المعلومات الشخصية"
      await tester.tap(find.text('المعلومات الشخصية'));
      await tester.pumpAndSettle();
      expect(find.text('المعلومات الشخصية للسائق'), findsOneWidget);
      await tester.tap(find.text('إغلاق'));
      await tester.pumpAndSettle();

      // Tap "بيانات الهوية الوطنية"
      await tester.tap(find.text('بيانات الهوية الوطنية'));
      await tester.pumpAndSettle();
      expect(find.text('بيانات الهوية الوطنية'), findsAtLeastNWidgets(1));
      await tester.tap(find.text('إغلاق'));
      await tester.pumpAndSettle();

      // Tap "رخصة القيادة"
      await tester.tap(find.text('رخصة القيادة'));
      await tester.pumpAndSettle();
      expect(find.text('تفاصيل رخصة القيادة'), findsOneWidget);
      await tester.tap(find.text('إغلاق'));
      await tester.pumpAndSettle();
    });

    testWidgets('5. Biometrics Switches can be toggled', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1100));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to switches
      await tester.scrollUntilVisible(find.text('استخدام البصمة لتسجيل الدخول'), 200);
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));

      // Toggle first switch
      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Toggle second switch
      await tester.tap(switches.last);
      await tester.pumpAndSettle();
    });

    testWidgets('6. Quick actions (+) button opens 4-quadrant modal', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Center FAB (+)
      final fabFinder = find.byIcon(Icons.add_rounded);
      expect(fabFinder, findsOneWidget);
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      // Verify the 4 quadrants (some titles also exist in the Support section)
      expect(find.text('تحديث الحالة'), findsOneWidget);
      expect(find.text('الطلبات المتاحة'), findsOneWidget);
      expect(find.text('طلب مساعدة'), findsAtLeastNWidgets(1));
      expect(find.text('الإبلاغ عن مشكلة'), findsAtLeastNWidgets(1));
    });

    testWidgets('7. Logout button shows confirmation dialog and executes logout callback', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      bool loggedOut = false;
      await tester.pumpWidget(createTestWidget(
        onLogout: () => loggedOut = true,
      ));
      await tester.pumpAndSettle();

      // Scroll down to logout
      final logoutBtn = find.text('تسجيل الخروج');
      await tester.scrollUntilVisible(logoutBtn, 200);
      await tester.pumpAndSettle();

      expect(logoutBtn, findsOneWidget);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Verify dialog
      expect(find.text('تأكيد تسجيل الخروج'), findsOneWidget);
      expect(find.text('هل أنت متأكد من رغبتك في تسجيل الخروج من حساب السائق في منصة حمولة؟'), findsOneWidget);

      // Tap confirm in dialog
      final confirmBtn = find.widgetWithText(ElevatedButton, 'تسجيل الخروج');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(loggedOut, isTrue);
    });
  });
}
