import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/payment/data/datasource/payment.client.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/entity/payment.entity.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/repository/payment.client.repo.dart';

class PaymentClientRepoImpl implements PaymentClientRepo {
  final PaymentClientRemoteDataSource remoteDataSource;

  PaymentClientRepoImpl({required this.remoteDataSource});

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

  @override
  Future<Either<Failure, List<PackageRequestModel>>> fetchPayables({required String clientVendorId}) async {
    try {
      final result = await remoteDataSource.fetchPayables(clientVendorId: clientVendorId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
