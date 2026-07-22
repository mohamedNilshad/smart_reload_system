import 'package:get_it/get_it.dart';
// import 'package:qr_vault/src/core/bloc/theme/theme.bloc.dart';
// import 'package:qr_vault/src/core/domain/repositories/database_helper.repository.dart';
// import 'package:qr_vault/src/features/profile/data/repositories/profile.repository_impl.dart';
// import 'package:qr_vault/src/features/profile/domain/repositories/profile.repository.dart';
// import 'package:qr_vault/src/features/profile/domain/usecases/fetch_settings.usecase.dart';
// import 'package:qr_vault/src/features/profile/domain/usecases/update_settings.usecase.dart';
// import 'package:qr_vault/src/features/profile/presentation/bloc/profile.bloc.dart';
// import 'package:qr_vault/src/features/home/data/repositories/history.repository_impl.dart';
// import 'package:qr_vault/src/features/home/domain/repositories/history.repository.dart';
// import 'package:qr_vault/src/features/home/domain/usecases/delete_history.usecase.dart';
// import 'package:qr_vault/src/features/home/domain/usecases/fetch_history.usecase.dart';
// import 'package:qr_vault/src/features/home/domain/usecases/rename_history.usecase.dart';
// import 'package:qr_vault/src/features/home/domain/usecases/save_history.usecase.dart';
// import 'package:qr_vault/src/features/home/domain/usecases/update_history.usecase.dart';
// import 'package:qr_vault/src/features/home/presentation/bloc/history.bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async{
  // final sharedPreference = await SharedPreferences.getInstance();
  // sl.registerLazySingleton<SharedPreferences>(() => sharedPreference);
  // sl.registerLazySingleton<ThemeBloc>(()=>ThemeBloc(sl()));
  //
  // ///Bloc
  // sl.registerLazySingleton<HistoryBloc>(()=>HistoryBloc());
  // sl.registerLazySingleton<SettingsBloc>(()=>SettingsBloc());
  //
  //
  // ///UseCase
  // //History
  // sl.registerLazySingleton<SaveHistory>(()=>SaveHistory(sl()));
  // sl.registerLazySingleton<FetchHistory>(()=>FetchHistory(sl()));
  //
  //
  // /// Repository
  // sl.registerLazySingleton(()=> DatabaseHelperRepository());
  // sl.registerLazySingleton<HistoryRepository>(()=>HistoryRepositoryImpl());
  // sl.registerLazySingleton<SettingsRepository>(()=>SettingsRepositoryImpl());

}