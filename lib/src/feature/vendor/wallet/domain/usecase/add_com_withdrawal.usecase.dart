import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/vendor/wallet/domain/repository/wallet.repo.dart';

class AddComWithdrawalUseCase {
  final WalletRepo repo;

  AddComWithdrawalUseCase(this.repo);

  Future<Either<Failure, bool>> call({
    required double withdrewAmount,
    required double totalAmount,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
  }) {
    return repo.addWithdrawal(
      withdrewAmount: withdrewAmount,
      totalAmount: totalAmount,
      bankName: bankName,
      accountHolder: accountHolder,
      accountNumber: accountNumber,
    );
  }
}
