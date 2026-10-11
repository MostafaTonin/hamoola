import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/cargo_card_item.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_cargos_screen.dart';
import 'package:flutter_application/features/merchant/presentation/widgets/merchant_cargo_card_widget.dart';

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

  testWidgets('MerchantCargosScreen renders title, header buttons, and cargo cards',
      (tester) async {
    bool backTapped = false;
    bool addCargoTapped = false;
    CargoCardItem? selectedCargo;

    await tester.pumpWidget(
      wrapWidget(
        MerchantCargosScreen(
          onBack: () => backTapped = true,
          onAddCargo: () => addCargoTapped = true,
          onCargoSelected: (c) => selectedCargo = c,
        ),
      ),
    );
    await tester.pump();

    // Verify Title
    expect(find.text('حمولاتي'), findsOneWidget);

    // Verify Add Cargo button in header
    expect(find.text('إضافة حمولة'), findsOneWidget);
    await tester.tap(find.text('إضافة حمولة'));
    expect(addCargoTapped, isTrue);

    // Verify Back button
    await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
    expect(backTapped, isTrue);

    // Verify Demo Cargo Cards
    expect(find.text('حديد تسليح'), findsOneWidget);
    expect(find.text('إسمنت'), findsOneWidget);
    expect(find.text('مواد تموينية وزيوت'), findsOneWidget);

    // Verify specs
    expect(find.text('10 طن'), findsOneWidget);
    expect(find.text('200 وحدة'), findsOneWidget);
    expect(find.text('تغطية أثناء النقل'), findsOneWidget);

    // Tap first cargo card
    await tester.tap(find.text('حديد تسليح'));
    expect(selectedCargo?.name, equals('حديد تسليح'));
    expect(selectedCargo?.id, equals('CRG-001'));
  });

  testWidgets('MerchantCargoCardWidget renders category and normal handling chip',
      (tester) async {
    const cargo = CargoCardItem(
      id: 'CRG-TEST',
      name: 'شحنة اختبار',
      category: 'مواد بناء',
      weight: '3 طن',
      quantity: '50 كيس',
      handlingRequirement: 'مناولة عادية',
      isSpecialHandling: false,
    );

    await tester.pumpWidget(
      wrapWidget(
        const Scaffold(
          body: MerchantCargoCardWidget(cargo: cargo),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('شحنة اختبار'), findsOneWidget);
    expect(find.text('مواد بناء'), findsOneWidget);
    expect(find.text('3 طن'), findsOneWidget);
    expect(find.text('50 كيس'), findsOneWidget);
    expect(find.text('مناولة عادية'), findsOneWidget);
  });
}
