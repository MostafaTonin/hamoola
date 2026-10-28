import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application/features/driver/domain/models/cargo_bid_opportunity.dart';
import 'package:flutter_application/features/driver/domain/models/driver_simulation_store.dart';
import 'package:flutter_application/features/driver/presentation/screens/driver_order_details_screen.dart';
import 'package:flutter_application/features/driver/presentation/widgets/driver_submit_bid_sheet.dart';

void main() {
  setUp(() {
    DriverSimulationStore.instance.resetToDemo();
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(420, 900)),
          child: child,
        ),
      ),
    );
  }

  testWidgets('DriverOrderDetailsScreen renders all required sections matching reference image', (tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final demoCargo = CargoBidOpportunity.demoOpportunities.first; // REQ-4091

    await tester.pumpWidget(buildTestWidget(DriverOrderDetailsScreen(cargo: demoCargo)));
    await tester.pumpAndSettle();

    // 1. Top Bar
    expect(find.text('تفاصيل الطلب'), findsOneWidget);
    expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

    // 2. Header Info
    expect(find.text('طلب عام'), findsOneWidget);
    expect(find.text('رقم الطلب: REQ-4091'), findsOneWidget);
    expect(find.text('نقل مواد بناء (أسمنت)'), findsOneWidget);
    expect(find.text('مواد بناء'), findsOneWidget);
    expect(find.text('أسمنت'), findsOneWidget);
    expect(find.text('12 طن'), findsWidgets);
    expect(find.textContaining('2025/05/20'), findsOneWidget);

    // 3. Image carousel count
    expect(find.text('1/3'), findsOneWidget);

    // 4. Transport route section
    expect(find.text('مسار النقل'), findsOneWidget);
    expect(find.text('فتح في الخرائط'), findsOneWidget);
    expect(find.text('92 كيلومتر'), findsOneWidget);
    expect(find.text('2 ساعة تقريباً'), findsOneWidget);
    expect(find.text('نقطة التحميل'), findsOneWidget);
    expect(find.text('صنعاء - منطقة الحصبة'), findsOneWidget);
    expect(find.text('وجهة التسليم'), findsOneWidget);
    expect(find.text('تعز - منطقة الحوبان'), findsOneWidget);

    // 5. Specs Table
    expect(find.text('بيانات الحمولة'), findsOneWidget);
    expect(find.text('نوع الحمولة'), findsOneWidget);
    expect(find.text('الكمية / الوزن'), findsOneWidget);
    expect(find.text('نوع التعبئة'), findsOneWidget);
    expect(find.text('طريقة التحميل'), findsOneWidget);
    expect(find.text('متطلبات الناقلة'), findsOneWidget);

    // 6. Additional Details & Terms
    expect(find.text('تفاصيل إضافية'), findsOneWidget);
    expect(find.text('تعليمات وشروط النقل'), findsOneWidget);
    expect(find.text('الالتزام بموعد التحميل والتسليم.'), findsOneWidget);

    // 7. Pre-bid notice verbatim
    expect(
      find.text('تأكد من ملاءمة الحمولة لناقلتك وقدرتك على تنفيذ متطلبات الطلب. السعر الذي تقدمه هو السعر الإجمالي للنقل وفق الشروط الموضحة.'),
      findsOneWidget,
    );

    // 8. Bottom Action Button
    expect(find.text('تقديم عرض سعر'), findsOneWidget);
  });

  testWidgets('Favorite button toggles visually and updates DriverSimulationStore', (tester) async {
    final demoCargo = CargoBidOpportunity.demoOpportunities.first;

    await tester.pumpWidget(buildTestWidget(DriverOrderDetailsScreen(cargo: demoCargo)));
    await tester.pumpAndSettle();

    expect(DriverSimulationStore.instance.isFavorite(demoCargo.id), isFalse);

    // Tap favorite icon
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();

    expect(DriverSimulationStore.instance.isFavorite(demoCargo.id), isTrue);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    // Tap again to unfavorite
    await tester.tap(find.byIcon(Icons.favorite_rounded));
    await tester.pumpAndSettle();

    expect(DriverSimulationStore.instance.isFavorite(demoCargo.id), isFalse);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
  });

  testWidgets('Private order displays Accept and Decline buttons instead of Bidding', (tester) async {
    const privateCargo = CargoBidOpportunity(
      id: 'REQ-PRIV-99',
      title: 'نقل مواد خاصة',
      merchantName: 'شركة النور',
      merchantRating: 4.8,
      originCity: 'صنعاء',
      destinationCity: 'عدن',
      distanceKm: 380,
      durationHours: 6.0,
      weightTons: 10.0,
      requiredTruckType: 'دينا مغلقة',
      urgencyLabel: 'طلب خاص',
      isUrgent: false,
      targetBudgetYmr: 120000,
      offersCount: 1,
      loadingWindow: '2025/05/22',
      paymentTerms: 'دفع مؤمن',
      isInsuranceRequired: true,
      notes: 'طلب مباشر للسائق',
      isPrivate: true,
    );

    await tester.pumpWidget(buildTestWidget(const DriverOrderDetailsScreen(cargo: privateCargo)));
    await tester.pumpAndSettle();

    expect(find.text('طلب خاص'), findsOneWidget);
    expect(find.text('قبول الطلب'), findsOneWidget);
    expect(find.text('اعتذار'), findsOneWidget);
    expect(find.text('تقديم عرض سعر'), findsNothing);
  });

  testWidgets('DriverSubmitBidSheet displays order summary, currency options, 500-char counter and review flow', (tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final demoCargo = CargoBidOpportunity.demoOpportunities.first;

    await tester.pumpWidget(buildTestWidget(
      Scaffold(
        body: Center(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => DriverSubmitBidSheet.show(ctx, cargo: demoCargo),
              child: const Text('افتح النموذج'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Open sheet
    await tester.tap(find.text('افتح النموذج'));
    await tester.pumpAndSettle();

    // Check title and order summary
    expect(find.text('تقديم عرض سعر'), findsWidgets);
    expect(find.text('رقم الطلب: REQ-4091'), findsOneWidget);
    expect(find.text('نقل مواد بناء (أسمنت)'), findsOneWidget);
    expect(find.text('صنعاء - منطقة الحصبة'), findsOneWidget);
    expect(find.text('تعز - منطقة الحوبان'), findsOneWidget);

    // Section «قيمة العرض» and Default Currency (YER)
    expect(find.text('قيمة العرض'), findsOneWidget);
    expect(find.text('المبلغ الإجمالي للنقل'), findsOneWidget);
    expect(find.text('ريال يمني'), findsOneWidget);

    // Character counter initial
    expect(find.text('0 / 500'), findsOneWidget);

    // Type notes and check counter update
    await tester.enterText(find.byType(TextField).last, 'جاهز مع كامل المعدات والرافعات');
    await tester.pump();
    expect(find.textContaining('/ 500'), findsOneWidget);

    // Pre-submit notice verbatim
    expect(
      find.text('تأكد من ملاءمة الحمولة لناقلتك وقدرتك على تنفيذ متطلبات الطلب. السعر الذي تقدمه هو السعر الإجمالي للنقل.'),
      findsOneWidget,
    );

    // Clear price and test validation
    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('مراجعة العرض'));
    await tester.pumpAndSettle();

    // Arabic error message appears
    expect(find.text('يرجى إدخال مبلغ صحيح أكبر من صفر'), findsOneWidget);

    // Enter valid amount
    await tester.enterText(find.byType(TextField).first, '58000');
    await tester.pump();

    // Click «مراجعة العرض»
    await tester.tap(find.text('مراجعة العرض'));
    await tester.pumpAndSettle();

    // Step 2: Intermediate Review Screen appears
    expect(find.text('مراجعة العرض قبل الإرسال'), findsOneWidget);
    expect(find.text('58000 ريال يمني'), findsOneWidget);
    expect(find.text('جاهز مع كامل المعدات والرافعات'), findsOneWidget);
    expect(find.text('تعديل العرض'), findsOneWidget);
    expect(find.text('تأكيد وإرسال العرض'), findsOneWidget);

    // Test «تعديل العرض» returns to form with values preserved
    await tester.tap(find.text('تعديل العرض'));
    await tester.pumpAndSettle();

    expect(find.text('تقديم عرض سعر'), findsWidgets);
    expect(find.text('58000'), findsOneWidget);
    expect(find.textContaining('/ 500'), findsOneWidget);

    // Move to review again and confirm submission
    await tester.tap(find.text('مراجعة العرض'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تأكيد وإرسال العرض'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify bid added to DriverSimulationStore
    expect(DriverSimulationStore.instance.hasBidOnCargo(demoCargo.id), isTrue);
    final submittedBid = DriverSimulationStore.instance.getBidForCargo(demoCargo.id);
    expect(submittedBid, isNotNull);
    expect(submittedBid!.bidAmount, 58000);
    expect(submittedBid.currencyCode, 'YER');
    expect(submittedBid.currencyLabel, 'ريال يمني');
    expect(submittedBid.notes, 'جاهز مع كامل المعدات والرافعات');
  });

  testWidgets('DriverSubmitBidSheet prevents duplicate bids for the same cargo', (tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final demoCargo = CargoBidOpportunity.demoOpportunities.first;

    // Manually submit first bid
    DriverSimulationStore.instance.submitBid(
      cargo: demoCargo,
      amount: 50000,
      currencyCode: 'YER',
    );
    expect(DriverSimulationStore.instance.hasBidOnCargo(demoCargo.id), isTrue);

    // Try to open and submit another bid on the same cargo
    await tester.pumpWidget(buildTestWidget(
      Scaffold(
        body: Center(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => DriverSubmitBidSheet.show(ctx, cargo: demoCargo),
              child: const Text('افتح النموذج'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('افتح النموذج'));
    await tester.pumpAndSettle();

    // Attempt review and submit
    await tester.enterText(find.byType(TextField).first, '52000');
    await tester.tap(find.text('مراجعة العرض'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('تأكيد وإرسال العرض'));
    await tester.pumpAndSettle();

    // Shows warning about duplicate bid
    expect(find.text('لقد قمت بتقديم عرض سعر على هذا الطلب مسبقاً!'), findsOneWidget);
  });
}
