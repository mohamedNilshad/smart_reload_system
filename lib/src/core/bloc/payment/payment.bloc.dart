import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.event.dart';
import 'package:smart_reload_system/src/core/bloc/payment/payment.state.dart';
import 'package:smart_reload_system/src/core/domain/usecases/start_payment.usecase.dart';


class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final StartPaymentUseCase startPaymentUseCase;

  PaymentBloc({required this.startPaymentUseCase}) : super(PaymentInitial()) {
    on<StartPaymentRequested>(_onStartPayment);
  }

  Future<void> _onStartPayment(StartPaymentRequested event, Emitter<PaymentState> emit) async {
    emit(PaymentProcessing());
    final result = await startPaymentUseCase(
      orderId: event.orderId,
      amount: event.amount,
      itemDescription: event.itemDescription,
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phone: event.phone,
      address: event.address,
      city: event.city,
    );
    result.fold(
          (failure) => emit(PaymentFailureState(failure.message)),
          (paymentRef) => emit(PaymentSuccess(paymentRef['paymentId'], DateTime.parse(paymentRef['paymentDate']))),
    );
  }
}