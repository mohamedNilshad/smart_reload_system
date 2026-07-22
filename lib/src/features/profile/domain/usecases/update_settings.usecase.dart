
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/features/profile/data/models/settings.model.dart';
import 'package:smart_reload_system/src/features/profile/domain/repositories/settings.repository.dart';

class UpdateSettings extends UseCase<bool, Params> {
  final SettingsRepository repository;

  UpdateSettings(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params){
    return repository.updateSettings(params.settings, params.isUpdate);
  }

}

class Params extends Equatable {
  final Settings settings;
  final bool isUpdate;

  const Params({required this.settings, required this.isUpdate});

  @override
  // TODO: implement props
  List<Object?> get props => [settings];

}
