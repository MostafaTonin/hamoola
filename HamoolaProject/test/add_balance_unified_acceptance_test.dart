import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/merchant/domain/models/wallet_models.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_add_balance_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_wallet_screen.dart';

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

  group('Add Balance Unified Acceptance Tests (شاشة إضافة الرصيد الموحدة)', () {
    // 1 & 4. Merchant Flow: Header, Quick Amounts, Custom Amount, Confirm Pending
    testWidgets('Criteria 1 & 4: Merchant opens screen, sees header badge, selects 50,000 quick amount, and submits',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Map<String, dynamic>? submittedData;

      await tester.pumpWidget(
        wrapTestWidget(
          MerchantAddBalanceScreen(
            userRole: AuthUserRole.merchant,
            onSubmitDeposit: (data) => submittedData = data,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header: Title, Subtitle, and Wallet Icon Badge
      expect(find.text('إضافة رصيد'), findsOneWidget);
      expect(find.text('شحن محفظتك في حمولة'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsWidgets);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Verify Quick Amount Buttons (5,000 | 10,000 | 20,000 | 50,000)
      expect(find.text('5,000'), findsOneWidget);
      expect(find.text('10,000'), findsOneWidget);
      expect(find.text('20,000'), findsOneWidget);
      expect(find.text('50,000'), findsOneWidget);

      // Tap 50,000 quick amount button
      await tester.tap(find.text('50,000'));
      await tester.pumpAndSettle();
      expect(find.text('50000'), findsOneWidget);

      // Fill proof fields
      final textFields = find.byType(TextFormField);
      // textFields: 0: Amount, 1: Ref, 2: Sender
      await tester.enterText(textFields.at(1), 'DEP-MERCHANT-50K');
      await tester.enterText(textFields.at(2), 'شركة التجارة والتوكيلات');
      await tester.pumpAndSettle();

      // Submit
      final submitBtn = find.text(AppStrings.confirmPaymentBtn);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Verify Submission Data & Role
      expect(submittedData, isNotNull);
      expect(submittedData!['amount'], '50000');
      expect(submittedData!['role'], 'merchant');

      // Verify Pending State in Store for Merchant
      final store = MerchantSimulationStore.instance;
      expect(store.getPendingBalanceForRole(AuthUserRole.merchant), 60000.0); // 10k initial + 50k
      final merchantTxns = store.getTransactionsForRole(AuthUserRole.merchant);
      expect(merchantTxns.first.status, TransactionStatus.pending);
      expect(merchantTxns.first.ref, 'DEP-MERCHANT-50K');
    });

    // 2. Client Flow: Isolated wallet and transaction record
    testWidgets('Criteria 2: Client role adds balance into client wallet exclusively',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final store = MerchantSimulationStore.instance;
      final initialMerchantPending = store.getPendingBalanceForRole(AuthUserRole.merchant);
      final initialOfficePending = store.getPendingBalanceForRole(AuthUserRole.office);

      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantAddBalanceScreen(
            userRole: AuthUserRole.client,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Select 10,000 quick amount
      await tester.tap(find.text('10,000'));
      await tester.pumpAndSettle();

      // Fill in proof
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), 'CL-REF-9988');
      await tester.enterText(textFields.at(2), 'مواطن يمني');
      await tester.pumpAndSettle();

      final submitBtn = find.text(AppStrings.confirmPaymentBtn);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Verify Client pending balance increased
      expect(store.getPendingBalanceForRole(AuthUserRole.client), 10000.0);

      // Verify Merchant and Office pending balances remain completely untouched!
      expect(store.getPendingBalanceForRole(AuthUserRole.merchant), initialMerchantPending);
      expect(store.getPendingBalanceForRole(AuthUserRole.office), initialOfficePending);
    });

    // 3. Transport Office Flow: Isolated wallet
    testWidgets('Criteria 3: Transport Office role adds operational balance without altering client/merchant',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final store = MerchantSimulationStore.instance;
      final initialClientBalance = store.getBalanceForRole(AuthUserRole.client);

      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantAddBalanceScreen(
            userRole: AuthUserRole.office,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 20,000
      await tester.tap(find.text('20,000'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), 'OF-DEP-2026');
      await tester.enterText(textFields.at(2), 'مكتب الأمل للنقل السريع');
      await tester.pumpAndSettle();

      final submitBtn = find.text(AppStrings.confirmPaymentBtn);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Verify Office pending balance updated (25k initial + 20k = 45k)
      expect(store.getPendingBalanceForRole(AuthUserRole.office), 45000.0);

      // Verify Client balance unaffected
      expect(store.getBalanceForRole(AuthUserRole.client), initialClientBalance);
    });

    // 5 & 6. Dropdown States (Closed vs Open) and Wallet Switching
    testWidgets('Criteria 5 & 6: Tests Dropdown Closed state, opens list with 8 options, selects Floosak and updates point',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantAddBalanceScreen(
            userRole: AuthUserRole.merchant,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // --- STATE 1: CLOSED ---
      // Chevron Down is visible, default is Jeeb with point 905027
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.text('محفظة جيب'), findsWidgets);
      expect(find.text('905027'), findsWidgets);
      expect(find.text('دفع مشتريات'), findsOneWidget);
      expect(find.text('عبر كود الشراء'), findsOneWidget);
      expect(find.text(AppStrings.trustAssuranceText), findsOneWidget);

      // --- OPEN DROPDOWN -> STATE 2 ---
      await tester.tap(find.text('محفظة جيب').first);
      await tester.pumpAndSettle();

      // Chevron Up is now visible
      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);

      // All 8 Yemeni payment wallets are presented in the opened dropdown list:
      expect(find.text('محفظة جيب'), findsWidgets);
      expect(find.text('محفظة فلوسك'), findsOneWidget);
      expect(find.text('محفظة جوالي'), findsOneWidget);
      expect(find.text('كريمي جوال'), findsOneWidget);
      expect(find.text('محفظة ون كاش'), findsOneWidget);
      expect(find.text('محفظة كاش'), findsOneWidget);
      expect(find.text('موبايل موني'), findsOneWidget);
      expect(find.text('البنك الأهلي'), findsOneWidget);

      // Sub-options and point box are collapsed in open dropdown state
      expect(find.text('دفع مشتريات'), findsNothing);

      // --- SELECT FLOOSAK (محفظة فلوسك) ---
      await tester.tap(find.text('محفظة فلوسك'));
      await tester.pumpAndSettle();

      // Dropdown closes back to STATE 1
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.text('محفظة فلوسك'), findsWidgets);

      // Point number dynamically updated to Floosak point: 812045
      expect(find.text('812045'), findsWidgets);
      expect(find.text('من دفع مشتريات - رقم النقطة: 812045'), findsOneWidget);
    });

    // 7. Validation: Empty amount and required fields
    testWidgets('Criteria 7: Validates required amount and proof fields before allowing submission',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantAddBalanceScreen(
            userRole: AuthUserRole.merchant,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final submitBtn = find.text(AppStrings.confirmPaymentBtn);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Expect amount validation error
      expect(find.text('يرجى تحديد المبلغ'), findsOneWidget);

      // Enter valid amount
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), '12000');
      await tester.pumpAndSettle();

      // Submit again without ref/sender
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('يرجى إدخال رقم الإيداع أو الحوالة'), findsOneWidget);
      expect(find.text('يرجى إدخال اسم المرسل'), findsOneWidget);
    });

    // 8. One-Tap Simulation Approval in Prototype
    testWidgets('Criteria 8: Simulating instant deposit approval updates available balance reactively',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final store = MerchantSimulationStore.instance;
      final initialBalance = store.getBalanceForRole(AuthUserRole.merchant);

      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantAddBalanceScreen(
            userRole: AuthUserRole.merchant,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('5,000'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), 'TXN-SIM-5K');
      await tester.enterText(textFields.at(2), 'متجر السلام');
      await tester.pumpAndSettle();

      final submitBtn = find.text(AppStrings.confirmPaymentBtn);
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Modal is visible with simulation CTA
      final simulateApprovalBtn = find.text('محاكاة اعتماد الإيداع فورياً للمحفظة');
      expect(simulateApprovalBtn, findsOneWidget);

      await tester.tap(simulateApprovalBtn);
      await tester.pumpAndSettle();

      // Balance has now completed and increased by 5,000!
      expect(store.getBalanceForRole(AuthUserRole.merchant), initialBalance + 5000.0);
    });

    // 9. Driver Restriction: Button hidden in wallet, access restricted in add balance
    testWidgets('Criteria 9: Driver cannot add balance (button absent in wallet, restricted screen)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. Driver in MerchantWalletScreen -> No "Add Balance" button!
      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantWalletScreen(
            userRole: AuthUserRole.driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.addBalanceBtn), findsNothing);

      // 2. Direct access to AddBalanceScreen with Driver role -> Restricted Guard Screen!
      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantAddBalanceScreen(
            userRole: AuthUserRole.driver,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('عذراً، إضافة الرصيد غير متاحة للسائق'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.text(AppStrings.confirmPaymentBtn), findsNothing);
    });

    // 10. Role isolation: Client wallet has NO withdrawal button, Office wallet HAS withdrawal button
    testWidgets('Criteria 10: Client wallet has no withdrawal, Office wallet has withdrawal option',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Client Wallet
      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantWalletScreen(
            userRole: AuthUserRole.client,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('طلب سحب أرباح المكتب'), findsNothing);
      expect(find.text(AppStrings.addBalanceBtn), findsOneWidget);

      // Transport Office Wallet
      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantWalletScreen(
            userRole: AuthUserRole.office,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('طلب سحب أرباح المكتب'), findsOneWidget);
      expect(find.text(AppStrings.addBalanceBtn), findsOneWidget);
    });

    // Responsiveness: Clean layout without overflow on compact 360px device
    testWidgets('Criteria 11: Screen renders cleanly with zero RenderFlex overflow on 360px width',
        (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapTestWidget(
          const MerchantAddBalanceScreen(
            userRole: AuthUserRole.merchant,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
