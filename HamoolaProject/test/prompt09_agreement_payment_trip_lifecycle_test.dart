import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/features/auth/domain/models/auth_simulation_store.dart';
import 'package:flutter_application/features/merchant/domain/models/driver_offer.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_order.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/merchant/domain/models/wallet_models.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_trip_tracking_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    AuthSimulationStore.instance.resetToInitialState();
    MerchantSimulationStore.instance.resetToInitialState();
  });

  group('Prompt 09: Agreement, Payment, 9-Stage Execution, Settlement, & Rating', () {
    // -------------------------------------------------------------------------
    // 1. Public broadcast: Quote selection locks agreement & masks contact pre-pay
    // -------------------------------------------------------------------------
    test('1. Public broadcast quote selection locks provider and agreed fare; contact info masked before payment', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      // Create an open public broadcast order
      final order = store.publishOrder(
        cargoName: 'أغذية معلبة ومجففة',
        originCity: 'صنعاء',
        destinationCity: 'عدن',
        maxBudget: 450000.0,
        vehicleType: 'شاحنة مغلقة',
        broadcastScope: 'all_drivers',
      );

      expect(order.status, equals(MerchantOrderStatus.pendingDriver));
      expect(order.isPaid, isFalse);
      expect(order.agreedFare, isNull);

      // Offer from independent quote
      final offer = DriverOffer(
        id: 'OFFER-P09-01',
        orderId: order.id,
        driverId: 'DRV-P09-01',
        driverName: 'سعيد عبده المقطري',
        rating: 4.8,
        tripsCount: 120,
        vehicleName: 'شاحنة مغلقة',
        vehiclePlate: 'عدن 24891',
        price: 380000.0,
        pickupTimeText: 'اليوم خلال ساعتين',
        deliveryTimeText: 'غداً صباحاً',
        notes: 'جاهز للنقل الفوري',
        driverPhone: '+967 777 112 233',
      );

      // Accept quote
      final accepted = store.acceptQuote(order.id, offer);
      expect(accepted, isTrue);

      final updated = store.getOrderById(order.id)!;
      expect(updated.status, equals(MerchantOrderStatus.assignedDriver));
      expect(updated.agreedFare, equals(380000.0));
      expect(updated.assignedDriverName, equals('سعيد عبده المقطري'));
      expect(updated.assignedDriverPhone, equals('+967 777 112 233'));
      // Pre-payment: order is not paid yet, contact info is masked
      expect(updated.isPaid, isFalse);
      expect(updated.isContactRevealed, isFalse);
      expect(updated.maskedTargetPhone, contains('***'));
    });

    // -------------------------------------------------------------------------
    // 2. Private broadcast: Direct order acceptance (no quotes/counter-offers)
    // -------------------------------------------------------------------------
    test('2. Private broadcast direct order acceptance locks fare; no quotes or counter-offers allowed', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      // Create a private order targeted to specific driver/office
      final order = store.publishOrder(
        cargoName: 'أدوية ومستلزمات طبية',
        originCity: 'الحديدة',
        destinationCity: 'صنعاء',
        minBudget: 320000.0,
        maxBudget: 320000.0,
        vehicleType: 'براد تبريد',
        broadcastScope: 'driver',
        targetProviderId: 'DRV-DIRECT-99',
        driverName: 'الكابتن وليد الحكيمي',
        targetProviderPhone: '+967 771 234 567',
      );

      expect(order.status, equals(MerchantOrderStatus.pendingDriver));
      expect(order.isDirectOrder, isTrue);
      expect(order.directFee, equals(320000.0));
      expect(store.getOffersForOrder(order.id), isEmpty, reason: 'No bidding/quotes on direct orders');

      // Direct acceptance
      final accepted = store.acceptDirectOrder(order.id, agreedPrice: 320000.0);
      expect(accepted, isTrue);

      final updated = store.getOrderById(order.id)!;
      expect(updated.directStatus, equals('accepted'));
      expect(updated.agreedFare, equals(320000.0));
      expect(updated.assignedDriverName, equals('الكابتن وليد الحكيمي'));
      expect(updated.assignedDriverPhone, equals('+967 771 234 567'));
      expect(updated.isPaid, isFalse);
      expect(updated.isContactRevealed, isFalse);
      expect(updated.maskedTargetPhone, contains('***'));
    });

    // -------------------------------------------------------------------------
    // 3. Wallet balance check, deficit calculation, and deposit shortcut
    // -------------------------------------------------------------------------
    test('3. Wallet balance check prevents underfunded payment, shows deficit, and succeeds after deposit shortcut', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 100000.0; // insufficient

      final order = store.publishOrder(
        cargoName: 'بضائع متنوعة',
        originCity: 'صنعاء',
        destinationCity: 'تعز',
        maxBudget: 250000.0,
        broadcastScope: 'all_drivers',
        vehicleType: 'دينا نقل',
      );

      final offer = DriverOffer(
        id: 'OFFER-03',
        orderId: order.id,
        driverId: 'DRV-03',
        driverName: 'ماجد العبسي',
        rating: 4.7,
        tripsCount: 95,
        vehicleName: 'دينا نقل',
        vehiclePlate: 'تعز 11-2094',
        price: 240000.0,
        pickupTimeText: 'اليوم خلال ساعتين',
        deliveryTimeText: 'غداً صباحاً',
        notes: 'جاهز فوراً',
        driverPhone: '+967 772 233 445',
      );
      store.acceptQuote(order.id, offer);

      // Total payment required = 240,000 + 15,000 platform fee = 255,000 YER
      final totalRequired = 240000.0 + 15000.0;
      expect(store.walletBalance < totalRequired, isTrue);

      // Payment attempt fails gracefully without deducting balance
      final payAttempt1 = store.payForOrder(order.id, null);
      expect(payAttempt1, isFalse);
      expect(store.walletBalance, equals(100000.0));

      // Deficit calculation
      final deficit = totalRequired - store.walletBalance;
      expect(deficit, equals(155000.0));

      // Deposit shortcut
      store.depositToWallet(deficit);
      expect(store.walletBalance, equals(totalRequired));

      // Re-attempt payment succeeds
      final payAttempt2 = store.payForOrder(order.id, null);
      expect(payAttempt2, isTrue);

      final paidOrder = store.getOrderById(order.id)!;
      expect(paidOrder.isPaid, isTrue);
      expect(paidOrder.status, equals(MerchantOrderStatus.assignedDriver));
      expect(store.getTripStageIndex(order.id), equals(1));
    });

    // -------------------------------------------------------------------------
    // 4. Single deduction of agreed fare only (not max budget) & duplicate prevention
    // -------------------------------------------------------------------------
    test('4. Deducts agreed fare + platform fee only (never max budget); blocks duplicate payments', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 1000000.0; // 1,000,000 YER

      final order = store.publishOrder(
        cargoName: 'أثاث وتجهيزات مكتبية',
        originCity: 'صنعاء',
        destinationCity: 'مأرب',
        maxBudget: 600000.0, // Max budget is 600,000 YER
        broadcastScope: 'all_drivers',
        vehicleType: 'قاطرة تريلا',
      );

      final offer = DriverOffer(
        id: 'OFFER-04',
        orderId: order.id,
        driverId: 'DRV-04',
        driverName: 'عصام الشرعبي',
        rating: 4.9,
        tripsCount: 160,
        vehicleName: 'قاطرة تريلا',
        vehiclePlate: 'صنعاء 19-3341',
        price: 420000.0, // Agreed fare is 420,000 YER
        pickupTimeText: 'اليوم خلال 3 ساعات',
        deliveryTimeText: 'غداً مساءً',
        notes: 'مجهز بأربطة حماية',
        driverPhone: '+967 773 344 556',
      );
      store.acceptQuote(order.id, offer);

      final initialBalance = store.walletBalance;

      // Pay for order
      final paid = store.payForOrder(order.id, null);
      expect(paid, isTrue);

      // Total deducted must be 420,000 + 15,000 = 435,000 YER (NOT 600,000 YER!)
      const expectedDeduction = 420000.0 + 15000.0;
      expect(store.walletBalance, equals(initialBalance - expectedDeduction));

      // Duplicate payment must be blocked
      final balanceBeforeDuplicate = store.walletBalance;
      final duplicatePay = store.payForOrder(order.id, null);
      expect(duplicatePay, isFalse);
      expect(store.walletBalance, equals(balanceBeforeDuplicate));
    });

    // -------------------------------------------------------------------------
    // 5. Provider settlement creation with pendingCompletion status
    // -------------------------------------------------------------------------
    test('5. Payment creates ProviderSettlementRecord in pendingCompletion holding provider earnings', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 500000.0;

      final order = store.publishOrder(
        cargoName: 'مواد بناء ودهانات',
        originCity: 'صنعاء',
        destinationCity: 'إب',
        maxBudget: 350000.0,
        broadcastScope: 'all_drivers',
        vehicleType: 'دينا',
      );

      final offer = DriverOffer(
        id: 'OFFER-05',
        orderId: order.id,
        driverId: 'DRV-05',
        driverName: 'جمال القدسي',
        rating: 4.6,
        tripsCount: 88,
        vehicleName: 'دينا',
        vehiclePlate: 'إب 08-1120',
        price: 300000.0,
        pickupTimeText: 'اليوم عصراً',
        deliveryTimeText: 'غداً ظهراً',
        notes: 'مظلة واقية كاملة',
        driverPhone: '+967 774 455 667',
      );
      store.acceptQuote(order.id, offer);
      store.payForOrder(order.id, null);

      final settlement = store.getProviderSettlement(order.id);
      expect(settlement, isNotNull);
      expect(settlement!.orderId, equals(order.id));
      expect(settlement.requesterPaidAmount, equals(315000.0)); // 300,000 + 15,000
      expect(settlement.platformFee, equals(15000.0));
      expect(settlement.providerDueAmount, equals(300000.0));
      expect(settlement.providerNetEarnings, equals(300000.0));
      expect(settlement.status, equals(ProviderSettlementStatus.pendingCompletion));
    });

    // -------------------------------------------------------------------------
    // 6. Strict 9-Stage sequential progression (no skipping)
    // -------------------------------------------------------------------------
    test('6. Trip executes through 9 sequential stages strictly without skipping', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 500000.0;

      final order = store.publishOrder(
        cargoName: 'شحنة خضار وفواكه',
        originCity: 'صعدة',
        destinationCity: 'صنعاء',
        maxBudget: 200000.0,
        broadcastScope: 'all_drivers',
        vehicleType: 'دينا',
      );

      final offer = DriverOffer(
        id: 'OFFER-06',
        orderId: order.id,
        driverId: 'DRV-06',
        driverName: 'أمين الوادعي',
        rating: 4.8,
        tripsCount: 130,
        vehicleName: 'دينا',
        vehiclePlate: 'صعدة 04-9981',
        price: 180000.0,
        pickupTimeText: 'اليوم صباحاً',
        deliveryTimeText: 'مساء اليوم',
        notes: 'تبريد خفيف',
        driverPhone: '+967 775 566 778',
      );
      store.acceptQuote(order.id, offer);
      store.payForOrder(order.id, null);

      // Initial stage after payment is Stage 1
      expect(store.getTripStageIndex(order.id), equals(1));
      expect(store.getTripStage(order.id), equals(1));

      // Advance through stages 2 to 7 sequentially
      for (int expected = 2; expected <= 7; expected++) {
        expect(store.canAdvanceTripStage(order.id), isTrue);
        final advanced = store.advanceTripStage(order.id);
        expect(advanced, isTrue);
        expect(store.getTripStageIndex(order.id), equals(expected));
      }

      // At stage 7 (arrivedAtDelivery), standard advanceTripStage stops (needs confirmDelivery)
      expect(store.canAdvanceTripStage(order.id), isFalse);
    });

    // -------------------------------------------------------------------------
    // 7. Delivery confirmation requirement before closure
    // -------------------------------------------------------------------------
    test('7. Delivery confirmation requires stage 7, advances to stage 8; closure blocked before delivery', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 500000.0;

      final order = store.publishOrder(
        cargoName: 'قطع غيار شاحنات',
        originCity: 'صنعاء',
        destinationCity: 'المكلا',
        maxBudget: 450000.0,
        broadcastScope: 'all_drivers',
        vehicleType: 'قاطرة',
      );

      final offer = DriverOffer(
        id: 'OFFER-07',
        orderId: order.id,
        driverId: 'DRV-07',
        driverName: 'صادق المريسي',
        rating: 4.9,
        tripsCount: 210,
        vehicleName: 'قاطرة',
        vehiclePlate: 'حضرموت 10-5542',
        price: 400000.0,
        pickupTimeText: 'خلال ساعة',
        deliveryTimeText: 'بعد غد',
        notes: 'جاهز للنقل',
        driverPhone: '+967 776 677 889',
      );
      store.acceptQuote(order.id, offer);
      store.payForOrder(order.id, null);

      // At Stage 1: cannot confirm delivery or close trip
      expect(store.confirmDelivery(order.id), isFalse);
      expect(store.closeTrip(order.id), isFalse);

      // Advance to stage 6
      for (int i = 1; i <= 5; i++) {
        store.advanceTripStage(order.id);
      }
      expect(store.getTripStageIndex(order.id), equals(6));
      expect(store.confirmDelivery(order.id), isFalse);
      expect(store.closeTrip(order.id), isFalse);

      // Advance to stage 7
      store.advanceTripStage(order.id);
      expect(store.getTripStageIndex(order.id), equals(7));

      // Cannot close before confirming delivery
      expect(store.closeTrip(order.id), isFalse);

      // Confirm delivery succeeds and advances to Stage 8
      final confirmed = store.confirmDelivery(order.id);
      expect(confirmed, isTrue);
      expect(store.getTripStageIndex(order.id), equals(8));
    });

    // -------------------------------------------------------------------------
    // 8. Trip closure transitions settlement to settled and is idempotent
    // -------------------------------------------------------------------------
    test('8. Trip closure releases provider settlement to settled, marks order closed, and is idempotent', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 500000.0;

      final order = store.publishOrder(
        cargoName: 'أثاث منزلي كامل',
        originCity: 'صنعاء',
        destinationCity: 'ذمار',
        maxBudget: 150000.0,
        broadcastScope: 'all_drivers',
        vehicleType: 'شاحنة نقل',
      );

      final offer = DriverOffer(
        id: 'OFFER-08',
        orderId: order.id,
        driverId: 'DRV-08',
        driverName: 'فؤاد الأنسي',
        rating: 4.5,
        tripsCount: 75,
        vehicleName: 'شاحنة نقل',
        vehiclePlate: 'ذمار 03-7712',
        price: 130000.0,
        pickupTimeText: 'اليوم خلال ساعة',
        deliveryTimeText: 'اليوم مساءً',
        notes: 'عمال تحميل وتنزيل',
        driverPhone: '+967 778 899 001',
      );
      store.acceptQuote(order.id, offer);
      store.payForOrder(order.id, null);

      // Advance to 7, then confirm delivery to 8
      for (int i = 1; i <= 6; i++) {
        store.advanceTripStage(order.id);
      }
      store.confirmDelivery(order.id);
      expect(store.getTripStageIndex(order.id), equals(8));

      // Settlement is still pending
      expect(store.getProviderSettlement(order.id)!.status,
          equals(ProviderSettlementStatus.pendingCompletion));

      // Close trip
      final closed = store.closeTrip(order.id);
      expect(closed, isTrue);

      // Stage is 9
      expect(store.getTripStageIndex(order.id), equals(9));

      // Order is closed
      final closedOrder = store.getOrderById(order.id)!;
      expect(closedOrder.status, equals(MerchantOrderStatus.completed));
      expect(closedOrder.isClosed, isTrue);
      expect(closedOrder.closedAt, isNotNull);

      // Settlement is now settled
      final settledRecord = store.getProviderSettlement(order.id)!;
      expect(settledRecord.status, equals(ProviderSettlementStatus.settled));
      expect(settledRecord.settledAt, isNotNull);

      // Repeated closure is idempotent
      final reclosed = store.closeTrip(order.id);
      expect(reclosed, isTrue);
      expect(store.getTripStageIndex(order.id), equals(9));
      expect(settledRecord.status, equals(ProviderSettlementStatus.settled));
    });

    // -------------------------------------------------------------------------
    // 9. Post-closure rating: enabled at Stage 9, blocks duplicates
    // -------------------------------------------------------------------------
    test('9. Rating is blocked before Stage 9, succeeds post-closure, and prevents duplicates', () {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();
      store.walletBalance = 500000.0;

      final order = store.publishOrder(
        cargoName: 'مولدات كهربائية',
        originCity: 'عدن',
        destinationCity: 'تعز',
        maxBudget: 300000.0,
        broadcastScope: 'all_drivers',
        vehicleType: 'شاحنة مغلقة',
      );

      final offer = DriverOffer(
        id: 'OFFER-09',
        orderId: order.id,
        driverId: 'DRV-09',
        driverName: 'نبيل المخلافي',
        rating: 4.9,
        tripsCount: 190,
        vehicleName: 'شاحنة مغلقة',
        vehiclePlate: 'تعز 14-6621',
        price: 260000.0,
        pickupTimeText: 'اليوم خلال ساعتين',
        deliveryTimeText: 'غداً فجراً',
        notes: 'تأمين كامل ومتابعة',
        driverPhone: '+967 779 900 112',
      );
      store.acceptQuote(order.id, offer);
      store.payForOrder(order.id, null);

      // Attempt rating before closure (Stage 1) -> fails
      expect(store.submitTripRating(order.id, 5.0, comment: 'تقييم مبكر'), isFalse);
      expect(store.hasOrderRating(order.id), isFalse);

      // Run through to closure
      for (int i = 1; i <= 6; i++) {
        store.advanceTripStage(order.id);
      }
      store.confirmDelivery(order.id);
      store.closeTrip(order.id);
      expect(store.getTripStageIndex(order.id), equals(9));

      // Submit rating post-closure succeeds
      final rated = store.submitTripRating(
        order.id,
        5.0,
        comment: 'سائق محترف ومواعيد دقيقة وحمولة سليمة',
      );
      expect(rated, isTrue);
      expect(store.hasOrderRating(order.id), isTrue);

      final ratingRecord = store.getOrderRating(order.id)!;
      expect(ratingRecord.rating, equals(5.0));
      expect(ratingRecord.comment, contains('سائق محترف'));

      // Duplicate rating is rejected
      final duplicateRating = store.submitTripRating(
        order.id,
        4.0,
        comment: 'تقييم مكرر',
      );
      expect(duplicateRating, isFalse);
      // Original rating remains unchanged
      expect(store.getOrderRating(order.id)!.rating, equals(5.0));
    });

    // -------------------------------------------------------------------------
    // 10. UI Widget: Tracking screen displays unpaid barrier when unpaid
    // -------------------------------------------------------------------------
    testWidgets('10. MerchantTripTrackingScreen displays unpaid barrier when order is not paid',
        (tester) async {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      // REQ-1024 is initially unpaid in demo store
      final order = store.getOrderById('REQ-1024')!;
      expect(order.isPaid, isFalse);

      await tester.pumpWidget(
        const MaterialApp(
          home: MerchantTripTrackingScreen(
            orderId: 'REQ-1024',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the barrier texts are shown
      expect(find.textContaining('الرحلة في انتظار تأكيد الاتفاق والدفع'), findsOneWidget);
      expect(find.textContaining('لا تبدأ دورة تنفيذ الرحلة ولا يُتاح التتبع المباشر'), findsOneWidget);
      expect(find.textContaining('الانتقال لشاشة تأكيد الاتفاق والدفع'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 11. UI Widget: Tracking screen displays prototype disclaimer & execution details for paid order
    // -------------------------------------------------------------------------
    testWidgets('11. MerchantTripTrackingScreen displays prototype disclaimer banner and tracking info for paid order',
        (tester) async {
      final store = MerchantSimulationStore.instance;
      store.resetToInitialState();

      // REQ-1023 is paid in demo store
      final order = store.getOrderById('REQ-1023')!;
      expect(order.isPaid, isTrue);

      await tester.pumpWidget(
        const MaterialApp(
          home: MerchantTripTrackingScreen(
            orderId: 'REQ-1023',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify disclaimer banner is visible
      expect(find.textContaining('نموذج محاكاة تفاعلي'), findsOneWidget);
      expect(find.textContaining('بيانات وهمية'), findsOneWidget);

      // Verify order header displays order id
      expect(find.textContaining('REQ-1023'), findsOneWidget);

      // Verify driver name is rendered
      expect(find.textContaining('أحمد صالح'), findsWidgets);
    });
  });
}
