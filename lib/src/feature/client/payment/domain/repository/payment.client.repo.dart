import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/entity/payment.entity.dart';

abstract class PaymentClientRepo {
  Future<Either<Failure, PaymentEntity>> createPayment({
    required double amount,
    required String currency,
    required String paymentMethod,
    required String description,
  });

  Future<Either<Failure, List<PackageRequestModel>>> fetchPayables({required String clientVendorId});
}
