
import 'package:flutter/material.dart';
import 'package:smart_reload_system/src/core/presentation/screens/main.client.screen.dart';
import 'package:smart_reload_system/src/core/presentation/screens/splash.screen.dart';
import 'package:smart_reload_system/src/core/presentation/screens/unknown.screen.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/screens/verify_email_client.screen.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/connection.model.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/connection_details.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/widgets/add_new_connection.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/notification/presentation/screens/notifications.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/profile/presentation/screens/edit_profile.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/profile/presentation/screens/profile.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/screens/connection.client.screen.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/screens/login_client.screen.dart';
import 'package:smart_reload_system/src/feature/client/profile/presentation/screens/reset_password.client.screen.dart';
import 'package:smart_reload_system/src/feature/vendor/auth/presentation/screens/login_vendor.screen.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/screens/register_client.screen.dart';
import 'package:smart_reload_system/src/feature/vendor/auth/presentation/screens/register_vendor.screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    debugPrint("Navigating to ${settings.name}");
    switch (settings.name) {
      case RouteConstants.splashScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.splashScreen),
          builder: (context) => const SplashScreen(),
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

      case RouteConstants.forgotPasswordClientScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.forgotPasswordClientScreen),
          builder: (context) => ForgotPasswordClientScreen(),
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

      ///CLIENT
      case RouteConstants.mainClientScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.mainClientScreen),
          builder: (context) => const MainClientScreen(),
        );

      case RouteConstants.connectionClientScreen:

        final args = settings.arguments as ({
          String name,
          String clientVendorId,
        });

        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.connectionClientScreen),
          builder: (context) => ConnectionClientScreen(name: args.name, clientVendorId: args.clientVendorId),
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

        final connectionModel = settings.arguments as ConnectionModel;

        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.connectionDetailsClientScreen),
          builder: (context) => ConnectionDetailsClientScreen(connectionModel: connectionModel),
        );

      case RouteConstants.settingsScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.settingsScreen),
          builder: (context) => const ProfileScreen(),
        );

      case RouteConstants.notificationClientScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.notificationClientScreen),
          builder: (context) => const NotificationScreen(),
        );

      case RouteConstants.editProfileClientScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.editProfileClientScreen),
          builder: (context) => const EditProfileClientScreen(),
        );

      case RouteConstants.resetPasswordClientScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteConstants.resetPasswordClientScreen),
          builder: (context) => const ResetPasswordClientScreen(),
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
