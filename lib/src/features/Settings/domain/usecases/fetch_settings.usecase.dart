
import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/features/Settings/data/models/settings.model.dart';
import 'package:smart_reload_system/src/features/Settings/domain/repositories/settings.repository.dart';

class FetchSettings extends UseCase<Settings, NoParams> {
  final SettingsRepository repository;

  FetchSettings(this.repository);

  @override
  Future<Either<Failure, Settings>> call(NoParams params){
    return repository.fetchSettings();
  }

}
