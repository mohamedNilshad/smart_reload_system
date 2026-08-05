import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';

abstract class ProfileRepo {
  Future<Either<Failure, void>> updateProfile({required bool isEmailChanged, required String fullName, required String phoneNumber, required String email, required String nic});
  Future<Either<Failure, void>> updatePassword({required String password});
}
