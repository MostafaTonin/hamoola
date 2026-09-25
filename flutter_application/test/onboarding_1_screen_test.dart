import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/onboarding/presentation/screens/onboarding_1_screen.dart';

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

  testWidgets('Onboarding1Screen renders title, description, skip and next buttons',
      (tester) async {
    bool nextTapped = false;
    bool skipTapped = false;

    await tester.pumpWidget(
      wrapWidget(
        Onboarding1Screen(
          onNext: () => nextTapped = true,
          onSkip: () => skipTapped = true,
        ),
      ),
    );

    await tester.pump();

    // Verify Title and Description
    expect(find.text(AppStrings.onboarding1Title), findsOneWidget);
    expect(find.text(AppStrings.onboarding1Desc), findsOneWidget);

    // Verify Skip and Next Buttons
    expect(find.text(AppStrings.skip), findsOneWidget);
    expect(find.text(AppStrings.next), findsOneWidget);

    // Tap Skip
    await tester.tap(find.text(AppStrings.skip));
    expect(skipTapped, isTrue);

    // Tap Next
    await tester.tap(find.text(AppStrings.next));
    expect(nextTapped, isTrue);
  });
}
