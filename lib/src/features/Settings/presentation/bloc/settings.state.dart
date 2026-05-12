part of 'settings.bloc.dart';

abstract class SettingsState {}

class InitialSettingsState extends SettingsState {}

class LoadingSettingsState extends SettingsState {
  final bool isFetch;
  final bool isSave;
  LoadingSettingsState({this.isFetch = false, this.isSave = false});
}

class LoadedSettingsState extends SettingsState {
  final Settings settings;
  LoadedSettingsState(this.settings);
}

class SuccessSettingsState extends SettingsState {
  final bool success;
  SuccessSettingsState({this.success = true});
}

class ErrorSettingsState extends SettingsState {
  final String error;
  ErrorSettingsState({required this.error});
}
