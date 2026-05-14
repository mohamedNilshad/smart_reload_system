
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/presentation/screens/splash.screen.dart';
import 'package:smart_reload_system/src/core/presentation/screens/unknown.screen.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/features/Settings/presentation/screens/default_settings.screen.dart';
import 'package:smart_reload_system/src/features/home/presentation/screens/home.screen.dart';
import 'package:smart_reload_system/src/features/Settings/presentation/screens/settings.screen.dart';
import 'package:smart_reload_system/src/features/login/presentation/screens/login_client.screen.dart';
import 'package:smart_reload_system/src/features/login/presentation/screens/login_vendor.screen.dart';
import 'package:smart_reload_system/src/features/register/presentation/screens/register_client.screen.dart';
import 'package:smart_reload_system/src/features/register/presentation/screens/register_vendor.screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    debugPrint("Navigating to ${settings.name}");
    switch (settings.name) {
      case RouteConstants.splashScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.splashScreen),
          builder: (context) => const SplashScreen(),
        );

      case RouteConstants.homeScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.homeScreen),
          builder: (context) => const HomeScreen(),
        );


      case RouteConstants.loginClientScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.loginClientScreen),
          builder: (context) => LoginClientScreen(),
        );

      case RouteConstants.loginVendorScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.loginVendorScreen),
          builder: (context) => LoginVendorScreen(),
        );


      case RouteConstants.registerVendorScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.registerVendorScreen),
          builder: (context) => RegisterVendorScreen(),
        );


      case RouteConstants.registerClientScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.registerClientScreen),
          builder: (context) => RegisterClientScreen(),
        );


      case RouteConstants.settingsScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.settingsScreen),
          builder: (context) => const SettingsScreen(),
        );

      case RouteConstants.defaultSettingsScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.defaultSettingsScreen),
          builder: (context) => const DefaultSettingsScreen(),
        );
    }

    assert(false, 'Need to implement ${settings.name}');
    return MaterialPageRoute(builder: (_) => const UnknownScreen());
  }
}

class MenuSlideUpRoute<T> extends MaterialPageRoute<T> {
  MenuSlideUpRoute(
      {required super.builder, required RouteSettings super.settings});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
