import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/home/data/model/package_request.model.dart';
import 'package:smart_reload_system/src/feature/client/payment/data/model/paid_invoice_data.model.dart';

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
  final bool isCreating;
  final bool isFetchingPaidInvoices;
  const PaymentLoading({this.isFetching =false, this.isCreating =false, this.isFetchingPaidInvoices =false});
}

class PayableSuccess extends PaymentClientState {
  final List<PackageRequestModel> payableList;
  final String serviceCharge;

  const PayableSuccess({required this.payableList, required this.serviceCharge});

  @override
  List<Object?> get props => [payableList, serviceCharge];
}

class PaymentClientSuccess extends PaymentClientState {
  final bool isPaymentCreated;

  const PaymentClientSuccess(this.isPaymentCreated);

  @override
  List<Object?> get props => [isPaymentCreated];
}

class PaidInvoicesSuccess extends PaymentClientState {
  final List<PaidInvoiceDataModel> paidInvoices;

  const PaidInvoicesSuccess({required this.paidInvoices});

  @override
  List<Object?> get props => [paidInvoices];
}

class PaymentFailure extends PaymentClientState {
  final String message;

  const PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}
