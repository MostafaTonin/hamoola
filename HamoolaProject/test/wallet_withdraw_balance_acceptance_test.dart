import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/merchant/domain/models/wallet_models.dart';
import 'package:flutter_application/features/merchant/presentation/screens/wallet_withdraw_balance_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Widget wrapTestWidget(Widget child, {TextDirection direction = TextDirection.rtl}) {
  return MaterialApp(
    home: Directionality(
      textDirection: direction,
      child: child,
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    MerchantSimulationStore.instance.resetToDemo();
  });

  group('Wallet Withdraw Balance Acceptance Tests (شاشة سحب الرصيد الموحدة)', () {
    // 1. Initial State & Visual Elements for Driver
    testWidgets(
        'Scenario 1: Driver opens screen, sees header, balance card with eye toggle, and default subscriber method',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const WalletWithdrawBalanceScreen(
            userRole: AuthUserRole.driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header verification
      expect(find.text(AppStrings.withdrawBalanceTitle), findsOneWidget);
      expect(find.text(AppStrings.withdrawBalanceHeaderSub), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsWidgets);

      // Balance Card verification
      expect(find.text(AppStrings.availableBalanceForWithdrawal), findsOneWidget);
      expect(find.text('25,000'), findsWidgets); // Appears in Balance Card and Max Chip
      expect(find.text(AppStrings.currencyYerShort), findsWidgets);
      expect(find.textContaining(AppStrings.pendingDuesLabel), findsOneWidget);

      // Eye toggle: tap to hide balance
      final eyeBtn = find.byIcon(Icons.visibility_rounded);
      expect(eyeBtn, findsOneWidget);
      await tester.tap(eyeBtn);
      await tester.pumpAndSettle();
      expect(find.text('••••••'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);

      // Restore balance visibility
      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pumpAndSettle();
      expect(find.text('25,000'), findsWidgets);

      // Default Method: "تحويل لمشترك"
      expect(find.text(AppStrings.withdrawMethodSubscriberTitle), findsOneWidget);
      expect(find.text(AppStrings.withdrawMethodSubscriberDesc), findsOneWidget);

      // Recipient Fields for Subscriber
      expect(find.text(AppStrings.recipientPhoneLabel), findsOneWidget);
      expect(find.text(AppStrings.recipientPhoneHint), findsOneWidget);
      expect(find.text(AppStrings.recipientFullNameLabel), findsOneWidget);
      expect(find.text(AppStrings.recipientFullNameHint), findsOneWidget);
      expect(find.text(AppStrings.subscriberWarningNotice), findsOneWidget);

      // Ensure POS fields are NOT visible
      expect(find.text(AppStrings.posPointNumberLabel), findsNothing);
      expect(find.text(AppStrings.posCommercialNameLabel), findsNothing);
    });

    // 2. Interactive Method Switch: Change to POS (دفع مشتريات)
    testWidgets(
        'Scenario 2: Tapping method opens picker modal, selecting POS swaps fields dynamically',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const WalletWithdrawBalanceScreen(
            userRole: AuthUserRole.driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on method selector to open modal
      await tester.tap(find.text(AppStrings.withdrawMethodSubscriberTitle));
      await tester.pumpAndSettle();

      // Verify modal options (Option 1: Subscriber, Option 2: POS)
      expect(find.text(AppStrings.withdrawMethodPosTitle), findsOneWidget);
      expect(find.text(AppStrings.withdrawMethodPosDesc), findsOneWidget);

      // Select POS
      await tester.tap(find.text(AppStrings.withdrawMethodPosTitle));
      await tester.pumpAndSettle();

      // Verify trigger updated to POS
      expect(find.text(AppStrings.withdrawMethodPosTitle), findsOneWidget);

      // Verify recipient fields swapped to POS fields
      expect(find.text(AppStrings.posPointNumberLabel), findsOneWidget);
      expect(find.text(AppStrings.posPointNumberHint), findsOneWidget);
      expect(find.text(AppStrings.posCommercialNameLabel), findsOneWidget);
      expect(find.text(AppStrings.posCommercialNameHint), findsOneWidget);
      expect(find.text(AppStrings.posWarningNotice), findsOneWidget);

      // Verify Subscriber fields are no longer displayed
      expect(find.text(AppStrings.recipientPhoneLabel), findsNothing);
      expect(find.text(AppStrings.recipientFullNameLabel), findsNothing);
      expect(find.text(AppStrings.subscriberWarningNotice), findsNothing);
    });

    // 3. Quick Amounts & Max Amount Auto-Fill
    testWidgets(
        'Scenario 3: Quick amount chips populate amount, Max Amount chip sets full balance',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const WalletWithdrawBalanceScreen(
            userRole: AuthUserRole.driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 10,000 quick chip
      await tester.tap(find.text('10,000'));
      await tester.pumpAndSettle();
      expect(find.text('10000'), findsOneWidget);

      // Tap 5,000 quick chip
      await tester.tap(find.text('5,000'));
      await tester.pumpAndSettle();
      expect(find.text('5000'), findsOneWidget);

      // Tap Max Amount ("الحد الأقصى")
      await tester.tap(find.text(AppStrings.maxAmountLabel));
      await tester.pumpAndSettle();
      expect(find.text('25000'), findsOneWidget);
    });

    // 4. Validation: Amount > available balance or missing fields
    testWidgets(
        'Scenario 4: Form validation catches empty amount, excess amount, and missing recipient data',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const WalletWithdrawBalanceScreen(
            userRole: AuthUserRole.driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter amount exceeding balance (30,000 > 25,000)
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), '30000');
      await tester.pumpAndSettle();

      // Tap submit button
      final submitBtn = find.text(AppStrings.sendWithdrawalRequestBtn);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Should show validation error for excess amount
      expect(find.text('المبلغ يتجاوز الرصيد المتاح للسحب'), findsOneWidget);
    });

    // 5. Successful Driver Withdrawal Flow (Mockup 4: Subscriber transfer)
    testWidgets(
        'Scenario 5: Driver submits subscriber withdrawal, deducts balance, and shows review modal',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Map<String, dynamic>? submittedData;

      await tester.pumpWidget(
        wrapTestWidget(
          WalletWithdrawBalanceScreen(
            userRole: AuthUserRole.driver,
            onSubmitWithdrawal: (data) => submittedData = data,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select 10,000
      await tester.tap(find.text('10,000'));
      await tester.pumpAndSettle();

      // Fill in subscriber details (Phone & Full Name matching Mockup 4)
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), '775123456');
      await tester.enterText(textFields.at(2), 'أحمد علي محمد صالح');
      await tester.pumpAndSettle();

      // Submit
      final submitBtn = find.text(AppStrings.sendWithdrawalRequestBtn);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Verify callback data
      expect(submittedData, isNotNull);
      expect(submittedData!['amount'], '10000.0');
      expect(submittedData!['recipientId'], '775123456');
      expect(submittedData!['recipientName'], 'أحمد علي محمد صالح');

      // Verify Store: Driver balance decreased by 10,000 (25k -> 15k)
      final store = MerchantSimulationStore.instance;
      expect(store.getBalanceForRole(AuthUserRole.driver), 15000.0);
      expect(store.getTotalWithdrawnForRole(AuthUserRole.driver), 50000.0); // 40k + 10k

      // Verify Transaction recorded as pending
      final txns = store.getTransactionsForRole(AuthUserRole.driver);
      expect(txns.first.type, TransactionType.withdrawal);
      expect(txns.first.status, TransactionStatus.pending);
      expect(txns.first.statusLabel, 'قيد المراجعة');

      // Verify Confirmation Modal Overlay
      expect(find.text(AppStrings.withdrawalSuccessTitle), findsOneWidget);
      expect(find.textContaining('10000'), findsWidgets);
      expect(find.text('قيد المراجعة'), findsOneWidget);
      expect(find.text(AppStrings.depositSuccessCloseBtn), findsOneWidget);
    });

    // 6. Successful POS Withdrawal Flow (Mockup 5: POS transfer)
    testWidgets(
        'Scenario 6: Transport Office submits POS withdrawal, isolates to office wallet',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final store = MerchantSimulationStore.instance;
      final initialDriverBalance = store.getBalanceForRole(AuthUserRole.driver);
      final initialOfficeBalance = store.getBalanceForRole(AuthUserRole.office);

      await tester.pumpWidget(
        wrapTestWidget(
          const WalletWithdrawBalanceScreen(
            userRole: AuthUserRole.office,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to POS
      await tester.tap(find.text(AppStrings.withdrawMethodSubscriberTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.withdrawMethodPosTitle));
      await tester.pumpAndSettle();

      // Select 5,000
      await tester.tap(find.text('5,000'));
      await tester.pumpAndSettle();

      // Fill POS details (Point 905027 & Commercial Name matching Mockup 5)
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), '905027');
      await tester.enterText(textFields.at(2), 'محلات اليمن التجارية');
      await tester.pumpAndSettle();

      // Submit
      final submitBtn = find.text(AppStrings.sendWithdrawalRequestBtn);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Verify Office balance decreased by 5,000
      expect(store.getBalanceForRole(AuthUserRole.office), initialOfficeBalance - 5000.0);

      // Verify Driver balance remains untouched
      expect(store.getBalanceForRole(AuthUserRole.driver), initialDriverBalance);
    });

    // 7. Role Restrictions: Merchant and Client cannot access withdrawal
    testWidgets(
        'Scenario 7: Merchant and Client roles are restricted from withdrawal screen',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const WalletWithdrawBalanceScreen(
            userRole: AuthUserRole.merchant,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Restricted view verification
      expect(find.text('سحب الرصيد مخصص للسائقين ومكاتب النقل'), findsOneWidget);
      expect(find.text('العودة للمحفظة'), findsOneWidget);
      expect(find.text(AppStrings.sendWithdrawalRequestBtn), findsNothing);
    });

    // 8. Responsive Layout: Zero RenderFlex Overflow on 360px Compact Screen
    testWidgets('Scenario 8: Screen renders cleanly with zero RenderFlex overflow on 360px width',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const WalletWithdrawBalanceScreen(
            userRole: AuthUserRole.driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(AppStrings.withdrawBalanceTitle), findsOneWidget);
      expect(find.text(AppStrings.sendWithdrawalRequestBtn), findsOneWidget);
    });
  });
}
