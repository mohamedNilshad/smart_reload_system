import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/features/Settings/data/models/settings.model.dart';
import 'package:smart_reload_system/src/features/Settings/domain/usecases/fetch_settings.usecase.dart' as fetch_settings;
import 'package:smart_reload_system/src/features/Settings/domain/usecases/update_settings.usecase.dart' as update_settings;
import 'package:smart_reload_system/src/injection_container.dart';

part 'settings.event.dart';
part 'settings.state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState>{

  final fetch_settings.FetchSettings _fetchSettings= sl<fetch_settings.FetchSettings>();
  final update_settings.UpdateSettings _updateSettings= sl<update_settings.UpdateSettings>();

  Settings? _settings;

  Settings? get settings => _settings;

  SettingsBloc() : super(InitialSettingsState()){
    on<FetchSettingsEvent>((event, emit)async => _fetchDefaultSettings(emit));
    on<UpdateSettingsEvent>((event, emit)async => _updateDefaultSettings(emit, event));

  }

  ///Fetch Data
  Future _fetchDefaultSettings(Emitter<SettingsState> emit)async{
    emit(LoadingSettingsState(isFetch: true));
    Either<Failure, Settings> result = await _fetchSettings(NoParams());
    return result.fold((l) {
      emit(ErrorSettingsState(error: l.toString()));
      return;
    }, (Settings s) {
      _settings = s;
      emit(LoadedSettingsState(s));
    });
  }

  ///Update Data
  Future _updateDefaultSettings(Emitter<SettingsState> emit, UpdateSettingsEvent event)async{
    emit(LoadingSettingsState(isSave: true));
    Either<Failure, bool> result = await _updateSettings(update_settings.Params(settings: event.settings, isUpdate: event.isUpdate));
    return result.fold((l) {
      emit(ErrorSettingsState(error: l.toString()));
      return;
    }, (bool s) {
      emit(SuccessSettingsState(success: s));
    });
  }


}