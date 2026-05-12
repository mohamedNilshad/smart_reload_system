
import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/features/home/data/models/code_history.dart';
import 'package:smart_reload_system/src/features/home/domain/repositories/history.repository.dart';

class FetchHistory extends UseCase<List<CodeHistory>, NoParams> {
  final HistoryRepository repository;

  FetchHistory(this.repository);

  @override
  Future<Either<Failure, List<CodeHistory>>> call(NoParams params){
    return repository.fetchHistory();
  }

}
