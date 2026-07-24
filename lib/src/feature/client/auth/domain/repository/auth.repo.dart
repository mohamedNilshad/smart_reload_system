import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/entity/client.entity.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserEntity>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String nic,
    required String password,
  });

  Future<Either<Failure, void>> logout();
}