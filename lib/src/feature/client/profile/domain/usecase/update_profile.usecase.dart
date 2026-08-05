import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/feature/client/profile/domain/repository/profile.repo.dart';

class UpdateProfileUseCase {
  final ProfileRepo repo;
  UpdateProfileUseCase(this.repo);

  Future<Either<Failure, void>> call({required bool isEmailChanged, required String fullName, required String phoneNumber, required String email, required String nic}){
    return repo.updateProfile(isEmailChanged: isEmailChanged, fullName: fullName, phoneNumber: phoneNumber, email: email, nic: nic);
  }
}
