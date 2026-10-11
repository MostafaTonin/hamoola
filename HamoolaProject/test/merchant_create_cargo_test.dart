import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/merchant/domain/models/cargo_card_item.dart';
import 'package:flutter_application/features/merchant/presentation/screens/merchant_create_cargo_screen.dart';

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

  testWidgets('MerchantCreateCargoScreen renders all core sections and handles back action',
      (tester) async {
    bool backPressed = false;

    await tester.pumpWidget(
      wrapWidget(
        MerchantCreateCargoScreen(
          onBack: () => backPressed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Section Header
    expect(find.text(AppStrings.createCargoTitle), findsOneWidget);
    expect(find.text(AppStrings.cargoInfoSection), findsOneWidget);

    // Verify Fields Labels
    expect(find.text(AppStrings.cargoNameLabel), findsOneWidget);
    expect(find.text(AppStrings.categoryLabel), findsOneWidget);
    expect(find.text(AppStrings.weightLabel), findsOneWidget);
    expect(find.text(AppStrings.quantityLabel), findsOneWidget);
    expect(find.text(AppStrings.handlingRequirementsTitle), findsOneWidget);

    // Verify Back Button works
    final backBtn = find.byTooltip(AppStrings.back);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    expect(backPressed, isTrue);
  });

  testWidgets('MerchantCreateCargoScreen validates required fields on empty submit',
      (tester) async {
    CargoCardItem? submittedCargo;

    await tester.pumpWidget(
      wrapWidget(
        MerchantCreateCargoScreen(
          onSubmitCargo: (cargo) => submittedCargo = cargo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to and tap Save Cargo button
    final saveButton = find.text(AppStrings.saveCargoButton);
    expect(saveButton, findsOneWidget);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Validation errors should be displayed
    expect(find.text(AppStrings.cargoNameRequiredError), findsOneWidget);
    expect(find.text(AppStrings.categoryRequiredError), findsOneWidget);
    expect(find.text(AppStrings.weightRequiredError), findsOneWidget);
    expect(find.text(AppStrings.qtyRequiredError), findsOneWidget);

    // No submission should have occurred
    expect(submittedCargo, isNull);
  });

  testWidgets('MerchantCreateCargoScreen handles chips and successful cargo creation',
      (tester) async {
    CargoCardItem? submittedCargo;

    // Use a larger surface size to prevent layout constraints in test
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      wrapWidget(
        MerchantCreateCargoScreen(
          onSubmitCargo: (cargo) => submittedCargo = cargo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Enter Cargo Name
    final nameField = find.widgetWithText(TextFormField, AppStrings.cargoNameHint);
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'شحنة حديد مجلفن');
    await tester.pump();

    // 2. Select Category
    final categoryDropdown = find.widgetWithText(DropdownButtonFormField<String>, AppStrings.categoryHint);
    expect(categoryDropdown, findsOneWidget);
    await tester.tap(categoryDropdown);
    await tester.pumpAndSettle();
    // Select 'مواد بناء'
    final catItem = find.text('مواد بناء').last;
    await tester.tap(catItem);
    await tester.pumpAndSettle();

    // 3. Enter Weight
    final weightField = find.widgetWithText(TextFormField, '0.0').first;
    await tester.enterText(weightField, '12.5');
    await tester.pump();

    // 4. Enter Quantity
    final qtyField = find.widgetWithText(TextFormField, '0');
    await tester.enterText(qtyField, '45');
    await tester.pump();

    // 5. Select Quantity Unit
    final qtyUnitDropdown = find.widgetWithText(DropdownButtonFormField<String>, AppStrings.unitHint);
    await tester.tap(qtyUnitDropdown);
    await tester.pumpAndSettle();
    final unitItem = find.text('طرد').last;
    await tester.tap(unitItem);
    await tester.pumpAndSettle();

    // 6. Toggle Handling Chip: 'تحتاج تغطية'
    final coveringChip = find.text(AppStrings.handlingCovering);
    await tester.ensureVisible(coveringChip);
    await tester.tap(coveringChip);
    await tester.pumpAndSettle();

    // 7. Add Sample Photo
    final samplePhotoChip = find.text(AppStrings.cargoSamplePort);
    await tester.ensureVisible(samplePhotoChip);
    await tester.tap(samplePhotoChip);
    await tester.pumpAndSettle();

    // 8. Add Sample Doc
    final sampleDocChip = find.text(AppStrings.cargoSampleWaybill);
    await tester.ensureVisible(sampleDocChip);
    await tester.tap(sampleDocChip);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.cargoSampleWaybill), findsWidgets);

    // 9. Submit Form
    final saveButton = find.text(AppStrings.saveCargoButton);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify Cargo was created and received
    expect(submittedCargo, isNotNull);
    expect(submittedCargo!.name, equals('شحنة حديد مجلفن'));
    expect(submittedCargo!.category, equals('مواد بناء'));
    expect(submittedCargo!.weight, equals('12.5 طن'));
    expect(submittedCargo!.quantity, equals('45 طرد'));
    expect(submittedCargo!.handlingRequirement, contains(AppStrings.handlingCovering));
    expect(submittedCargo!.isSpecialHandling, isTrue);
    expect(submittedCargo!.imageAsset, equals('assets/images/hamula_port_cargo.jpg'));
  });

  testWidgets('MerchantCreateCargoScreen reveals and validates custom unit when "أخرى" is selected',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      wrapWidget(
        const MerchantCreateCargoScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Select "أخرى" from Unit dropdown
    final qtyUnitDropdown = find.widgetWithText(DropdownButtonFormField<String>, AppStrings.unitHint);
    await tester.tap(qtyUnitDropdown);
    await tester.pumpAndSettle();
    final customUnitOption = find.text('أخرى').last;
    await tester.tap(customUnitOption);
    await tester.pumpAndSettle();

    // The custom unit text field should now be visible
    final customUnitField = find.widgetWithText(TextFormField, AppStrings.customUnitHint);
    expect(customUnitField, findsOneWidget);

    // Submit without filling custom unit
    final saveButton = find.text(AppStrings.saveCargoButton);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Custom unit required error should appear
    expect(find.text(AppStrings.customUnitRequiredError), findsOneWidget);
  });
}
