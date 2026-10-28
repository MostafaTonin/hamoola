import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_order.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_assignment_payment_screen.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_cargo_details_screen.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    MerchantSimulationStore.instance.resetToDemo();
  });

  Widget wrapWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      home: child,
    );
  }

  group('MerchantSimulationStore Unit Tests', () {
    test('initializes with default cargos, orders, offers, and wallet', () {
      final store = MerchantSimulationStore.instance;
      expect(store.cargos.length, equals(3));
      expect(store.orders.length, equals(3));
      expect(store.walletBalance, equals(2000.0));
      expect(store.pendingBalance, equals(10000.0));
      expect(store.transactions.isNotEmpty, isTrue);

      final offers = store.getOffersForOrder('REQ-1024');
      expect(offers.length, equals(4));
    });

    test('creates order with sequential ID and generates broadcast offers', () {
      final store = MerchantSimulationStore.instance;
      final cargo = store.cargos.first;

      final newOrder = store.createOrder(
        cargo: cargo,
        originCity: 'صنعاء',
        destinationCity: 'الرياض',
        broadcastScope: 'all_drivers',
        expectedPrice: 500000.0,
      );

      expect(newOrder.id, startsWith('REQ-'));
      expect(newOrder.originCity, equals('صنعاء'));
      expect(newOrder.destinationCity, equals('الرياض'));
      expect(store.orders.first.id, equals(newOrder.id));

      // Check auto-generated bids for broadcast order
      final bids = store.getOffersForOrder(newOrder.id);
      expect(bids.length, equals(3));
      expect(bids.any((b) => b.driverName.contains('أحمد السالمي')), isTrue);
    });

    test('prevents cargo deletion when linked to active order', () {
      final store = MerchantSimulationStore.instance;
      // CRG-001 is linked to active REQ-1024
      final deleted = store.deleteCargo('CRG-001');
      expect(deleted, isFalse);
      expect(store.getCargoById('CRG-001'), isNotNull);

      // CRG-002 has no active orders linked
      final deletedUnlinked = store.deleteCargo('CRG-002');
      expect(deletedUnlinked, isTrue);
      expect(store.getCargoById('CRG-002'), isNull);
    });

    test('deposit request and instant approval simulation updates wallet balance', () {
      final store = MerchantSimulationStore.instance;
      final initialBalance = store.walletBalance;

      store.addDepositRequest(
        amount: 250000.0,
        walletName: 'محفظة جيب',
        ref: 'TXN-TEST-1',
      );

      expect(store.pendingBalance, equals(260000.0));
      expect(store.walletBalance, equals(initialBalance));

      final approved = store.simulateApproveLatestDeposit();
      expect(approved, isTrue);
      expect(store.walletBalance, equals(initialBalance + 250000.0));
      expect(store.pendingBalance, equals(10000.0));
    });
  });

  group('MerchantCargoDetailsScreen Widget Tests', () {
    testWidgets('renders cargo details, packaging, perishable flag, and documents',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cargo = MerchantSimulationStore.instance.getCargoById('CRG-001')!;

      await tester.pumpWidget(
        wrapWidget(
          MerchantCargoDetailsScreen(cargo: cargo),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Cargo Name and ID badge
      expect(find.text('حديد تسليح'), findsOneWidget);
      expect(find.text('CRG-001'), findsOneWidget);

      // Verify Specs
      expect(find.text('10 طن'), findsOneWidget);
      expect(find.text('200 وحدة'), findsOneWidget);
      expect(find.text('ربطات حديدية'), findsOneWidget);

      // Verify Action buttons
      expect(find.text('تعديل الحمولة'), findsOneWidget);
      expect(find.text('إغلاق'), findsOneWidget);
    });

    testWidgets('alerts and blocks deleting cargo linked to active order',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cargo = MerchantSimulationStore.instance.getCargoById('CRG-001')!;

      await tester.pumpWidget(
        wrapWidget(
          MerchantCargoDetailsScreen(cargo: cargo),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Delete icon
      final deleteBtn = find.byTooltip('حذف الحمولة');
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Verify warning dialog appeared
      expect(find.text('تعذر حذف الحمولة'), findsOneWidget);
      expect(find.textContaining('مرتبطة بطلب نقل نشط حالياً'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('حسناً'));
      await tester.pumpAndSettle();

      // Cargo is still in store
      expect(MerchantSimulationStore.instance.getCargoById('CRG-001'), isNotNull);
    });
  });

  group('MerchantAssignmentPaymentScreen Widget Tests', () {
    testWidgets('shows insufficient balance warning, simulates top-up, and pays',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final store = MerchantSimulationStore.instance;
      final offer = store.getOffersForOrder('REQ-1024').first;
      bool paid = false;

      await tester.pumpWidget(
        wrapWidget(
          MerchantAssignmentPaymentScreen(
            offer: offer,
            orderId: 'REQ-1024',
            onPaymentSuccess: (_) => paid = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify order and driver details
      expect(find.text('REQ-1024'), findsOneWidget);
      expect(find.text(offer.driverName), findsOneWidget);
      expect(find.text('420,000 ر.ي'), findsOneWidget);

      // Balance is 2,000 so insufficient warning is shown
      expect(find.text('رصيد المحفظة غير كافٍ لإتمام التعاقد'), findsOneWidget);
      expect(find.text('شحن المحفظة الآن'), findsOneWidget);

      // Scroll down so recharge button is fully visible in viewport
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -350));
      await tester.pumpAndSettle();

      // Tap quick simulation recharge (+500,000 YER)
      final simRechargeBtn = find.byKey(const Key('sim_recharge_button'));
      expect(simRechargeBtn, findsOneWidget);
      await tester.tap(simRechargeBtn);
      await tester.pumpAndSettle();

      // Now balance is sufficient! Button turns to "تأكيد الإسناد والدفع من المحفظة"
      expect(find.text('رصيد المحفظة كافٍ لإتمام العملية'), findsOneWidget);
      final confirmPayBtn = find.text('تأكيد الإسناد والدفع من المحفظة');
      expect(confirmPayBtn, findsOneWidget);

      // Confirm payment
      await tester.tap(confirmPayBtn);
      await tester.pumpAndSettle();

      expect(paid, isTrue);

      // Verify order status updated in store
      final updatedOrder = store.getOrderById('REQ-1024');
      expect(updatedOrder?.status, equals(MerchantOrderStatus.assignedDriver));
      expect(updatedOrder?.driverName, equals(offer.driverName));
    });
  });
}
