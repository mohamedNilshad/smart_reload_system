import 'package:equatable/equatable.dart';

abstract class PackageRequestState extends Equatable {
  const PackageRequestState();

  @override
  List<Object?> get props => [];
}

class PackageRequestInitial extends PackageRequestState {
  const PackageRequestInitial();
}


class PackageRequestLoading extends PackageRequestState {
  const PackageRequestLoading();
}

class PackageRequestSuccess extends PackageRequestState {
  final bool isRequested;
  const PackageRequestSuccess(this.isRequested);

  @override
  List<Object?> get props => [isRequested];
}

class PackageRequestFailure extends PackageRequestState {
  final String message;
  const PackageRequestFailure(this.message);

  @override
  List<Object?> get props => [message];
}
