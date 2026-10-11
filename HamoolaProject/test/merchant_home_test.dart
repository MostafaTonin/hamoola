import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_home_screen.dart';
import 'package:flutter_application/features/merchant/presentation/widgets/merchant_bottom_nav_bar.dart';
import 'package:flutter_application/features/merchant/presentation/widgets/merchant_drawer.dart';

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
      'MerchantHomeScreen renders screenshot UI: header greeting, hero banner, quick services and summary',
      (tester) async {
    bool createOrderTapped = false;
    bool cargosTapped = false;

    await tester.pumpWidget(
      wrapWidget(
        MerchantHomeScreen(
          isVerified: true,
          onCreateOrder: () => createOrderTapped = true,
          onCargos: () => cargosTapped = true,
        ),
      ),
    );
    await tester.pump();

    // Verify top header matching screenshot
    expect(find.text(AppStrings.goodMorningGreeting), findsOneWidget);
    expect(find.text(AppStrings.readyToTransportSubtitle), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

    // Verify hero banner
    expect(find.text(AppStrings.newCargoBadge), findsOneWidget);
    expect(find.text(AppStrings.doYouHaveNewCargoTitle), findsOneWidget);
    expect(find.text(AppStrings.createOrderHeroDesc), findsOneWidget);

    // Verify quick services section & primary CTA
    expect(find.text(AppStrings.quickServicesSection), findsOneWidget);
    expect(find.text(AppStrings.createTransportOrderBtn), findsOneWidget);
    await tester.tap(find.text(AppStrings.createTransportOrderBtn));
    expect(createOrderTapped, isTrue);

    // Verify 4 square action cards (حمولاتي, عروضي, التتبع, السجل)
    expect(find.text(AppStrings.myCargosQuick), findsOneWidget);
    expect(find.text(AppStrings.myOffersQuick), findsOneWidget);
    expect(find.text(AppStrings.trackingQuick), findsOneWidget);
    expect(find.text(AppStrings.historyQuick), findsOneWidget);

    await tester.tap(find.text(AppStrings.myCargosQuick));
    expect(cargosTapped, isTrue);

    // Verify activity summary section
    expect(find.text(AppStrings.activitySummarySection), findsOneWidget);
    expect(find.text(AppStrings.activeOrders), findsOneWidget);
    expect(find.text(AppStrings.newOffers), findsWidgets);
    expect(find.text(AppStrings.pendingAction), findsOneWidget);
  });

  testWidgets(
      'MerchantHomeScreen gates restricted actions when account is unverified',
      (tester) async {
    bool verifyNowTapped = false;
    bool createOrderTapped = false;

    await tester.pumpWidget(
      wrapWidget(
        MerchantHomeScreen(
          isVerified: false,
          onCreateOrder: () => createOrderTapped = true,
          onVerifyNow: () => verifyNowTapped = true,
        ),
      ),
    );
    await tester.pump();

    // Verify unverified notice banner is shown
    expect(find.text(AppStrings.accountNotVerifiedBannerTitle), findsOneWidget);
    expect(find.text(AppStrings.accountNotVerifiedBannerSubtitle), findsOneWidget);

    // Tap CTA when unverified -> must NOT trigger createOrder, must show modal
    await tester.tap(find.text(AppStrings.createTransportOrderBtn));
    await tester.pumpAndSettle();

    expect(createOrderTapped, isFalse);
    expect(find.text(AppStrings.verificationRequiredTitle), findsOneWidget);
    expect(find.text(AppStrings.startVerificationBtn), findsOneWidget);

    // Tap start verification button inside modal
    await tester.tap(find.text(AppStrings.startVerificationBtn));
    await tester.pumpAndSettle();
    expect(verifyNowTapped, isTrue);
  });

  testWidgets('MerchantDrawer displays merchant profile and triggers menu actions',
      (tester) async {
    bool servicePointsTapped = false;
    bool supportTapped = false;
    bool logoutTapped = false;

    await tester.pumpWidget(
      wrapWidget(
        Scaffold(
          drawer: MerchantDrawer(
            onServicePoints: () => servicePointsTapped = true,
            onSupport: () => supportTapped = true,
            onLogout: () => logoutTapped = true,
          ),
          body: const SizedBox(),
        ),
      ),
    );
    await tester.pump();

    // Open drawer
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('محمد أحمد'), findsOneWidget);
    expect(find.text('مؤسسة الأمل التجارية'), findsOneWidget);
    expect(find.text('حساب تاجر معتمد'), findsOneWidget);
    expect(find.text('نقاط الخدمة'), findsOneWidget);
    expect(find.text('خدمة العملاء'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);

    // Tap Support
    await tester.tap(find.text('خدمة العملاء'));
    await tester.pumpAndSettle();
    expect(supportTapped, isTrue);

    // Reopen drawer and tap points
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('نقاط الخدمة'));
    await tester.pumpAndSettle();
    expect(servicePointsTapped, isTrue);

    // Reopen drawer and tap logout
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسجيل الخروج'));
    await tester.pumpAndSettle();
    expect(logoutTapped, isTrue);
  });

  testWidgets('MerchantBottomNavBar renders 5 slots and triggers callbacks',
      (tester) async {
    MerchantNavTab selectedTab = MerchantNavTab.home;
    bool fabTapped = false;

    await tester.pumpWidget(
      wrapWidget(
        Scaffold(
          bottomNavigationBar: MerchantBottomNavBar(
            currentTab: selectedTab,
            onTabSelected: (tab) => selectedTab = tab,
            onFabPressed: () => fabTapped = true,
            showMapTab: true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('طلباتي'), findsOneWidget);
    expect(find.text('الخريطة'), findsOneWidget);
    expect(find.text('حسابي'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Tap orders tab
    await tester.tap(find.text('طلباتي'));
    expect(selectedTab, equals(MerchantNavTab.orders));

    // Tap FAB
    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(fabTapped, isTrue);
  });

  testWidgets(
      'MerchantHomeScreen FAB (+) opens Quick Services bottom sheet modal with 4 square options',
      (tester) async {
    bool createOrderCalled = false;

    await tester.pumpWidget(
      wrapWidget(
        MerchantHomeScreen(
          isVerified: true,
          onCreateOrder: () => createOrderCalled = true,
        ),
      ),
    );
    await tester.pump();

    // Verify initial slide
    expect(find.text('هل لديك شحنة جديدة؟'), findsOneWidget);

    // Tap center FAB (+) button in bottom navigation bar
    final fabFinder = find.descendant(
      of: find.byType(MerchantBottomNavBar),
      matching: find.byIcon(Icons.add_rounded),
    );
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // Verify Quick Services modal header
    expect(find.text('خدمات سريعة'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Verify 4 square options without explanatory subtexts
    expect(find.text('طلب نقل'), findsOneWidget);
    expect(find.text('تتبع الرحلة'), findsOneWidget);
    expect(find.text('إضافة حمولة'), findsOneWidget);
    expect(find.text('خريطة السائقين'), findsOneWidget);

    // Tap "طلب نقل" inside the modal
    await tester.tap(find.text('طلب نقل'));
    await tester.pumpAndSettle();

    expect(createOrderCalled, isTrue);
  });
}
