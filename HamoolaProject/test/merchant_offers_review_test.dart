import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/driver_offer.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_offers_review_screen.dart';

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
      'MerchantOffersReviewScreen renders order hero, filters, driver bids, and handles accept',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool backTapped = false;
    DriverOffer? acceptedOffer;

    await tester.pumpWidget(
      wrapWidget(
        MerchantOffersReviewScreen(
          orderId: 'REQ-1024',
          onBack: () => backTapped = true,
          onOfferAccepted: (offer) => acceptedOffer = offer,
        ),
      ),
    );
    await tester.pump();

    // Verify title and header badges
    expect(find.text(AppStrings.offersReviewTitle), findsOneWidget);
    expect(find.text('REQ-1024'), findsOneWidget);
    expect(find.text(AppStrings.cargoFoodstuff), findsOneWidget);
    expect(find.text(AppStrings.routeSanaaAden), findsOneWidget);

    // Verify filter chips
    expect(find.text(AppStrings.filterLowestPrice), findsOneWidget);
    expect(find.text(AppStrings.filterHighestRating), findsWidgets);

    // Verify driver cards exist
    expect(find.text('كابتن سالم العولقي'), findsOneWidget);
    expect(find.text('كابتن نبيل الحاشدي'), findsOneWidget);
    expect(find.text('420,000 ر.ي'), findsOneWidget);

    // Verify back button
    await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
    expect(backTapped, isTrue);

    // Tap negotiate button to open negotiation sheet
    await tester.tap(find.text(AppStrings.negotiateOfferBtn).first);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.counterOfferTitle), findsOneWidget);
    expect(find.text(AppStrings.sendCounterOfferBtn), findsOneWidget);

    // Close negotiation sheet
    await tester.tap(find.text(AppStrings.sendCounterOfferBtn));
    await tester.pumpAndSettle();

    // Tap accept offer button
    await tester.tap(find.text(AppStrings.acceptOfferBtn).first);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.contractConfirmTitle), findsOneWidget);
    expect(find.text(AppStrings.confirmAndDispatchBtn), findsOneWidget);

    // Confirm contract
    await tester.tap(find.text(AppStrings.confirmAndDispatchBtn));
    await tester.pumpAndSettle();

    expect(acceptedOffer, isNotNull);
    expect(acceptedOffer?.driverName, equals('كابتن سالم العولقي'));
  });

  testWidgets('MerchantOffersReviewScreen filters offers by criteria',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      wrapWidget(
        const MerchantOffersReviewScreen(),
      ),
    );
    await tester.pump();

    // Tap filter fastest
    await tester.tap(find.text(AppStrings.filterFastestPickup));
    await tester.pumpAndSettle();

    // Fastest driver should be present
    expect(find.text('كابتن عادل باوزير'), findsOneWidget);
  });
}
