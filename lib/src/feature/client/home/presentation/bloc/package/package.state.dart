import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package.model.dart';

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
  final bool fetching;
  const PackageLoading({this.fetching = false, this.requesting = false});
}

class PackageSuccess extends PackageState {
  final bool? isRequested;
  final List<PackageModel>? packages;

  const PackageSuccess({this.isRequested, this.packages});

  @override
  List<Object?> get props => [isRequested];
}

class PackageFailure extends PackageState {
  final String message;
  const PackageFailure(this.message);

  @override
  List<Object?> get props => [message];
}
