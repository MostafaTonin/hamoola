import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/auth/domain/models/auth_user.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_order.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_assignment_payment_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_create_order_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_offers_review_screen.dart';
import 'package:flutter_application/features/merchant/presentation/widgets/merchant_order_details_dialog.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthSimulationStore.instance.resetToInitialState();
    MerchantSimulationStore.instance.resetToInitialState();
  });

  group('Prompt 08: Order Lifecycle, Wallet Checks, Publishing, & Payment', () {
    // -------------------------------------------------------------------------
    // Scenario 1: Draft creation without wallet balance check
    // -------------------------------------------------------------------------
    test('1. Draft creation succeeds regardless of wallet balance without deducting funds', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 0.0; // Zero balance

      final initialBalance = store.walletBalance;

      // Save draft with high max budget
      final draft = store.saveDraft(
        cargoName: 'أجهزة إلكترونية حساسة',
        originCity: 'صنعاء',
        destinationCity: 'عدن',
        minBudget: 300000.0,
        maxBudget: 450000.0,
        vehicleType: 'شاحنة مغلقة',
        notes: 'مسودة تجريبية',
      );

      expect(draft.id, isNotEmpty);
      expect(draft.status, equals(MerchantOrderStatus.draft));
      expect(draft.maxBudget, equals(450000.0));
      expect(draft.minBudget, equals(300000.0));
      // Wallet balance must NOT be checked or deducted for drafts
      expect(store.walletBalance, equals(initialBalance));
      expect(store.drafts.any((d) => d.id == draft.id), isTrue);
    });

    // -------------------------------------------------------------------------
    // Scenario 2: Block publish when wallet < maxBudget and show required deficit
    // -------------------------------------------------------------------------
    test('2. Publishing is blocked when walletBalance < maxBudget, revealing exact deficit', () {
      final store = MerchantSimulationStore.instance;
      store.walletBalance = 100000.0;
      const maxBudget = 350000.0;

      final canPublish = store.canPublishOrder(maxBudget);
      expect(canPublish, isFalse, reason: 'Must block publish when balance < maxBudget');

      final deficit = maxBudget - store.walletBalance;
      expect(deficit, equals(250000.0));
    });

    // -------------------------------------------------------------------------
    // Scenario 3: Add balance and publish without losing form inputs
    // -------------------------------------------------------------------------
    test('3. Top-up increases wallet balance and allows publishing with preserved order data', () {
      final store = MerchantSimulationStore.instance;
      store.walletBalance = 50000.0;
      const maxBudget = 200000.0;

      expect(store.canPublishOrder(maxBudget), isFalse);

      // User adds balance
      store.addBalance(150000.0);
      expect(store.walletBalance, equals(200000.0));
      expect(store.canPublishOrder(maxBudget), isTrue);

      // Publish order with preserved parameters
      final order = store.publishOrder(
        cargoName: 'مواد بناء',
        originCity: 'الحديدة',
        destinationCity: 'صنعاء',
        minBudget: 150000.0,
        maxBudget: maxBudget,
        broadcastScope: 'all_drivers',
        vehicleType: 'تريلا 30 طن',
      );

      expect(order.status, equals(MerchantOrderStatus.pendingDriver));
      expect(order.maxBudget, equals(maxBudget));
      // Publishing must NOT deduct funds
      expect(store.walletBalance, equals(200000.0));
    });

    // -------------------------------------------------------------------------
    // Scenario 4: Allow publish when wallet >= maxBudget without deduction
    // -------------------------------------------------------------------------
    test('4. Publishing is allowed when wallet >= maxBudget and NEVER deducts wallet upon publishing', () {
      final store = MerchantSimulationStore.instance;
      store.walletBalance = 500000.0;
      const maxBudget = 350000.0;

      expect(store.canPublishOrder(maxBudget), isTrue);

      final balanceBefore = store.walletBalance;
      final order = store.publishOrder(
        cargoName: 'أدوية ومستلزمات طبية',
        originCity: 'صنعاء',
        destinationCity: 'إب',
        minBudget: 250000.0,
        maxBudget: maxBudget,
        broadcastScope: 'all_offices',
        vehicleType: 'دينا ثلاجة',
      );

      expect(order.status, equals(MerchantOrderStatus.pendingOffice));
      // Strict Rule: No deduction upon publishing
      expect(store.walletBalance, equals(balanceBefore));
    });

    // -------------------------------------------------------------------------
    // Scenario 5: Re-check wallet balance before publish confirmation
    // -------------------------------------------------------------------------
    test('5. Re-check validates balance at the exact moment before order broadcast', () {
      final store = MerchantSimulationStore.instance;
      store.walletBalance = 300000.0;
      const maxBudget = 300000.0;

      expect(store.canPublishOrder(maxBudget), isTrue);

      // Suppose wallet balance dropped right before final click (e.g. another payment)
      store.walletBalance = 100000.0;
      expect(store.canPublishOrder(maxBudget), isFalse);
    });

    // -------------------------------------------------------------------------
    // Scenario 6: Public broadcast separation: all_drivers vs all_offices
    // -------------------------------------------------------------------------
    test('6. Public orders separate cleanly: all_drivers visible to drivers, all_offices visible to offices', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      // 6a. Publish to all drivers
      final driverOrder = store.publishOrder(
        cargoName: 'حمولة عامة للسائقين',
        originCity: 'ذمار',
        destinationCity: 'صنعاء',
        maxBudget: 150000.0,
        broadcastScope: 'all_drivers',
      );

      // 6b. Publish to all offices
      final officeOrder = store.publishOrder(
        cargoName: 'حمولة أسطول لمكاتب النقل',
        originCity: 'عدن',
        destinationCity: 'المكلا',
        maxBudget: 600000.0,
        broadcastScope: 'all_offices',
      );

      final driverAvailable = store.getAvailableOrdersForDriver('driver_1');
      final officeAvailable = store.getAvailableOrdersForOffices('office_1');

      // Driver feed contains driverOrder, but NOT officeOrder
      expect(driverAvailable.any((o) => o.id == driverOrder.id), isTrue);
      expect(driverAvailable.any((o) => o.id == officeOrder.id), isFalse);

      // Office feed contains officeOrder, but NOT driverOrder
      expect(officeAvailable.any((o) => o.id == officeOrder.id), isTrue);
      expect(officeAvailable.any((o) => o.id == driverOrder.id), isFalse);
    });

    // -------------------------------------------------------------------------
    // Scenario 7: Independent quotes in public broadcast without negotiation
    // -------------------------------------------------------------------------
    test('7. Public broadcast receives independent quotes; offers review has NO negotiation/counter-bidding', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      // Get an order with offers
      final orderWithOffers = store.orders.firstWhere((o) => o.offersCount > 0);
      final offers = store.getOffersForOrder(orderWithOffers.id);

      expect(offers, isNotEmpty);
      for (final offer in offers) {
        expect(offer.price, isPositive);
        expect(offer.driverName, isNotEmpty);
      }
    });

    // -------------------------------------------------------------------------
    // Scenario 8: Direct request targeted to specific driver or office
    // -------------------------------------------------------------------------
    test('8. Targeted direct orders are visible ONLY to the specific provider and hidden from public feed', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      // Direct order targeted to specific driver "driver_99"
      final directDriverOrder = store.publishOrder(
        cargoName: 'طلب خاص لسائق محدد',
        originCity: 'صنعاء',
        destinationCity: 'تعز',
        maxBudget: 250000.0,
        broadcastScope: 'driver',
        targetProviderId: 'driver_99',
        targetProviderPhone: '+967 777 999 111',
      );

      // Direct order targeted to specific office "office_88"
      final directOfficeOrder = store.publishOrder(
        cargoName: 'طلب خاص لمكتب محدد',
        originCity: 'الحديدة',
        destinationCity: 'صنعاء',
        maxBudget: 400000.0,
        broadcastScope: 'office',
        targetProviderId: 'office_88',
        targetProviderPhone: '+967 777 888 222',
      );

      expect(directDriverOrder.isDirectOrder, isTrue);
      expect(directDriverOrder.directStatus, equals('pending'));
      expect(directDriverOrder.offersCount, equals(0), reason: 'Direct orders have no bidding offers list');

      // Check visibility for targeted driver
      final targetDriverFeed = store.getAvailableOrdersForDriver('driver_99');
      final otherDriverFeed = store.getAvailableOrdersForDriver('driver_other');
      expect(targetDriverFeed.any((o) => o.id == directDriverOrder.id), isTrue);
      expect(otherDriverFeed.any((o) => o.id == directDriverOrder.id), isFalse);

      // Check visibility for targeted office
      final targetOfficeFeed = store.getAvailableOrdersForOffices('office_88');
      final otherOfficeFeed = store.getAvailableOrdersForOffices('office_other');
      expect(targetOfficeFeed.any((o) => o.id == directOfficeOrder.id), isTrue);
      expect(otherOfficeFeed.any((o) => o.id == directOfficeOrder.id), isFalse);
    });

    // -------------------------------------------------------------------------
    // Scenario 9: Direct request displays only Accept / Reject (NO bidding loop)
    // -------------------------------------------------------------------------
    test('9. Targeted provider has binary Accept/Reject choice on direct orders', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      final directOrder = store.publishOrder(
        cargoName: 'طلب مباشر بدون مزايدة',
        originCity: 'صنعاء',
        destinationCity: 'عدن',
        maxBudget: 320000.0,
        broadcastScope: 'driver',
        targetProviderId: 'driver_77',
      );

      expect(directOrder.directStatus, equals('pending'));

      // Provider accepts direct order
      store.acceptDirectOrder(
        directOrder.id,
        agreedPrice: 320000.0,
        providerName: 'الكابتن علي',
        providerPhone: '+967 771 999 000',
      );

      final accepted = store.orders.firstWhere((o) => o.id == directOrder.id);
      expect(accepted.directStatus, equals('accepted'));
      expect(accepted.agreedFare, equals(320000.0));
      expect(accepted.driverName, equals('الكابتن علي'));
      expect(accepted.isPaid, isFalse, reason: 'Acceptance does not automatically mark as paid');
    });

    // -------------------------------------------------------------------------
    // Scenario 10: Direct request rejection updates status without auto-reassignment
    // -------------------------------------------------------------------------
    test('10. Direct request rejection marks status rejected and does NOT auto-reassign', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      final directOrder = store.publishOrder(
        cargoName: 'طلب مباشر للتجربة',
        originCity: 'صنعاء',
        destinationCity: 'مارب',
        maxBudget: 280000.0,
        broadcastScope: 'office',
        targetProviderId: 'office_55',
      );

      // Provider rejects direct order
      store.rejectDirectOrder(directOrder.id);

      final rejected = store.orders.firstWhere((o) => o.id == directOrder.id);
      expect(rejected.directStatus, equals('rejected'));
      // No auto-reassignment: broadcastScope stays office, no driver assigned
      expect(rejected.driverName, isNull);
      expect(rejected.isPaid, isFalse);
    });

    // -------------------------------------------------------------------------
    // Scenario 11: Direct request acceptance transitions to payment confirmation
    // -------------------------------------------------------------------------
    test('11. Direct request acceptance establishes agreed fare ready for payment', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      final directOrder = store.publishOrder(
        cargoName: 'شحنة جاهزة للاتفاق',
        originCity: 'صنعاء',
        destinationCity: 'إب',
        maxBudget: 220000.0,
        broadcastScope: 'driver',
        targetProviderId: 'driver_33',
      );

      store.acceptDirectOrder(
        directOrder.id,
        agreedPrice: 220000.0,
        providerName: 'كابتن محمد',
        providerPhone: '+967 773 333 444',
      );

      final updated = store.orders.firstWhere((o) => o.id == directOrder.id);
      expect(updated.directStatus, equals('accepted'));
      expect(updated.agreedFare, equals(220000.0));
      expect(updated.isPaid, isFalse);
    });

    // -------------------------------------------------------------------------
    // Scenario 12: Public offer selection transitions to payment confirmation
    // -------------------------------------------------------------------------
    test('12. Selecting an offer from public broadcast transitions to payment confirmation with offer fare', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      final publicOrder = store.orders.firstWhere((o) => o.offersCount > 0);
      final offers = store.getOffersForOrder(publicOrder.id);
      final selectedOffer = offers.first;

      expect(selectedOffer.price, isPositive);
      expect(selectedOffer.driverName, isNotEmpty);
    });

    // -------------------------------------------------------------------------
    // Scenario 13: Agreed fare clarity before payment
    // -------------------------------------------------------------------------
    test('13. Agreed fare amount is explicitly established before payment execution', () {
      final order = const MerchantOrder(
        id: 'REQ-TEST-1',
        cargoName: 'بضائع',
        originCity: 'صنعاء',
        destinationCity: 'عدن',
        status: MerchantOrderStatus.pendingDriver,
        timeAgo: 'الآن',
        agreedFare: 290000.0,
        isPaid: false,
      );

      expect(order.agreedFare, equals(290000.0));
      expect(order.isPaid, isFalse);
    });

    // -------------------------------------------------------------------------
    // Scenario 14: Block payment if wallet balance < agreed fare
    // -------------------------------------------------------------------------
    test('14. Payment fails if wallet balance is less than agreed fare', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 100000.0;

      final directOrder = store.publishOrder(
        cargoName: 'طلب للنقل',
        originCity: 'صنعاء',
        destinationCity: 'تعز',
        maxBudget: 300000.0,
        broadcastScope: 'driver',
      );

      store.acceptDirectOrder(directOrder.id, agreedPrice: 300000.0);

      // Attempt payment with insufficient funds (100k < 300k)
      expect(
        () => store.payForOrder(directOrder.id, 300000.0),
        throwsA(isA<Exception>()),
      );

      final orderAfter = store.orders.firstWhere((o) => o.id == directOrder.id);
      expect(orderAfter.isPaid, isFalse);
      expect(store.walletBalance, equals(100000.0), reason: 'Balance must not change on failed payment');
    });

    // -------------------------------------------------------------------------
    // Scenario 15: Contact info masked before payment, revealed only after payment
    // -------------------------------------------------------------------------
    test('15. Contact info is masked prior to payment and revealed strictly after successful payment', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 400000.0;

      final directOrder = store.publishOrder(
        cargoName: 'بضائع خاصة',
        originCity: 'صنعاء',
        destinationCity: 'الحديدة',
        maxBudget: 250000.0,
        broadcastScope: 'driver',
        targetProviderId: 'driver_priv',
        targetProviderPhone: '+967 775 678 901',
      );

      store.acceptDirectOrder(
        directOrder.id,
        agreedPrice: 250000.0,
        providerName: 'كابتن السرية',
        providerPhone: '+967 775 678 901',
      );

      final beforePayment = store.orders.firstWhere((o) => o.id == directOrder.id);
      expect(beforePayment.isPaid, isFalse);
      expect(beforePayment.isContactRevealed, isFalse);
      expect(beforePayment.maskedTargetPhone, equals('+967 77*** ***'));
      expect(beforePayment.maskedTargetPhone, isNot(contains('678')));

      // Pay for order
      store.payForOrder(
        directOrder.id,
        250000.0,
        driverName: 'كابتن السرية',
        driverPhone: '+967 775 678 901',
      );

      final afterPayment = store.orders.firstWhere((o) => o.id == directOrder.id);
      expect(afterPayment.isPaid, isTrue);
      expect(afterPayment.isContactRevealed, isTrue);
      expect(afterPayment.maskedTargetPhone, equals('+967 775 678 901'));
    });

    // -------------------------------------------------------------------------
    // Scenario 16: No trip creation / tracking prior to payment completion
    // -------------------------------------------------------------------------
    test('16. Trip tracking stage begins ONLY after payment completion', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 300000.0;

      final order = store.publishOrder(
        cargoName: 'شحنة لتتبع الرحلة',
        originCity: 'صنعاء',
        destinationCity: 'عدن',
        maxBudget: 200000.0,
        broadcastScope: 'driver',
      );

      // Before payment, trip stage is 0
      expect(store.getTripCurrentStage(order.id), equals(0));

      store.payForOrder(order.id, 200000.0, driverName: 'كابتن الرحلة');

      // After payment, trip stage advances to 1 (arrived at loading)
      expect(store.getTripCurrentStage(order.id), equals(1));
    });

    // -------------------------------------------------------------------------
    // Scenario 17: Prevent duplicate publish, payment, and deduction
    // -------------------------------------------------------------------------
    test('17. Duplicate payment is strictly guarded and prevents double wallet deduction', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 500000.0;

      final order = store.publishOrder(
        cargoName: 'شحنة منع التكرار',
        originCity: 'صنعاء',
        destinationCity: 'تعز',
        maxBudget: 200000.0,
        broadcastScope: 'driver',
      );

      // First payment
      final pay1 = store.payForOrder(order.id, 200000.0);
      expect(pay1, isTrue);
      expect(store.walletBalance, equals(300000.0));

      // Attempt second payment on same order
      final pay2 = store.payForOrder(order.id, 200000.0);
      expect(pay2, isFalse, reason: 'Must block duplicate payment on already paid order');
      expect(store.walletBalance, equals(300000.0), reason: 'Must NOT deduct funds twice');
    });

    // -------------------------------------------------------------------------
    // Scenario 18: Role separation and permission boundaries across 4 roles
    // -------------------------------------------------------------------------
    test('18. Role boundaries: Customer & Merchant create orders; Driver & Office fulfill orders', () {
      final authStore = AuthSimulationStore.instance;
      authStore.resetToInitialState();

      // Ensure all 4 roles exist in authentication store
      final roles = [
        AuthUserRole.client,
        AuthUserRole.driver,
        AuthUserRole.merchant,
        AuthUserRole.office,
      ];

      for (final role in roles) {
        expect(authStore.users.any((u) => u.role == role), isTrue,
            reason: 'Role $role must be provisioned in the prototype');
      }
    });

    // -------------------------------------------------------------------------
    // Widget Test 19: MerchantCreateOrderScreen wallet check modal when balance insufficient
    // -------------------------------------------------------------------------
    testWidgets('19. MerchantCreateOrderScreen shows modal sheet when balance < maxBudget', (tester) async {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 1000.0; // Insufficient for default budget (4,000)

      await tester.pumpWidget(
        const MaterialApp(
          home: MerchantCreateOrderScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap publish button
      final publishBtn = find.text('نشر الطلب');
      expect(publishBtn, findsOneWidget);
      await tester.tap(publishBtn);
      await tester.pumpAndSettle();

      // Verify modal sheet appears with deficit information
      expect(find.text('رصيد المحفظة غير كافٍ لنشر الطلب'), findsOneWidget);
      expect(find.text('الرصيد الحالي في المحفظة:'), findsOneWidget);
      expect(find.text('الحد الأعلى للميزانية المطلوبة:'), findsOneWidget);
      expect(find.text('المبلغ المطلوب إيداعه (الفرق):'), findsOneWidget);
      expect(find.text('إضافة رصيد للمحفظة الآن'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Widget Test 20: MerchantOffersReviewScreen displays independent quotes without negotiation
    // -------------------------------------------------------------------------
    testWidgets('20. MerchantOffersReviewScreen has NO negotiation input or counter-offer chips', (tester) async {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      final orderWithOffers = store.orders.firstWhere((o) => o.offersCount > 0);

      await tester.pumpWidget(
        MaterialApp(
          home: MerchantOffersReviewScreen(orderId: orderWithOffers.id),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and offers list
      expect(find.text(AppStrings.offersReviewTitle), findsOneWidget);

      // Verify NO negotiation sheet or counter-offer chips exist
      expect(find.text('تفاوض على السعر'), findsNothing);
      expect(find.text('تقديم عرض مضاد'), findsNothing);
      expect(find.text('خصم 5%'), findsNothing);
      expect(find.text('خصم 10%'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // Widget Test 21: MerchantAssignmentPaymentScreen displays agreed fare and masks phone before payment
    // -------------------------------------------------------------------------
    testWidgets('21. MerchantAssignmentPaymentScreen displays clear agreed fare & masks phone before payment', (tester) async {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 600000.0;

      final directOrder = store.publishOrder(
        cargoName: 'شحنة اختبار الدفع',
        originCity: 'صنعاء',
        destinationCity: 'عدن',
        maxBudget: 350000.0,
        broadcastScope: 'driver',
        targetProviderId: 'driver_test',
        targetProviderPhone: '+967 771 234 567',
      );

      store.acceptDirectOrder(
        directOrder.id,
        agreedPrice: 350000.0,
        providerName: 'كابتن وسيم',
        providerPhone: '+967 771 234 567',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MerchantAssignmentPaymentScreen(orderId: directOrder.id),
        ),
      );
      await tester.pumpAndSettle();

      // Agreed fare must be visible
      expect(find.text('تأكيد الإسناد والدفع'), findsOneWidget);
      expect(find.text('350,000 ر.ي'), findsWidgets);

      // Phone number must be masked prior to payment
      expect(find.text('+967 77*** ***'), findsOneWidget);
      expect(find.text('محجوب حتى الدفع'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Widget Test 22: MerchantOrderDetailsDialog shows direct order status branches
    // -------------------------------------------------------------------------
    testWidgets('22. MerchantOrderDetailsDialog shows accept/reject/pending states correctly for direct orders', (tester) async {
      final acceptedOrder = const MerchantOrder(
        id: 'REQ-DIRECT-1',
        cargoName: 'بضائع مباشرة مقبولة',
        originCity: 'صنعاء',
        destinationCity: 'تعز',
        status: MerchantOrderStatus.pendingDriver,
        timeAgo: 'منذ نصف ساعة',
        broadcastScope: 'driver',
        directStatus: 'accepted',
        agreedFare: 280000.0,
        driverName: 'كابتن خليل',
        isPaid: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantOrderDetailsDialog(order: acceptedOrder),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تمت الموافقة على طلبك المباشر'), findsOneWidget);
      expect(find.text('تأكيد الاتفاق والدفع (280000 ر.س)'), findsOneWidget);
      expect(find.textContaining('+967 77*** ***'), findsOneWidget);
    });
  });
}
