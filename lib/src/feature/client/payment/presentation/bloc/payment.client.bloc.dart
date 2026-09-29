import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/usecase/create_payment.usecase.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/usecase/get_paid_invoices.usecase.dart';
import 'package:smart_reload_system/src/feature/client/payment/domain/usecase/get_payable_details.usecase.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.event.dart';
import 'package:smart_reload_system/src/feature/client/payment/presentation/bloc/payment.client.state.dart';

class PaymentClientBloc extends Bloc<PaymentClientEvent, PaymentClientState> {

  final GetPayableDetailsUseCase getPayableDetailsUseCase;
  final GetPaidInvoicesUsecase getPaidInvoicesUseCase;
  final CreatePaymentUseCase createPaymentUseCase;

  PaymentClientBloc({
    required this.getPayableDetailsUseCase,
    required this.getPaidInvoicesUseCase,
    required this.createPaymentUseCase,
  }) : super(const PaymentInitial()) {
    on<PaymentReset>(_onPaymentReset);
    on<FetchPayableDetails>(_onFetchPayableDetails);
    on<FetchPaidInvoices>(_onFetchPaidInvoices);
    on<CreatePayment>(_onCreatePayment);
  }


  Future<void> _onFetchPayableDetails(FetchPayableDetails event, Emitter<PaymentClientState> emit) async {
    emit(const PaymentLoading(isFetching: true));

    final result = await getPayableDetailsUseCase(event.clientVendorId);

    result.fold(
          (failure) => emit(PaymentFailure(failure.message)),
          (result) => emit(PayableSuccess(payableList: result["packages"], serviceCharge: result["serviceCharge"])),
    );
  }

  Future<void> _onFetchPaidInvoices(FetchPaidInvoices event, Emitter<PaymentClientState> emit) async {
    emit(const PaymentLoading(isFetchingPaidInvoices: true));

    final result = await getPaidInvoicesUseCase(event.clientVendorId);

    result.fold(
          (failure) => emit(PaymentFailure(failure.message)),
          (result) => emit(PaidInvoicesSuccess(paidInvoices: result)),
    );
  }

  Future<void> _onPaymentReset(PaymentReset event, Emitter<PaymentClientState> emit) async {
    emit(const PaymentInitial());
  }

  Future<void> _onCreatePayment(CreatePayment event, Emitter<PaymentClientState> emit) async {
    emit(const PaymentLoading(isCreating: true));

    final result = await createPaymentUseCase(
      clientVendorId: event.clientVendorId,
      lastPaidAmount: event.lastPaidAmount,
      lastPaidDate: event.lastPaidDate,
      reqPackageIdList: event.reqPackageIdList,
      vendorId: event.vendorId,
      vendorComAmount: event.vendorComAmount,
      paymentRefNumber: event.paymentRefNumber,
      invoiceData: event.invoiceData,
    );

    result.fold(
          (failure) => emit(PaymentFailure(failure.message)),
          (isPaymentCreated) => emit(PaymentClientSuccess(isPaymentCreated)),
    );
  }
}
