import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:flutter_application/features/auth/presentation/screens/terms_screen.dart';
import 'package:flutter_application/features/auth/presentation/widgets/biometric_modal_sheet.dart';
import 'package:flutter_application/features/auth/presentation/widgets/toll_free_dialer_modal_sheet.dart';
import 'package:flutter_application/features/common/presentation/screens/customer_support_screen.dart';
import 'package:flutter_application/features/common/presentation/screens/service_points_screen.dart';

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

  testWidgets('TermsScreen renders articles and handles accept', (tester) async {
    bool accepted = false;
    await tester.pumpWidget(
      wrapWidget(
        TermsScreen(onAccept: () => accepted = true),
      ),
    );
    await tester.pump();

    expect(find.text('الشروط والأحكام'), findsWidgets);
    expect(find.text('مقدمة'), findsOneWidget);
    expect(find.text('أوافق على الشروط والمتابعة'), findsOneWidget);

    await tester.tap(find.text('أوافق على الشروط والمتابعة'));
    expect(accepted, isTrue);
  });

  testWidgets('CustomerSupportScreen renders channels and FAQs', (tester) async {
    await tester.pumpWidget(
      wrapWidget(
        const CustomerSupportScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('خدمة العملاء'), findsOneWidget);
    expect(find.text('فريق الدعم الفني جاهز لمساعدتك'), findsOneWidget);
    expect(find.text('اتصال هاتفي مباشر'), findsOneWidget);
    expect(find.text('محادثة واتساب (WhatsApp)'), findsOneWidget);
    expect(find.text('الأسئلة الشائعة (FAQ)'), findsOneWidget);
    expect(find.textContaining('800002026'), findsWidgets);
    expect(find.textContaining('783707104'), findsWidgets);

    // Tap phone channel
    await tester.tap(find.text('اتصال هاتفي مباشر'));
    await tester.pump();

    // Tap WhatsApp channel
    await tester.tap(find.text('محادثة واتساب (WhatsApp)'));
    await tester.pump();
  });

  testWidgets('ServicePointsScreen renders search and city points', (tester) async {
    await tester.pumpWidget(
      wrapWidget(
        const ServicePointsScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('نقاط الخدمة'), findsOneWidget);
    expect(find.text('المراكز والمحطات المعتمدة'), findsOneWidget);
    expect(find.text('نقطة خدمة صنعاء المركزية'), findsOneWidget);
    expect(find.text('نقطة خدمة ميناء عدن'), findsOneWidget);

    // Search filter
    await tester.enterText(find.byType(TextFormField), 'المكلا');
    await tester.pump();

    expect(find.text('نقطة خدمة حضرموت - المكلا'), findsOneWidget);
    expect(find.text('نقطة خدمة صنعاء المركزية'), findsNothing);
  });

  testWidgets('ForgotPasswordScreen completes step 1 to step 2', (tester) async {
    await tester.pumpWidget(
      wrapWidget(
        const ForgotPasswordScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('استعادة كلمة المرور'), findsWidgets);
    expect(find.text('إرسال رمز التحقق'), findsOneWidget);

    // Enter phone and submit
    await tester.enterText(find.byType(TextFormField), '771234567');
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pump();

    // Now in step 2 (OTP)
    expect(find.text('التحقق من رقم الهاتف'), findsOneWidget);
    expect(find.text('تحقق ومتابعة'), findsOneWidget);
  });

  testWidgets('TollFreeDialerModalSheet renders number and triggers call', (tester) async {
    await tester.pumpWidget(
      wrapWidget(
        const Scaffold(
          body: TollFreeDialerModalSheet(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('حمولة — الرقم المجاني'), findsOneWidget);
    expect(find.text('800002026'), findsOneWidget);
    expect(find.text('اتصال الآن'), findsOneWidget);

    await tester.tap(find.text('اتصال الآن'));
    await tester.pump();
  });

  testWidgets('BiometricModalSheet renders sensor and verifies', (tester) async {
    bool verified = false;
    await tester.pumpWidget(
      wrapWidget(
        Scaffold(
          body: BiometricModalSheet(onSuccess: () => verified = true),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('المصادقة بالبصمة'), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);

    // Tap sensor directly
    await tester.tap(find.byIcon(Icons.fingerprint_rounded));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('تم التحقق بنجاح!'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(verified, isTrue);
  });
}
