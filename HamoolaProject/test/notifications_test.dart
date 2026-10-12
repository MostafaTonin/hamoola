import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_application/core/constants/app_strings.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/common/domain/models/app_notification.dart';
import 'package:flutter_application/features/common/presentation/screens/notifications_screen.dart';

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

  testWidgets(
      'NotificationsScreen renders title, filter tabs, notification items, and mark all read',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool backTapped = false;
    AppNotification? tappedItem;

    await tester.pumpWidget(
      wrapWidget(
        NotificationsScreen(
          onBack: () => backTapped = true,
          onNotificationTap: (item) => tappedItem = item,
        ),
      ),
    );
    await tester.pump();

    // Verify title and mark all button
    expect(find.text(AppStrings.notificationsTitle), findsOneWidget);
    expect(find.text(AppStrings.markAllAsReadBtn), findsOneWidget);

    // Verify filter tabs
    expect(find.text(AppStrings.notifFilterBids), findsOneWidget);
    expect(find.text(AppStrings.notifFilterTracking), findsOneWidget);
    expect(find.text(AppStrings.notifFilterFinance), findsOneWidget);

    // Verify notifications present
    expect(find.text('عرض سعر جديد على الشحنة REQ-1024'), findsOneWidget);
    expect(find.text('الشاحنة وصلت إلى نقطة التحميل'), findsOneWidget);

    // Verify back action
    await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
    expect(backTapped, isTrue);

    // Tap first notification item
    await tester.tap(find.text('عرض سعر جديد على الشحنة REQ-1024'));
    await tester.pump();

    expect(tappedItem, isNotNull);
    expect(tappedItem?.id, equals('NTF-101'));

    // Tap Mark All as Read
    await tester.tap(find.text(AppStrings.markAllAsReadBtn));
    await tester.pump();

    expect(find.text(AppStrings.allNotificationsReadSuccess), findsOneWidget);
  });

  testWidgets('NotificationsScreen filters notifications by category',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      wrapWidget(
        const NotificationsScreen(),
      ),
    );
    await tester.pump();

    // Tap filter bids
    await tester.tap(find.text(AppStrings.notifFilterBids));
    await tester.pumpAndSettle();

    expect(find.text('عرض سعر جديد على الشحنة REQ-1024'), findsOneWidget);
    expect(find.text('الشاحنة وصلت إلى نقطة التحميل'), findsNothing);
  });
}
