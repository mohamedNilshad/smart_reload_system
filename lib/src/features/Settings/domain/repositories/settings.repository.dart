
import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/features/Settings/data/models/settings.model.dart';

abstract class SettingsRepository {
  Future<Either<Failure, Settings>> fetchSettings();
  Future<Either<Failure, bool>> updateSettings(Settings settings, bool isUpdate);
}
