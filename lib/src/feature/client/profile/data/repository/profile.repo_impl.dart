import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/exceptions.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/profile/data/datasource/profile.remote_datasource.dart';
import 'package:smart_reload_system/src/feature/client/profile/domain/repository/profile.repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> updateProfile({required bool isEmailChanged, required String fullName, required String phoneNumber, required String email, required String nic}) async {
    try {
      await remoteDataSource.updateProfile(isEmailChanged: isEmailChanged, fullName: fullName, phoneNumber: phoneNumber, email: email, nic: nic);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({required String password}) async {
    try {
      await remoteDataSource.updatePassword(password: password);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
