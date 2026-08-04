import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.bloc.dart';
import 'package:smart_reload_system/src/core/data/datasource/payment.remote_datasource.dart';
import 'package:smart_reload_system/src/core/data/repository/payment.repo_impl.dart';
import 'package:smart_reload_system/src/core/domain/repositories/payment.repo.dart';
import 'package:smart_reload_system/src/core/domain/usecases/start_payment.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/data/datasource/auth.local_datasource.dart';
import 'package:smart_reload_system/src/feature/client/auth/data/datasource/auth.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/auth/data/repositories/auth.repo_impl.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/repository/auth.repo.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/get_cached_user.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/login.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/logout.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/register.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/watch_auth_state.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.bloc.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/session.cubit.dart';
import 'package:smart_reload_system/src/feature/client/home/data/datasource/home.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/home/data/repository/home.repo_impl.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/repository/home.repo.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_banner_news.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_connections.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_vendors.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/request_package.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/connection/connection.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/home/home.bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/presentation/bloc/package_request/package_request.bloc.dart';


final sl = GetIt.instance;

Future<void> init() async{
  /// External
  sl.registerLazySingleton(() => fb.FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  /// Data source
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()));
  sl.registerLazySingleton<PaymentRemoteDataSource>(() => PaymentRemoteDataSourceImpl());
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()));

  /// Repository
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(remoteDataSource: sl(), localDataSource: sl()));
  sl.registerLazySingleton<HomeRepo>(() => HomeRepoImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<PaymentRepo>(() => PaymentRepoImpl(sl()));

  /// Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => WatchAuthStateUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetBannerNewsUseCase(sl()));
  sl.registerLazySingleton(() => GetVendorsUseCase(sl()));
  sl.registerLazySingleton(() => GetConnectionsUseCase(sl()));
  sl.registerLazySingleton(() => StartPaymentUseCase(sl()));
  sl.registerLazySingleton(() => RequestPackageUseCase(sl()));

  /// Bloc
  sl.registerLazySingleton(() => AuthBloc(loginUseCase: sl(), registerUseCase: sl(), logoutUseCase: sl()));
  sl.registerLazySingleton(() => SessionCubit(watchAuthStateUseCase: sl(), getCachedUserUseCase: sl()));
  sl.registerLazySingleton(() => HomeBloc(getBannerNewsUseCase: sl(), getVendorsUseCase: sl()));
  sl.registerLazySingleton(() => ConnectionBloc(getConnectionsUseCase: sl()));
  sl.registerLazySingleton(() => PackageRequestBloc(requestPackageUseCase: sl()));
  sl.registerLazySingleton(() => PaymentBloc(startPaymentUseCase: sl()));
}
