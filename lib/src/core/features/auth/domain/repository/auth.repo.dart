import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/domain/entity/user.entity.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserEntity>> login({
    required String phoneNumber,
    required String password,
    required String role,
  });

  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String nic,
    required String password,
  });

  Future<Either<Failure, bool>> forgotPassword(String email);

  Future<Either<Failure, void>> reauthenticate(String password);

  Future<Either<Failure, void>> logout();

  Stream<UserEntity?> get authStateChanges;

  Stream<UserEntity?> watchUser(String uid);

  Future<void> updateUser(String uid, Map<String, dynamic> data);

  Future<UserEntity?> getCachedUser();

  Future<void> updateCachedUser(UserEntity user);

  Future<void> clearCachedUser();
}