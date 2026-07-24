import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;
  const LoginRequested({required this.phoneNumber, required this.password});
  @override
  List<Object> get props => [phoneNumber, password];
}

class RegisterRequested extends AuthEvent {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String nic;
  final String password;

  const RegisterRequested({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.nic,
    required this.password,
  });

  @override
  List<Object> get props => [fullName, phoneNumber, email, nic, password];
}