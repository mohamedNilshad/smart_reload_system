
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/bloc/theme/theme.bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/router/route.dart';
import 'package:smart_reload_system/src/core/theme/theme.dart';
import 'package:smart_reload_system/src/core/utils/helpers/navigator_key.dart';
import 'package:smart_reload_system/src/features/Settings/presentation/bloc/settings.bloc.dart';
import 'package:smart_reload_system/src/features/home/presentation/bloc/history.bloc.dart';

class App extends StatelessWidget {
  final ThemeMode theme;
  const App({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    // return MultiBlocProvider(
    //   providers: [
    //     BlocProvider(create: (_) => ThemeBloc(theme)),
    //     BlocProvider(create: (_) => HistoryBloc()),
    //     BlocProvider(create: (_) => SettingsBloc()),
    //   ],
    //   child: BlocBuilder<ThemeBloc, ThemeMode>(
    //       builder: (context, state) {
    //         return MaterialApp(
    //           title: 'QR Vault',
    //           debugShowCheckedModeBanner: false,
    //           theme: AppTheme.lightTheme,
    //           darkTheme: AppTheme.darkTheme,
    //           themeMode: state,
    //           initialRoute: RouteConstants.splashScreen,
    //           onGenerateRoute: AppRouter.onGenerateRoute,
    //         );
    //       }
    //   ),
    // );

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: AppStrings.brandName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: RouteConstants.splashScreen,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}