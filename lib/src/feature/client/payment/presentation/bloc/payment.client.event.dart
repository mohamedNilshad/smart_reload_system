import 'package:equatable/equatable.dart';

abstract class PaymentClientEvent extends Equatable {
  const PaymentClientEvent();

  @override
  List<Object?> get props => [];
}

class FetchPayableDetails extends PaymentClientEvent {
  final String clientVendorId;
  const FetchPayableDetails({required this.clientVendorId});

  @override
  List<Object?> get props => [clientVendorId];
}

class PaymentReset extends PaymentClientEvent {
  const PaymentReset();
}
