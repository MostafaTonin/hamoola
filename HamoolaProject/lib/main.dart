import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/storage/app_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Lock orientation strictly to portrait across the entire application
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 2. Set default system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 3. Initialize persistent storage & restore existing session
  await AppPreferences.instance.init();

  runApp(const HamulaApp());
}

