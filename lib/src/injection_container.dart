import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:get_it/get_it.dart';
import 'package:smart_reload_system/src/feature/client/auth/data/datasource/auth.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/auth/data/repositories/auth.repo_impl.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/repository/auth.repo.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/login.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/register.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.bloc.dart';


final sl = GetIt.instance;

Future<void> init() async{
  /// External
  sl.registerLazySingleton(() => fb.FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  /// Data source
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  /// Repository
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl()));

  /// Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  /// Bloc
  sl.registerLazySingleton(() => AuthBloc(loginUseCase: sl(), registerUseCase: sl()));

}