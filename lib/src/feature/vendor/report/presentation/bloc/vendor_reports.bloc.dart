import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/usecase/get_vendor_report.usecase.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/bloc/vendor_reports.event.dart';
import 'package:smart_reload_system/src/feature/vendor/report/presentation/bloc/vendor_reports.state.dart';

class VendorReportsBloc extends Bloc<VendorReportsEvent, VendorReportsState> {
  final GetVendorReportUseCase getVendorReportUseCase;

  /// Lets a newer request win when the user switches period quickly.
  int _requestId = 0;

  VendorReportsBloc({required this.getVendorReportUseCase})
      : super(const VendorReportsInitial()) {
    on<VendorReportsRequested>(_onRequested);
    on<VendorReportsReset>((_, emit) {
      _requestId++;
      emit(const VendorReportsInitial());
    });
  }

  Future<void> _onRequested(
    VendorReportsRequested event,
    Emitter<VendorReportsState> emit,
  ) async {
    final id = ++_requestId;
    emit(const VendorReportsLoading());

    final result = await getVendorReportUseCase(
      vendorId: event.vendorId,
      period: event.period,
    );

    if (id != _requestId) return; // superseded by a newer request
    result.fold(
      (failure) => emit(VendorReportsFailureState(failure.message)),
      (summary) => emit(VendorReportsSuccess(summary)),
    );
  }
}
