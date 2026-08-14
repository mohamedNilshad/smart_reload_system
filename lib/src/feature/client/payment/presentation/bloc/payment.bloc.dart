import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/usecase/create_payment.usecase.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.event.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreatePaymentUseCase createPaymentUseCase;

  PaymentBloc({required this.createPaymentUseCase})
      : super(const PaymentInitial()) {
    on<CreatePaymentRequested>(_onCreatePaymentRequested);
    on<PaymentReset>(_onPaymentReset);
  }

  Future<void> _onCreatePaymentRequested(
    CreatePaymentRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    final result = await createPaymentUseCase(
      amount: event.amount,
      currency: event.currency,
      paymentMethod: event.paymentMethod,
      description: event.description,
    );
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (payment) => emit(PaymentSuccess(payment)),
    );
  }

  Future<void> _onPaymentReset(
    PaymentReset event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentInitial());
  }
}
