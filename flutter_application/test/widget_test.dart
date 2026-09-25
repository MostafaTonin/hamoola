import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/app.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('HamulaApp root smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HamulaApp());
    await tester.pump();
    expect(find.text('حمولة'), findsOneWidget);
  });
}
