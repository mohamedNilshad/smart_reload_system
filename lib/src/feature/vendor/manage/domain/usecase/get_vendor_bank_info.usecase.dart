import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/data/model/bank_details.vendor.model.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/domain/repository/manage.repo.dart';

class GetVendorBankInfoUseCase {
  final ManageRepo repo;

  GetVendorBankInfoUseCase(this.repo);

  Future<Either<Failure, List<BankDetailsModel>>> call() {
    return repo.getVendorBankInfo();
  }
}
