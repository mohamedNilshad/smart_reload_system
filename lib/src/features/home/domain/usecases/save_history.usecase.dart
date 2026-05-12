
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/features/home/data/models/code_history.dart';
import 'package:smart_reload_system/src/features/home/domain/repositories/history.repository.dart';


class SaveHistory extends UseCase<bool, Params> {
  final HistoryRepository repository;

  SaveHistory(this.repository);

  @override

  Future<Either<Failure, bool>> call(Params params) async {
    return await repository.saveHistory(params.history);
  }

}
class Params extends Equatable {
  final CodeHistory history;

  const Params({
    required this.history,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [history];

}
