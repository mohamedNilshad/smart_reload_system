import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/domain/repository/manage.repo.dart';

class RemoveBankInfoUseCase {
  final ManageRepo repo;

  RemoveBankInfoUseCase(this.repo);

  Future<Either<Failure, bool>> call({required String bankDetailsId}) {
    return repo.removeBankInfo(bankDetailsId: bankDetailsId);
  }
}
