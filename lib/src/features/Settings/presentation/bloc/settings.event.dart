
part of 'settings.bloc.dart';

abstract class SettingsEvent{}

class FetchSettingsEvent extends SettingsEvent{}

class UpdateSettingsEvent extends SettingsEvent{
  Settings settings;
  bool isUpdate;
  UpdateSettingsEvent({required this.settings, this.isUpdate = true});
}
