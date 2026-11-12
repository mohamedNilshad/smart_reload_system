import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_activated_packages.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/get_packages.usecase.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/request_package.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/home/domain/usecase/activate_package_request.usecase.dart';
import 'package.event.dart';
import 'package.state.dart';

class PackageBloc extends Bloc<PackageEvent, PackageState> {
  final RequestPackageUseCase requestPackageUseCase;
  final GetPackagesUseCase getPackageUseCase;
  final GetActivatedPackagesUseCase getActivatedPackagesUseCase;
  final ActivatePackageRequestUseCase? activatePackageRequestUseCase;
  final CancelPackageRequestUseCase? cancelPackageRequestUseCase;

  PackageBloc({
    required this.requestPackageUseCase,
    required this.getPackageUseCase,
    required this.getActivatedPackagesUseCase,
    this.activatePackageRequestUseCase,
    this.cancelPackageRequestUseCase,
  }) : super(const PackageRequestInitial()) {
    on<PackageRequest>(_onPackageRequest);
    on<ActivatePackageRequest>(_onActivatePackageRequest);
    on<CancelPackageRequest>(_onCancelPackageRequest);
    on<FetchPackages>(_onFetchPackage);
    on<FetchActivatedPackages>(_onFetchActivatedPackage);
  }

  Future<void> _onPackageRequest(PackageRequest event, Emitter<PackageState> emit) async {
    emit(const PackageLoading(requesting: true));

    final result = await requestPackageUseCase(packageRequestModel: event.packageRequestModel, clientName: event.userName);

    result.fold(
      (failure) => emit(PackageFailure(failure.message)),
      (requestStatus) => emit(PackageSuccess(isRequested: requestStatus)),
    );
  }

  Future<void> _onActivatePackageRequest(ActivatePackageRequest event, Emitter<PackageState> emit) async {
    if (activatePackageRequestUseCase == null) {
      emit(const PackageFailure('Activate package is not configured'));
      return;
    }

    emit(const PackageLoading(activating: true));

    final result = await activatePackageRequestUseCase!(event.packageRequestModel, event.clientId);

    result.fold(
      (failure) => emit(PackageFailure(failure.message)),
      (success) => emit(PackageSuccess(isActivated: success)),
    );
  }

  Future<void> _onCancelPackageRequest(CancelPackageRequest event, Emitter<PackageState> emit) async {
    if (cancelPackageRequestUseCase == null) {
      emit(const PackageFailure('Cancel package is not configured'));
      return;
    }

    emit(const PackageLoading(canceling: true));

    final result = await cancelPackageRequestUseCase!(event.packageRequestModel);

    result.fold(
      (failure) => emit(PackageFailure(failure.message)),
      (success) => emit(PackageSuccess(isCanceled: success)),
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
