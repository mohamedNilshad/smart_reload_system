import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/data/model/bank_details.vendor.model.dart';

abstract class ManageRepo {
  Future<Either<Failure, List<BankDetailsModel>>> getVendorBankInfo();
  Future<Either<Failure, BankDetailsModel>> addNewBankInfo({required BankDetailsModel bankDetails});
  Future<Either<Failure, bool>> removeBankInfo({required String bankDetailsId});
}
