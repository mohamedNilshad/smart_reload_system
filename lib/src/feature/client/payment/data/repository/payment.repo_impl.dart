import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/payment/data/datasource/payment.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/entity/payment.entity.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/repository/payment.repo.dart';

class PaymentRepoImpl implements PaymentRepo {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaymentEntity>> createPayment({
    required double amount,
    required String currency,
    required String paymentMethod,
    required String description,
  }) async {
    try {
      final payment = await remoteDataSource.createPayment(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        description: description,
      );
      return Right(payment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
