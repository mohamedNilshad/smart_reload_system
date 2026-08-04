import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/domain/repositories/payment.repo.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';


class StartPaymentUseCase {
  final PaymentRepo repo;
  StartPaymentUseCase(this.repo);

  Future<Either<Failure, String>> call({
    required String orderId,
    required double amount,
    required String itemDescription,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String city,
  }) {
    return repo.startOneTimePayment(
      orderId: orderId,
      amount: amount,
      itemDescription: itemDescription,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      city: city,
    );
  }
}