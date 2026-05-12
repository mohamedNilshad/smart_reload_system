import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/app.dart';
import 'package:smart_reload_system/src/injection_container.dart' as di;

void main()  {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // ThemeMode initTheme = await getInitialThemeState();
    await di.init();
    runApp(App(theme: ThemeMode.light));
  }, (error, stack) =>
      print(error));
  // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

// Future<ThemeMode> getInitialThemeState() async {
//   final prefs = await SharedPreferences.getInstance();
//   final isDarkMode = prefs.getBool('isDarkMode') ?? false;
//   return isDarkMode ? ThemeMode.dark : ThemeMode.light;
// }

