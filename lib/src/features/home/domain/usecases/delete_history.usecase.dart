
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/features/home/domain/repositories/history.repository.dart';

class DeleteHistory extends UseCase<bool, Params> {
  final HistoryRepository repository;

  DeleteHistory(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    return await repository.deleteHistory(params.historyId);
  }

}
class Params extends Equatable {
  final int historyId;

  const Params({required this.historyId});

  @override
  List<Object?> get props => [historyId];
}
