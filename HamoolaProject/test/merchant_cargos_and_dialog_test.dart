import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/cargo_card_item.dart';
import 'package:flutter_application/features/merchant/domain/models/merchant_simulation_store.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_cargos_screen.dart';
import 'package:flutter_application/features/merchant/presentation/widgets/merchant_cargo_card_widget.dart';
import 'package:flutter_application/features/merchant/presentation/widgets/merchant_cargo_details_dialog.dart';

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

  testWidgets('Scenario 1: Opens حمولاتي and displays dynamic count & uniform cards',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(wrapWidget(const MerchantCargosScreen()));
    await tester.pumpAndSettle();

    // Verify header and title
    expect(find.text('حمولاتي'), findsOneWidget);
    expect(find.text('إدارة الحمولات المسجلة لديك'), findsOneWidget);
    expect(find.text('إضافة حمولة'), findsOneWidget);

    // Verify dynamic registered count
    final count = MerchantSimulationStore.instance.cargos.length;
    expect(find.text('$count حمولة مسجلة'), findsOneWidget);

    // Verify cards are rendered with exact names
    expect(find.text('حديد تسليح'), findsOneWidget);
    expect(find.text('إسمنت'), findsOneWidget);
    expect(find.text('مواد تموينية وزيوت'), findsOneWidget);
  });

  testWidgets('Scenario 2: Search cargo by name or category', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(wrapWidget(const MerchantCargosScreen()));
    await tester.pumpAndSettle();

    final searchField = find.byKey(const ValueKey('cargos_search_field'));
    expect(searchField, findsOneWidget);

    // Search by name "إسمنت"
    await tester.enterText(searchField, 'إسمنت');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(MerchantCargoCardWidget, 'إسمنت'), findsOneWidget);
    expect(find.widgetWithText(MerchantCargoCardWidget, 'حديد تسليح'), findsNothing);

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(MerchantCargoCardWidget, 'حديد تسليح'), findsOneWidget);
  });

  testWidgets('Scenario 3: Filter by status and sorting', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(wrapWidget(const MerchantCargosScreen()));
    await tester.pumpAndSettle();

    // Select "مرتبطة بطلب نشط" chip
    final linkedFilterChip =
        find.byKey(const ValueKey('filter_chip_مرتبطة بطلب نشط'));
    expect(linkedFilterChip, findsOneWidget);
    await tester.tap(linkedFilterChip);
    await tester.pumpAndSettle();

    // Verify linked active cargo (CRG-001) appears
    expect(find.widgetWithText(MerchantCargoCardWidget, 'حديد تسليح'), findsOneWidget);

    // Select "الكل" to reset filter
    final allFilterChip = find.byKey(const ValueKey('filter_chip_الكل'));
    await tester.tap(allFilterChip);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(MerchantCargoCardWidget, 'إسمنت'), findsOneWidget);
  });

  testWidgets('Scenario 4 & 5: Opens MerchantCargoDetailsDialog, closes and reopens',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(wrapWidget(const MerchantCargosScreen()));
    await tester.pumpAndSettle();

    // Tap on 'حديد تسليح' card
    await tester.tap(find.text('حديد تسليح'));
    await tester.pumpAndSettle();

    // Verify Dialog opened
    expect(find.byType(MerchantCargoDetailsDialog), findsOneWidget);
    expect(find.text('معلومات الحمولة الكاملة'), findsOneWidget);
    expect(find.text('10 طن'), findsWidgets);
    expect(find.text('تعديل الحمولة'), findsOneWidget);

    // Close Dialog by tapping the close button
    final closeBtn = find.byIcon(Icons.close_rounded);
    expect(closeBtn, findsOneWidget);
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();

    // Verify Dialog is closed
    expect(find.byType(MerchantCargoDetailsDialog), findsNothing);

    // Reopen dialog
    await tester.tap(find.text('حديد تسليح'));
    await tester.pumpAndSettle();
    expect(find.byType(MerchantCargoDetailsDialog), findsOneWidget);
  });

  testWidgets('Scenario 9: Blocks deletion of cargo linked to active order with reason',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 'CRG-001' is linked to REQ-1024 (Pending active order)
    final activeCargo = MerchantSimulationStore.instance.getCargoById('CRG-001')!;

    await tester.pumpWidget(
      wrapWidget(
        Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => MerchantCargoDetailsDialog.show(ctx, activeCargo),
                child: const Text('افتح'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('افتح'));
    await tester.pumpAndSettle();

    // Tap delete button inside dialog
    final deleteBtn = find.text('حذف الحمولة');
    expect(deleteBtn, findsOneWidget);
    await tester.ensureVisible(deleteBtn);
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    // Verify blocking dialog appears with reason
    expect(find.text('تعذر حذف الحمولة'), findsOneWidget);
    expect(find.textContaining('هذه الحمولة مرتبطة بطلب نقل نشط'), findsOneWidget);
  });

  testWidgets('Scenario 7 & 8: Delete unlinked cargo with confirmation',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Add a free unlinked cargo to store
    const freeCargo = CargoCardItem(
      id: 'CRG-DELETE-ME',
      name: 'بضاعة قابلة للحذف',
      category: 'مواد بناء',
      weight: '5 طن',
      quantity: '10 كراتين',
      handlingRequirement: 'مناولة عادية',
    );
    MerchantSimulationStore.instance.addCargo(freeCargo);

    await tester.pumpWidget(
      wrapWidget(
        Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => MerchantCargoDetailsDialog.show(ctx, freeCargo),
                child: const Text('افتح'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('افتح'));
    await tester.pumpAndSettle();

    // Tap delete
    final deleteBtn = find.text('حذف الحمولة');
    await tester.ensureVisible(deleteBtn);
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    // Confirmation dialog appears
    expect(find.text('تأكيد حذف الحمولة'), findsOneWidget);

    // Cancel first
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(MerchantSimulationStore.instance.getCargoById('CRG-DELETE-ME'), isNotNull);

    // Tap delete again and confirm
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف نهائي'));
    await tester.pumpAndSettle();

    // Verify cargo was deleted from store
    expect(MerchantSimulationStore.instance.getCargoById('CRG-DELETE-ME'), isNull);
  });
}
