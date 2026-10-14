import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_activated_packages.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_packages.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/request_package.usecase.dart';
import 'package.event.dart';
import 'package.state.dart';


class PackageBloc extends Bloc<PackageEvent, PackageState> {
  final RequestPackageUseCase requestPackageUseCase;
  final GetPackagesUseCase getPackageUseCase;
  final GetActivatedPackagesUseCase getActivatedPackagesUseCase;

  PackageBloc({
    required this.requestPackageUseCase,
    required this.getPackageUseCase,
    required this.getActivatedPackagesUseCase,
  }) : super(const PackageRequestInitial()) {
    on<PackageRequest>(_onPackageRequest);
    on<FetchPackages>(_onFetchPackage);
    on<FetchActivatedPackages>(_onFetchActivatedPackage);
  }


  Future<void> _onPackageRequest(PackageRequest event, Emitter<PackageState> emit) async {
    emit(const PackageLoading(requesting: true));

    final result = await requestPackageUseCase(packageRequestModel : event.packageRequestModel, clientName: event.userName);

    result.fold(
      (failure) => emit(PackageFailure(failure.message)),
      (requestStatus) => emit(PackageSuccess(isRequested: requestStatus)),
    );
  }

  Future<void> _onFetchPackage(FetchPackages event, Emitter<PackageState> emit) async {
    emit(const PackageLoading(fetching: true));

    final result = await getPackageUseCase(Params(type: event.type, serviceProvider: event.serviceProvider));

    result.fold(
      (failure) => emit(PackageFailure(failure.message)),
      (list) => emit(PackageSuccess(packages: list)),
    );
  }

  Future<void> _onFetchActivatedPackage(FetchActivatedPackages event, Emitter<PackageState> emit) async {
    emit(const PackageLoading(fetchingActPackage: true));

    final result = await getActivatedPackagesUseCase(event.connectionId);

    result.fold(
      (failure) => emit(PackageFailure(failure.message)),
      (list) => emit(PackageSuccess(actPackages: list)),
    );
  }
}
