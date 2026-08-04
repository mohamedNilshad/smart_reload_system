import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';

abstract class PaymentRepo {
  Future<Either<Failure, String>> startOneTimePayment({
    required String orderId,
    required double amount,
    required String itemDescription,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String city,
  });
}