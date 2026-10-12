import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_verification_screen.dart';

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

  testWidgets(
      'MerchantVerificationScreen renders title, step tracker, form fields, and document cards',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool backTapped = false;
    bool? verifiedStatus;

    await tester.pumpWidget(
      wrapWidget(
        MerchantVerificationScreen(
          onBack: () => backTapped = true,
          onVerificationComplete: (val) => verifiedStatus = val,
        ),
      ),
    );
    await tester.pump();

    // Verify title and status pill
    expect(find.text(AppStrings.merchantKycTitle), findsOneWidget);
    expect(find.text('غير مكتمل'), findsOneWidget);

    // Verify step tracker items
    expect(find.text('الهاتف'), findsOneWidget);
    expect(find.text('بيانات المنشأة'), findsOneWidget);
    expect(find.text('الاعتماد'), findsOneWidget);

    // Verify form fields
    expect(find.text(AppStrings.companyNameField), findsOneWidget);
    expect(find.text(AppStrings.crNumberField), findsOneWidget);
    expect(find.text(AppStrings.taxNumberField), findsOneWidget);
    expect(find.text(AppStrings.authorizedPersonField), findsOneWidget);

    // Verify document cards
    expect(find.text(AppStrings.crDocTitle), findsOneWidget);
    expect(find.text(AppStrings.nationalIdDocTitle), findsOneWidget);
    expect(find.text(AppStrings.authorizationDocTitle), findsOneWidget);

    // Verify back action
    await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
    expect(backTapped, isTrue);

    // Tap submit for review
    await tester.ensureVisible(find.text(AppStrings.submitKycBtn));
    await tester.tap(find.text(AppStrings.submitKycBtn));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify transition to pending review
    expect(find.text(AppStrings.kycPendingReviewStatus), findsOneWidget);

    // Tap instant approve demo button
    await tester.ensureVisible(find.text(AppStrings.kycInstantApproveDemoBtn));
    await tester.tap(find.text(AppStrings.kycInstantApproveDemoBtn));
    await tester.pumpAndSettle();

    expect(verifiedStatus, isTrue);
    expect(find.text(AppStrings.kycVerifiedStatus), findsOneWidget);
    expect(find.text('موثق ✓'), findsOneWidget);
  });
}
