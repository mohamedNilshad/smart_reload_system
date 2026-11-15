import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/repository/wallet.repo.dart';

class GetWalletSummaryUseCase {
  final WalletRepo repo;

  GetWalletSummaryUseCase(this.repo);

  Future<Either<Failure, double>> call() {
    return repo.getWalletSummary();
  }
}
