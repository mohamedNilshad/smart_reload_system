// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentEntity _$PaymentEntityFromJson(Map<String, dynamic> json) =>
    PaymentEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentEntityToJson(PaymentEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'paymentMethod': instance.paymentMethod,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
