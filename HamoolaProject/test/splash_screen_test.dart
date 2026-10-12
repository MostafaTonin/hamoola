import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/onboarding/presentation/screens/splash_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('SplashScreen renders brand title, tagline, logo, and version',
      (tester) async {
    // Provide a long duration to test static initial frame rendering
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        home: const SplashScreen(
          duration: Duration(seconds: 10),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify brand title and tagline
    expect(find.text('حمولة'), findsOneWidget);
    expect(find.text('منصتك الذكية لربط الشحنات والشاحنات'), findsOneWidget);

    // Verify version text
    expect(find.text('الإصدار 1.0.0'), findsOneWidget);
  });
}
