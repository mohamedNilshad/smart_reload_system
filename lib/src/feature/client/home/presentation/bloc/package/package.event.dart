import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';

abstract class PackageEvent extends Equatable {
  const PackageEvent();

  @override
  List<Object?> get props => [];
}

class PackageRequest extends PackageEvent {
  final PackageRequestModel packageRequestModel;
  const PackageRequest(this.packageRequestModel);

  @override
  List<Object?> get props => [packageRequestModel];
}

class FetchPackages extends PackageEvent {
  final String type;
  final String serviceProvider;
  const FetchPackages({required this.type, required this.serviceProvider});

  @override
  List<Object?> get props => [type, serviceProvider];
}