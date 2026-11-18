import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/app.dart';
import 'package:smart_reload_system/src/core/services/notification.service.dart';
import 'package:smart_reload_system/src/injection_container.dart' as di;
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_reload_system/src/core/error/error_logger.dart';


void main()  {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await di.init();
    await Firebase.initializeApp();
    debugPrint("Firebase Connected!");

    final notificationService = di.sl<NotificationService>();
    notificationService.onNotificationTap = (message) {
      // e.g. use your router to navigate based on message.data
      final route = message.data['route'];
      if (route != null) {
        // AppRouter.navigatorKey.currentState?.pushNamed(route);
      }
    };
    await notificationService.initialize();

    await FirebaseAppCheck.instance.activate(
      providerAndroid: kReleaseMode ? const AndroidPlayIntegrityProvider() : const AndroidDebugProvider(debugToken: "66913490-5f52-4042-bb93-470d2152cf4a"),
      providerApple: kReleaseMode ? const AppleAppAttestProvider() : const AppleDebugProvider(debugToken: "66913490-5f52-4042-bb93-470d2152cf4a"),
    );

    runApp(App(theme: ThemeMode.light));
  }, (e, st) =>
      ErrorLogger.log(
        e,
        location: 'HomeRemoteDataSourceImpl.requestPackage',
        stackTrace: st,
      )
  );
  // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}



