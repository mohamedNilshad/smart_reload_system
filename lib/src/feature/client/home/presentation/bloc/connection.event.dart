import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object?> get props => [];
}

class ConnectionsRequested extends ConnectionEvent {
  final String clientVendorId;
  const ConnectionsRequested(this.clientVendorId);

  @override
  List<Object?> get props => [clientVendorId];
}

class PackageRequest extends ConnectionEvent {
  final PackageRequestModel packageRequestModel;
  const PackageRequest(this.packageRequestModel);

  @override
  List<Object?> get props => [packageRequestModel];
}

class ConnectionsReset extends ConnectionEvent {
  const ConnectionsReset();
}
