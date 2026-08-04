import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';

abstract class PackageRequestEvent extends Equatable {
  const PackageRequestEvent();

  @override
  List<Object?> get props => [];
}

class PackageRequest extends PackageRequestEvent {
  final PackageRequestModel packageRequestModel;
  const PackageRequest(this.packageRequestModel);

  @override
  List<Object?> get props => [packageRequestModel];
}