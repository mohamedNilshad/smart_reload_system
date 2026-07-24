import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/login.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/domain/usecase/register.usecase.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.event.dart';
import 'package:smart_reload_system/src/feature/client/auth/presentation/bloc/auth.state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({required this.loginUseCase, required this.registerUseCase}) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(phoneNumber: event.phoneNumber, password: event.password);
    result.fold(
          (failure) => emit(AuthFailureState(failure.message)),
          (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUseCase(
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
      email: event.email,
      nic: event.nic,
      password: event.password,
    );
    result.fold(
          (failure) => emit(AuthFailureState(failure.message)),
          (user) => emit(AuthSuccess(user)),
    );
  }
}