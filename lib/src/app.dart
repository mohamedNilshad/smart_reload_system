import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.bloc.dart';
import 'package:smart_reload_system/src/core/bloc/theme/theme.bloc.dart';
import 'package:smart_reload_system/src/core/constants/app_strings.dart';
import 'package:smart_reload_system/src/core/presentation/screens/no_internet_banner.widget.dart';
import 'package:smart_reload_system/src/core/router/route.constants.dart';
import 'package:smart_reload_system/src/core/router/route.dart';
import 'package:smart_reload_system/src/core/theme/theme.dart';
import 'package:smart_reload_system/src/core/utils/helpers/navigator_key.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.bloc.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/home/home.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/packaget.bloc.dart';
import 'package:smart_reload_system/src/core/features/notification/presentation/bloc/notification.bloc.dart';
import 'package:smart_reload_system/src/core/features/notification/presentation/bloc/unread_count.cubit.dart';
import 'package:smart_reload_system/src/core/features/profile/presentation/bloc/profile.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/home/home.vendor.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/home/package_request.cubit.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/presentation/bloc/bank/bank.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/com_history/com_history.bloc.dart';
import 'package:smart_reload_system/src/injection_container.dart';

import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/wallet/wallet.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/package/packaget.bloc.dart' as vendor;

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
        BlocProvider(create: (_) => sl<PaymentClientBloc>()),
        BlocProvider(create: (_) => sl<PackageBloc>()),
        BlocProvider(create: (_) => sl<NotificationBloc>()),
        BlocProvider(create: (_) => sl<UnreadCountCubit>()),
        BlocProvider(create: (_) => sl<ProfileBloc>()),

        ///Vendor
        BlocProvider(create: (_) => sl<HomeVendorBloc>()),
        BlocProvider(create: (_) => sl<PackageRequestCubit>()),
        BlocProvider(create: (_) => sl<BankBloc>()),
        BlocProvider(create: (_) => sl<WalletBloc>()),
        BlocProvider(create: (_) => sl<vendor.PackageBloc>()),
        BlocProvider(create: (_) => sl<ComHistoryBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, state) {
          return MaterialApp(
            builder: (context, child) => NoInternetBanner(child: child!),
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
        },
      ),
    );
  }
}
