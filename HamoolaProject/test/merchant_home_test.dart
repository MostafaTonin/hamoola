import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_profile.dart';
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
      'MerchantHomeScreen renders Image 3 UI: header greeting, hero banner, main services and summary',
      (tester) async {
    bool createOrderTapped = false;
    bool cargosTapped = false;
    bool mapTapped = false;
    bool ordersTapped = false;

    await tester.pumpWidget(
      wrapWidget(
        MerchantHomeScreen(
          isVerified: true,
          onCreateOrder: () => createOrderTapped = true,
          onCargos: () => cargosTapped = true,
          onMap: () => mapTapped = true,
          onOrders: () => ordersTapped = true,
        ),
      ),
    );
    await tester.pump();

    // Verify top header matching Image 3
    expect(find.text(AppStrings.goodMorningGreeting), findsOneWidget);
    expect(find.text('مؤسسة النور للتجارة العامة'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);

    // Verify hero banner carousel title
    expect(find.textContaining('انقل حمولتك'), findsOneWidget);

    // Verify "الخدمات الرئيسية" section and pastel action cards
    expect(find.text('الخدمات الرئيسية'), findsOneWidget);
    expect(find.text('إنشاء طلب نقل'), findsOneWidget);
    expect(find.text('عرض السائقين'), findsOneWidget);
    expect(find.text('حمولاتي'), findsOneWidget);
    expect(find.text('طلباتي'), findsWidgets);

    // Tap "إنشاء طلب نقل"
    await tester.tap(find.text('إنشاء طلب نقل'));
    expect(createOrderTapped, isTrue);

    // Tap "عرض السائقين"
    await tester.tap(find.text('عرض السائقين'));
    expect(mapTapped, isTrue);

    // Tap "حمولاتي"
    await tester.tap(find.text('حمولاتي'));
    expect(cargosTapped, isTrue);

    // Tap "طلباتي"
    await tester.tap(find.text('طلباتي').first);
    expect(ordersTapped, isTrue);

    // Verify activity summary section
    expect(find.text(AppStrings.activitySummarySection), findsOneWidget);
    expect(find.text(AppStrings.activeOrders), findsOneWidget);
    expect(find.text(AppStrings.newOffers), findsWidgets);
    expect(find.text('حمولات مسجلة'), findsOneWidget);
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
    await tester.tap(find.text('إنشاء طلب نقل'));
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
            merchantName: MerchantProfile.instance.contactName,
            companyName: MerchantProfile.instance.companyName,
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
    expect(find.text('مؤسسة النور للتجارة العامة'), findsOneWidget);
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
    expect(find.text('الخريطة'), findsOneWidget);
    expect(find.text('طلباتي'), findsOneWidget);
    expect(find.text('حسابي'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Tap orders tab
    await tester.tap(find.text('طلباتي'));
    expect(selectedTab, equals(MerchantNavTab.orders));

    // Tap Map tab
    await tester.tap(find.text('الخريطة'));
    expect(selectedTab, equals(MerchantNavTab.map));

    // Tap FAB
    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(fabTapped, isTrue);
  });

  testWidgets(
      'MerchantHomeScreen FAB (+) toggles in-screen dark quick actions card and converts to (X)',
      (tester) async {
    bool createOrderCalled = false;
    bool cargosCalled = false;

    await tester.pumpWidget(
      wrapWidget(
        MerchantHomeScreen(
          isVerified: true,
          onCreateOrder: () => createOrderCalled = true,
          onCargos: () => cargosCalled = true,
        ),
      ),
    );
    await tester.pump();

    // Tap center FAB (+) button in bottom navigation bar
    final addIconFinder = find.byIcon(Icons.add_rounded);
    expect(addIconFinder, findsOneWidget);
    await tester.tap(addIconFinder);
    await tester.pumpAndSettle();

    // Verify FAB icon changed from (+) to (X)
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Verify 4 approved actions only inside the dark card
    expect(find.text('طلب نقل'), findsOneWidget);
    expect(find.text('تتبع الحمولة'), findsOneWidget);
    expect(find.text('إضافة حمولة'), findsOneWidget);
    expect(find.text('إضافة رصيد'), findsOneWidget);

    // Tap "طلب نقل" -> must execute callback and close card
    await tester.tap(find.text('طلب نقل'));
    await tester.pumpAndSettle();

    expect(createOrderCalled, isTrue);
    // Card closed, icon reverted back to (+)
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Open again and test tapping "إضافة حمولة"
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    await tester.tap(find.text('إضافة حمولة'));
    await tester.pumpAndSettle();
    expect(cargosCalled, isTrue);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
