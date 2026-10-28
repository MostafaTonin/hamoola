import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_order.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_orders_screen.dart';
import 'package:flutter_application/features/merchant/presentation/widgets/merchant_order_details_dialog.dart';

void main() {
  setUp(() {
    MerchantSimulationStore.instance.resetToDemo();
  });

  group('MerchantOrderDetailsDialog Tests', () {
    testWidgets('Tapping order card opens MerchantOrderDetailsDialog with complete specs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MerchantOrdersScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find first order card and tap it
      final firstCard = find.text('REQ-1024');
      expect(firstCard, findsOneWidget);

      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Dialog should be open
      expect(find.byType(MerchantOrderDetailsDialog), findsOneWidget);
      expect(find.text('تفاصيل طلب النقل'), findsOneWidget);
      expect(find.text('مسار النقل'), findsOneWidget);
      expect(find.text('مواصفات الطلب'), findsOneWidget);
      expect(find.text('من: صنعاء'), findsOneWidget);
      expect(find.text('إلى: عدن'), findsOneWidget);
    });

    testWidgets('Order is editable if pendingDriver or pendingOffice or draft', (tester) async {
      final pendingOrder = MerchantOrder(
        id: 'REQ-TEST-1',
        cargoName: 'أدوية ومستلزمات طبية',
        originCity: 'صنعاء',
        destinationCity: 'تعز',
        status: MerchantOrderStatus.pendingDriver,
        timeAgo: 'الآن',
        vehicleType: 'دينا تبريد',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => MerchantOrderDetailsDialog.show(context, pendingOrder),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Should show active edit button
      final editBtn = find.text('تعديل الطلب');
      expect(editBtn, findsOneWidget);

      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      // Should open edit order dialog
      expect(find.text('تعديل طلب النقل'), findsOneWidget);
      expect(find.text('حفظ التعديلات'), findsOneWidget);
    });

    testWidgets('Order edit is LOCKED and restricted if assignedDriver, inTransit, or completed', (tester) async {
      final assignedOrder = MerchantOrder(
        id: 'REQ-TEST-2',
        cargoName: 'حديد تسليح',
        originCity: 'الرياض',
        destinationCity: 'جدة',
        status: MerchantOrderStatus.assignedDriver,
        driverName: 'كابتن سلطان القحطاني',
        timeAgo: 'أمس',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => MerchantOrderDetailsDialog.show(context, assignedOrder),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Edit should show locked
      final lockedBtn = find.text('التعديل مقفل');
      expect(lockedBtn, findsOneWidget);

      await tester.tap(lockedBtn);
      await tester.pumpAndSettle();

      // Should show restriction dialog explaining why editing is locked
      expect(find.text('لا يمكن تعديل الطلب'), findsOneWidget);
      expect(find.textContaining('مسودة'), findsOneWidget);
      expect(find.textContaining('بانتظار سائق'), findsOneWidget);
      expect(find.textContaining('بانتظار مكتب'), findsOneWidget);
    });
  });
}
