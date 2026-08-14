import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment.entity.g.dart';

@JsonSerializable()
class PaymentEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory PaymentEntity.fromJson(Map<String, dynamic> json) =>
      _$PaymentEntityFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentEntityToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        currency,
        status,
        paymentMethod,
        description,
        createdAt,
        updatedAt,
      ];
}
