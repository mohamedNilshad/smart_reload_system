
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.bloc.dart';
import 'package:smart_reload_system/src/core/bloc/theme/theme.bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/router/route.dart';
import 'package:smart_reload_system/src/core/theme/theme.dart';
import 'package:smart_reload_system/src/core/utils/helpers/navigator_key.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.bloc.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/home/home.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package_request/package_request.bloc.dart';
import 'package:smart_reload_system/src/feature/client/notification/presentation/bloc/notification.bloc.dart';
import 'package:smart_reload_system/src/feature/client/notification/presentation/bloc/unread_count.cubit.dart';
import 'package:smart_reload_system/src/feature/client/profile/presentation/bloc/profile.bloc.dart';
import 'package:smart_reload_system/src/injection_container.dart';

class App extends StatelessWidget {
  final ThemeMode theme;
  const App({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeBloc(theme)),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<SessionCubit>()),
        BlocProvider(create: (_) => sl<HomeBloc>()),
        BlocProvider(create: (_) => sl<ConnectionBloc>()),
        BlocProvider(create: (_) => sl<PaymentBloc>()),
        BlocProvider(create: (_) => sl<PackageRequestBloc>()),
        BlocProvider(create: (_) => sl<NotificationBloc>()),
        BlocProvider(create: (_) => sl<UnreadCountCubit>()),
        BlocProvider(create: (_) => sl<ProfileBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, state) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: AppStrings.brandName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              //themeMode: state,
              themeMode: ThemeMode.light,
              initialRoute: RouteConstants.splashScreen,
              onGenerateRoute: AppRouter.onGenerateRoute,
            );
          }
      ),
    );
  }
}