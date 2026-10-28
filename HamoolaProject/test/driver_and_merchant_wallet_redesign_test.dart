import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_colors.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_wallet_screen.dart';

Widget wrapTestWidget(Widget child) {
  return MaterialApp(
    home: child,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGold),
      textTheme: GoogleFonts.cairoTextTheme(),
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    MerchantSimulationStore.instance.resetToDemo();
  });

  group('Driver Wallet Screen Tests (محفظة السائق — مطابقة الصورة المرجعية)', () {
    testWidgets('Driver sees available balance for withdrawal, eye toggle, dues, and withdrawals metrics',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool backPressed = false;

      await tester.pumpWidget(
        wrapTestWidget(
          MerchantWalletScreen(
            userRole: AuthUserRole.driver,
            onBack: () => backPressed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.text(AppStrings.merchantWalletTitle), findsOneWidget); // محفظتي
      expect(find.text(AppStrings.merchantWalletSub), findsOneWidget); // محفظتك الرقمية في حمولة
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsWidgets);

      // Back action
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backPressed, isTrue);

      // 2. Balance Card Top
      expect(find.text(AppStrings.availableBalanceForWithdrawal), findsOneWidget); // الرصيد المتاح للسحب
      expect(find.text('25000'), findsOneWidget); // 25,000 YER initial demo balance

      // 3. Eye Toggle Interaction
      final eyeIcon = find.byIcon(Icons.visibility_rounded);
      expect(eyeIcon, findsOneWidget);

      // Toggle to hide
      await tester.tap(eyeIcon);
      await tester.pumpAndSettle();
      expect(find.text('••••••'), findsWidgets);
      expect(find.text('25000'), findsNothing);

      // Toggle to show again
      final eyeOffIcon = find.byIcon(Icons.visibility_off_rounded);
      expect(eyeOffIcon, findsOneWidget);
      await tester.tap(eyeOffIcon);
      await tester.pumpAndSettle();
      expect(find.text('25000'), findsOneWidget);

      // 4. Two Bottom Columns
      expect(find.text(AppStrings.pendingDuesLabel), findsOneWidget); // المستحقات المعلّقة
      expect(find.text('5000 ${AppStrings.currencyYerShort}'), findsOneWidget); // 5,000 YER pending
      expect(find.text(AppStrings.totalWithdrawnLabel), findsOneWidget); // إجمالي المسحوبات
      expect(find.text('40000 ${AppStrings.currencyYerShort}'), findsOneWidget); // 40,000 YER total withdrawn

      // 5. Action Card: Withdraw balance button is PRESENT, Add balance is ABSENT
      expect(find.text(AppStrings.withdrawBalanceBtn), findsOneWidget); // سحب الرصيد
      expect(find.text(AppStrings.withdrawBalanceSub), findsOneWidget);
      expect(find.text(AppStrings.addBalanceBtn), findsNothing); // Drivers cannot add balance

      // 6. Transaction filters for driver
      expect(find.text(AppStrings.txFilterAll), findsOneWidget);
      expect(find.text(AppStrings.txFilterDues), findsOneWidget);
      expect(find.text(AppStrings.txFilterWithdrawals), findsOneWidget);

      // Transactions from reference image are displayed
      expect(find.textContaining('HM-1042'), findsOneWidget);
      expect(find.textContaining('WD-204'), findsOneWidget);
      expect(find.textContaining('HM-1038'), findsOneWidget);
    });

    testWidgets('Driver filters transactions by dues and withdrawals properly', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantWalletScreen(
            userRole: AuthUserRole.driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Filter by Dues (المستحقات)
      await tester.tap(find.text(AppStrings.txFilterDues));
      await tester.pumpAndSettle();

      expect(find.textContaining('HM-1042'), findsOneWidget);
      expect(find.textContaining('HM-1038'), findsOneWidget);
      expect(find.textContaining('WD-204'), findsNothing); // Withdrawal hidden

      // Filter by Withdrawals (السحوبات)
      await tester.tap(find.text(AppStrings.txFilterWithdrawals));
      await tester.pumpAndSettle();

      expect(find.textContaining('WD-204'), findsOneWidget);
      expect(find.textContaining('WD-203'), findsOneWidget);
      expect(find.textContaining('HM-1042'), findsNothing); // Trip dues hidden
    });

    testWidgets('Driver tapping withdraw opens withdrawal request sheet and submits', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantWalletScreen(
            userRole: AuthUserRole.driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Withdraw action card
      await tester.tap(find.text(AppStrings.withdrawBalanceBtn));
      await tester.pumpAndSettle();

      // Verify sheet opened
      expect(find.text('طلب سحب المستحقات المالية'), findsOneWidget);
      expect(find.text('بنك الكريمي للتمويل الأصغر الإسلامي'), findsWidgets);
      expect(find.text('تأكيد إرسال طلب السحب'), findsOneWidget);

      // Submit withdrawal of 5000 YER
      await tester.tap(find.text('تأكيد إرسال طلب السحب'));
      await tester.pumpAndSettle();

      // Sheet closed and balance deducted from 25,000 to 20,000
      expect(find.text('20000'), findsOneWidget);
      expect(find.text('طلب سحب'), findsWidgets);
    });
  });

  group('Merchant & Client Wallet Screen Tests (محفظة التاجر والعميل الموحدة)', () {
    testWidgets('Merchant sees available balance, pending reviews, add balance button, and no withdrawal button',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool addBalanceTriggered = false;

      await tester.pumpWidget(
        wrapTestWidget(
          MerchantWalletScreen(
            userRole: AuthUserRole.merchant,
            onAddBalance: () => addBalanceTriggered = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Balance card
      expect(find.text(AppStrings.currentBalanceLabel), findsOneWidget); // الرصيد المتاح
      expect(find.text(AppStrings.pendingReviewLabel), findsOneWidget); // المبالغ المعلّقة
      expect(find.text(AppStrings.totalPaymentsLabel), findsOneWidget); // إجمالي المدفوعات

      // 2. Action card
      expect(find.text(AppStrings.addBalanceBtn), findsOneWidget); // إضافة رصيد
      expect(find.text(AppStrings.withdrawBalanceBtn), findsNothing); // NO withdraw button for Merchant

      // Tap Add Balance
      await tester.tap(find.text(AppStrings.addBalanceBtn));
      expect(addBalanceTriggered, isTrue);

      // 3. Filters for Merchant
      expect(find.text(AppStrings.txFilterAll), findsOneWidget);
      expect(find.text(AppStrings.txFilterDeposits), findsOneWidget);
      expect(find.text(AppStrings.txFilterPayments), findsOneWidget);
      expect(find.text(AppStrings.txFilterRefunds), findsOneWidget);
    });

    testWidgets('Client wallet uses same visual layout without withdrawal capability', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantWalletScreen(
            userRole: AuthUserRole.client,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.merchantWalletTitle), findsOneWidget);
      expect(find.text(AppStrings.currentBalanceLabel), findsOneWidget);
      expect(find.text(AppStrings.addBalanceBtn), findsOneWidget);
      expect(find.text(AppStrings.withdrawBalanceBtn), findsNothing);
      expect(find.text('طلب سحب أرباح المكتب'), findsNothing);
    });

    testWidgets('Renders cleanly on 360px width without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantWalletScreen(
            userRole: AuthUserRole.driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
