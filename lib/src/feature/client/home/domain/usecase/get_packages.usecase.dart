import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/core/usecase/usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/repository/home.repo.dart';

class GetPackagesUseCase implements UseCase<List<PackageModel>, Params> {
  final HomeRepo repository;

  GetPackagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<PackageModel>>> call(Params params) {
    return repository.getPackages(params.type, params.serviceProvider);
  }
}

class Params extends Equatable {
  final String type;
  final String serviceProvider;

  const Params({required this.type, required this.serviceProvider});

  @override
  List<Object> get props => [type, serviceProvider];
}
