import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/data/datasource/wallet.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/entity/commission_withdrew_history.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/repository/wallet.repo.dart';

class WalletRepoImpl implements WalletRepo {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, double>> getWalletSummary() async {
    try {
      final summary = await remoteDataSource.getWalletSummary();
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ComWithdrawHistoryEntity>>>
  getHistory() async {
    try {
      final history = await remoteDataSource.getHistory();
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> addWithdrawal({
    required double withdrewAmount,
    required double totalAmount,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
  }) async {
    try {
      final saved = await remoteDataSource.addWithdrawal(
        withdrewAmount: withdrewAmount,
        totalAmount: totalAmount,
        bankName: bankName,
        accountHolder: accountHolder,
        accountNumber: accountNumber,
      );
      return Right(saved);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
