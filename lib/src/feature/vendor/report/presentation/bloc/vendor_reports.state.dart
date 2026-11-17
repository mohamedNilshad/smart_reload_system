import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_summary.entity.dart';

abstract class VendorReportsState extends Equatable {
  const VendorReportsState();

  @override
  List<Object?> get props => [];
}

class VendorReportsInitial extends VendorReportsState {
  const VendorReportsInitial();
}

class VendorReportsLoading extends VendorReportsState {
  const VendorReportsLoading();
}

class VendorReportsSuccess extends VendorReportsState {
  final ReportSummaryEntity summary;

  const VendorReportsSuccess(this.summary);

  @override
  List<Object?> get props => [summary];
}

class VendorReportsFailureState extends VendorReportsState {
  final String message;

  const VendorReportsFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
