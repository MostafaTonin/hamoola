import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/client/presentation/screens/client_home_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget wrapWidget(Widget child) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
        );
      },
    );
  }

  setUp(() {
    AuthSimulationStore.instance.resetToDemo();
    final client = AuthSimulationStore.instance.users.firstWhere((u) => u.role == AuthUserRole.client);
    AuthSimulationStore.instance.setCurrentUser(client);
  });

  group('Prompt 04 - Client Home Screen Complete Implementation Tests', () {
    testWidgets('1. رأس الصفحة: تحية مصطفى وشارة حساب شخصي وشريط البحث وأيقونة الفلتر',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      // Greeting with name
      expect(find.textContaining('أهلاً، مصطفى'), findsOneWidget);

      // Account type badge
      expect(find.text('حساب شخصي'), findsOneWidget);

      // Search field placeholder
      expect(find.text('ابحث عن حمولة، سائق، أو مسار...'), findsOneWidget);

      // Filter button icon
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    });

    testWidgets('2. بطاقة التوثيق للعميل غير الموثق: تظهر بلون أصفر ورسالة توجيهية وزر توثيق',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final client = AuthSimulationStore.instance.currentUser!;
      AuthSimulationStore.instance.simulateSetVerificationStatus(client.id, AccountVerificationStatus.unverified);

      var verifyTapped = false;
      await tester.pumpWidget(
        wrapWidget(
          ClientHomeScreen(
            onVerifyNow: () => verifyTapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('حسابك غير موثق حالياً'), findsOneWidget);
      expect(find.text('توثيق الحساب الآن'), findsOneWidget);

      final verifyBtn = find.text('توثيق الحساب الآن');
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pump();

      expect(verifyTapped, isTrue);
    });

    testWidgets('3. بطاقة التوثيق عند قيد المراجعة: تظهر باللون الأزرق وزر عرض حالة التوثيق ومودال التفاصيل',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final client = AuthSimulationStore.instance.currentUser!;
      AuthSimulationStore.instance.submitClientVerification(
        userId: client.id,
        identityData: ClientIdentityData(
          fullName: 'مصطفى صالح طنين',
          idNumber: '11010290469',
          issuePlace: 'حضرموت - المكلا',
          issueDate: '2026-01-10',
          birthPlace: 'حضرموت',
          birthDate: '1992-05-15',
          submittedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      expect(find.text('طلب التوثيق قيد المراجعة'), findsOneWidget);
      expect(find.text('عرض حالة التوثيق'), findsOneWidget);

      await tester.tap(find.text('عرض حالة التوثيق'));
      await tester.pumpAndSettle();

      expect(find.text('بيانات توثيق الهوية المرسلة'), findsOneWidget);
      expect(find.text('11010290469'), findsOneWidget);
      expect(find.text('حضرموت - المكلا'), findsOneWidget);
    });

    testWidgets('4. بطاقة التوثيق للعميل الموثق: تختفي تنبيهات التوثيق وتظهر شارة موثق ومعتمد بنجاح',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final client = AuthSimulationStore.instance.currentUser!;
      AuthSimulationStore.instance.simulateSetVerificationStatus(client.id, AccountVerificationStatus.verified);

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen(isVerified: true)));
      await tester.pump();

      expect(find.text('حساب موثق ومعتمد بنجاح'), findsOneWidget);
      expect(find.text('موثق ومعتمد'), findsWidgets);
      expect(find.text('حسابك غير موثق حالياً'), findsNothing);
      expect(find.text('طلب التوثيق قيد المراجعة'), findsNothing);
    });

    testWidgets('5. شرائح الترويج الأربع (Hero Carousel) تطابق تماماً موضوعات العميل',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      // Card 1
      expect(find.text('انقل أثاث منزلك بأمان مع حمولة'), findsOneWidget);
      expect(find.text('نقل عفش وأثاث منزلي'), findsOneWidget);

      // Card 2
      expect(find.text('احجز شاحنة مخصصة لنقل بضائعك'), findsOneWidget);
      expect(find.text('شاحنات دينا ونقل خفيف'), findsOneWidget);

      // Card 3
      expect(find.text('توصيل سريع بين المدن والمحافظات'), findsOneWidget);
      expect(find.text('شحن بين المحافظات'), findsOneWidget);

      // Card 4
      expect(find.text('ضمان وصول حمولتك وسلامتها'), findsOneWidget);
      expect(find.text('تغطية وتأمين موثوق'), findsOneWidget);
    });

    testWidgets('6. صف الخدمات الست الرئيسية: تظهر بالترتيب الصحيح وتستجيب للنقر',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var myCargosTapped = false;
      var walletTapped = false;
      var mapTapped = false;
      var addCargoTapped = false;

      await tester.pumpWidget(
        wrapWidget(
          ClientHomeScreen(
            onMyCargos: () => myCargosTapped = true,
            onWallet: () => walletTapped = true,
            onMap: () => mapTapped = true,
            onAddCargo: () => addCargoTapped = true,
          ),
        ),
      );
      await tester.pump();

      // Verify presence of all 6 services
      expect(find.text('حمولاتي'), findsWidgets);
      expect(find.text('محفظتي'), findsWidgets);
      expect(find.text('عرض السائقين'), findsWidgets);
      expect(find.text('إنشاء طلب نقل'), findsOneWidget);
      expect(find.text('إضافة حمولة'), findsWidgets);
      expect(find.text('تتبع الحمولة'), findsWidgets);

      // Test tapping on services
      await tester.tap(find.text('حمولاتي').first);
      await tester.pump();
      expect(myCargosTapped, isTrue);

      await tester.tap(find.text('محفظتي').first);
      await tester.pump();
      expect(walletTapped, isTrue);

      await tester.tap(find.text('عرض السائقين').first);
      await tester.pump();
      expect(mapTapped, isTrue);

      await tester.tap(find.text('إضافة حمولة').first);
      await tester.pump();
      expect(addCargoTapped, isTrue);
    });

    testWidgets('7. بطاقات إحصائيات النشاط الأربع: تعرض الأرقام المحددة بدقة',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      expect(find.text('ملخص النشاط'), findsOneWidget);
      expect(find.text('طلبات نشطة'), findsOneWidget);
      expect(find.text('2'), findsWidgets);

      expect(find.text('بانتظار العروض'), findsOneWidget);
      expect(find.text('1'), findsWidgets);

      expect(find.text('قيد النقل'), findsOneWidget);

      expect(find.text('مكتملة'), findsOneWidget);
      expect(find.text('12'), findsWidgets);
    });

    testWidgets('8. العرض الترويجي: يظهر خصم 15% وكود HAMULA15 مع زر النسخ',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      expect(find.text('خصم 15% على أول طلب نقل'), findsOneWidget);
      expect(find.text('HAMULA15'), findsOneWidget);
      expect(find.text('نسخ الكود'), findsOneWidget);

      await tester.tap(find.text('نسخ الكود'));
      await tester.pumpAndSettle();

      expect(find.textContaining('تم نسخ كود الخصم HAMULA15 بنجاح!'), findsOneWidget);
    });

    testWidgets('9. شريط التنقل السفلي والزر العائم: 5 أقسام وقائمة الإجراءات السريعة',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('الإشعارات'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // Tap central floating + button
      final fabButton = find.byTooltip('إجراءات سريعة');
      expect(fabButton, findsOneWidget);
      await tester.tap(fabButton);
      await tester.pumpAndSettle();

      // Check Quick Actions bottom sheet appeared
      expect(find.text('الإجراءات السريعة'), findsOneWidget);
      expect(find.text('إغلاق'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('إغلاق'));
      await tester.pumpAndSettle();
      expect(find.text('الإجراءات السريعة'), findsNothing);
    });

    testWidgets('10. عزل هوية العميل: لا يظهر السجل التجاري أو رخصة القيادة أو سعة الشاحنة',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      // Merchant and Driver specific terms must NEVER be in client home
      expect(find.text('السجل التجاري'), findsNothing);
      expect(find.text('رخصة القيادة'), findsNothing);
      expect(find.text('سعة الشاحنة'), findsNothing);
      expect(find.text('حمولة الشاحنة'), findsNothing);
      expect(find.text('بيانات الشاحنة'), findsNothing);
    });

    testWidgets('11. شريط البحث وشارة حساب شخصي وأيقونات الرأس تظهر بوضوح',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWidget(const ClientHomeScreen()));
      await tester.pump();

      // Badge 'حساب شخصي'
      expect(find.text('حساب شخصي'), findsOneWidget);

      // Search Bar with prompt text and filter icon
      expect(find.text('ابحث عن حمولة، سائق، أو مسار...'), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });
  });
}
