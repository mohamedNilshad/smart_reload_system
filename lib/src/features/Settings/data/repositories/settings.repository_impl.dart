
import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/domain/repositories/database_helper.repository.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/features/Settings/data/models/settings.model.dart';
import 'package:smart_reload_system/src/features/Settings/domain/repositories/settings.repository.dart';
import 'package:smart_reload_system/src/injection_container.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final DatabaseHelperRepository databaseHelper = sl<DatabaseHelperRepository>();
  // final JokeRemoteDataSource remoteDataSource;

  // HistoryRepositoryImpl(this.remoteDataSource);

  ///Fetch Settings
  @override
  Future<Either<Failure, Settings>> fetchSettings() async {
    try {
      final db = await databaseHelper.database;

      final result = await db.query('Code_Settings');
      if (result.isNotEmpty) {
        Settings data = Settings.fromMap(result.first);
        return Right(data);
      }
      return Right(Settings.fromMap({}));
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  ///Save Settings
  @override
  Future<Either<Failure, bool>> updateSettings(Settings settings, bool isUpdate) async {
    try {
      final db = await databaseHelper.database;
      int result;
      if(isUpdate){
        result = await db.update(
          'Code_Settings',
          settings.toMap(),
          where: 'id = ?',
          whereArgs: [settings.id],
        );
      }else{
        result = await db.insert('Code_Settings', settings.toMap());
      }

      return Right(result > 0);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

}


