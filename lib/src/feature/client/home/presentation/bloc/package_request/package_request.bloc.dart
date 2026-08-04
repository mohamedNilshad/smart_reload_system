import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/home/domain/usecase/request_package.usecase.dart';
import 'package_request.event.dart';
import 'package_request.state.dart';


class PackageRequestBloc extends Bloc<PackageRequestEvent, PackageRequestState> {
  final RequestPackageUseCase requestPackageUseCase;

  PackageRequestBloc({required this.requestPackageUseCase}) : super(const PackageRequestInitial()) {
    on<PackageRequest>(_onPackageRequest);
  }


  Future<void> _onPackageRequest(PackageRequest event, Emitter<PackageRequestState> emit) async {
    emit(const PackageRequestLoading());

    final result = await requestPackageUseCase(packageRequestModel : event.packageRequestModel);

    result.fold(
      (failure) => emit(PackageRequestFailure(failure.message)),
      (requestStatus) => emit(PackageRequestSuccess(requestStatus)),
    );
  }
}
