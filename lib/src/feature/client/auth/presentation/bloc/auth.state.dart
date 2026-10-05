import 'package:equatable/equatable.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/entity/client.entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {
  final bool isClient;
  final bool isVendor;
  const AuthLoading({this.isClient = false, this.isVendor = false});
}

class AuthSuccess extends AuthState {
  final UserEntity user;
  final bool isClient;
  const AuthSuccess(this.user, this.isClient);
  @override
  List<Object> get props => [user, isClient];
}

class AuthLogoutSuccess extends AuthState {}

class ReauthenticationSuccess extends AuthState {}

class AuthVerifyEmailSuccess extends AuthState {
  final bool value;
  const AuthVerifyEmailSuccess(this.value);

  @override
  List<Object> get props => [value];
}

class AuthFailureState extends AuthState {
 final String message;
 const AuthFailureState(this.message);
 @override
 List<Object> get props => [message];
}