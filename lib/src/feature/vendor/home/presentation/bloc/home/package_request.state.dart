
abstract class PackageRequestState {}

class PackageRequestInitial extends PackageRequestState {}

class PackageRequestLoading extends PackageRequestState {}

class PackageRequestLoaded extends PackageRequestState {
  final Map<String, dynamic> requests;

  PackageRequestLoaded(this.requests);
}

class PackageRequestFailure extends PackageRequestState {
  final String message;

  PackageRequestFailure(this.message);
}