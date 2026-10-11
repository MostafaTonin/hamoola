import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/core/widgets/widgets.dart';

Widget _wrapTestWidget(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('ar'),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('HamulaButton Tests', () {
    testWidgets('renders button with label and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrapTestWidget(
        HamulaButton(
          label: 'متابعة',
          onPressed: () => tapped = true,
        ),
      ));

      expect(find.text('متابعة'), findsOneWidget);
      await tester.tap(find.text('متابعة'));
      expect(tapped, isTrue);
    });

    testWidgets('disabled button does not trigger callback', (tester) async {
      await tester.pumpWidget(_wrapTestWidget(
        const HamulaButton(
          label: 'معطل',
          onPressed: null,
        ),
      ));

      expect(find.text('معطل'), findsOneWidget);
      await tester.tap(find.text('معطل'));
      // No crash, button is disabled
    });

    testWidgets('loading state renders progress indicator and hides text', (tester) async {
      await tester.pumpWidget(_wrapTestWidget(
        HamulaButton(
          label: 'تحميل',
          isLoading: true,
          onPressed: () {},
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('تحميل'), findsNothing);
    });
  });

  group('HamulaCard Tests', () {
    testWidgets('renders card content and handles tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrapTestWidget(
        HamulaCard(
          onTap: () => tapped = true,
          child: const Text('بطاقة اختبار'),
        ),
      ));

      expect(find.text('بطاقة اختبار'), findsOneWidget);
      await tester.tap(find.text('بطاقة اختبار'));
      expect(tapped, isTrue);
    });
  });

  group('HamulaTextField Tests', () {
    testWidgets('renders label, hint, and accepts text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_wrapTestWidget(
        HamulaTextField(
          label: 'رقم الهاتف',
          hint: 'أدخل الرقم',
          controller: controller,
        ),
      ));

      expect(find.text('رقم الهاتف'), findsOneWidget);
      expect(find.text('أدخل الرقم'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '770000000');
      expect(controller.text, '770000000');
    });

    testWidgets('renders error text when provided', (tester) async {
      await tester.pumpWidget(_wrapTestWidget(
        const HamulaTextField(
          label: 'الاسم',
          errorText: 'الحقل مطلوب',
        ),
      ));

      expect(find.text('الحقل مطلوب'), findsOneWidget);
    });
  });

  group('StatusBadge Tests', () {
    testWidgets('renders status badge with correct label and icon', (tester) async {
      await tester.pumpWidget(_wrapTestWidget(
        const StatusBadge(
          label: 'مكتمل',
          type: StatusBadgeType.success,
          icon: Icon(Icons.check, size: 12),
        ),
      ));

      expect(find.text('مكتمل'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('HamulaAppBar Tests', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          appBar: HamulaAppBar(
            title: 'حمولاتي',
            subtitle: 'إدارة الشحنات النشطة',
          ),
        ),
      ));

      expect(find.text('حمولاتي'), findsOneWidget);
      expect(find.text('إدارة الشحنات النشطة'), findsOneWidget);
    });
  });
}
