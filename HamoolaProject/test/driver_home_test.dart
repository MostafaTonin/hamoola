import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_home_screen.dart';

void main() {
  Widget createTestWidget({
    VoidCallback? onNotifications,
    VoidCallback? onSwitchToMerchant,
    VoidCallback? onWallet,
    VoidCallback? onSupport,
    VoidCallback? onLogout,
    ValueChanged<String>? onTripDetails,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: DriverHomeScreen(
          onNotifications: onNotifications,
          onSwitchToMerchant: onSwitchToMerchant,
          onWallet: onWallet,
          onSupport: onSupport,
          onLogout: onLogout,
          onTripDetails: onTripDetails,
        ),
      ),
    );
  }

  group('DriverHomeScreen Tests', () {
    testWidgets('renders driver header, captain identity, metrics, active trip, and marketplace', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Captain Header
      expect(find.text('كابتن عبد الله الصبري'), findsOneWidget);
      expect(find.text('براد مرسيدس 32 طن • 14/5820 ص'), findsOneWidget);

      // Status Bar
      expect(find.textContaining('متصل • متاح لاستقبال طلبات النقل والمزايدة'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      // Metrics
      expect(find.text('أرباح اليوم'), findsOneWidget);
      expect(find.text('85,000 ر.ي'), findsOneWidget);
      expect(find.text('عروضي النشطة'), findsOneWidget);
      expect(find.text('3 معلقة'), findsOneWidget);

      // Active Trip Card
      expect(find.text('رحلة جارية الآن'), findsOneWidget);
      expect(find.text('TRP-4091'), findsOneWidget);
      expect(find.textContaining('نقيل سمارة'), findsOneWidget);

      // Marketplace Section
      expect(find.text('سوق الحمولات المتاحة'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('مطابق لشاحنتي'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'تحميل فوري'), findsOneWidget);

      // Cargo Bid button (may need scroll)
      expect(find.text('تقديم عرض سعر'), findsWidgets);
    });

    testWidgets('toggles availability switch between online and offline states', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Toggle switch to false
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('غير متصل • لن تتلقى تنبيهات'), findsOneWidget);

      // Toggle back to true
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(find.textContaining('متصل • متاح لاستقبال طلبات النقل'), findsOneWidget);
    });

    testWidgets('filters cargo marketplace by criteria chips', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap 'تحميل فوري'
      final urgentFilter = find.widgetWithText(ChoiceChip, 'تحميل فوري');
      expect(urgentFilter, findsOneWidget);
      await tester.tap(urgentFilter);
      await tester.pumpAndSettle();

      // Should show matching urgent badges
      expect(find.text('تحميل فوري اليوم'), findsWidgets);

      // Tap 'مطابق لشاحنتي'
      final matchFilter = find.widgetWithText(ChoiceChip, 'مطابق لشاحنتي');
      expect(matchFilter, findsOneWidget);
      await tester.tap(matchFilter);
      await tester.pumpAndSettle();

      expect(find.textContaining('براد'), findsWidgets);
    });

    testWidgets('opens DriverBidModalSheet and submits bid', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final firstBidBtn = find.text('تقديم عرض سعر').first;
      await tester.ensureVisible(firstBidBtn);
      await tester.pumpAndSettle();

      // Tap first 'تقديم عرض سعر' button
      await tester.tap(firstBidBtn);
      await tester.pumpAndSettle();

      // Modal should appear
      expect(find.text('تقديم عرض سعر (مزايدة)'), findsOneWidget);
      expect(find.text('سعرك المقترح للشحنة (ريال يمني)'), findsOneWidget);
      expect(find.text('موعد جاهزيتك للتحميل'), findsOneWidget);

      // Tap quick price chip '-15,000 (تنافسي)'
      final discountChip = find.text('-15,000 (تنافسي)');
      expect(discountChip, findsOneWidget);
      await tester.tap(discountChip);
      await tester.pumpAndSettle();

      // Submit bid
      final submitBtn = find.widgetWithText(ElevatedButton, 'إرسال العرض للتاجر');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Modal closed and SnackBar shown
      expect(find.text('تقديم عرض سعر (مزايدة)'), findsNothing);
      expect(find.textContaining('تم إرسال عرضك بمبلغ'), findsOneWidget);
    });

    testWidgets('opens drawer and triggers onSwitchToMerchant callback', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      bool switchedToMerchant = false;

      await tester.pumpWidget(createTestWidget(
        onSwitchToMerchant: () => switchedToMerchant = true,
      ));
      await tester.pumpAndSettle();

      // Open drawer using menu icon
      final menuBtn = find.byTooltip('القائمة الرئيسية');
      expect(menuBtn, findsOneWidget);
      await tester.tap(menuBtn);
      await tester.pumpAndSettle();

      // Drawer should be open
      expect(find.text('التبديل إلى واجهة التاجر'), findsOneWidget);

      // Tap switch to merchant
      await tester.tap(find.text('التبديل إلى واجهة التاجر'));
      await tester.pumpAndSettle();

      expect(switchedToMerchant, isTrue);
    });
  });
}
