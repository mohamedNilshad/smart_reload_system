
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/presentation/screens/main.client.screen.dart';
import 'package:smart_reload_system/src/core/presentation/screens/main.vendor.screen.dart';
import 'package:smart_reload_system/src/core/presentation/screens/splash.screen.dart';
import 'package:smart_reload_system/src/core/presentation/screens/unknown.screen.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/screens/verify_email.screen.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/vendor.model.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/connection_details.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/package_details.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/reload_history.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/widgets/add_new_connection.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/notification/presentation/screens/notifications.client.screen.dart';
import 'package:smart_reload_system/src/core/features/profile/presentation/screens/edit_profile.screen.dart';
import 'package:smart_reload_system/src/core/features/profile/presentation/screens/profile.screen.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/connection.client.screen.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/screens/login.screen.dart';
import 'package:smart_reload_system/src/core/features/profile/presentation/screens/reset_password.screen.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/screens/register_client.screen.dart';


class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    debugPrint("Navigating to ${settings.name}");
    switch (settings.name) {
      case RouteConstants.splashScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.splashScreen),
          builder: (context) => const SplashScreen(),
        );

      case RouteConstants.loginScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.loginScreen),
          builder: (context) => LoginScreen(),
        );

      case RouteConstants.forgotPasswordScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.forgotPasswordScreen),
          builder: (context) => ForgotPasswordScreen(),
        );

      case RouteConstants.registerClientScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.registerClientScreen),
          builder: (context) => RegisterClientScreen(),
        );

      ///CLIENT
      case RouteConstants.mainClientScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.mainClientScreen),
          builder: (context) => const MainClientScreen(),
        );

      case RouteConstants.connectionClientScreen:

        final VendorModel vendor = settings.arguments as VendorModel;

        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.connectionClientScreen),
          builder: (context) => ConnectionClientScreen(vendor: vendor),
        );

      case RouteConstants.addNewConnectionClientScreen:

        final args = settings.arguments as ({
          String clientVendorId,
          List<Map<String, String>> connectionNumbers,
        });

        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.addNewConnectionClientScreen),
          builder: (context) => AddNewConnectionClientScreen(clientVendorId: args.clientVendorId, connectionNumbers: args.connectionNumbers),
        );

      case RouteConstants.connectionDetailsClientScreen:

        final args = settings.arguments as ({
          ConnectionModel connectionModel,
          String vendorId,
        });

        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.connectionDetailsClientScreen),
          builder: (context) => ConnectionDetailsClientScreen(connectionModel: args.connectionModel, vendorId: args.vendorId),
        );

      case RouteConstants.packageDetailsClientScreen:

        // final connectionModel = settings.arguments as ConnectionModel;

        final args = settings.arguments as ({
          ConnectionModel connectionModel,
          String vendorId,
        });

        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.packageDetailsClientScreen),
          builder: (context) => PackageDetailsClientScreen(connectionModel: args.connectionModel, vendorId: args.vendorId),
        );

      case RouteConstants.reloadHistoryClientScreen:

        final args = settings.arguments as ({
          List<PackageRequestModel> packageList,
          ConnectionModel connection,
          bool isMobile,
        });

        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.reloadHistoryClientScreen),
          builder: (context) => ReloadHistoryClientScreen(packageList: args.packageList, connection: args.connection, isMobile: args.isMobile),
        );

      case RouteConstants.settingsScreen:
        final bool isDark = settings.arguments as bool;
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.settingsScreen),
          builder: (context) => ProfileScreen(isDark: isDark),
        );

      case RouteConstants.notificationClientScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.notificationClientScreen),
          builder: (context) => const NotificationScreen(),
        );

      case RouteConstants.editProfileScreen:
        final bool isDark = settings.arguments as bool;
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.editProfileScreen),
          builder: (context) => EditProfileScreen(isDark: isDark),
        );

      case RouteConstants.resetPasswordScreen:
        final bool isDark = settings.arguments as bool;

        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.resetPasswordScreen),
          builder: (context) => ResetPasswordScreen(isDark: isDark),
        );

      ///VENDOR
      case RouteConstants.mainVendorScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.mainVendorScreen),
          builder: (context) => const MainVendorScreen(),
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
