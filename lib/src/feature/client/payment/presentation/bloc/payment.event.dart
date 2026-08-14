import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CreatePaymentRequested extends PaymentEvent {
  final double amount;
  final String currency;
  final String paymentMethod;
  final String description;

  const CreatePaymentRequested({
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.description,
  });

  @override
  List<Object?> get props => [amount, currency, paymentMethod, description];
}

class PaymentReset extends PaymentEvent {
  const PaymentReset();
}
