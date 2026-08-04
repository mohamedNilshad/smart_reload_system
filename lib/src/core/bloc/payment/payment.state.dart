import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}
class PaymentProcessing extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String paymentId;
  const PaymentSuccess(this.paymentId);
  @override
  List<Object?> get props => [paymentId];
}

class PaymentFailureState extends PaymentState {
  final String message;
  const PaymentFailureState(this.message);
  @override
  List<Object?> get props => [message];
}