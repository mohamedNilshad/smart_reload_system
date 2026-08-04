// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
  uid: json['uid'] as String,
  fullName: json['fullName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  email: json['email'] as String,
  nic: json['nic'] as String,
  role: json['role'] as String? ?? 'client',
  token: json['token'] as String?,
);

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'nic': instance.nic,
      'role': instance.role,
      'token': instance.token,
    };
