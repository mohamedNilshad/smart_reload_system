import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/data/datasource/payment.remote_datasource.dart';
import 'package:smart_reload_system/src/core/domain/repositories/payment.repo.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';

class PaymentRepoImpl implements PaymentRepo {
  final PaymentRemoteDataSource remoteDataSource;
  PaymentRepoImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Map<String, dynamic>>> startOneTimePayment({
    required String orderId,
    required double amount,
    required String itemDescription,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String city,
  }) async {
    try {
      final result = await remoteDataSource.startOneTimePayment(
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
      return Right(result);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message)); // or a dedicated PaymentFailure — see note below
    }
  }
}