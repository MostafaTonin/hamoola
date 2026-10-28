import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/client/presentation/screens/client_account_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget wrapWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      home: child,
    );
  }

  testWidgets('ClientAccountScreen renders Image 1 UI strictly in RTL', (tester) async {
    bool backTapped = false;

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      wrapWidget(
        ClientAccountScreen(
          onBack: () => backTapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Profile
    expect(find.text('حسابي'), findsWidgets);
    expect(find.text('مصطفى يحيى صالح طنين'), findsOneWidget);
    expect(find.text('موثق'), findsOneWidget);
    expect(find.text('رقم الحساب'), findsOneWidget);
    expect(find.text('783707104'), findsOneWidget);
    expect(find.text('رقم الهاتف'), findsOneWidget);
    expect(find.text('+967 777 123 456'), findsOneWidget);
    expect(find.text('تعديل بيانات الحساب'), findsWidgets);

    // Verify 3 KPI cards (Image 1)
    expect(find.text('رحلة مكتملة'), findsOneWidget);
    expect(find.text('طلبات نشطة'), findsOneWidget);
    expect(find.text('حمولة مسجلة'), findsOneWidget);

    // Verify Menu Items & Sections (Image 1)
    expect(find.text('بيانات الحساب'), findsOneWidget);
    expect(find.text('تحديث بيانات الهوية'), findsOneWidget);
    expect(find.text('بيانات التواصل'), findsOneWidget);
    expect(find.text('العنوان والموقع'), findsOneWidget);
    expect(find.text('عمليات حمولة'), findsOneWidget);
    expect(find.text('طلباتي'), findsWidgets);
    expect(find.text('حمولاتي'), findsOneWidget);
    expect(find.text('محفظتي'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);

    // Verify Back navigation tap
    await tester.tap(find.byTooltip('رجوع'));
    expect(backTapped, isTrue);
  });
}
