import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/entity/payment.entity.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentSuccess extends PaymentState {
  final PaymentEntity payment;

  const PaymentSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentFailure extends PaymentState {
  final String message;

  const PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}
