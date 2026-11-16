import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/entity/commission_withdrew_history.entity.dart';

abstract class WalletRepo {
  Future<Either<Failure, double>> getWalletSummary();
  Future<Either<Failure, List<ComWithdrawHistoryEntity>>> getHistory();
  Future<Either<Failure, bool>> addWithdrawal({required double withdrewAmount, required double totalAmount, required String bankId});
}
