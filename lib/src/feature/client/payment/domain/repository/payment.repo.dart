import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/entity/payment.entity.dart';

abstract class PaymentRepo {
  Future<Either<Failure, PaymentEntity>> createPayment({
    required double amount,
    required String currency,
    required String paymentMethod,
    required String description,
  });
}
