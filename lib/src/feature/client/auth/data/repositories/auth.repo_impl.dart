import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/auth/data/datasource/auth.local_datasource.dart';
import 'package:smart_reload_system/src/feature/client/auth/data/datasource/auth.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/entity/client.entity.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/repository/auth.repo.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepoImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, UserEntity>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(phoneNumber: phoneNumber, password: password);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String nic,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.register(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        nic: nic,
        password: password,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> reauthenticate(String password) async {
    try {
      await remoteDataSource.reauthenticate(password);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCachedUser();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((user) {
      // Keep the cache in sync with whatever Firebase confirms.
      if (user != null) {
        localDataSource.cacheUser(user);
      } else {
        localDataSource.clearCachedUser();
      }
      return user;
    });
  }

  @override
  Future<UserEntity?> getCachedUser() => localDataSource.getCachedUser();
}