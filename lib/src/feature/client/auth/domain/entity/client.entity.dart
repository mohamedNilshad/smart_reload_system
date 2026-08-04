import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client.entity.g.dart';

@JsonSerializable()
class UserEntity extends Equatable {
  final String uid;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String nic;
  final String role; // 'client' | 'vendor' — defaults to client for now
  final String? token;

  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.nic,
    this.role = 'client',
    this.token,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  @override
  List<Object?> get props => [uid, fullName, phoneNumber, email, nic, role, token];
}