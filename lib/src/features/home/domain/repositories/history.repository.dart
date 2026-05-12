
import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/features/home/data/models/code_history.dart';

abstract class HistoryRepository {
  Future<Either<Failure, bool>> updateHistory(CodeHistory history);
  Future<Either<Failure, bool>> saveHistory(CodeHistory history);
  Future<Either<Failure, bool>> deleteHistory(int historyId);
  Future<Either<Failure, bool>> renameHistory(int id, String newName);
  Future<Either<Failure, List<CodeHistory>>> fetchHistory();

}
