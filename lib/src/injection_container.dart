import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.bloc.dart';
import 'package:smart_reload_system/src/core/constants/constant.dart';
import 'package:smart_reload_system/src/core/data/datasource/payment.remote_datasource.dart';
import 'package:smart_reload_system/src/core/data/repository/payment.repo_impl.dart';
import 'package:smart_reload_system/src/core/domain/repositories/payment.repo.dart';
import 'package:smart_reload_system/src/core/domain/usecases/start_payment.usecase.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/usecase/clear_cached_user.usecase.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/usecase/update_cached_user.usecase.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/usecase/update_user_realtime.usecase.dart';
import 'package:smart_reload_system/src/core/services/notification.service.dart';
import 'package:smart_reload_system/src/core/features/auth/data/datasource/auth.local_datasource.dart';
import 'package:smart_reload_system/src/core/features/auth/data/datasource/auth.remote_datasource.dart';
import 'package:smart_reload_system/src/core/features/auth/data/repositories/auth.repo_impl.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/repository/auth.repo.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/usecase/get_cached_user.usecase.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/usecase/login.usecase.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/usecase/logout.usecase.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/usecase/reauthenticate.usecase.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/usecase/register.usecase.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/usecase/verify_email.usecase.dart';
import 'package:smart_reload_system/src/core/features/auth/domain/usecase/watch_user_realtime.usecase.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/auth.bloc.dart';
import 'package:smart_reload_system/src/core/features/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/feature/client/home/data/datasource/home.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/home/data/repository/home.repo_impl.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/repository/home.repo.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/add_new_connection.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_activated_packages.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_banner_news.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_connections.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_packages.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_vendors.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/request_package.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/home/home.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package/packaget.bloc.dart';
import 'package:smart_reload_system/src/core/features/notification/data/datasource/notification.remote_datasource.dart';
import 'package:smart_reload_system/src/core/features/notification/data/repository/notification.repo_impl.dart';
import 'package:smart_reload_system/src/core/features/notification/domain/repository/notification.repo.dart';
import 'package:smart_reload_system/src/core/features/notification/domain/usecase/get_notifications.usecase.dart';
import 'package:smart_reload_system/src/core/features/notification/domain/usecase/mark_all_as_read.usecase.dart';
import 'package:smart_reload_system/src/core/features/notification/domain/usecase/mark_as_read.usecase.dart';
import 'package:smart_reload_system/src/core/features/notification/domain/usecase/watch_unread_count.usecase.dart';
import 'package:smart_reload_system/src/core/features/notification/presentation/bloc/notification.bloc.dart';
import 'package:smart_reload_system/src/core/features/notification/presentation/bloc/unread_count.cubit.dart';
import 'package:smart_reload_system/src/feature/client/payment/data/datasource/payment.client.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/payment/data/repository/payment.client.repo_impl.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/repository/payment.client.repo.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/usecase/create_payment.usecase.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/usecase/get_paid_invoices.usecase.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/usecase/get_payable_details.usecase.dart';
import 'package:smart_reload_system/src/core/features/profile/data/datasource/profile.remote_datasource.dart';
import 'package:smart_reload_system/src/core/features/profile/data/repository/profile.repo_impl.dart';
import 'package:smart_reload_system/src/core/features/profile/domain/repository/profile.repo.dart';
import 'package:smart_reload_system/src/core/features/profile/domain/usecase/update_password.usecase.dart';
import 'package:smart_reload_system/src/core/features/profile/domain/usecase/update_profile.usecase.dart';
import 'package:smart_reload_system/src/core/features/profile/presentation/bloc/profile.bloc.dart';

import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/home/data/datasource/home.remote_datasource.vendor.dart';
import 'package:smart_reload_system/src/feature/vendor/home/data/repository/home.repo_impl.vendor.dart';
import 'package:smart_reload_system/src/feature/vendor/home/domain/repository/home.repo.vendor.dart';
import 'package:smart_reload_system/src/feature/vendor/home/domain/usecase/activate_package_request.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/home/domain/usecase/get_clients.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/home/domain/usecase/watch_package_requests.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/home/home.vendor.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/home/package_request.cubit.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/data/datasource/manage.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/data/repository/manage.repo_impl.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/domain/repository/manage.repo.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/domain/usecase/new_bank_info.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/domain/usecase/get_vendor_bank_info.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/domain/usecase/remove_bank_info.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/presentation/bloc/bank/bank.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/data/datasource/wallet.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/data/repository/wallet.repo_impl.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/repository/wallet.repo.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/usecase/add_com_withdrawal.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/usecase/get_com_withdrew_history.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/usecase/get_wallet_summary.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/com_history/com_history.bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/presentation/bloc/wallet/wallet.bloc.dart';

import 'package:smart_reload_system/src/feature/vendor/home/presentation/bloc/package/packaget.bloc.dart'
    as vendor;

final sl = GetIt.instance;

