
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/features/home/domain/repositories/history.repository.dart';

class RenameHistory extends UseCase<bool, Params> {
  final HistoryRepository repository;

  RenameHistory(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    return await repository.renameHistory(params.id, params.newName);
  }

}
class Params extends Equatable {
  final int id;
  final String newName;
  const Params({required this.id, required this.newName});

  @override
  List<Object?> get props => [id, newName];
}
