import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/usecase/get_payable_details.usecase.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.event.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.state.dart';

class PaymentClientBloc extends Bloc<PaymentClientEvent, PaymentClientState> {

  final GetPayableDetailsUseCase getPayableDetailsUseCase;

  PaymentClientBloc({required this.getPayableDetailsUseCase})
      : super(const PaymentInitial()) {
    on<PaymentReset>(_onPaymentReset);
    on<FetchPayableDetails>(_onFetchPayableDetails);
  }


  Future<void> _onFetchPayableDetails(FetchPayableDetails event, Emitter<PaymentClientState> emit) async {
    emit(const PaymentLoading(isFetching: true));

    final result = await getPayableDetailsUseCase(event.clientVendorId);

    result.fold(
          (failure) => emit(PaymentFailure(failure.message)),
          (list) => emit(PayableSuccess(list)),
    );
  }

  Future<void> _onPaymentReset(
    PaymentReset event,
    Emitter<PaymentClientState> emit,
  ) async {
    emit(const PaymentInitial());
  }
}
