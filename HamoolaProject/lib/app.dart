import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root Application Widget for Hamoola with lifecycle management
class HamulaApp extends StatefulWidget {
  const HamulaApp({super.key});

  @override
  State<HamulaApp> createState() => _HamulaAppState();
}

class _HamulaAppState extends State<HamulaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Preserves app state when moving to background or foreground
    if (state == AppLifecycleState.resumed) {
      // Returned from background: do NOT reset navigation or push splash!
      debugPrint('HamulaApp resumed from background - preserving current screen state');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'حمولة — النقل الثقيل',
      debugShowCheckedModeBanner: false,

      // Routing via go_router with persisted route restoration
      routerConfig: appRouter,

      // Design System Themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default light as in prototype

      // Native RTL Arabic Configuration
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
