import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';

abstract class PackageState extends Equatable {
  const PackageState();

  @override
  List<Object?> get props => [];
}

class PackageRequestInitial extends PackageState {
  const PackageRequestInitial();
}


class PackageLoading extends PackageState {
  final bool requesting;
  final bool activating;
  final bool canceling;
  final bool fetching;
  final bool fetchingActPackage;
  const PackageLoading({this.fetching = false, this.requesting = false, this.activating = false, this.canceling = false, this.fetchingActPackage = false});
}

class PackageSuccess extends PackageState {
  final bool? isRequested;
  final bool? isActivated;
  final bool? isCanceled;
  final List<PackageModel>? packages;
  final List<PackageRequestModel>? actPackages;

  const PackageSuccess({this.isRequested, this.isActivated, this.isCanceled, this.packages, this.actPackages});

  @override
  List<Object?> get props => [isRequested];
}

class PackageFailure extends PackageState {
  final String message;
  const PackageFailure(this.message);

  @override
  List<Object?> get props => [message];
}