Future<void> init() async {
  /// External
  sl.registerLazySingleton(() => fb.FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  // sl.registerLazySingleton(() => FirebaseDatabase.instance);
  sl.registerLazySingleton<FirebaseDatabase>(
    () => FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: dbURL),
  );
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => NotificationService());

  /// Data source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      database: sl(),
    ),
  );
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      database: sl(),
    ),
  );
  sl.registerLazySingleton<ManageRemoteDataSource>(
    () => ManageRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
  sl.registerLazySingleton<PaymentClientRemoteDataSource>(
    () =>
        PaymentClientRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );

  /// Repository
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRepo>(
    () => HomeRepoImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ManageRepo>(
    () => ManageRepoImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PaymentRepo>(() => PaymentRepoImpl(sl()));
  sl.registerLazySingleton<NotificationRepo>(() => NotificationRepoImpl(sl()));
  sl.registerLazySingleton<ProfileRepo>(
    () => ProfileRepoImpl(remoteDataSource: sl(), remoteAuthDataSource: sl()),
  );
  sl.registerLazySingleton<PaymentClientRepo>(
    () => PaymentClientRepoImpl(remoteDataSource: sl()),
  );

  /// Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => WatchUserRealtimeUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserRealtimeUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCachedUserUseCase(sl()));
  sl.registerLazySingleton(() => ClearCachedUserUseCase(sl()));
  sl.registerLazySingleton(() => ReauthenticateUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetBannerNewsUseCase(sl()));
  sl.registerLazySingleton(() => GetVendorsUseCase(sl()));
  sl.registerLazySingleton(() => GetConnectionsUseCase(sl()));
  sl.registerLazySingleton(() => StartPaymentUseCase(sl()));
  sl.registerLazySingleton(() => RequestPackageUseCase(sl()));
  sl.registerLazySingleton(() => GetPackagesUseCase(sl()));
  sl.registerLazySingleton(() => GetActivatedPackagesUseCase(sl()));
  sl.registerLazySingleton(() => WatchUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllAsReadUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => AddNewConnectionUseCase(sl()));
  sl.registerLazySingleton(() => GetVendorBankInfoUseCase(sl()));
  sl.registerLazySingleton(() => NewBankInfoUseCase(sl()));
  sl.registerLazySingleton(() => GetPayableDetailsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetPaidInvoicesUsecase(sl()));

  /// Bloc
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      reauthenticateUseCase: sl(),
      verifyEmailUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => SessionCubit(
      watchUserRealtimeUseCase: sl(),
      getCachedUserUseCase: sl(),
      firebaseAuth: sl(),
      logoutUseCase: sl(),
      updateCachedUserUseCase: sl(),
      clearCachedUserUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => HomeBloc(getBannerNewsUseCase: sl(), getVendorsUseCase: sl()),
  );
  sl.registerLazySingleton(
    () => ConnectionBloc(
      getConnectionsUseCase: sl(),
      addNewConnectionUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => PackageBloc(
      requestPackageUseCase: sl(),
      getPackageUseCase: sl(),
      getActivatedPackagesUseCase: sl(),
      activatePackageRequestUseCase: sl(),
      cancelPackageRequestUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => PaymentBloc(startPaymentUseCase: sl()));
  sl.registerLazySingleton(
    () => PaymentClientBloc(
      getPayableDetailsUseCase: sl(),
      createPaymentUseCase: sl(),
      getPaidInvoicesUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => UnreadCountCubit(watchUnreadCountUseCase: sl(), firebaseAuth: sl()),
  );
  sl.registerLazySingleton(
    () => NotificationBloc(
      getNotificationsUseCase: sl(),
      markAsReadUseCase: sl(),
      markAllAsReadUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => ProfileBloc(updateProfileUseCase: sl(), updatePasswordUseCase: sl()),
  );
  sl.registerLazySingleton(
    () => BankBloc(
      getVendorBankInfoUseCase: sl(),
      newBankInfoUseCase: sl(),
      removeBankInfoUseCase: sl()
    ),
  );

  ///VENDORS
  //BLOC
  sl.registerLazySingleton(
    () => HomeVendorBloc(getBannerNewsUseCase: sl(), getClientsUseCase: sl()),
  );

  sl.registerLazySingleton(
    () => PackageRequestCubit(watchPackageRequestsUseCase: sl()),
  );

  sl.registerLazySingleton(() => WalletBloc(getWalletSummaryUseCase: sl(), addWithdrawalUseCase: sl()));
  sl.registerLazySingleton(() => ComHistoryBloc(getHistoryUseCase: sl()));


  sl.registerLazySingleton(
    () => vendor.PackageBloc(
      requestPackageUseCase: sl(),
      getPackageUseCase: sl(),
      getActivatedPackagesUseCase: sl(),
      activatePackageRequestUseCase: sl(),
      cancelPackageRequestUseCase: sl(),
    ),
  );

  //USECASE
  sl.registerLazySingleton(() => GetClientsUseCase(sl()));
  sl.registerLazySingleton(() => WatchPackageRequestsUseCase(sl()));
  sl.registerLazySingleton(() => ActivatePackageRequestUseCase(sl()));
  sl.registerLazySingleton(() => CancelPackageRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetWalletSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetComWithdrawHistoryUseCase(sl()));
  sl.registerLazySingleton(() => AddComWithdrawalUseCase(sl()));
  sl.registerLazySingleton(() => RemoveBankInfoUseCase(sl()));

  //Repository
  sl.registerLazySingleton<HomeRepoV>(
    () => HomeRepoVImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<WalletRepo>(
    () => WalletRepoImpl(remoteDataSource: sl()),
  );


  //Datasource
  sl.registerLazySingleton<HomeRemoteDataSourceV>(
    () => HomeRemoteDataSourceVImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      database: sl(),
    ),
  );
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
}
