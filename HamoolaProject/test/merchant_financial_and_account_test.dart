import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/wallet_models.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_account_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_add_balance_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_wallet_screen.dart';

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

  group('MerchantAccountScreen Tests', () {
    testWidgets('renders account hub with profile, stats, menu items, and actions',
        (tester) async {
      bool backTapped = false;
      bool walletTapped = false;
      bool supportTapped = false;
      bool logoutTapped = false;

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          MerchantAccountScreen(
            onBack: () => backTapped = true,
            onWallet: () => walletTapped = true,
            onSupport: () => supportTapped = true,
            onLogout: () => logoutTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header and Bottom Nav Account Label
      expect(find.text(AppStrings.merchantAccountTitle), findsWidgets);

      // Verify Profile Info & Verified Badge
      expect(find.text('محمد أحمد'), findsOneWidget);
      expect(find.text(AppStrings.merchantVerifiedBadge), findsOneWidget);
      expect(find.text('مؤسسة الأمل التجارية'), findsOneWidget);

      // Verify Stats
      expect(find.text('24'), findsOneWidget);
      expect(find.text(AppStrings.completedTripsStatLabel), findsOneWidget);
      expect(find.text('4.9 ★'), findsOneWidget);
      expect(find.text(AppStrings.ratingStatLabel), findsOneWidget);
      expect(find.text('98%'), findsOneWidget);
      expect(find.text(AppStrings.commitmentStatLabel), findsOneWidget);

      // Verify Menu Items
      expect(find.text(AppStrings.myWalletMenuTitle), findsOneWidget);
      expect(find.text(AppStrings.companyVerifyMenuTitle), findsOneWidget);
      expect(find.text(AppStrings.verificationCompleteBadge), findsOneWidget);
      expect(find.text(AppStrings.generalSettingsMenuTitle), findsOneWidget);
      expect(find.text(AppStrings.customerSupportMenuTitle), findsOneWidget);
      expect(find.text(AppStrings.termsAndPrivacyMenuTitle), findsOneWidget);
      expect(find.text(AppStrings.logoutMenuTitle), findsOneWidget);

      // Tap Wallet menu
      await tester.tap(find.text(AppStrings.myWalletMenuTitle));
      expect(walletTapped, isTrue);

      // Tap Support menu
      await tester.tap(find.text(AppStrings.customerSupportMenuTitle));
      expect(supportTapped, isTrue);

      // Tap Logout
      await tester.tap(find.text(AppStrings.logoutMenuTitle));
      expect(logoutTapped, isTrue);

      // Tap Back button
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backTapped, isTrue);
    });
  });

  group('MerchantWalletScreen Tests', () {
    testWidgets('renders balance card, top button, filters, and transaction tap',
        (tester) async {
      bool backTapped = false;
      bool addBalanceTapped = false;
      MerchantTransaction? tappedTx;

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          MerchantWalletScreen(
            onBack: () => backTapped = true,
            onAddBalance: () => addBalanceTapped = true,
            onTransactionTap: (tx) => tappedTx = tx,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text(AppStrings.merchantWalletTitle), findsOneWidget);
      expect(find.text(AppStrings.merchantWalletSub), findsOneWidget);

      // Verify Add Balance Button
      expect(find.text(AppStrings.addBalanceBtn), findsOneWidget);
      await tester.tap(find.text(AppStrings.addBalanceBtn));
      expect(addBalanceTapped, isTrue);

      // Verify Compact Balance Card
      expect(find.text(AppStrings.currentBalanceLabel), findsOneWidget);
      expect(find.text('2000'), findsOneWidget);
      expect(find.text(AppStrings.pendingReviewLabel), findsOneWidget);
      expect(find.text('10000 ${AppStrings.currencyYerShort}'), findsOneWidget);

      // Verify Filter Chips
      expect(find.text(AppStrings.txFilterAll), findsOneWidget);
      expect(find.text(AppStrings.txFilterDeposits), findsOneWidget);
      expect(find.text(AppStrings.txFilterPayments), findsOneWidget);

      // Verify Transactions rendered
      expect(find.text('شحن رصيد — محفظة جيب'), findsOneWidget);
      expect(find.text('دفع أجرة نقل (طلب #REQ-1024)'), findsOneWidget);

      // Filter by Payments
      await tester.tap(find.text(AppStrings.txFilterPayments));
      await tester.pumpAndSettle();
      expect(find.text('دفع أجرة نقل (طلب #REQ-1024)'), findsOneWidget);
      expect(find.text('شحن رصيد — محفظة جيب'), findsNothing);

      // Tap on Transaction
      await tester.tap(find.text('دفع أجرة نقل (طلب #REQ-1024)'));
      expect(tappedTx, isNotNull);
      expect(tappedTx!.id, 'TXN-894120');

      // Filter by Deposits
      await tester.tap(find.text(AppStrings.txFilterDeposits));
      await tester.pumpAndSettle();
      expect(find.text('شحن رصيد — محفظة جيب'), findsOneWidget);

      // Tap Back button
      await tester.tap(find.byTooltip(AppStrings.back));
      expect(backTapped, isTrue);
    });
  });

  group('MerchantAddBalanceScreen Tests', () {
    testWidgets('validates required fields, selects wallet, copies point, and confirms deposit',
        (tester) async {
      bool closeTapped = false;
      Map<String, dynamic>? submittedData;
      bool successDone = false;

      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapWidget(
          MerchantAddBalanceScreen(
            onClose: () => closeTapped = true,
            onSubmitDeposit: (d) => submittedData = d,
            onSuccessDone: () => successDone = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header and Field Label
      expect(find.text(AppStrings.paymentMethodTitle), findsWidgets);

      // Close action
      await tester.tap(find.byTooltip(AppStrings.cancelBtn));
      expect(closeTapped, isTrue);

      // Empty submit validation
      await tester.tap(find.text(AppStrings.confirmPaymentBtn));
      await tester.pumpAndSettle();
      expect(find.text('يرجى تحديد المبلغ'), findsOneWidget);

      // Default wallet: 'محفظة جيب' with point '905027'
      expect(find.text('محفظة جيب'), findsWidgets);
      expect(find.text('905027'), findsWidgets);

      // Copy Point Button
      final copyBtn = find.byTooltip(AppStrings.copyPointTooltip);
      expect(copyBtn, findsOneWidget);
      await tester.tap(copyBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining(AppStrings.pointCopiedSuccess), findsOneWidget);

      // Open Dropdown and choose 'كريمي جوال'
      await tester.tap(find.text('محفظة جيب').first);
      await tester.pumpAndSettle();
      expect(find.text('كريمي جوال'), findsOneWidget);
      await tester.tap(find.text('كريمي جوال'));
      await tester.pumpAndSettle();

      // Selected wallet is now 'كريمي جوال' and point is '553901'
      expect(find.text('كريمي جوال'), findsWidgets);
      expect(find.text('553901'), findsWidgets);

      // Toggle Sub-option: 'عبر كود الشراء'
      await tester.tap(find.text(AppStrings.subOptionCodeTitle));
      await tester.pumpAndSettle();

      // Fill in Form Inputs
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(3));

      // Amount
      await tester.enterText(textFields.at(0), '15000');
      // Reference
      await tester.enterText(textFields.at(1), 'REF-789012');
      // Sender Name
      await tester.enterText(textFields.at(2), 'مؤسسة التجارة الحديثة');
      await tester.pumpAndSettle();

      // Submit Payment
      await tester.tap(find.text(AppStrings.confirmPaymentBtn));
      await tester.pumpAndSettle();

      // Verify Callback Data
      expect(submittedData, isNotNull);
      expect(submittedData!['amount'], '15000');
      expect(submittedData!['ref'], 'REF-789012');
      expect(submittedData!['sender'], 'مؤسسة التجارة الحديثة');

      // Verify Success Modal Overlay
      expect(find.text(AppStrings.depositSuccessTitle), findsOneWidget);
      expect(find.text(AppStrings.depositSuccessSubtitle), findsOneWidget);
      expect(find.text('#REF-789012'), findsOneWidget);
      expect(find.text(AppStrings.depositSuccessCloseBtn), findsOneWidget);

      // Close Success Modal
      await tester.tap(find.text(AppStrings.depositSuccessCloseBtn));
      await tester.pumpAndSettle();
      expect(successDone, isTrue);
    });
  });
}
