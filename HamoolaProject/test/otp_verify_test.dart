import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/auth/presentation/screens/otp_verify_screen.dart';

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

  testWidgets('OtpVerifyScreen renders header, phone pill, 6 inputs, timer and submit',
      (tester) async {
    bool backPressed = false;
    bool verified = false;

    await tester.pumpWidget(
      wrapWidget(
        OtpVerifyScreen(
          phoneNumber: '+967 770 123 456',
          onBack: () => backPressed = true,
          onVerified: () => verified = true,
        ),
      ),
    );
    await tester.pump();

    // Verify title and subtitle
    expect(find.text(AppStrings.otpTitle), findsOneWidget);
    expect(find.text(AppStrings.otpSubtitle), findsOneWidget);

    // Verify phone pill with edit button
    expect(find.text('+967 770 123 456'), findsOneWidget);
    expect(find.text(AppStrings.editPhoneBtn), findsOneWidget);

    // Verify 6 TextField boxes
    expect(find.byType(TextField), findsNWidgets(6));

    // Verify submit button is visible initially
    expect(find.text(AppStrings.verifyButton), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
    expect(backPressed, isTrue);

    // Enter digits into all 6 fields
    final textFields = find.byType(TextField);
    for (int i = 0; i < 6; i++) {
      await tester.enterText(textFields.at(i), '${i + 1}');
    }
    await tester.pump();

    // Completing all 6 digits auto-verifies
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(verified, isTrue);
  });

  testWidgets('OtpVerifyScreen shows error message when code is incomplete',
      (tester) async {
    await tester.pumpWidget(
      wrapWidget(
        const OtpVerifyScreen(),
      ),
    );
    await tester.pump();

    // Tap verify without entering code
    await tester.tap(find.text(AppStrings.verifyButton));
    await tester.pump();

    expect(find.text('يرجى إدخال كامل الرمز (6 أرقام)'), findsOneWidget);
  });
}
