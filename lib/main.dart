import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/app.dart';
import 'package:smart_reload_system/src/injection_container.dart' as di;
import 'package:firebase_core/firebase_core.dart';

void main()  {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await di.init();
    await Firebase.initializeApp();
    debugPrint("Firebase Connected!");
    runApp(App(theme: ThemeMode.light));
  }, (error, stack) =>
      print(error));
  // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

