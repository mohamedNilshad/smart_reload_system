import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/entity/wallet_summary.entity.dart';

abstract class WalletRepo {
  Future<Either<Failure, WalletSummaryEntity>> getWalletSummary();
}
