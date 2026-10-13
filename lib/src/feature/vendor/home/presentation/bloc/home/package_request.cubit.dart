import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/home/domain/usecase/watch_package_requests.usecase.dart';

import 'package_request.state.dart';

class PackageRequestCubit extends Cubit<PackageRequestState> {
  final WatchPackageRequestsUseCase watchPackageRequestsUseCase;

  StreamSubscription<Map<String, dynamic>>? _subscription;

  PackageRequestCubit({required this.watchPackageRequestsUseCase}) : super(PackageRequestInitial());

  Future<void> listenToPackageRequests(String vendorId) async {
    await _subscription?.cancel();
    _subscription = null;

    if (isClosed) return;

    emit(PackageRequestLoading());

    _subscription = watchPackageRequestsUseCase(vendorId).listen(
          (data) {
        if (isClosed) return;

        emit(PackageRequestLoaded(data));
      },
      onError: (error) {
        if (isClosed) return;

        emit(PackageRequestFailure(error.toString()));
      },
    );
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<void> close() async {
    await stopListening();
    return super.close();
  }
}