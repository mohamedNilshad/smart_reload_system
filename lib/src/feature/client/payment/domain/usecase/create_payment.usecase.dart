import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/entity/payment.entity.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/repository/payment.client.repo.dart';

class CreatePaymentUseCase {
  final PaymentClientRepo repo;

  CreatePaymentUseCase(this.repo);

  Future<Either<Failure, PaymentEntity>> call({
    required double amount,
    required String currency,
    required String paymentMethod,
    required String description,
  }) {
    return repo.createPayment(
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      description: description,
    );
  }
}
