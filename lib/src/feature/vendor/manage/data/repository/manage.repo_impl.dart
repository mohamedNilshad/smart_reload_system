import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/data/datasource/manage.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/data/model/bank_details.vendor.model.dart';
import 'package:smart_reload_system/src/feature/vendor/manage/domain/repository/manage.repo.dart';

class ManageRepoImpl implements ManageRepo {
  final ManageRemoteDataSource remoteDataSource;

  ManageRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BankDetailsModel>>> getVendorBankInfo() async {
    try {
      final items = await remoteDataSource.getVendorBankInfo();
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BankDetailsModel>> addNewBankInfo({required BankDetailsModel bankDetails}) async {
    try {
      final result = await remoteDataSource.addNewBankInfo(bankDetails: bankDetails);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeBankInfo({required String bankDetailsId}) async {
    try {
      final result = await remoteDataSource.removeBankInfo(bankDetailsId: bankDetailsId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
