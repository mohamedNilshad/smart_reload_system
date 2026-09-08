import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';

abstract class PaymentClientState extends Equatable {
  const PaymentClientState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentClientState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentClientState {
  final bool isFetching;
  const PaymentLoading({this.isFetching =false});
}

class PayableSuccess extends PaymentClientState {
  final List<PackageRequestModel> payableList;

  const PayableSuccess(this.payableList);

  @override
  List<Object?> get props => [payableList];
}

class PaymentFailure extends PaymentClientState {
  final String message;

  const PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}
