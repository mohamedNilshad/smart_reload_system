import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object> get props => [];
}

class StartPaymentRequested extends PaymentEvent {
  final String orderId;
  final double amount;
  final String itemDescription;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;

  const StartPaymentRequested({
    required this.orderId,
    required this.amount,
    required this.itemDescription,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
  });

  @override
  List<Object> get props =>
      [orderId, amount, itemDescription, firstName, lastName, email, phone, address, city];
}