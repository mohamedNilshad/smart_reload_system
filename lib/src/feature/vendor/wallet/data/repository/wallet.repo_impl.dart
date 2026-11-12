import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/data/datasource/wallet.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/entity/wallet_summary.entity.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/repository/wallet.repo.dart';

class WalletRepoImpl implements WalletRepo {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WalletSummaryEntity>> getWalletSummary() async {
    try {
      final summary = await remoteDataSource.getWalletSummary();
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
