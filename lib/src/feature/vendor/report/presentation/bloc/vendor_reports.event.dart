import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/vendor/report/domain/entity/report_period.entity.dart';

abstract class VendorReportsEvent extends Equatable {
  const VendorReportsEvent();

  @override
  List<Object?> get props => [];
}

class VendorReportsRequested extends VendorReportsEvent {
  final String vendorId;
  final ReportPeriodEntity period;

  const VendorReportsRequested({required this.vendorId, required this.period});

  @override
  List<Object?> get props => [vendorId, period];
}

/// Clears state left over from an earlier visit (the bloc is an app-level
/// singleton).
class VendorReportsReset extends VendorReportsEvent {
  const VendorReportsReset();
}
