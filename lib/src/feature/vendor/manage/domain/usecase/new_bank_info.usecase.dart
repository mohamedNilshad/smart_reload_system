import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/data/model/bank_details.vendor.model.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/domain/repository/manage.repo.dart';

class NewBankInfoUseCase {
  final ManageRepo repo;

  NewBankInfoUseCase(this.repo);

  Future<Either<Failure, BankDetailsModel>> call({required BankDetailsModel bankDetails}) {
    return repo.addNewBankInfo(bankDetails: bankDetails);
  }
}
